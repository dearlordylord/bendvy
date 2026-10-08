import assert from 'node:assert/strict';
import fs from 'node:fs';
import {pathToFileURL,fileURLToPath} from 'node:url';
const expected=JSON.parse(fs.readFileSync(new URL('ts-common-expected.json',import.meta.url),'utf8'));
const target=process.argv[2]??fileURLToPath(new URL('reference-ts.mjs',import.meta.url));
const {observation}=await import(pathToFileURL(target).href);
// Retain complete actual observations even if a later strict comparison refuses.
console.log(JSON.stringify(observation));
assert.equal(observation.status,'ACTUAL_PINNED_TS_BUNDLE_COMMON_WITH_COMPLETE_RAW');
assert.deepEqual(Object.keys(observation.schemas),['A','B']);
for(const schema of ['A','B']){
 const rows=observation.schemas[schema];
 assert.deepEqual(Object.keys(rows),Object.keys(expected.comparable[schema]));
 assert.equal(Object.keys(rows).length,21);
 for(const [name,record] of Object.entries(rows)){
  assert.deepEqual(Object.keys(record),['common','raw']);
  assert.deepEqual(record.common,expected.comparable[schema][name],schema+':'+name);
  assert.ok(record.raw.world&&Array.isArray(record.raw.history));
 }
}
