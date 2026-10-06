#!/usr/bin/env python3
"""Read-only Node debugger, checker15/emitter30 bounds; no compiler edits."""
import argparse,json,os,selectors,signal,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--entry',type=Path,required=True);p.add_argument('--expected-c',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--source-root',type=Path,required=True);a=p.parse_args()
import hashlib
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
sourcePins={str(p.relative_to(a.source_root)):sha(p) for p in a.source_root.rglob('*.bend')};assert len(sourcePins)==29
overlay=json.loads((a.source_root/'overlay.json').read_text());cache=json.loads((a.source_root/'cache-specialization.json').read_text());assert overlay['sources']==cache['runtimeClosure']==cache['specializedClosure']==sourcePins and overlay['cacheSpecialization']==cache
assert sha(Path('/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts'))=='32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9'
assert sha(Path('/workspace/formal-proofs/bendvy/.references/bend2/bend2/base.bend'))=='c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661'
assert not any(Path(str(a.output)+x).exists() for x in ['.json','.c','.log','.run.json'])
assert not any(p.is_symlink() for p in a.source_root.rglob('*'))
assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(sourcePins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
cmd=['taskset','-c','7','node',str(Path(__file__).with_name('hotness-inspector.mjs')),str(a.entry),str(a.expected_c),str(a.output)]
child=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
sel=selectors.DefaultSelector();sel.register(child.stdout,selectors.EVENT_READ);deadline=time.monotonic()+15;output=[];stage='read/check15';timedout=False
while child.poll() is None:
 if time.monotonic()>deadline:
  os.killpg(child.pid,signal.SIGKILL);output.append('BOUNDED_TIMEOUT:'+stage+'\n');timedout=True;break
 for key,_ in sel.select(.1):
  line=key.fileobj.readline();output.append(line)
  if line.strip()=='CHECK_PASS_EMIT_BEGIN':deadline=time.monotonic()+30;stage='emit30'
child.wait();output.append(child.stdout.read());text=''.join(output)
Path(str(a.output)+'.log').write_text(text)
sourceUnchanged=sourcePins=={str(p.relative_to(a.source_root)):sha(p) for p in a.source_root.rglob('*.bend')}
Path(str(a.output)+'.run.json').write_text(json.dumps({'argv':cmd,'source29Pins':sourcePins,'source29Unchanged':sourceUnchanged,'runnerSHA256':sha(Path(__file__)),'inspectorSHA256':sha(Path(__file__).with_name('hotness-inspector.mjs')),'checkerLimitSeconds':15,'emitterLimitSeconds':30,'exit':child.returncode,'timeout':timedout,'lastStage':stage,'privateDebugger':'Node inspector in-process Session, no listening endpoint','scope':'Read-only attribution; no law/proof or performance acceptance'},indent=2)+'\n')
print(text);raise SystemExit(0 if child.returncode==0 and not timedout and sourceUnchanged else 1)
