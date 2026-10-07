import assert from 'node:assert/strict';
import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const observations=[];
for(const schema of ['Workshop','Garden'])for(const present of [false,true]){
 const Score=D.Resource()(schema+'/OptionalScore'),Neighbor=D.Resource()(schema+'/OptionalNeighbor');
 const G=Schema.bind(Schema.fragment({resources:{Score,Neighbor}}));
 const runtime=G.Runtime.make({resources:{Neighbor:{cells:[91,91,91,94]},...(present?{Score:{cells:[21,21,21,24]}}:{})}});
 let fail=false,label;const project=ctx=>({value:ctx.resources.score.get()===undefined?'undefined':[...ctx.resources.score.get().cells],neighbor:[...ctx.resources.neighbor.get().cells]});
 const inspector=G.Inspector(schema+'/OptionalInspector',{resources:{score:G.System.readResource(Score),neighbor:G.System.readResource(Neighbor)}},ctx=>{const value=project(ctx);observations.push({schema,present,label,ok:!fail,...value});if(fail)throw new Error('optional-after-read');return value;});
 const inspect=name=>{label=name;if(fail)assert.throws(()=>runtime.inspect(inspector),/optional-after-read/);else runtime.inspect(inspector);};
 const condition=G.Condition.check(schema+'/OptionalCheck',{resources:{score:G.System.readResource(Score)}},ctx=>{assert.equal(ctx.resources.score.get()===undefined,false);return true;});
 const noop=G.System(schema+'/OptionalNoop',{},()=>{});
 const check=name=>{const result=runtime.tryTick(G.Schedule.when([condition],noop));observations.push({schema,present,label:name,ok:result.ok,value:result.ok?true:{kind:result.error.kind,requirements:result.error.requirements}});};
 inspect('first');inspect('repeat');check('check');fail=true;inspect('failed');check('check-after');fail=false;inspect('retry');
}
console.log(JSON.stringify({format:1,application:'InspectorOptionalResources',observations}));
