import {Schema, Descriptor as D, Fx} from '../../../.references/bevy-ts/packages/core/src/index.ts';

// Complete shared observations only. Private runtime bookkeeping is qualified
// by the ordinary scope capsules, outside this matched measurement interval.
export function run(lifecycles) {
  const output=[];
  const sorted=edges=>edges.sort((a,b)=>a[0]-b[0]||a[1]-b[1]);
  for(let repeat=0;repeat<lifecycles;repeat++) {
    for(const schema of ['ScopeTimingAlpha','ScopeTimingBeta']) {
      const Payload=D.Component()('Payload');
      const {relation:Parent}=D.Hierarchy('Parent','Children');
      const {relation:Link}=D.Relation('Link','Incoming');
      const G=Schema.bind(Schema.fragment({components:{Payload},relations:{Parent,Link}}),Schema.defineRoot(schema));
      let runtime=G.Runtime.make({services:G.Runtime.services()});
      const scene=G.EntityScope('scene');
      const same=G.EntityScope('scene');
      const ids=[];
      let phase;
      let status='ok';
      let scenario='linked-failure';
      const tick=(...steps)=>{
        const result=runtime.tick(G.Schedule(...steps));
        if(!result.ok)throw Error('unexpected scope failure');
      };
      const flush=G.Schedule.applyDeferred();
      const observer=G.System('scope/matched-observer',{
        queries:{all:G.Query({selection:{payload:G.Query.read(Payload)}})},
        removed:{payload:G.System.readRemoved(Payload)},
        despawned:{all:G.System.readDespawned()}
      },({queries,lookup,removed,despawned})=>{
        const rows=queries.all.each().map(row=>({id:row.entity.id.value,payload:[...row.data.payload.get()]})).sort((a,b)=>a.id-b.id);
        const forward=relation=>sorted(ids.flatMap(id=>{
          const seen=lookup.related(id,relation);
          return seen.ok&&seen.value!==null?[[id.value,seen.value.value]]:[];
        }));
        const inverse=relation=>sorted(ids.flatMap(id=>{
          const seen=lookup.relatedSources(id,relation);
          return seen.ok?seen.value.map(source=>[id.value,source.value]):[];
        }));
        output.push({repeat,schema,case:scenario,phase,status,rows,parent:forward(Parent),children:inverse(Parent),link:forward(Link),incoming:inverse(Link),removed:removed.payload.all().map(id=>id.value).sort((a,b)=>a-b),despawned:despawned.all.all().map(id=>id.value).sort((a,b)=>a-b)});
      });
      const observe=name=>{phase=name;tick(observer);};
      tick(G.System('scope/matched-spawn',{},({commands})=>{
        for(let id=1;id<=6;id++) {
          const spawn=G.Command.spawn([Payload,[id,id+10,id+20]]);
          ids.push(id===1?commands.spawnIn(scene,spawn):id===5?commands.spawnIn(same,spawn):commands.spawn(spawn));
        }
        commands.relate(ids[1],Parent,ids[0]);
        commands.relate(ids[3],Parent,ids[1]);
        commands.relate(ids[2],Link,ids[0]);
      }));
      observe('pending-spawn');
      const failure=G.System('scope/matched-failure',{},({commands})=>{commands.despawnScope(scene);return Fx.fail('Rejected');});
      const failed=runtime.tick(G.Schedule(failure));
      if(failed.ok||failed.error.error!=='Rejected')throw Error('missing expected failure');
      status='Rejected';observe('failed-cleanup');status='ok';tick(flush);observe('spawned');
      const cleanup=G.System('scope/matched-cleanup',{},({commands})=>commands.despawnScope(scene));
      tick(cleanup);observe('pending-cleanup');tick(flush);observe('cleaned');
      tick(cleanup,flush);observe('repeated-cleanup');
      // Queue-position controls use fresh worlds, preserving complete payloads.
      runtime=G.Runtime.make({services:G.Runtime.services()});ids.length=0;
      scenario='cleanup-before-spawn';
      tick(G.System('scope/order-before',{},({commands})=>{
        commands.despawnScope(scene);
        ids.push(commands.spawnIn(scene,G.Command.spawn([Payload,[1,11,21]])));
        ids.push(commands.spawn(G.Command.spawn([Payload,[2,12,22]])));
      }));
      observe('pending');tick(flush);observe('spawned');
      tick(cleanup,flush);observe('cleaned');
      runtime=G.Runtime.make({services:G.Runtime.services()});ids.length=0;
      scenario='abort-and-cleanup-after';
      tick(G.System('scope/order-seed',{},({commands})=>{
        ids.push(commands.spawn(G.Command.spawn([Payload,[2,12,22]])));
      }),flush);observe('seeded');
      const abort=G.System('scope/order-abort',{},({commands})=>{
        commands.spawnIn(scene,G.Command.spawn([Payload,[99,109,119]]));
        return Fx.fail('Rejected');
      });
      const aborted=runtime.tick(G.Schedule(abort));
      if(aborted.ok||aborted.error.error!=='Rejected')throw Error('missing expected abort');
      status='Rejected';observe('aborted');status='ok';
      tick(G.System('scope/order-after',{},({commands})=>{
        ids.push(commands.spawnIn(scene,G.Command.spawn([Payload,[3,13,23]])));
        commands.despawnScope(scene);
      }));
      observe('pending');tick(flush);observe('cleaned');

    }
  }
  return JSON.stringify(output);
}
