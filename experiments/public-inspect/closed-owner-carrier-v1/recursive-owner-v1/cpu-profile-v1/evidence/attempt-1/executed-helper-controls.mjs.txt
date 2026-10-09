// Fake inspector callback controls; imports no Bend/compiler.
import * as assert from 'node:assert/strict';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { withProfile, writeProfile } from './profile-helper.mjs';
import { armBudget, checkBudget, DiagnosticAbort } from './profile-budget.mjs';
const profile = {nodes:[{id:1,callFrame:{functionName:'synthetic'}}], samples:[1],timeDeltas:[1],startTime:0,endTime:1};
class FakeSession {
  constructor(stopError = false) { this.methods=[]; this.closed=false; this.stopError=stopError; }
  connect() { this.connected=true; }
  disconnect() { this.closed=true; }
  post(method, _parameters, callback) {
    this.methods.push(method);
    callback(method==='Profiler.stop' && this.stopError ? new Error('synthetic stop error') : null, method==='Profiler.stop' ? {profile} : {});
  }
}
const root=fs.mkdtempSync(path.join(os.tmpdir(),'bendvy-profile-controls-'));
try {
  for (const outcome of ['success','original-error','diagnostic-abort']) {
    const file=path.join(root,outcome+'.cpuprofile'); const session=new FakeSession();
    const error=outcome==='diagnostic-abort' ? new DiagnosticAbort() : new Error('original');
    const work=()=> { if(outcome!=='success') throw error; return 42; };
    if(outcome==='success') assert.equal(await withProfile(work,file,session),42);
    else await assert.rejects(withProfile(work,file,session),value=>value===error);
    assert.deepEqual(JSON.parse(fs.readFileSync(file)),profile);
    assert.deepEqual(session.methods,['Profiler.enable','Profiler.start','Profiler.stop']); assert.equal(session.closed,true);
  }
  const file=path.join(root,'success.cpuprofile'); const symlink=path.join(root,'symlink'); fs.symlinkSync(file,symlink);
  assert.throws(()=>writeProfile(file,profile)); assert.throws(()=>writeProfile(symlink,profile));
  const original=new Error('preserve original'); await assert.rejects(withProfile(()=>{throw original;},path.join(root,'failed.cpuprofile'),new FakeSession(true)),value=>value===original);
  armBudget(-1); assert.throws(checkBudget,DiagnosticAbort);
  console.log('FAKE_HELPER_CONTROLS_PASS');
} finally { fs.rmSync(root,{recursive:true}); }
