// Complete independent caller observations; no subset acceptance.
import fs from 'node:fs';
import { pathToFileURL } from 'node:url';
import assert from 'node:assert/strict';
const modulePath = process.argv[2];
assert(modulePath, 'generated module path required');
const expected = JSON.parse(fs.readFileSync(new URL('./expected-draft.json', import.meta.url), 'utf8')).rows;
const generated = (await import(pathToFileURL(modulePath))).default;
const observed = {};
for (const name of Object.keys(expected)) {
  assert.equal(typeof generated[name], 'function', `missing complete observation ${name}`);
  observed[name] = JSON.parse(generated[name]());
}
assert.deepEqual(observed, expected);
process.stdout.write(JSON.stringify(observed) + '\n');
