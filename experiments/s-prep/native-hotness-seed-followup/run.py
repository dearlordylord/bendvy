#!/usr/bin/env python3
"""Read-only Node debugger, checker15/emitter30 bounds; no compiler edits."""
import argparse,json,os,selectors,signal,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--entry',type=Path,required=True);p.add_argument('--expected-c',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
cmd=['taskset','-c','11','node',str(Path(__file__).with_name('inspect.mjs')),str(a.entry),str(a.expected_c),str(a.output)]
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
Path(str(a.output)+'.run.json').write_text(json.dumps({'argv':cmd,'checkerLimitSeconds':15,'emitterLimitSeconds':30,'exit':child.returncode,'timeout':timedout,'lastStage':stage,'privateDebugger':'Node inspector in-process Session, no listening endpoint','scope':'Read-only attribution; no law/proof or performance acceptance'},indent=2)+'\n')
print(text);raise SystemExit(0 if child.returncode==0 and not timedout else 1)
