import * as fs from 'node:fs';
import assert from 'node:assert/strict';
import * as Bend from '/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts';
import {native_fanout_probe} from './probe-comp.ts';
import {templateInstances} from '/workspace/formal-proofs/bendvy/experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/layout-followup-v1/provenance-v1/book-provenance.mjs';
const [entry]=process.argv.slice(2);
if(!entry)throw new Error('complete entry required');
const book=Bend.book_nil(),seen=new Map<string,string|null>();
await Bend.book_load(book,entry,'',seen);
Bend.book_valid(book);if(book.hols)throw new Error('incomplete Book');
const report={observed:native_fanout_probe(book),loaded:[...seen],templateInstances:templateInstances(book)};
// Publish the entire witness before assertions, including a failed control.
fs.writeSync(1,JSON.stringify(report,null,2)+'\n');
assert(report.observed.routes.length>0,'no reached routed specialization');
for(const route of report.observed.routes){
 assert(route.arguments.includes('flag'),'live selector parameter missing');
 const arms=route.arms.filter(arm=>arm.calls.length>0);
 assert.equal(arms.length,2,'both original arms must survive higher lowering');
 assert.deepEqual(arms.map(arm=>arm.constructor.split(':').at(-1)).sort(),['False','True']);
 const keys=new Set(arms.flatMap(arm=>arm.calls.map(call=>call.key)));
 assert.equal(keys.size,1,'both arms must call the exact same specialized body');
 for(const arm of arms){assert.equal(arm.calls.length,1,'one retained operation per arm');for(const call of arm.calls){assert(call.countedSites>=2,'once-site survived');assert.equal(call.flatCall,false,'mandatory flat fusion still eligible');assert.equal(call.bang,false,'routing changed');assert.equal(call.tail,true,'callsite is not retained in tail context');}}
}
fs.writeSync(1,'REFERENCE_INITIAL_SURVIVAL_PASS; no stock compiler or Native acceptance\n');
