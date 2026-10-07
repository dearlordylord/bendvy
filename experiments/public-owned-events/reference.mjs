import assert from 'node:assert/strict';
import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import {expected} from './oracle.mjs';
const observed=[];
for(const root of ['OwnedAlpha','OwnedBeta']){
 const Ping=D.Event()(root+'/Ping'),Foreign=D.Event()(root+'/Foreign');
 const G=Schema.bind(Schema.fragment({events:{Ping}}),Schema.defineRoot(root));
 const runtime=G.Runtime.make({debug:true});let label,enabled=true,fail=false;const refs=new Map();let calls=[];
 const record=(reader,view)=>{const values=view.all();calls.push({reader,lagged:view.lagged(),values:values.map(x=>({id:x.id,cells:[...x.cells],nested:{text:x.nested.text}})),identity:values.map(x=>({payload:x===refs.get(x.id),cells:x.cells===refs.get(x.id).cells,nested:x.nested===refs.get(x.id).nested})),sameBatch:view.all()===values,readCanEmit:typeof view.emit==='function'});};
 const fast=G.System('fast',{events:{ping:G.System.readEvent(Ping)}},ctx=>{record('fast',ctx.events.ping);if(fail)throw Error('reader-failure');});
 const slow=G.System('slow',{events:{ping:G.System.readEvent(Ping)},when:[G.Condition.check('enabled',{},()=>enabled)]},ctx=>record('slow',ctx.events.ping));
 const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
 const capture=()=>{observed.push({root,label,calls});calls=[];};
 const publish=id=>{const value={id,cells:[id*10+1,id*10+2],nested:{text:'event-'+id}};refs.set(id,value);tick(G.System('publish-'+id,{events:{ping:G.System.writeEvent(Ping)}},ctx=>{ctx.events.ping.emit(value);}));return value;};
 label='registered-empty';tick(fast,slow);capture();
 const first=publish(1);first.cells[1]=99;first.nested.text='publisher-mutated';label='fast-shared-payload';tick(fast);capture();
 label='fast-repeat';tick(fast);capture();label='slow-independent';tick(slow);capture();
 publish(2);fail=true;label='fast-failed';assert.throws(()=>tick(fast),{message:'reader-failure'});capture();fail=false;label='fast-retry';tick(fast);capture();
 enabled=false;label='slow-condition-skipped';tick(slow);capture();enabled=true;label='slow-resume-discards';tick(slow);capture();
 const peer=G.Runtime.make();label='other-runtime-empty';assert.equal(peer.tick(G.Schedule(fast)).ok,true);capture();
 label='undeclared';tick(G.System('undeclared',{},ctx=>{calls.push({reader:'undeclared',hasPing:Object.hasOwn(ctx.events,'ping')});}));capture();
 const unheld=G.Runtime.make({debug:true});const peek=G.Inspector('unheld',{events:{ping:G.System.readEvent(Ping)}},ctx=>({values:ctx.events.ping.all().map(x=>({id:x.id,cells:[...x.cells],nested:{text:x.nested.text}})),lagged:ctx.events.ping.lagged()}));
 label='unheld-initial';calls=[unheld.inspect(peek)];capture();
 const final={id:3,cells:[31,32],nested:{text:'event-3'}};assert.equal(unheld.tick(G.Schedule(G.System('unheld-publish',{events:{ping:G.System.writeEvent(Ping)}},ctx=>{ctx.events.ping.emit(final);}))).ok,true);
 for(let i=0;i<3;i++)assert.equal(unheld.tick(G.Schedule()).ok,true);
 label='default-window-trim';calls=[unheld.inspect(peek)];capture();
 label='public-disposal-api';calls=[{runtimeDispose:typeof runtime.dispose==='function',runtimeUnregister:typeof runtime.unregister==='function',streamClear:typeof runtime.clearEvents==='function'}];capture();
 // JavaScript deliberately erases the TS schema typing here. Record this
 // dynamic boundary separately; it is not a nominal-type negative test.
 label='erased-cross-schema';const foreign=G.System('foreign',{events:{ping:G.System.readEvent(Foreign)}},ctx=>{record('foreign',ctx.events.ping);});tick(foreign);capture();
}
assert.deepEqual(observed,expected());console.log(JSON.stringify({developmentOnly:true,acceptance:false,completeIssue53:false,observed}));
