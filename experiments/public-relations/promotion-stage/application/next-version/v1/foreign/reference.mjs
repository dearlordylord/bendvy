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

 const other=G.Runtime.make({});const peerIds=[];const records=[];const retained={};
 const values=()=>[{tag:100,cells:[10]},{tag:200,cells:[20,21]},{tag:300,cells:[30,31,32,33]},{tag:400,cells:[40,41,42,43,44,45,46,47]}];
 const tick=(rt,...steps)=>{const r=rt.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 for(const [rt,handles] of [[runtime,ids],[other,peerIds]])tick(rt,G.System('spawn',{},({commands})=>{for(const value of values())handles.push(commands.spawn(G.Command.spawn([Payload,value])));handles.push(commands.spawn(G.Command.spawn()));}),G.Schedule.applyDeferred());
 const observe=(rt,handles,role,phase)=>tick(rt,G.System(role+'-'+phase,{queries,relationFailures:{link:G.System.readRelationFailures(Link),other:G.System.readRelationFailures(OtherLink),parent:G.System.readRelationFailures(Parent)}},({queries:q,lookup,relationFailures})=>{
  const rows=Object.fromEntries(Object.keys(defs).map(key=>[key,q[key].each().map(({entity,data})=>({id:entity.id.value,component:[data.payload.get().tag,...data.payload.get().cells],cells:Object.keys(defs[key].selection).filter(x=>x!=='payload').map(name=>{const cell=data[name];return {key:name,value:cell.present===false?null:Array.isArray(cell.get())?cell.get().map(id=>id.value):cell.get().value};})}))]));
  const graphs=[Link,OtherLink,Parent].map((relation,index)=>({key:index+1,name:relation.name,targets:handles.map(id=>{const r=lookup.related(id,relation);return r.ok?(r.value?.value??null):null;}),sources:handles.map(id=>{const r=lookup.relatedSources(id,relation);return r.ok?r.value.map(x=>x.value):null;})}));
  const failures=Object.values(relationFailures).flatMap(reader=>reader.all().map(f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error})));
  retained[role]??=structuredClone(rows.optional);records.push({root,role,phase,rows,graphs,failures,retained:retained[role]});
 }));
 observe(runtime,ids,'local','before');observe(other,peerIds,'peer','before');
 tick(runtime,G.System('foreign-attempt',{},({commands})=>{commands.relate(ids[2],Link,ids[0]);commands.relate(ids[1],Link,peerIds[0]);}));
 observe(runtime,ids,'local','queued');observe(other,peerIds,'peer','queued');
 tick(runtime,G.Schedule.applyDeferred());
 observe(runtime,ids,'local','applied');observe(other,peerIds,'peer','applied');
 console.log(JSON.stringify({root,sourceIds:ids.map(x=>x.value),peerIds:peerIds.map(x=>x.value),records}));
}
