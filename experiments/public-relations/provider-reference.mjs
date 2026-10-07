import {Schema, Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
for (const root of ['Workshop','Other']) {
 const Payload=D.Component()('Payload'); const {relation:Link}=D.Relation('Link','LinkedBy');
 const G=Schema.bind(Schema.fragment({components:{Payload},relations:{Link}}),Schema.defineRoot(root));
 const runtime=G.Runtime.make({});const ids=[];let phase='initial';let retained=[];const observations=[];
 const all=G.Query({selection:{payload:G.Query.read(Payload)}});
 const record=G.System('observer',{queries:{all}},({queries,lookup})=>{
  const sources=id=>{const r=lookup.relatedSources(id,Link);if(!r.ok)throw Error(JSON.stringify(r));return r.value.map(x=>x.value)};
  observations.push({root,phase,owners:queries.all.each().map(({data})=>{const p=data.payload.get();return [p.tag,...p.cells]}),inverse1:sources(ids[0]),inverse2:sources(ids[1]),retained:retained.map(x=>x.value)});
 });
 const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));if(!result.ok)throw Error(JSON.stringify(result))};
 const snapshot=p=>{phase=p;tick(record)};
 tick(G.System('spawn',{},({commands})=>{
  const values=[{tag:100,cells:[10]},{tag:200,cells:[20,21]},{tag:300,cells:[30,31,32,33]},{tag:400,cells:[40,41,42,43,44,45,46,47]}];
  for(const value of values)ids.push(commands.spawn(G.Command.spawn([Payload,value])));
 }),G.Schedule.applyDeferred());
 const writer=G.System('relate-system',{},({commands})=>commands.relate(ids[2],Link,ids[0]));
 const reader=G.System('inverse-reader',{},({lookup})=>{const r=lookup.relatedSources(ids[0],Link);if(!r.ok)throw Error(JSON.stringify(r));retained=r.value;});
 snapshot('registered-writer');tick(writer,G.Schedule.applyDeferred());snapshot('written');
 snapshot('registered-reader');tick(reader);snapshot('read');
 tick(G.System('replace',{},({commands})=>commands.relate(ids[2],Link,ids[1])),G.Schedule.applyDeferred());snapshot('replaced');
 console.log(JSON.stringify({root,observations}));
}
