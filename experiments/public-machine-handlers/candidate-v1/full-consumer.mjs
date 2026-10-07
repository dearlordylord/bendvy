import fs from 'node:fs';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const api=(await import(pathToFileURL(process.argv[2]))).default;
const expected=JSON.parse(fs.readFileSync(process.argv[3],'utf8'));
// Preserve the actual comparator's complete emitted JSON, not a reconstruction.
const originalLog=console.log;let referenceText;
try{console.log=(text)=>{assert.equal(referenceText,undefined);referenceText=text;};await import(pathToFileURL(process.argv[4]));}
finally{console.log=originalLog;}
assert.equal(typeof referenceText,'string');const reference=JSON.parse(referenceText);
assert.deepEqual(reference,expected.reference,'actual TS: all 96 records and 12 refusals');
function list(v){const xs=[];for(;v.$==='Con';v=v.tail)xs.push(v.head);assert.equal(v.$,'Nil');return xs;}
const bend={};
for(const name of Object.keys(expected.bend)){assert.equal(typeof api[name],'function');bend[name]=list(api[name]());assert.deepEqual(bend[name],expected.bend[name],name);}
console.log(JSON.stringify({bend,reference}));
