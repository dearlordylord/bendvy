import {Descriptor,Fx,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import {performance} from 'node:perf_hooks';
const [mode,n,count]=process.argv.slice(2).map(Number);
if(!Number.isInteger(mode)||n<1||count<0)throw Error('mode size count required');
const P=Descriptor.Component()('Position'),Ping=Descriptor.Event()('Ping');
const G=Schema.bind(Schema.fragment({components:{P},events:{Ping}}));
const Read=G.Query({selection:{p:G.Query.read(P)}}),Write=G.Query({selection:{p:G.Query.write(P)}});
function sample(print=true){
 const runtime=G.Runtime.make({services:G.Runtime.services()}),ids=[],labels=new Map();let observed=0,round=2;
 const Spawn=G.System('Spawn',{},({commands})=>{for(let i=0;i<n;i++){const id=commands.spawn(G.Command.spawn([P,{x:1}]));ids.push(id);labels.set(id.value,i);}});
 runtime.tick(G.Schedule(Spawn,G.Schedule.applyDeferred()));
 if(mode===1){const Remove=G.System('Sparse',{},({commands})=>{for(let i=0;i<n;i++)if(i%8!==0)commands.remove(ids[i],P);});runtime.tick(G.Schedule(Remove,G.Schedule.applyDeferred()));}
 const Query=G.System('Query',{queries:{r:Read}},({queries})=>{for(const x of queries.r.each())observed+=x.data.p.get().x;});
 const Update=G.System('Update',{queries:{w:Write}},({queries})=>{for(const x of queries.w.each())x.data.p.set({x:round});});
 const Fail=G.System('Fail',{queries:{w:Write}},({queries})=>{for(const x of queries.w.each()){x.data.p.set({x:round});observed+=x.data.p.get().x;}return Fx.fail(7);});
 const Churn=G.System('Churn',{},({commands})=>{commands.remove(ids[0],P);commands.insert(ids[0],[P,{x:1}]);});
 const Removed=G.System('Removed',{removed:{p:G.System.readRemoved(P)}},({removed})=>{observed+=removed.p.all().length;});
 const Emit=G.System('Emit',{events:{ping:G.System.writeEvent(Ping)}},({events})=>{events.ping.emit(1);});
 const Reader=G.System('Reader',{events:{ping:G.System.readEvent(Ping)}},({events})=>{for(const x of events.ping.all())observed+=x;});
 const schedule=G.Schedule(...(mode<2?[Query]:mode===2?[Update]:mode===3?[Churn,G.Schedule.applyDeferred(),Removed]:mode===4?[Emit,Reader]:[Fail]));
 const start=performance.now();for(let i=0;i<count;i++){round=i+2;runtime.tick(schedule);}
 let sum=0,members=0,ordered='';const End=G.System('End',{queries:{r:Read}},({queries})=>{for(const x of queries.r.each()){members++;sum+=x.data.p.get().x;const label=labels.get(x.entity.id.value);if(label===undefined)throw Error('unmapped');ordered+=label+'='+x.data.p.get().x+',';}});runtime.tick(G.Schedule(End));const elapsed=performance.now()-start;
 if(print)console.log(`${members}:${sum}:${observed}|${ordered}:${elapsed}`);
}
// Fresh worlds and separate setup per sample; warmups execute the exact workload.
for(let i=0;i<3;i++)sample(false);sample();
