import {Schema,Descriptor as D,Entity} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
for(const root of ['Workshop','Other']){
 const Payload=D.Component()('Payload');const {relation:Parent}=D.Hierarchy('Parent','Children');
 const G=Schema.bind(Schema.fragment({components:{Payload},relations:{Parent}}),Schema.defineRoot(root));
 const runtime=G.Runtime.make({});const ids=[];let phase='';const records=[],failures=[];
 const query=G.Query({selection:{payload:G.Query.read(Payload)}});
 const observer=G.System('observe',{queries:{owners:query},relationFailures:{parent:G.System.readRelationFailures(Parent)}},({queries,lookup,relationFailures})=>{
  failures.push(...relationFailures.parent.all().map(f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error})));
  records.push({root,phase,owners:queries.owners.each().map(x=>[x.entity.id.value,[...x.data.payload.get().cells]]),targets:ids.map(id=>{const r=lookup.related(id,Parent);return r.ok?(r.value?.value??null):null;}),inverses:ids.map(id=>{const r=lookup.relatedSources(id,Parent);return r.ok?r.value.map(x=>x.value):null;}),failures:[...failures]});
 });
 const tick=(...steps)=>{const r=runtime.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 tick(observer);
 tick(G.System('spawn',{},({commands})=>{[[100,10],[200,20,21],[300,30,31,32,33],[400,40,41,42,43,44,45,46,47]].forEach(cells=>ids.push(commands.spawn(G.Command.spawn([Payload,{cells}]))));}),G.Schedule.applyDeferred());
 tick(G.System('edges',{},({commands})=>{commands.relate(ids[2],Parent,ids[0]);commands.relate(ids[1],Parent,ids[0]);commands.relate(ids[3],Parent,ids[1]);}),G.Schedule.applyDeferred());
 const id=n=>ids[n-1]??Entity.makeEntityId(n);let serial=0;
 const subjects=[['reverse',1,[2,3]],['repeat',1,[2,3]],['missing-parent',9,[99,99]],['early-duplicate',1,[2,2,99]],['early-missing-child',1,[99,2,2]],['not-related',1,[4,2,3]],['empty-mismatch',1,[]],['subset-mismatch',1,[2]],['duplicate',1,[2,2]],['other-parent',2,[4]],['empty-parent',3,[]],['restore-order',1,[3,2]]];
 for(const[name,parent,children]of subjects){phase=name+'-queued';tick(G.System('queue-'+(++serial),{},({commands})=>commands.reorderChildren(id(parent),Parent,children.map(id))),observer);phase=name+'-after';tick(G.Schedule.applyDeferred(),observer);}
 phase='fifo-queued';tick(G.System('fifo',{},({commands})=>{commands.reorderChildren(id(1),Parent,[id(2),id(3)]);commands.unrelate(id(3),Parent);commands.reorderChildren(id(1),Parent,[id(2)]);commands.relate(id(3),Parent,id(1));commands.reorderChildren(id(1),Parent,[id(3),id(2)]);}),observer);phase='fifo-after';tick(G.Schedule.applyDeferred(),observer);
 for(const record of records.filter(x=>x.phase))console.log(JSON.stringify(record));
}
