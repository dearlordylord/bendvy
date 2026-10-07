import {Schema,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
for (const destroy of [1,2]) {
 const Payload=D.Component()('Payload');const {relation:A}=D.Hierarchy('A','AChildren');const {relation:B}=D.Hierarchy('B','BChildren');
 const G=Schema.bind(Schema.fragment({components:{Payload},relations:{A,B}}),Schema.defineRoot('CrossDescriptorCycle'+destroy));
 const runtime=G.Runtime.make({});const ids=[];const tick=(...steps)=>{const r=runtime.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 const owners=G.Query({selection:{payload:G.Query.read(Payload)}});const observations=[];let phase='registered';
 const observer=G.System('observer',{queries:{owners},removed:{payload:G.System.readRemoved(Payload)},despawned:{entities:G.System.readDespawned()}},({lookup,queries,removed,despawned})=>{
  const lookupIds=[];if(ids.length){const a=lookup.related(ids[0],A),b=lookup.related(ids[1],B);lookupIds.push(a.ok?{target:a.value.value}:{error:a.error},b.ok?{target:b.value.value}:{error:b.error});}
  observations.push({phase,lookups:lookupIds,owners:queries.owners.each().map(x=>({id:x.entity.id.value,cells:[...x.data.payload.get().cells]})),removed:removed.payload.all().map(x=>x.value),despawned:despawned.entities.all().map(x=>x.value)});
 });
 tick(observer);
 tick(G.System('spawn',{},({commands})=>{ids.push(commands.spawn(G.Command.spawn([Payload,{cells:[10,11]}])));ids.push(commands.spawn(G.Command.spawn([Payload,{cells:[20,21]}])));}),G.Schedule.applyDeferred());
 tick(G.System('make-cross-descriptor-cycle',{},({commands})=>{commands.relate(ids[0],A,ids[1]);commands.relate(ids[1],B,ids[0]);}),G.Schedule.applyDeferred());
 phase='constructed';tick(observer);console.log(JSON.stringify({destroy,phase,observations:[...observations]}));
 try {tick(G.System('delete-cycle',{},({commands})=>commands.despawn(ids[destroy-1])),G.Schedule.applyDeferred());phase='after-delete';tick(observer);console.log(JSON.stringify({destroy,phase,observations:[...observations]}));}
 catch(error){console.log(JSON.stringify({destroy,phase:'upstream-error',name:error.name,message:error.message,stack:error.stack}));process.exitCode=1;}
}
