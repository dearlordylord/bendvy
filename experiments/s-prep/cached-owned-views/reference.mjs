import assert from 'node:assert/strict';
import {Descriptor,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const results=[];
for(const schema of ['Motion','Health']){
 const Main=Descriptor.Component()('Main'),Aux=Descriptor.Component()('Aux'),Flag=Descriptor.Component()('Flag'),Ledger=Descriptor.Resource()('Ledger');
 const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{Ledger}}));
 const raw=schema==='Motion'?{coordinates:[10,11,12,13],frame:7}:{levels:[10,11,12,13],reserve:9,class:2};
 const runtime=G.Runtime.make({resources:{Ledger:{totals:[100,101,102,103],epoch:4}}});let id,context;
 const seed=G.System('Seed',{},({commands})=>{id=commands.spawn(G.Command.spawn([Main,raw],[Aux,schema==='Motion'?{rates:[110,111,112,113],moving:true}:{layers:[110,111,112,113],grade:3}],[Flag,{group:8}]));});assert.equal(runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred())).ok,true);
 const query=G.Query({selection:{main:G.Query.write(Main),aux:G.Query.read(Aux),flag:G.Query.read(Flag)}});const mainChecks=[],ledgerChecks=[];let sum;
 const body=G.System('Body',{queries:{q:query},resources:{ledger:G.System.writeResource(Ledger)}},({queries,resources})=>{
  const m=queries.q.get(id);assert.equal(m.ok,true);context={aux:structuredClone(m.value.data.aux.get()),flag:structuredClone(m.value.data.flag.get())};const owner=m.value.data.main,key=schema==='Motion'?'coordinates':'levels';
  const mc=()=>mainChecks.push(structuredClone(owner.get()));const lc=()=>ledgerChecks.push(structuredClone(resources.ledger.get()));
  mc();lc();
  for(let i=0;i<2;i++){
   const view=owner.get();mc();sum=view[key].reduce((a,b)=>a+b,0);owner.set({...view,[key]:[view[key][0]+1,...view[key].slice(1)]});mc();
   const lv=resources.ledger.get();lc();resources.ledger.set({...lv,totals:[lv.totals[0]+1,...lv.totals.slice(1)]});lc();
  }
  const v=owner.get();owner.set({...v,[key]:[10,...v[key].slice(1)]});mc();
  const lv=resources.ledger.get();resources.ledger.set({...lv,totals:[100,...lv.totals.slice(1)]});lc();
 });assert.equal(runtime.tick(G.Schedule(body)).ok,true);
 results.push({schema:schema.toLowerCase(),sum,mainChecks,ledgerChecks,context});
}
console.log(JSON.stringify(results));
