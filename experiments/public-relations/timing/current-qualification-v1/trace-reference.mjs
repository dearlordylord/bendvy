import {Schema,Fx,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
function freeze(value) { if(value && typeof value === 'object') { for(const child of Object.values(value)) freeze(child); Object.freeze(value); } return value; }
export function runPublicTrace() { const result=[];
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
 let phase='';let systemResult=null;let retained;const records=[];const notices=[];
 const componentWrite=G.Query({selection:{payload:G.Query.write(Payload)}});
 const observer=()=>G.System('query-'+phase,{queries,relationFailures:{link:G.System.readRelationFailures(Link),other:G.System.readRelationFailures(OtherLink),parent:G.System.readRelationFailures(Parent)},removed:{payload:G.System.readRemoved(Payload)},despawned:{entities:G.System.readDespawned()}},({queries:q,lookup,relationFailures,removed,despawned})=>{
  const rows=Object.fromEntries(Object.keys(defs).map(key=>[key,q[key].each().map(({entity,data})=>({id:entity.id.value,component:[data.payload.get().tag,...data.payload.get().cells],cells:Object.keys(defs[key].selection).filter(x=>x!=='payload').map(name=>{const cell=data[name];return {key:name,value:cell.present===false?null:Array.isArray(cell.get())?cell.get().map(id=>id.value):cell.get().value};})}))]));
  const graphs=[Link,OtherLink,Parent].map((relation,index)=>({key:index+1,name:relation.name,targets:ids.map(id=>{const r=lookup.related(id,relation);return r.ok?(r.value?.value??null):null;}),sources:ids.map(id=>{const r=lookup.relatedSources(id,relation);return r.ok?r.value.map(x=>x.value):null;})}));
  const failures=Object.values(relationFailures).flatMap(reader=>reader.all().map(f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error})));
  if(phase==='initial')retained=structuredClone(rows.optional);
  records.push({root,phase,rows,graphs,failures,removed:removed.payload.all().map(id=>id.value),despawned:despawned.entities.all().map(id=>id.value),retained,systemResult});
 });
 phase='initial';tick(observer());
 const writers=[
  G.System('write-0',{},({commands})=>{commands.relate(ids[1],Parent,ids[0]);commands.relate(ids[2],Parent,ids[0]);commands.relate(ids[3],Parent,ids[2]);}),
  G.System('write-1',{queries:{write:componentWrite}},({commands,queries:q})=>{for(const row of q.write.each())if(row.entity.id.value===3)row.data.payload.set({tag:3300,cells:[130,131,132,133]});commands.relate(ids[2],Link,ids[1]);commands.unrelate(ids[3],OtherLink);commands.relate(ids[1],Link,ids[1]);}),
  G.System('write-2',{},({commands})=>commands.reorderChildren(ids[0],Parent,[ids[2],ids[1]])),
  G.System('write-3',{},({commands})=>commands.despawn(ids[2])),
  G.System('write-4',{},({commands})=>commands.despawn(ids[0]))
 ];
 writers[5]=G.System('relation-write-5',{queries:{write:componentWrite}},({commands,queries:q})=>{for(const row of q.write.each())if(row.entity.id.value===3)row.data.payload.set({tag:9000,cells:[230,231,232,233]});commands.relate(ids[4],OtherLink,ids[0]);return Fx.fail(903);});
 writers[6]=G.System('relation-write-6',{},({commands})=>{const future=commands.spawn(G.Command.spawn());ids.push(future);commands.relate(ids[4],Link,future);});
 for(const i of [0,1,2,5,6,3,4]){phase='queued-'+i;systemResult=null;if(i===5){const result=runtime.tick(G.Schedule(writers[i]));if(result.ok)throw Error('Expected actual system failure');systemResult=result.error;tick(observer());}else tick(writers[i],observer());phase='applied-'+i;systemResult=null;tick(G.Schedule.applyDeferred(),observer());}
 result.push(freeze({root,records}));
}

return freeze(result);
}
export function forcePublicTrace(trace) {
 const pending=[trace];let nodes=0,characters=0,sum=0;
 while(pending.length) { const value=pending.pop();nodes=(nodes+1)>>>0;
  if(value===null)sum=(sum+1)>>>0;
  else if(typeof value==='number')sum=(sum+2+value)>>>0;
  else if(typeof value==='string') {sum=(sum+3)>>>0;for(const c of value){characters=(characters+1)>>>0;sum=(sum+c.codePointAt(0))>>>0;}}
  else if(typeof value==='boolean')sum=(sum+(value?5:4))>>>0;
  else if(Array.isArray(value)) {sum=(sum+6)>>>0;for(let i=value.length-1;i>=0;i--)pending.push(value[i]);}
  else {sum=(sum+7)>>>0;const entries=Object.entries(value);for(let i=entries.length-1;i>=0;i--){pending.push(entries[i][1]);pending.push(entries[i][0]);}}
 }
 return {nodes,characters,sum};
}
console.error(JSON.stringify({boundary:'begin'}));
const trace=runPublicTrace();const summary=forcePublicTrace(trace);
console.error(JSON.stringify({boundary:'complete-trace-forced',...summary}));
console.log(JSON.stringify(trace));
