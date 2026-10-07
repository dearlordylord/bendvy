import {Schema,Fx,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
function freeze(value) { if(value && typeof value === 'object') { for(const child of Object.values(value)) freeze(child); Object.freeze(value); } return value; }
export function prepareWorld(root,input) {
 const {family,population,span,payloadSeed,control}=input;
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
 const payload=id=>id===1?{tag:100,cells:[10]}:id===2?{tag:200,cells:[20,21]}:id===3?{tag:300,cells:[30,31,32,33]}:id===4?{tag:400,cells:[40,41,42,43,44,45,46,47]}:id===5?null:{tag:(payloadSeed+1000+id)>>>0,cells:[0,1,2,3].map(j=>(payloadSeed+10*id+j)>>>0)};
 if(control!=='empty')tick(G.System('spawn',{},({commands})=>{for(let id=1;id<=population;id++){const value=control==='sparse'&&id>=6?null:payload(id);ids.push(commands.spawn(value===null?G.Command.spawn():G.Command.spawn([Payload,value])));}}),G.Schedule.applyDeferred());
 if(control!=='empty')tick(G.System('seed',{},({commands})=>{commands.relate(ids[2],Link,ids[0]);commands.relate(ids[1],Link,ids[0]);commands.relate(ids[4],Link,ids[0]);commands.relate(ids[0],OtherLink,ids[3]);commands.relate(ids[3],OtherLink,ids[1]);}),G.Schedule.applyDeferred());
 return {metadata:freeze({root,worldCreates:1,registeredSystems:control==='empty'?0:2,spawnCommands:population,payloadOwners:control==='empty'?0:control==='sparse'?4:population-1,seedRelations:control==='empty'?0:5,barriers:control==='empty'?0:2}),run(){
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
 if(control==='empty')return freeze({root,records});
 const writers=[
  G.System('write-0',{},({commands})=>{commands.relate(ids[1],Parent,ids[0]);commands.relate(ids[2],Parent,ids[0]);commands.relate(ids[3],Parent,ids[2]);if(family!=='population')for(let j=0;j<span;j++)commands.relate(ids[5+j],Parent,family==='fanout'?ids[0]:j===0?ids[3]:ids[4+j]);}),
  G.System('write-1',{queries:{write:componentWrite}},({commands,queries:q})=>{for(const row of q.write.each())if(row.entity.id.value===3)row.data.payload.set({tag:3300,cells:[130,131,132,133]});commands.relate(ids[2],Link,ids[1]);commands.unrelate(ids[3],OtherLink);commands.relate(ids[1],Link,ids[1]);}),
  G.System('write-2',{},({commands})=>commands.reorderChildren(ids[0],Parent,[ids[2],ids[1],...(family==='fanout'?ids.slice(5,5+span).reverse():[])])),
  G.System('write-3',{},({commands})=>commands.despawn(ids[2])),
  G.System('write-4',{},({commands})=>commands.despawn(ids[0]))
 ];
 writers[5]=G.System('relation-write-5',{queries:{write:componentWrite}},({commands,queries:q})=>{for(const row of q.write.each())if(row.entity.id.value===3)row.data.payload.set({tag:9000,cells:[230,231,232,233]});commands.relate(ids[4],OtherLink,ids[0]);return Fx.fail(903);});
 writers[6]=G.System('relation-write-6',{},({commands})=>{const future=commands.spawn(G.Command.spawn());ids.push(future);commands.relate(ids[4],Link,future);});
 for(const i of [0,1,2,5,6,3,4]){phase='queued-'+i;systemResult=null;if(i===5){const result=runtime.tick(G.Schedule(writers[i]));if(result.ok)throw Error('Expected actual system failure');systemResult=result.error;tick(observer());}else tick(writers[i],observer());phase='applied-'+i;systemResult=null;tick(G.Schedule.applyDeferred(),observer());}
 return freeze({root,records});
 }};
}
export function parseInput(args){
 if(args.length!==2||!['nonpower','sparse','empty'].includes(args[0])||!/^\d+$/.test(args[1]))throw Error('INPUT_REFUSED');
 const [control,seed]=args;const payloadSeed=Number(seed);
 if(!Number.isInteger(payloadSeed)||payloadSeed<0||payloadSeed>0xffffffff)throw Error('INPUT_REFUSED');
 return freeze({family:'population',population:control==='empty'?0:7,span:0,payloadSeed,control});
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
const input=parseInput(process.argv.slice(2));
const worlds=['Workshop','Other'].map(root=>prepareWorld(root,input));
console.error(JSON.stringify({boundary:'begin'}));
const trace=freeze({input:{control:input.control,population:input.population,payloadSeed:input.payloadSeed},setup:worlds.map(world=>world.metadata),roots:worlds.map(world=>world.run())});
const summary=forcePublicTrace(trace);
console.error(JSON.stringify({boundary:'complete-trace-forced',...summary}));
console.log(JSON.stringify(trace));
