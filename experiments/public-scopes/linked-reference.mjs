import assert from 'node:assert/strict';
import {Schema, Descriptor as D} from '../../.references/bevy-ts/packages/core/src/index.ts';

// Unscoped membership does not override a hierarchy's linked-despawn contract.
const observations=[];
for (const root of ['ScopeLinkedAlpha','ScopeLinkedBeta']) {
  const Payload=D.Component()('Payload');
  const {relation:Parent}=D.Hierarchy('Parent','Children');
  const {relation:Link}=D.Relation('Link','Incoming');
  const G=Schema.bind(Schema.fragment({components:{Payload},relations:{Parent,Link}}),Schema.defineRoot(root));
  const runtime=G.Runtime.make({});
  const scene=G.EntityScope('scene');
  const ids=[];
  let phase;
  const flush=G.Schedule.applyDeferred();
  const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
  const observer=G.System('scope/linked-observer',{
    queries:{all:G.Query({selection:{payload:G.Query.read(Payload)}})},
    removed:{payload:G.System.readRemoved(Payload)},
    despawned:{all:G.System.readDespawned()}
  },({queries,lookup,removed,despawned})=>{
    const link=ids.length===4?lookup.related(ids[2],Link):undefined;
    observations.push({root,phase,
      rows:queries.all.each().map(row=>({id:row.entity.id.value,payload:structuredClone(row.data.payload.get())})),
      link:link===undefined?null:link.ok?{ok:true,value:link.value.value}:{ok:false,error:link.error},
      removed:removed.payload.all().map(id=>id.value),
      despawned:despawned.all.all().map(id=>id.value)});
  });
  const observe=label=>{phase=label;tick(observer);};
  tick(G.System('scope/linked-spawn',{},({commands})=>{
    ids.push(commands.spawnIn(scene,G.Command.spawn([Payload,[11,12]])));
    ids.push(commands.spawn(G.Command.spawn([Payload,[21,22]])));
    ids.push(commands.spawn(G.Command.spawn([Payload,[31,32]])));
    ids.push(commands.spawn(G.Command.spawn([Payload,[41,42]])));
    commands.relate(ids[1],Parent,ids[0]);
    commands.relate(ids[3],Parent,ids[1]);
    commands.relate(ids[2],Link,ids[0]);
  }));
  observe('pending-spawn');tick(flush);observe('spawned');
  const cleanup=G.System('scope/linked-cleanup',{},({commands})=>commands.despawnScope(scene));
  tick(cleanup);observe('pending-cleanup');tick(flush);observe('cleaned');
  tick(cleanup,flush);observe('repeated-cleanup');
  const records=observations.filter(record=>record.root===root);
  assert.deepEqual(records.map(record=>record.rows.map(row=>row.id)),[[],[1,2,3,4],[1,2,3,4],[3],[3]]);
  assert.deepEqual(records[3].rows,[{id:3,payload:[31,32]}]);
  assert.equal(records[3].link.ok,false);
  assert.equal(records[3].link.error._tag,'MissingRelation');
  assert.deepEqual([...records[3].removed].sort((a,b)=>a-b),[1,2,4]);
  assert.deepEqual([...records[3].despawned].sort((a,b)=>a-b),[1,2,4]);
  assert.deepEqual(records[4].removed,[]);
  assert.deepEqual(records[4].despawned,[]);
}
console.log(JSON.stringify(observations));
