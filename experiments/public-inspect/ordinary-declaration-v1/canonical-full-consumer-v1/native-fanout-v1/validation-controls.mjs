// Reuse isolated decision-control style: no compiler import or backend.
import assert from 'node:assert/strict';
import fs from 'node:fs';
const text=fs.readFileSync(new URL('./probe.mts',import.meta.url),'utf8');
const begin=text.indexOf("assert(report.observed.routes.length>0");
const end=text.indexOf("fs.writeSync(1,'REFERENCE_INITIAL_SURVIVAL_PASS",begin);
assert(begin>=0&&end>begin);
const validate=new Function('assert','report',text.slice(begin,end));
const valid=()=>({observed:{routes:[{arguments:['flag','owner','target'],arms:['True','False'].map(constructor=>({constructor,calls:[{key:'exact_body~0',countedSites:2,flatCall:false,bang:false,tail:true}]}))}]}});
validate(assert,valid());
for(const mutate of [r=>r.observed.routes=[],r=>r.observed.routes[0].arguments=[],r=>r.observed.routes[0].arms.pop(),r=>r.observed.routes[0].arms[1].calls[0].key='different_body~0',r=>r.observed.routes[0].arms[0].calls[0].countedSites=1,r=>r.observed.routes[0].arms[0].calls[0].flatCall=true,r=>r.observed.routes[0].arms[0].calls[0].bang=true,r=>r.observed.routes[0].arms[0].calls[0].tail=false]){const report=valid();mutate(report);assert.throws(()=>validate(assert,report));}
console.log('PASS: exact survival-validator success and eight refusal controls; no compiler');
