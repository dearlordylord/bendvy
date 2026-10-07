import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const api=(await import(pathToFileURL(process.argv[2]))).default;
const expected=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));
assert.deepEqual(Object.keys(expected).sort(),['schemaA','schemaB']);
const actual={};
for(const name of ['schemaA','schemaB']){
  actual[name]=[];
  for(let xs=api[name]();;xs=xs.tail){
    if(xs.$==='Nil')break;
    assert.equal(xs.$,'Con');actual[name].push(xs.head);
  }
  assert.deepEqual(actual[name],expected[name],`${name}: complete actual foreign registration ownership/cursor/World/Invocation refusal`);
}
console.log(JSON.stringify(actual));
