#!/usr/bin/env python3
"""Owned orphan/fork supervision controls only; no compiler or benchmark."""
import argparse,json,os,subprocess,sys,time
from pathlib import Path
import supervisor as S
p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);a=p.parse_args();result={'status':'INCOMPLETE','cases':[]}
S.enable_subreaper();unrelated=subprocess.Popen([sys.executable,'-c','import time;time.sleep(10)'],start_new_session=True)
try:
 for label,program in [('orphan-setsid-retains-pipe',"import subprocess,sys;subprocess.Popen([sys.executable,'-c','import time;time.sleep(10)'],start_new_session=True)"),('fork-race',"import subprocess,sys,time\nwhile True:\n subprocess.Popen([sys.executable,'-c','import time;time.sleep(10)'],start_new_session=True)\n time.sleep(.02)")]:
  started=time.monotonic()
  try:S.execute([sys.executable,'-c',program],.15)
  except TimeoutError:pass
  else:raise AssertionError('timeout unexpectedly accepted')
  assert time.monotonic()-started<3 and S.child_pids(os.getpid())=={unrelated.pid} and unrelated.poll() is None
  result['cases'].append({'name':label,'timeoutRejected':True,'ownedChildrenRemaining':0,'unrelatedChildPreserved':True})
 result['status']='OWNED_ORPHAN_FORK_AND_UNRELATED_CONTROLS_PASS'
except Exception as error:result.update(status='FAIL',error=repr(error));raise
finally:
 unrelated.kill();unrelated.wait(timeout=1);a.evidence.write_text(json.dumps(result,indent=2)+'\n')
