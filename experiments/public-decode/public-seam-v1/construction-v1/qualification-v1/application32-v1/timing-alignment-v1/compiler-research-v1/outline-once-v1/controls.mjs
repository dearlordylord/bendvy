// Isolated diagnostic/decision controls, no compiler import or compilation.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import * as Cost from './cost.mjs';
const source=fs.readFileSync(new URL('./cost-comp.ts',import.meta.url),'utf8');
const branch=source.match(/if \((fl\.seg\.def !== ck\.k && !flat_call\(fl, x\) && dst === null && once)\) \{\n        Cost\.suppressed_once/);
assert(branch);
const decision=new Function('fl','ck','x','dst','once','flat_call','return '+branch[1]);
for(const same of [false,true])for(const flat of [false,true])for(const isTail of [false,true])for(const once of [false,true]){
 const fl={seg:{def:'caller'}},ck={k:same?'caller':'callee'};
 assert.equal(decision(fl,ck,null,isTail?null:{},once,()=>flat),!same&&!flat&&isTail&&once);
}
assert(source.includes('if (fl.seg.def !== ck.k && flat_call(fl, x)) {'));
Cost.arm(10000);const root=Cost.enter('root');
Cost.suppressed_once('caller','callee','segmentA');Cost.suppressed_once('caller','callee','segmentA');
Cost.suppressed_once('caller','callee','segmentB');
const child=Cost.enter('nested');Cost.suppressed_once('caller','callee','segmentA');Cost.leave(child,true);
Cost.leave(root,true);const snapshot=Cost.snapshot();
assert.deepEqual(snapshot.active,[]);assert.equal(snapshot.suppressedOnce.length,3);
assert.deepEqual(snapshot.suppressedOnce.map(x=>x.count),[2,1,1]);
assert.deepEqual(snapshot.suppressedOnce.map(x=>x.root),['root','root','nested']);
for(const e of snapshot.suppressedOnce)for(const key of ['root','caller','callee'])assert(snapshot.rows.some(r=>r.key===e[key]));
console.log('optional-once decision/mandatory flat fusion/root-callee aggregation controls PASS; no compiler');
