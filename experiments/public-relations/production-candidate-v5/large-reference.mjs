import {Schema,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const count=131072;
for(const root of ['Workshop','Other']){
 const Payload=D.Component()('Payload');const R=D.Hierarchy('R1','Sources1').relation;
 const G=Schema.bind(Schema.fragment({components:{Payload},relations:{R1:R}}),Schema.defineRoot('Large'+root));
 const runtime=G.Runtime.make({});const ids=[];let phase='';
 const rows=G.Query({selection:{}});const payloads=G.Query({selection:{payload:G.Query.read(Payload)}});
 const observer=G.System('observe',{queries:{rows,payloads},removed:{payload:G.System.readRemoved(Payload)},despawned:{entities:G.System.readDespawned()}},({lookup,queries,removed,despawned})=>{
  if(!phase)return;
  const all=queries.rows.each();const expected=phase==='after'?count-1:count;
  let valid=all.length===expected && all.every((row,i)=>row.entity.id.value===i+(phase==='after'?2:1));
  let graph=true;
  for(let id=1;id<=count;id++){
   const outgoing=lookup.related(ids[id-1],R);const incoming=lookup.relatedSources(ids[id-1],R);
   if(phase==='after'&&id===1){graph&&=!outgoing.ok&&outgoing.error._tag==='MissingEntity'&&!incoming.ok&&incoming.error._tag==='MissingEntity';continue;}
   if(id<count)graph&&=outgoing.ok&&outgoing.value.value===id+1;
   else graph&&=!outgoing.ok&&outgoing.error._tag==='MissingRelation';
   const children=(id===1||(phase==='after'&&id===2))?[]:[id-1];
   graph&&=incoming.ok&&JSON.stringify(incoming.value.map(x=>x.value))===JSON.stringify(children);
  }
  const owners=queries.payloads.each().map(row=>[row.entity.id.value,[...row.data.payload.get().cells]]);
  console.log(JSON.stringify({root,phase,count,liveCount:all.length,owners,allLiveShape:valid,allGraphFields:graph,removed:removed.payload.all().map(x=>x.value),despawned:despawned.entities.all().map(x=>x.value)}));
 });
 const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));if(!result.ok)throw Error(JSON.stringify(result));};
 tick(observer);
 tick(G.System('spawn',{},({commands})=>{const first=[[100,10],[200,20,21],[300,30,31,32,33],[400,40,41,42,43,44,45,46,47]];for(let i=0;i<count;i++)ids.push(commands.spawn((i<4?G.Command.spawn([Payload,{cells:first[i]}]):G.Command.spawn())));}),G.Schedule.applyDeferred());
 tick(G.System('relate',{},({commands})=>{for(let i=0;i<count-1;i++)commands.relate(ids[i],R,ids[i+1]);}),G.Schedule.applyDeferred());
 phase='before';tick(observer);
 phase='queued';tick(G.System('despawn',{},({commands})=>commands.despawn(ids[0])),observer);
 phase='after';tick(G.Schedule.applyDeferred(),observer);
}
