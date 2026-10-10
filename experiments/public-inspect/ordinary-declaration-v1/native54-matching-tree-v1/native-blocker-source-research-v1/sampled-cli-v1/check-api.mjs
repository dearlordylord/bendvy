import fs from 'node:fs';
import assert from 'node:assert/strict';
import {start,finish,due,writeAll} from './sample-helper.mjs';
const path=process.argv[2];assert(path.startsWith('/'));
assert.equal(due(true,100,15099),false);assert.equal(due(true,100,15100),true);assert.equal(due(false,100,99999),false);
const buffer=Buffer.from('λ😀'.repeat(60000));
for(const chunk of [1,7,131072,buffer.length]) {
 const captures=[];writeAll(buffer,(b,o,n)=>{const count=Math.min(n,chunk);captures.push(b.subarray(o,o+count));return count;});
 assert.deepEqual(Buffer.concat(captures),buffer);
}
for(const invalid of [0,-1,NaN,0.5,buffer.length+1])assert.throws(()=>writeAll(buffer,()=>invalid));
start(path);assert.throws(()=>start(path));
const until=performance.now()+20;let value=0;while(performance.now()<until)value=(value*1664525+1013904223)>>>0;
const meta=finish('api-control');assert(meta&&meta.reason==='api-control');
const profile=JSON.parse(fs.readFileSync(path,'utf8'));assert(profile.samples.length>0);
assert.equal(profile.samples.length,profile.timeDeltas.length);assert.equal(finish('second-finish'),undefined);
assert.equal(JSON.parse(fs.readFileSync(path+'.metadata.json','utf8')).sha256,meta.sha256);
console.log(JSON.stringify({status:'SAME_ELF_PROFILE_CONTROL_PASS',samples:profile.samples.length,transportBytes:buffer.length,shortWrites:[1,7,131072,buffer.length],zeroProgressRejected:true,secondStartRejected:true,synchronousResult:true}));
