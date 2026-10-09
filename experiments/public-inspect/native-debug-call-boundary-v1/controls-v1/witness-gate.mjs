// Pure metadata gate; only actual emitter logs can qualify consuming coverage.
export function validate(name, baseline, candidate) {
 const target=r=>r.caller==='main'&&r.callee==='target';
 const eligible=baseline.filter(r=>r.kind==='decision'&&target(r)&&r.oldEligible&&!r.flat);
 const fused=baseline.filter(r=>r.kind==='fuse'&&target(r)&&!r.flat&&r.tail);
 const jumped=candidate.filter(r=>r.kind==='jump'&&target(r));
 const stillFused=candidate.filter(r=>r.kind==='fuse'&&target(r)&&!r.flat&&r.tail);
 if(name!=='layout-cut'&&(!eligible.length||!fused.length||!jumped.length||stillFused.length))throw new Error('authored main-target changed branch not reached: '+name);
 if(name==='layout-cut'&&!candidate.some(r=>r.kind==='cut'&&target(r)))throw new Error('authored generic main-target cut not reached');
 if(name==='parallel-return'&&(!candidate.some(r=>r.kind==='fork'&&r.caller==='target'&&r.bindings===2&&Array.isArray(r.callees)&&r.callees.length===2&&r.callees.every(k=>k==='Array.size'))||candidate.filter(r=>r.kind==='task'&&r.caller==='target'&&r.callee==='Array.size'&&r.rem===0).length<2))throw new Error('authored target-Array.size parallel child tasks not reached');
 if(name==='recursive-tail'&&!candidate.some(r=>r.kind==='jump'&&r.caller==='countdown'&&r.callee==='countdown'&&r.self))throw new Error('authored countdown self-return not reached');
}
