import assert from 'node:assert/strict';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const results=[];
for(const failed of [false,true]){
 const Main=Descriptor.Component()('Main'),Ledger=Descriptor.Resource()('Ledger');
 const G=Schema.bind(Schema.fragment({components:{Main},resources:{Ledger}}));
 const runtime=G.Runtime.make({resources:{Ledger:{cells:[5,6,7,8]}},services:G.Runtime.services()});
 const ids=[],trace=[];
 const Seed=G.System('Seed',{},({commands})=>{ids.push(commands.spawn(G.Command.spawn([Main,{cells:[1,3,4]}])));ids.push(commands.spawn(G.Command.spawn([Main,{cells:[2,3,4]}])));});
 assert.equal(runtime.tick(G.Schedule(Seed,G.Schedule.applyDeferred())).ok,true);
 const Q=G.Query({selection:{main:G.Query.write(Main)}});
 const Update=G.System('Update',{queries:{q:Q},resources:{ledger:G.System.writeResource(Ledger)}},({queries,resources})=>{
  const set=(id,v)=>{const r=queries.q.get(ids[id]);assert.equal(r.ok,true);const old=r.value.data.main.get();r.value.data.main.set({cells:[v,...old.cells.slice(1)]});};
  const ledger=v=>{const old=resources.ledger.get();resources.ledger.set({cells:[v,...old.cells.slice(1)]});};
  set(0,11);ledger(101);trace.push(resources.ledger.get().cells[0]);ledger(202);set(1,22);ledger(303);trace.push(resources.ledger.get().cells[0]);set(0,44);
  if(failed)return Fx.fail({code:7});
 });
 assert.equal(runtime.tick(G.Schedule(Update)).ok,!failed);
 let observed;
 const Read=G.Query({selection:{main:G.Query.read(Main)}});
 const Observe=G.System('Observe',{queries:{q:Read},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources})=>{observed={main:queries.q.each().map(r=>r.data.main.get().cells),ledger:resources.ledger.get().cells};});
 assert.equal(runtime.tick(G.Schedule(Observe)).ok,true);
 assert.deepEqual(trace,[101,303]);
 assert.deepEqual(observed,{main:failed?[[1,3,4],[2,3,4]]:[[44,3,4],[22,3,4]],ledger:failed?[5,6,7,8]:[303,6,7,8]});
 results.push({failed,trace,observed});
}
console.log(JSON.stringify({status:'FINITE_FRESH_TS_PASS',results}));
