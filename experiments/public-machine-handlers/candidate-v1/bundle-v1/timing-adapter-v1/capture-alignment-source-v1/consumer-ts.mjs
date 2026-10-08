// No-clock full every-operation common oracle; actual raw TS fields retained before assertions.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {complete} from './reference-ts-snapshot-reuse.mjs';
const expected=JSON.parse(readFileSync(new URL('./expected-before-output.json',import.meta.url),'utf8'));
const ledger=JSON.parse(readFileSync(new URL('../operations.json',import.meta.url),'utf8'));
const common42=JSON.parse(readFileSync(new URL('../common-expected.json',import.meta.url),'utf8')).comparable;
const fields=['component','resource','extraPresent','extraPayload','current','previous','locals','attempts','prefix','pendingStructural','structuralApplied','deliveries','requirements','missing','outcome'];
const common=value=>Object.fromEntries(fields.map(name=>[name,value[name]]).concat([['pending',value.pending===null?null:value.pending.value]]));
const actual=complete(()=>0n);
console.log(JSON.stringify(actual));
assert.equal(actual.status,'UNQUALIFIED_ALIGNED_CAPTURE_SOURCE_NO_CLOCK');
assert.deepEqual(Object.keys(actual.schemas),['A','B']);
for(const schema of ['A','B']){
 const result=actual.schemas[schema];assert.deepEqual(Object.keys(result),['rows','samples','captures']);
 assert.equal(result.captures.length,13);assert.equal(result.samples.length,58);
 assert.deepEqual(result.samples.map(sample=>sample.kind),ledger.scenarios.flatMap(scenario=>['setup',...scenario.steps.map(step=>'steady:'+step.kind)]));
 assert.ok(result.samples.every(sample=>sample.nanoseconds==='0'));
 let count=0;const checkpoints={};
 for(let index=0;index<13;index++){
  const descriptor=ledger.scenarios[index],scenario=result.captures[index],wanted=expected.captures[schema][index];
  assert.equal(scenario.scenario,descriptor.scenario);assert.equal(scenario.captures.length,1+descriptor.steps.length);
  for(let ordinal=0;ordinal<scenario.captures.length;ordinal++){
   const captured=scenario.captures[ordinal],modeled=wanted.captures[ordinal];
   assert.deepEqual(Object.keys(captured),['kind','checkpoint','raw','common']);
   assert.equal(captured.kind,modeled.kind);assert.equal(captured.checkpoint,modeled.checkpoint);
   assert.deepEqual(captured.common,common(modeled.values[0]));
   assert.deepEqual(Object.keys(captured.raw),['label','result','world','streams','hostLocal','attempts','prefix','deliveries']);
   assert.equal(captured.raw.label,ordinal===0?'seed':captured.kind);
   assert.ok(captured.raw.result!==null&&typeof captured.raw.result==='object');
   assert.deepEqual(captured.raw.hostLocal,captured.common.locals);assert.deepEqual(captured.raw.attempts,captured.common.attempts);
   assert.deepEqual(captured.raw.prefix,captured.common.prefix);assert.deepEqual(captured.raw.deliveries,captured.common.deliveries);
   if(captured.checkpoint!==null){
    checkpoints[captured.checkpoint]=captured.common;
    assert.deepEqual(result.rows[captured.checkpoint].common,captured.common);
    assert.deepEqual(result.rows[captured.checkpoint].raw.world,captured.raw.world);
    assert.deepEqual(result.rows[captured.checkpoint].raw.streams,captured.raw.streams);
    assert.deepEqual(result.rows[captured.checkpoint].raw.history,scenario.captures.slice(0,ordinal+1).map(record=>record.raw));
   }
   count++;
  }
 }
 assert.equal(count,58);assert.deepEqual(checkpoints,common42[schema]);
 assert.deepEqual(Object.keys(result.rows),Object.keys(common42[schema]));
}
