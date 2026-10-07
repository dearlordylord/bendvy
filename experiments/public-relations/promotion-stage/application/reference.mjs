import {Schema,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
for(const root of ['Workshop','Other']) {
 const Payload=D.Component()('Payload');const {relation:Link}=D.Relation('Link','LinkedBy');const {relation:OtherLink}=D.Relation('OtherLink','OtherIncoming');const {relation:Parent}=D.Hierarchy('Parent','Children');
 const G=Schema.bind(Schema.fragment({components:{Payload},relations:{Link,OtherLink,Parent}}),Schema.defineRoot(root));const runtime=G.Runtime.make({});const ids=[];
 const p=()=>({payload:G.Query.read(Payload)});
 const defs={
 'other-optional':{selection:{...p(),otherTarget:G.Query.optionalRelation(OtherLink),otherSources:G.Query.optionalRelated(OtherLink)}},
 optional:{selection:{...p(),target:G.Query.optionalRelation(Link),sources:G.Query.optionalRelated(Link)}},
 outgoing:{selection:{...p(),target:G.Query.readRelation(Link)}},incoming:{selection:{...p(),sources:G.Query.readRelated(Link)}},
 'with-out':{selection:p(),withRelations:[Link]},'without-out':{selection:p(),withoutRelations:[Link]},
 'with-in':{selection:p(),withRelated:[Link]},'without-in':{selection:p(),withoutRelated:[Link]},
 multi:{selection:{...p(),target:G.Query.readRelation(Link),otherTarget:G.Query.optionalRelation(OtherLink),otherSources:G.Query.optionalRelated(OtherLink)},withoutRelated:[OtherLink]},
 'cross-filters':{selection:{...p(),sources:G.Query.optionalRelated(Link)},withRelations:[OtherLink],withoutRelations:[Link]},empty:{selection:p()}
 };
 const queries=Object.fromEntries(Object.entries(defs).map(([key,value])=>[key,G.Query(value)]));
 const tick=(...steps)=>{const r=runtime.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 tick(G.System('spawn',{},({commands})=>{for(const value of [{tag:100,cells:[10]},{tag:200,cells:[20,21]},{tag:300,cells:[30,31,32,33]},{tag:400,cells:[40,41,42,43,44,45,46,47]}])ids.push(commands.spawn(G.Command.spawn([Payload,value])));ids.push(commands.spawn(G.Command.spawn()));}),G.Schedule.applyDeferred());
 tick(G.System('seed',{},({commands})=>{commands.relate(ids[2],Link,ids[0]);commands.relate(ids[1],Link,ids[0]);commands.relate(ids[4],Link,ids[0]);commands.relate(ids[0],OtherLink,ids[3]);commands.relate(ids[3],OtherLink,ids[1]);}),G.Schedule.applyDeferred());
 let phase='';let retained;const records=[];const notices=[];
 const componentWrite=G.Query({selection:{payload:G.Query.write(Payload)}});
 const observer=G.System('application-observer',{queries,relationFailures:{link:G.System.readRelationFailures(Link),other:G.System.readRelationFailures(OtherLink),parent:G.System.readRelationFailures(Parent)},removed:{payload:G.System.readRemoved(Payload)},despawned:{entities:G.System.readDespawned()}},({queries:q,lookup,relationFailures,removed,despawned})=>{
  const rows=Object.fromEntries(Object.keys(defs).map(key=>[key,q[key].each().map(({entity,data})=>({id:entity.id.value,component:[data.payload.get().tag,...data.payload.get().cells],cells:Object.keys(defs[key].selection).filter(x=>x!=='payload').map(name=>{const cell=data[name];return {key:name,value:cell.present===false?null:Array.isArray(cell.get())?cell.get().map(id=>id.value):cell.get().value};})}))]));
  const graphs=[Link,OtherLink,Parent].map((relation,index)=>({key:index+1,name:relation.name,targets:ids.map(id=>{const r=lookup.related(id,relation);return r.ok?(r.value?.value??null):null;}),sources:ids.map(id=>{const r=lookup.relatedSources(id,relation);return r.ok?r.value.map(x=>x.value):null;})}));
  const failures=Object.values(relationFailures).flatMap(reader=>reader.all().map(f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error})));
  if(phase==='initial')retained=structuredClone(rows.optional);
  records.push({root,phase,rows,graphs,failures,removed:removed.payload.all().map(id=>id.value),despawned:despawned.entities.all().map(id=>id.value),retained});
 });
 phase='initial';tick(observer);
 const writers=[
  G.System('write-0',{},({commands})=>{commands.relate(ids[1],Parent,ids[0]);commands.relate(ids[2],Parent,ids[0]);commands.relate(ids[3],Parent,ids[2]);}),
  G.System('write-1',{queries:{write:componentWrite}},({commands,queries:q})=>{for(const row of q.write.each())if(row.entity.id.value===3)row.data.payload.set({tag:3300,cells:[130,131,132,133]});commands.relate(ids[2],Link,ids[1]);commands.unrelate(ids[3],OtherLink);commands.relate(ids[1],Link,ids[1]);}),
  G.System('write-2',{},({commands})=>commands.reorderChildren(ids[0],Parent,[ids[2],ids[1]])),
  G.System('write-3',{},({commands})=>commands.despawn(ids[2])),
  G.System('write-4',{},({commands})=>commands.despawn(ids[0]))
 ];
 for(let i=0;i<writers.length;i++){phase='queued-'+i;tick(writers[i],observer);phase='applied-'+i;tick(G.Schedule.applyDeferred(),observer);}
 console.log(JSON.stringify({root,records}));
}
