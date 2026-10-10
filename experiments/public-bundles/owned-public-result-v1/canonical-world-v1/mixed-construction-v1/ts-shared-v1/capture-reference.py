"""Mechanical reference adapter to unchanged stock5 capture/executor, no new runner."""
from pathlib import Path
import fcntl,functools,gzip,hashlib,importlib.util,json,sys
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
CAPTURE=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/check-source.py'
HELPER=ROOT/'scripts/task_runner.py';CONFIG=ROOT/'experiments/public-simulation/delivery-v1/installed-config.py'
NODE=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
def main():
 inventory=json.loads((HERE/'FREEZE.json').read_text())['sourceInventory'];assert all(sha(n)==h for n,h in inventory.items())
 config=load('reference_environment',CONFIG);cap=load('reference_capture',CAPTURE);runner=load('reference_executor',HELPER);out=HERE/sys.argv[1]
 sources=[*map(Path,inventory),CAPTURE,HELPER,CONFIG,NODE,Path('/usr/bin/taskset'),Path(__file__),HERE/'FREEZE.json',HERE/'INDEPENDENT-SOURCE-BASIS.json',HERE/'ORACLES.json',HERE/'model.py',HERE/'expected.stdout.gz']
 pins=cap.prepare_attempt(out,sources);env=config.environment();(out/'ENVIRONMENT.json').write_text(json.dumps(env,sort_keys=True,indent=2)+'\n');(out/'CLOSURE.json').write_text(json.dumps({'sourceInventory':inventory,'scope':'Reference Node execution, not Bend proof'},indent=2)+'\n')
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  try:
   assert all(sha(n)==h for n,h in pins.items())
   result=cap.capture(out,['/usr/bin/taskset','-c','5',str(NODE),str(HERE/'reference.mjs')],functools.partial(runner.execute_result,env=env))
   assert result['exit']==0 and result['failure'] is None and (out/'stderr').read_bytes()==b''
   raw=(out/'stdout').read_bytes();expected=gzip.decompress((HERE/'expected.stdout.gz').read_bytes());assert raw==expected
   (out/'COMPARISON.json').write_text(json.dumps({'completeIndependentOracleMatch':True,'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'scope':'TS shared constructor observations; no Bend physical-world identity claim'},indent=2)+'\n')
  finally:(out/'post.json').write_text(json.dumps({'unchanged':all(sha(n)==h for n,h in pins.items())})+'\n')
if __name__=='__main__':main()
