// Pure metadata gate; only actual emitter logs can qualify consuming coverage.
export function validate(name, baseline, candidate, beforeIdentity, afterIdentity) {
 if(!beforeIdentity||!afterIdentity||!beforeIdentity.bindingSHA256||beforeIdentity.bindingSHA256!==afterIdentity.bindingSHA256)throw new Error('checked Book identity mismatch');
 const allowed=beforeIdentity.allowed;
 if(JSON.stringify(allowed)!==JSON.stringify(afterIdentity.allowed))throw new Error('checked specialization identity mismatch');
 const exact=(author,name)=>Array.isArray(allowed[author])&&allowed[author].includes(name);
 const target=r=>exact('main',r.caller)&&exact('target',r.callee);
 const eligible=baseline.filter(r=>r.kind==='decision'&&target(r)&&r.oldEligible&&!r.flat);
 const fused=baseline.filter(r=>r.kind==='fuse'&&target(r)&&!r.flat&&r.tail);
 const jumped=candidate.filter(r=>r.kind==='jump'&&target(r));
 const stillFused=candidate.filter(r=>r.kind==='fuse'&&target(r)&&!r.flat&&r.tail);
 if(name!=='layout-cut'&&(!eligible.length||!fused.length||!jumped.length||stillFused.length))throw new Error('authored main-target changed branch not reached: '+name);
 if(name==='layout-cut'&&!candidate.some(r=>r.kind==='cut'&&target(r)))throw new Error('authored generic main-target cut not reached');
 if(name==='parallel-return'&&(!candidate.some(r=>r.kind==='fork'&&exact('target',r.caller)&&r.bindings===2&&Array.isArray(r.callees)&&r.callees.length===2&&r.callees.every(k=>exact('measure',k)))||candidate.filter(r=>r.kind==='task'&&exact('target',r.caller)&&exact('measure',r.callee)&&r.rem===0).length<2))throw new Error('authored target-measure parallel child tasks not reached');
 if(name==='recursive-tail'&&!candidate.some(r=>r.kind==='jump'&&exact('countdown',r.caller)&&exact('countdown',r.callee)&&r.self))throw new Error('authored countdown self-return not reached');
}
