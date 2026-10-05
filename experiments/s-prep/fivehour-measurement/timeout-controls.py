#!/usr/bin/env python3
"""Own orphan/fork cleanup controls only; no compiler/Node/benchmark."""
import argparse,json,os,pathlib,subprocess,sys,time
import guard,packet
p=argparse.ArgumentParser();p.add_argument('--evidence',type=pathlib.Path,required=True);a=p.parse_args()
guard.enable_subreaper();unrelated=subprocess.Popen([sys.executable,'-c','import time;time.sleep(10)'],start_new_session=True)
try:
 cases=[]
 for label,program in [
  ('orphaned-setsid-retains-pipe',"import subprocess,sys;subprocess.Popen([sys.executable,'-c','import time;time.sleep(10)'],start_new_session=True)"),
  ('forking-during-timeout',"import subprocess,sys,time\nwhile True:\n subprocess.Popen([sys.executable,'-c','import time;time.sleep(10)'],start_new_session=True)\n time.sleep(.02)")]:
  logs=[];start=time.monotonic()
  try:packet.child([sys.executable,'-c',program],.15,logs)
  except ValueError:pass
  else:raise AssertionError('timeout control survived')
  assert time.monotonic()-start<3
  assert guard.child_pids(os.getpid())=={unrelated.pid}
  assert unrelated.poll() is None
  cases.append({'name':label,'timeoutRejected':True,'ownedChildrenRemaining':0,'unrelatedChildPreserved':True,'log':logs})
 with a.evidence.open('x') as f:json.dump({'status':'ORPHAN_FORK_RACE_AND_UNRELATED_PROCESS_CONTROLS_PASS','cases':cases,'noCompilerNodeOrPacketExecuted':True},f,indent=2)
 print('TIMEOUT_CONTROLS_PASS')
finally:
 unrelated.kill();unrelated.wait(timeout=1)
