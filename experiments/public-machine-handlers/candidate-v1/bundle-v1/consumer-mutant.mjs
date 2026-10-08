// Complete independently specified bundle routes and both actual foreign Worlds.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
const model = JSON.parse(fs.readFileSync(new URL('./expected.json', import.meta.url)));
const expected=model.rows;
const normal=JSON.parse(fs.readFileSync(new URL('./normal-expected.json', import.meta.url))).rows;
const generated = (await import(pathToFileURL(process.argv[2]))).default;
const observed = {};
for (const schema of ['A','B']) {
  assert.equal(typeof generated[schema+'_rows'], 'function');
  const rows = JSON.parse(generated[schema+'_rows']());
  assert.deepEqual(rows.map(r => r.name), Object.keys(expected[schema]));
  observed[schema] = Object.fromEntries(rows.map(r => [r.name,r.value]));
  assert.equal(Object.keys(observed[schema]).length,24);
}
process.stdout.write(JSON.stringify(observed)+'\n');
assert.deepEqual(observed,expected);
for(const schema of ['A','B'])assert.notDeepEqual(observed[schema][model.witness],normal[schema][model.witness],schema+':actual reached mutant witness');
