"""Preparation adapter to existing development source capture; no new child runner."""
from pathlib import Path
import fcntl,hashlib,importlib.util,json,sys
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
CAPTURE=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/check-source.py'
HELPER=ROOT/'scripts/task_runner.py';TOOL=Path('/home/node/.bend/bin/bend-2.0.35')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
def main():
 case=sys.argv[1];attempt=sys.argv[2];basis=json.loads((HERE/'SOURCE-PREPARATION.json').read_text());selected=[r for r in basis['cases'] if r['case']==case];assert len(selected)==1;row=selected[0]
 assert all(sha(p)==h for p,h in row['sources'].items())
 cap=load('public_fields_source_capture',CAPTURE);runner=load('public_fields_source_runner',HELPER)
 out=HERE/'checks'/attempt;out.parent.mkdir(exist_ok=True)
 sources=[*map(Path,row['sources']),HELPER,CAPTURE,TOOL,Path(__file__),HERE/'SOURCE-PREPARATION.json']
 pins=cap.prepare_attempt(out,sources);(out/'CLOSURE.json').write_text(json.dumps(row,indent=2)+'\n')
 argv=['/usr/bin/taskset','-c','11',str(TOOL),row['entrypoint'],'--check-only']
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  try:
   assert all(sha(p)==h for p,h in pins.items())
   result=cap.capture(out,argv,runner.execute_result);print(json.dumps({'case':case,'sources':len(row['sources']),'exit':result.get('exit'),'failure':result.get('failure'),'attempt':attempt}))
  finally:
   (out/'post.json').write_text(json.dumps({'unchanged':all(sha(p)==h for p,h in pins.items())})+'\n')
if __name__=='__main__':main()
