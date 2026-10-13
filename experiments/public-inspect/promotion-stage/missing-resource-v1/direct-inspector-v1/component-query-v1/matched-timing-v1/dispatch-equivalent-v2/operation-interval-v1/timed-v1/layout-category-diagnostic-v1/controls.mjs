import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const here=new URL('./',import.meta.url);
const header=fs.readFileSync(new URL('logging-header.mjs.source',here),'utf8');
const candidate=fs.readFileSync(new URL('compiler/candidate.mjs',here),'utf8');
const base=fs.readFileSync(new URL('../runtime-selector-profile-v1/compiler/candidate.mjs',here),'utf8');
assert(candidate.includes(header));
let restored=candidate.replace(header,'').replace('return memo(LAYS, diagnostic_layout_key(t), (key) => {','return memo(LAYS, term_key(term_lower(t)), (key) => {').replace('      diagnostic_layout_flush();\n      fs2.writeSync(2,"DIAGNOSTIC_PROFILE_STOP\\n");','      fs2.writeSync(2,"DIAGNOSTIC_PROFILE_STOP\\n");').replace('function compile_book(book) {\n  try {','function compile_book(book) {').replace('  return diagnostic_result;\n  } finally { diagnostic_layout_flush(); }\n}\nfunction js_sat(k) {','  return diagnostic_result;\n}\nfunction js_sat(k) {');
assert.equal(restored,base);
let passed=1;
const marker=new Error('original failure');
function test(config={},error=null,keys=1) {
 let lowers=0,serializes=0,writes=0,clock=0;
 const performance={now(){assert.equal(this,performance);return ++clock;}};
 const ctx=vm.createContext({performance,LAYS:new Map(),fs2:{writeSync(){writes++;}},term_lower(t){lowers++;if(config.lowerError)throw marker;return t;},term_key(t){serializes++;if(config.keyError)throw marker;return JSON.stringify(t);}});
 vm.runInContext(header,ctx);
 if(config.prepare)config.prepare(ctx);
 let actual;
 try {actual=ctx.diagnostic_layout_key({k:'Product',x:[1,2]});assert.equal(error,null);}
 catch(e){assert.equal(e,error);}
 assert.equal(lowers,1);assert.equal(serializes,keys);
 if(error===null)assert.equal(actual,'{"k":"Product","x":[1,2]}');
 ctx.diagnostic_layout_flush();ctx.diagnostic_layout_flush();
 passed++;return {ctx,writes};
}
let normal=test();assert.equal(normal.writes,1);assert.equal(normal.ctx.DIAGNOSTIC_LAYOUT_ROWS.get('Product').calls,1);
test({prepare(c){c.LAYS.set('{"k":"Product","x":[1,2]}',{});}});
test({lowerError:true},marker,0);test({keyError:true},marker);
test({prepare(c){c.performance.now=()=>{throw new Error('timer');};}});
test({prepare(c){c.performance.now=()=>NaN;}});
test({prepare(c){c.DIAGNOSTIC_LAYOUT_ROWS={get(){throw new Error('stats');}};}});
test({prepare(c){c.DIAGNOSTIC_LAYOUT_ROWS={get(){},set(){throw new Error('stats');}};}});
test({prepare(c){c.DIAGNOSTIC_LAYOUT_ROWS={get(){return new Proxy({calls:0},{set(){throw new Error('counter');}});}};}});
test({prepare(c){c.LAYS.has=()=>{throw new Error('lookup observation');};}});
test({prepare(c){c.fs2.writeSync=()=>{throw new Error('publication');};}});
test({lowerError:true,prepare(c){c.performance.now=()=>{throw new Error('timer');};c.fs2.writeSync=()=>{throw new Error('publication');};}},marker,0);
test({keyError:true,prepare(c){c.DIAGNOSTIC_LAYOUT_ROWS={get(){throw new Error('stats');}};c.fs2.writeSync=()=>{throw new Error('publication');};}},marker);
console.log(JSON.stringify({status:'PASS_LOGGING_ONLY_CONTROLS',passed,scope:'Source reversibility and stub primary-result/error preservation; no compiler emission or performance measurement'}));
