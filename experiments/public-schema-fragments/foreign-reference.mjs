import {Schema,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
for(const root of ['Workshop','Other']){
 const Position=D.Component()('Position'),Velocity=D.Component()('Velocity');const G=Schema.bind(Schema.fragment({components:{Position}}),Schema.fragment({components:{Velocity}}),Schema.defineRoot(root));
 const worlds=[G.Runtime.make({}),G.Runtime.make({})];let firstId;
 const q=G.Query({selection:{a:G.Query.read(Position),b:G.Query.read(Velocity)}});
 for(let i=0;i<2;i++){
  const seed=G.System('seed'+i,{},({commands})=>{const id=commands.spawn(G.Command.spawn([Position,{cells:i?[20,21]:[10,11]}],[Velocity,{cells:i?[4,5]:[2,3]}]));if(i===0)firstId=id;});const result=worlds[i].tick(G.Schedule(seed,G.Schedule.applyDeferred()));if(!result.ok)throw Error(JSON.stringify(result));
 }
 const handle=G.Entity.handle(firstId,Position);let missing;const values=[];
 for(let i=0;i<2;i++){
  const read=G.System('read'+i,{queries:{q}},({queries,lookup})=>{if(i===1){const result=lookup.getHandle(handle,q);missing=result.ok?'alias:'+result.value.data.a.get().cells.join(','):result.error._tag;}const {data}=queries.q.each()[0];values.push(data.a.get().cells.join(',')+',:'+data.b.get().cells.join(',')+',:0::0');});let r=worlds[i].tick(G.Schedule(read));if(!r.ok)throw Error(JSON.stringify(r));
 }
 console.log(JSON.stringify({root,foreignLookup:missing,worlds:values}));
}
