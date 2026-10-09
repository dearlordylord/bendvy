// Synthetic gate/refusal controls only; no compiler imports or emitter execution.
import { validate as validateExact } from './witness-gate.mjs';
const identity={bindingSHA256:'synthetic-book',allowed:{main:['main'],target:['target'],countdown:['countdown'],measure:['measure']}};
const validate=(name,b,c)=>validateExact(name,b,c,identity,identity);
const baseline=[{kind:'decision',caller:'main',callee:'target',oldEligible:true,flat:false},{kind:'fuse',caller:'main',callee:'target',flat:false,tail:true}];
const candidate=[{kind:'jump',caller:'main',callee:'target'}];
function reject(name,b,c){try{validate(name,b,c);}catch{return;}throw new Error('unrelated witness accepted: '+name);}
validate('physical-owners',baseline,candidate);
reject('physical-owners',baseline.map(r=>({...r,caller:'Base.other'})),candidate);
const recursive=[...candidate,{kind:'jump',caller:'countdown',callee:'countdown',self:true}];validate('recursive-tail',baseline,recursive);
reject('recursive-tail',baseline,[...candidate,{kind:'jump',caller:'observe',callee:'observe',self:true}]);
const tasks=[{kind:'fork',caller:'target',bindings:2,callees:['measure','measure']},{kind:'task',caller:'target',callee:'measure',rem:0},{kind:'task',caller:'target',callee:'measure',rem:0}];
validate('parallel-return',baseline,[...candidate,...tasks]);
reject('parallel-return',baseline,[...candidate,...tasks.map(r=>({...r,caller:'observe'}))]);
reject('parallel-return',baseline,[...candidate,...tasks.map(r=>({...r,callee:'Base.other',callees:['Base.other','Base.other']}))]);
validate('layout-cut',[],[{kind:'cut',caller:'main',callee:'target'}]);
reject('layout-cut',[],[{kind:'cut',caller:'report',callee:'Base.other'}]);
console.log('SYNTHETIC_WITNESS_REFUSALS_PASS: no compiler child');
