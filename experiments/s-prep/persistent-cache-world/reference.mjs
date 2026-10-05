import assert from 'node:assert/strict';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const results=[];
for(const schema of ['Motion','Health']){
 const Main=Descriptor.Component()('Main'),Aux=Descriptor.Component()('Aux'),Flag=Descriptor.Component()('Flag'),Ledger=Descriptor.Resource()('Ledger'),Ping=Descriptor.Event()('Ping');
 const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{Ledger},events:{Ping}}));
 const key=schema==='Motion'?'coordinates':'levels';const raw=schema==='Motion'?{coordinates:[10,11,12,13],frame:7}:{levels:[10,11,12,13],reserve:9,class:2};const aux=schema==='Motion'?{rates:[110,111,112,113],moving:true}:{layers:[110,111,112,113],grade:3};
 const runtime=G.Runtime.make({resources:{Ledger:{totals:[100,101,102,103],epoch:4}}});let id,fail=false,sum,observed;
 const seed=G.System('Seed',{},({commands})=>{id=commands.spawn(G.Command.spawn([Main,raw],[Aux,aux],[Flag,{group:8}]));});assert.equal(runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred())).ok,true);
 const read=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.read(Aux),flag:G.Query.read(Flag)}}),write=G.Query({selection:{main:G.Query.write(Main)}});
 const observe=G.System('Observe',{queries:{q:read},resources:{ledger:G.System.readResource(Ledger)},events:{in:G.System.readEvent(Ping)}},({queries,resources,events})=>{observed={rows:queries.q.each().map(r=>({id:r.entity.id.value,main:structuredClone(r.data.main.get()),aux:structuredClone(r.data.aux.get()),flag:structuredClone(r.data.flag.get())})),ledger:structuredClone(resources.ledger.get()),pings:events.in.all().map(x=>x.code)};});
 const body=G.System('Body',{queries:{q:write},resources:{ledger:G.System.writeResource(Ledger)},events:{out:G.System.writeEvent(Ping)}},({queries,resources,commands,events})=>{
  const r=queries.q.get(id);assert.equal(r.ok,true);const owner=r.value.data.main;
  const set=value=>{const old=owner.get();owner.set({...old,[key]:[value,...old[key].slice(1)]});};const sl=value=>{const old=resources.ledger.get();resources.ledger.set({...old,totals:[value,...old.totals.slice(1)]});};
  const view=owner.get();sum=view[key].reduce((a,b)=>a+b,0);set(view[key][0]+1);sl(resources.ledger.get().totals[0]+1);
  if(fail){set(99);sl(88);set(77);commands.despawn(id);events.out.emit({code:12});return Fx.fail({code:7});}
  commands.insert(id,Flag,{group:9});events.out.emit({code:11});
 });
 assert.equal(runtime.tick(G.Schedule(observe)).ok,true);results.push({schema:schema.toLowerCase(),step:'init',...observed});
 assert.equal(runtime.tick(G.Schedule(body)).ok,true);assert.equal(sum,46);assert.equal(runtime.tick(G.Schedule(observe)).ok,true);results.push({schema:schema.toLowerCase(),step:'tick1',sum,...observed});
 fail=true;assert.equal(runtime.tick(G.Schedule(body)).ok,false);assert.equal(sum,47);assert.equal(runtime.tick(G.Schedule(observe)).ok,true);results.push({schema:schema.toLowerCase(),step:'tick2',sum,...observed});
}
console.log(JSON.stringify(results));
