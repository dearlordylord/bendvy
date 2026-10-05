import assert from 'node:assert/strict';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const out=[];
for(const schema of ['Motion','Health'])for(const fail of [false,true]){
 const Main=Descriptor.Component()('Main'),Aux=Descriptor.Component()('Aux'),Flag=Descriptor.Component()('Flag'),Ledger=Descriptor.Resource()('Ledger'),Ping=Descriptor.Event()('Ping');
 const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{Ledger},events:{Ping}}));
 const runtime=G.Runtime.make({resources:{Ledger:{totals:[100,101,102,103],epoch:4}}});
 const main=x=>schema==='Motion'?{coordinates:[x,x+1,x+2,x+3],frame:7}:{levels:[x,x+1,x+2,x+3],reserve:9,class:2};
 const aux=x=>schema==='Motion'?{rates:[x,x+1,x+2,x+3],moving:true}:{layers:[x,x+1,x+2,x+3],grade:3};
 let id,second;
 const Seed=G.System('Seed',{},({commands})=>{id=commands.spawn(G.Command.spawn([Main,main(10)],[Aux,aux(110)],[Flag,{group:8}]));second=commands.spawn(G.Command.spawn([Main,main(900)],[Aux,aux(190)]));});
 assert.equal(runtime.tick(G.Schedule(Seed,G.Schedule.applyDeferred())).ok,true);
 const Q=G.Query({selection:{main:G.Query.write(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)}});
 let sum=0;const inverses=[];
 const Body=G.System('Body',{queries:{q:Q},resources:{ledger:G.System.writeResource(Ledger)},events:{out:G.System.writeEvent(Ping)}},({queries,resources,lookup,commands,events})=>{
  const selected=queries.q.get(id);assert.equal(selected.ok,true);const m=selected.value.data.main;
  const key=schema==='Motion'?'coordinates':'levels';
  const set=x=>{const old=m.get();inverses.unshift('M1:'+old[key][0]+';');m.set({...old,[key]:[x,...old[key].slice(1)]});};
  const sl=x=>{const old=resources.ledger.get();inverses.unshift('L:'+old.totals[0]+';');resources.ledger.set({...old,totals:[x,...old.totals.slice(1)]});};
  for(let i=0;i<2;i++){sum=m.get()[key].reduce((a,b)=>a+b,0);set(m.get()[key][0]+1);sl(resources.ledger.get().totals[0]+1);}
  set(77);sl(88);set(99);commands.insert(second,Flag,{group:9});commands.despawn(second);events.out.emit({code:11});events.out.emit({code:12}); // staged only; no applyDeferred
  if(fail)return Fx.fail({code:7});
 });
 const result=runtime.tick(G.Schedule(Body));assert.equal(result.ok,!fail);
 let rows,ledger,pings;const Observe=G.System('Observe',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)},events:{input:G.System.readEvent(Ping)}},({queries,resources,events})=>{rows=queries.q.each().map(r=>({id:r.entity.id.value,main:r.data.main.get(),aux:r.data.aux.present?r.data.aux.get():null,flag:r.data.flag.present?r.data.flag.get():null}));ledger=resources.ledger.get();pings=events.input.all().map(x=>x.code);});
 assert.equal(runtime.tick(G.Schedule(Observe)).ok,true);
 out.push({schema: schema.toLowerCase(),fail,sum,inverse:inverses.join(''),rows,ledger,pings});
}
console.log(JSON.stringify(out));
