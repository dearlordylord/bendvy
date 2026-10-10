"""Preparation adapter to unchanged source capture; no new child runner."""
from pathlib import Path
import fcntl, hashlib, importlib.util, json, re, sys
ROOT=Path('/workspace/formal-proofs/bendvy'); HERE=Path(__file__).resolve().parent
CAPTURE=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/check-source.py'
HELPER=ROOT/'scripts/task_runner.py'; TOOL=Path('/home/node/.bend/bin/bend-2.0.35')
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path); module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module); return module
def main():
 entry=(HERE/sys.argv[1]).resolve(); out=HERE/sys.argv[2]; inventory={}
 def visit(p):
  p=p.resolve(); n=str(p)
  if n in inventory: return
  inventory[n]=sha(p)
  for target in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
   if target!='Base': visit(p.parent/target)
 visit(entry); cap=load('relation_resume_source_capture',CAPTURE); runner=load('relation_resume_source_runner',HELPER)
 pins=cap.prepare_attempt(out,[*map(Path,inventory),CAPTURE,HELPER,TOOL,Path('/home/node/.bend/bend2/base.bend'),Path(__file__)])
 (out/'CLOSURE.json').write_text(json.dumps(dict(entrypoint=str(entry),sourceInventory=inventory),indent=2)+'\n')
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  try:
   assert all(sha(n)==h for n,h in pins.items())
   result=cap.capture(out,['/usr/bin/taskset','-c','5',str(TOOL),str(entry),'--check-only'],runner.execute_result)
   print(result['exit'],result['failure']); print((out/'stderr').read_text())
  finally: (out/'post.json').write_text(json.dumps(dict(unchanged=all(sha(n)==h for n,h in pins.items())))+'\n')
if __name__=='__main__': main()
