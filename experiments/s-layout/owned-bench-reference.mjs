import {Descriptor,Fx,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import {performance} from 'node:perf_hooks';
const P=Descriptor.Component()('P'),G=Schema.bind(Schema.fragment({components:{P}}));
const Read=G.Query({selection:{p:G.Query.read(P)}}),Write=G.Query({selection:{p:G.Query.write(P)}});
function sample(print){const r=G.Runtime.make({services:G.Runtime.services()}),ids=[];let own='';
 r.tick(G.Schedule(G.System('Spawn',{},({commands})=>{for(const x of [10,20])ids.push(commands.spawn(G.Command.spawn([P,{items:[x,x,x,x]}])));}),G.Schedule.applyDeferred()));
 function step(name,target,ok){return G.System(name,{queries:{w:Write}},({queries})=>{const row=queries.w.each().find(x=>x.entity.id.value===ids[target].value);const old=row.data.p.get().items[1];for(const x of [17,19]){const items=row.data.p.get().items.slice();items[1]=x;row.data.p.set({items});}own=old+'->'+row.data.p.get().items[1];if(!ok)return Fx.fail(7);});}
 r.tick(G.Schedule(step('Commit',1,true)));const fail=G.Schedule(step('Fail',0,false));const start=performance.now();for(let i=0;i<10000;i++)r.tick(fail);
 let values=[];r.tick(G.Schedule(G.System('End',{queries:{r:Read}},({queries})=>{values=queries.r.each().map(x=>x.data.p.get().items[1]);})));const elapsed=performance.now()-start;
 if(print)console.log(own+';restored='+values[0]+';earlier='+values[1]+':'+elapsed);
}
for(let i=0;i<3;i++)sample(false);sample(true);
