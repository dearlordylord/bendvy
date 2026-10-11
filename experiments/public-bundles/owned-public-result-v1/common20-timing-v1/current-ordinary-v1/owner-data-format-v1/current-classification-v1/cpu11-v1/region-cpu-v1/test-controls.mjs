import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
const base = "/workspace/formal-proofs/bendvy-worktrees/ordinary-custom-store-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/cpu11-v1/region-cpu-v1";
const patches = JSON.parse(fs.readFileSync(base + '/PATCHES.json'));
const original = fs.readFileSync(patches.original,'utf8');
const successor = fs.readFileSync(patches.patched,'utf8');
let inverse = successor;
for (const p of patches.patches.slice().reverse()) {
 assert.equal(inverse.split(p.new).length - 1,1);
 inverse = inverse.replace(p.new,p.old);
}
assert.equal(inverse,original);
const helper = fs.readFileSync(base + '/observer.cjs','utf8');
function observer(mode,events) {
 const exports = {};
 class Session {
  connect(){events.push('connect');}
  disconnect(){events.push('disconnect');}
  post(method,params,callback){
   events.push(method);
   if (mode==='async' && method==='Profiler.start') return;
   if (mode==='error' && method==='Profiler.start') return callback(Error('planted'));
   callback(null,method==='Profiler.stop' ? {profile:mode==='missing' ? null : {nodes:[{id:1}],samples:[1],timeDeltas:[100]}} : {});
  }
 }
 vm.runInNewContext(helper,{exports,require(name){if(name==='node:inspector')return {Session};if(name==='node:fs')return {writeFileSync(path,text,options){assert.equal(options.flag,'wx');assert.ok(JSON.parse(text).nodes);events.push('profile-write');}};throw Error(name);}});
 return exports;
}
function timing(source,obs,events) {
 const begin=source.indexOf(`(() => {
// Harness-only`);
 const end=source.indexOf('})();',begin)+5;
 assert.ok(begin>=0 && end>begin);
 const effects={},output=[];let ticks=0;
 vm.runInNewContext(source.slice(begin,end),{require(){return obs;},process:{hrtime:{bigint(){events.push('clock');return BigInt(++ticks*1000);}}},io_eff(key,fn){effects[key]=fn;},io_bytes(text){return Buffer.from(text);},io_out(fd,bytes){output.push([fd,bytes.toString()]);events.push('write'+fd);}});
 const get=suffix=>effects[Object.keys(effects).find(k=>k.endsWith('timing.'+suffix))];
 get('begin')();get('capture')('complete field1');get('capture')('Array[91,92]');get('capture')('final field');get('end')();return output;
}
const beforeEvents=[];const before=timing(original,{},beforeEvents);
const events=[];const obs=observer('sync',events);const after=timing(successor,obs,events);assert.deepEqual(after,before);
assert.ok(events.indexOf('Profiler.start')<events.indexOf('clock'));
assert.ok(events.lastIndexOf('clock')<events.indexOf('Profiler.stop'));
assert.ok(events.indexOf('profile-write')<events.indexOf('write2'));
assert.throws(()=>obs.begin(),/exactly once/);
assert.throws(()=>observer('sync',[]).end(),/after begin/);
for(const mode of ['async','error'])assert.throws(()=>observer(mode,[]).begin());
const missing=observer('missing',[]);missing.begin();assert.throws(()=>missing.end(),/no complete profile/);
console.log(JSON.stringify({literalArtifactInverse:true,fullStaticOutputAndMetricEquality:true,startBeforeTimer:true,stopAfterElapsed:true,writeOutsideTimer:true,duplicateAndEarlyEndRefuse:true,asyncAndErrorRefuse:true,missingProfileRefuse:true,noRealInspectorOrWorkload:true}));
