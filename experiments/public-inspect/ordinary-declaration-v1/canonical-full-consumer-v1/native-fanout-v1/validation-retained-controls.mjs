// Fixed-shape wrapper/App and bang controls, no compiler or actual witness read.
import assert from 'node:assert/strict';
import {validateRetained} from './validate-retained.mjs';
const ann=x=>({$:'Ann',x,T:{$:'Typ'}});
const application=()=>ann({$:'App',f:ann({$:'App',f:ann({$:'Ref',k:'body~0'}),x:{$:'Var',k:'owner',i:0}}),x:{$:'Var',k:'target',i:1}});
const branch=()=>ann({$:'Lam',k:'owner',f:ann({$:'Lam',k:'target',f:application()})});
const valid=()=>({templateInstances:[{template:'owner-carrier:check_target_routed',instances:['route~0']},{template:'owner-carrier:check_target_body',instances:['body~0']}],observed:{bodies:[{key:'body~0',origin:['owner-carrier:check_target_body'],countedSites:2,flat:false}],routes:[{key:'route~0',origin:['owner-carrier:check_target_routed'],arguments:['flag','owner','target'],raisedBodyKey:JSON.stringify(ann({$:'Mat',k:'True',h:branch(),m:ann({$:'Mat',k:'False',h:branch(),m:{$:'Efq'}})})),arms:['True','False'].map(constructor=>({constructor,calls:[0,1].map(()=>({key:'body~0',argumentCount:2,countedSites:2,flatCall:false,tail:true}))}))}]}});
const edit=(r,fn)=>{const route=r.observed.routes[0],tree=JSON.parse(route.raisedBodyKey);fn(tree);route.raisedBodyKey=JSON.stringify(tree);};
assert.equal(validateRetained(valid()).routes,1);
const explicitFalse=valid();for(const arm of explicitFalse.observed.routes[0].arms)for(const row of arm.calls)row.bang=false;edit(explicitFalse,t=>{t.x.h.x.f.x.f.x.f.x.f.x.b=false;t.x.m.x.h.x.f.x.f.x.f.x.f.x.b=false;});validateRetained(explicitFalse);
const mutations=[r=>r.observed.routes=[],r=>r.observed.routes[0].arguments=[],r=>r.observed.routes[0].arms[0].calls.pop(),r=>r.observed.routes[0].arms[0].calls[1].key='other',r=>r.observed.bodies[0].countedSites=1,r=>r.observed.bodies[0].flat=true,r=>r.observed.routes[0].arms[0].calls[0].bang=true,r=>r.observed.routes[0].arms[0].calls[0].bang='false',r=>edit(r,t=>t.x.h.x.f.x.f=t.x.h.x.f.x.f.x),r=>edit(r,t=>t.x.h.x.f.x.f.x.x={$:'Var',k:'target',i:99}),r=>edit(r,t=>t.x.h.x.f.x.f.x.f.x.f.x.b=true),r=>edit(r,t=>t.x.m.x.k='True'),r=>r.templateInstances[1].instances=[],r=>r.observed.routes[0].arms[0].calls[0].tail=false];
for(const mutate of mutations){const report=valid();mutate(report);assert.throws(()=>validateRetained(report));}
console.log('PASS retained-validator: absent/explicit-false positives and14 wrapper/child/arguments/keys/flatness/sites/bang/origin/tail refusal controls; no actual witness/probe');
