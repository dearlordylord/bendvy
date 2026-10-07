import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const api=(await import(pathToFileURL(process.argv[2]))).default;
const expected=JSON.parse(fs.readFileSync(process.argv[3],'utf8')).bend;
const names=['A','B'].flatMap(s=>['exit','transition','enter'].flatMap(p=>[0,1].flatMap(i=>['','_missing'].map(suffix=>`schema${s}_${p}${i}${suffix}`))));
assert.deepEqual([...names].sort(),Object.keys(expected).sort());
const wanted=names.map(name=>`${name}|[${expected[name].join(', ')}]`);
const actual=[];
for(let v=api.all_observations();;v=v.tail){if(v.$==='Nil')break;assert.equal(v.$,'Con');actual.push(v.head);}
assert.deepEqual(actual,wanted,'runtime driver: complete full96 plus12 physical refusals');
console.log(JSON.stringify({observations:actual}));
