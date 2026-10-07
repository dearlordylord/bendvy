import assert from 'node:assert/strict';
import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const observations=[];
const detached=value=>JSON.parse(JSON.stringify(value));
for(const schema of ['Workshop','Garden']){
 const Ping=D.Event()(schema+'/RetryPing');
 const G=Schema.bind(Schema.fragment({events:{Ping}}));
 const access={events:{ping:G.System.readEvent(Ping)}};
 const read=({events})=>({values:detached(events.ping.all()),lagged:events.ping.lagged()});
 const record=(label,value)=>{observations.push({schema,label,value:detached(value)});};
 const emit=(name,cells)=>G.System(schema+'/'+name,{events:{ping:G.System.writeEvent(Ping)}},({events})=>{events.ping.emit({cells});});
 const retained=G.Runtime.make();let fail=true;
 const reader=G.System(schema+'/RetainingReader',access,ctx=>{record('retaining-system',read(ctx));});
 const inspect=G.Inspector(schema+'/ThrowAfterRead',access,ctx=>{const value=read(ctx);record('retained-projection',value);if(fail)throw new Error('after-event-read');return value;});
 const attempt=label=>{try{record(label,{ok:true,value:retained.inspect(inspect)});}catch(error){record(label,{ok:false,name:error.name,message:error.message});}};
 assert.equal(retained.tick(G.Schedule(reader)).ok,true);
 assert.equal(retained.tick(G.Schedule(emit('EmitFirst',[11,12]))).ok,true);
 attempt('retained-fail-first');attempt('retained-fail-repeat');
 fail=false;attempt('retained-success-retry');attempt('retained-success-repeat');
 assert.equal(retained.tick(G.Schedule(emit('EmitSecond',[21,22]))).ok,true);
 fail=true;attempt('retained-fail-second');
 assert.equal(retained.tick(G.Schedule()).ok,true);assert.equal(retained.tick(G.Schedule()).ok,true);
 fail=false;attempt('retained-late-retry');
 assert.equal(retained.tick(G.Schedule(reader)).ok,true);attempt('retained-after-system');
 // Independent runtime: this inspector is the only stream observer. It must
 // not participate in retention merely because its projection read then threw.
 const unretained=G.Runtime.make();let failUnretained=true;
 const alone=G.Inspector(schema+'/AloneThrow',access,ctx=>{const value=read(ctx);record('alone-projection',value);if(failUnretained)throw new Error('alone-after-read');return value;});
 const aloneAttempt=label=>{try{record(label,{ok:true,value:unretained.inspect(alone)});}catch(error){record(label,{ok:false,name:error.name,message:error.message});}};
 assert.equal(unretained.tick(G.Schedule(emit('EmitAlone',[31,32]))).ok,true);aloneAttempt('alone-fail');
 assert.equal(unretained.tick(G.Schedule()).ok,true);assert.equal(unretained.tick(G.Schedule()).ok,true);
 failUnretained=false;aloneAttempt('alone-late-retry');aloneAttempt('alone-success-repeat');
 const warmRuntime=G.Runtime.make();let warmFail=true;
 const warm=G.Inspector(schema+'/WarmThrow',access,ctx=>{const value=read(ctx);record('warm-projection',value);if(warmFail)throw new Error('warm-after-read');return value;});
 const warmAttempt=label=>{try{record(label,{ok:true,value:warmRuntime.inspect(warm)});}catch(error){record(label,{ok:false,name:error.name,message:error.message});}};
 warmAttempt('warm-before-publication-fail');
 assert.equal(warmRuntime.tick(G.Schedule(emit('EmitWarm',[41,42]))).ok,true);warmAttempt('warm-event-fail');
 assert.equal(warmRuntime.tick(G.Schedule()).ok,true);assert.equal(warmRuntime.tick(G.Schedule()).ok,true);
 warmFail=false;warmAttempt('warm-late-retry');warmAttempt('warm-success-repeat');
}
console.log(JSON.stringify({format:1,application:'PublicInspectEventRetry',observations}));
