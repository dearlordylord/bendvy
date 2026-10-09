"""Metadata-only exact reused copied-profile cohort; no compiler child."""
from pathlib import Path
import json,hashlib,re,sys
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
PROFILE=ROOT/'experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/cpu-profile-v1'
REFERENCE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-54-boxed-scan/experiments/public-inspect/closed-owner-carrier-v1/schema-partition-v1/garden-reference-diagnostic-v1')
RUNNER=HERE.parent.parent/'cpu-profile-v1/diagnostic-run.py'
PREVIOUS=Path('/tmp/bendvy-inspect54-recursive-native02/plan.json')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main(out):
 old=json.loads(PREVIOUS.read_text());assert sha(PREVIOUS)=='772a4aa0bdb96b5bea2aa5249110be26ede0321d2b681d693df04ba9a87d7e98'
 entry=Path(old['entrypoint']);stage=Path(old['stage']);pins={};seen=set()
 assert (REFERENCE/'base.bend').read_bytes()==Path('/home/node/.bend/bend2/base.bend').read_bytes()
 for file,digest in old['sourceInventory'].items():assert sha(stage/file)==digest
 def visit(path):
  path=path.resolve()
  if path in seen:return
  seen.add(path);pins[str(path)]=sha(path)
  for dep in re.findall(r'^import (\S+)',path.read_text(),re.M):visit(Path('/home/node/.bend/bend2/base.bend') if dep=='Base' else path.parent/dep)
 visit(entry);assert {str(f.relative_to(stage)) for f in seen if f.is_relative_to(stage)}==set(old['sourceInventory'])
 files=[PREVIOUS,Path(old['oracle']),REFERENCE/'bend.ts',REFERENCE/'base.bend',REFERENCE/'compiler-copy.tar.gz',REFERENCE/'copy-inventory.json',PROFILE/'profile-helper.mjs',PROFILE/'profile-budget.mjs',PROFILE/'comp.ts.gz',ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',RUNNER,Path('/usr/bin/taskset'),Path(sys.executable).resolve(),Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node')]
 for file in files:pins[str(file.resolve())]=sha(file)
 for file in (REFERENCE/'effs').rglob('*'):
  if file.is_file():pins[str(file.resolve())]=sha(file)
 for file in HERE.rglob('*'):
  if file.is_file() and file.name not in ('PREPARED.json','prepared-plan.json') and '__pycache__' not in file.parts:pins[str(file.resolve())]=sha(file)
 out=Path(out);out.mkdir();node='/home/node/.local/share/mise/installs/node/24.20.0/bin/node'
 plan=dict(scope='Full unchanged recursive23-grant copied-profile layout provenance only; not installed compiler/Native/performance',pins=pins,sourceEntry=str(entry),sourceInventory=old['sourceInventory'],wholeOracleSHA256=old['oracleSHA256'],wholeOracleBytes=old['oracleBytes'],environment=old['environment'],output=str(out/'reference.c'),profile=str(out/'recursive.cpuprofile'),argv=['/usr/bin/taskset','-c','5',node,str(HERE/'emit.mts'),str(entry),str(out/'reference.c'),str(out/'recursive.cpuprofile')],capSeconds=30,cooperativeCutoffMilliseconds=25000,pythonInterpreter=str(Path(sys.executable).resolve()),scopeLimit='Profile/provenance may be censored. Numeric counts not elapsed cost; helper may dominate allocation. No installed-ELF attribution. Full discovery/cleanhost are not qualified.')
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');(HERE/'prepared-plan.json').write_bytes(path.read_bytes());(HERE/'PREPARED.json').write_text(json.dumps(dict(plan=str(path),sha256=sha(path),runner=str(RUNNER),status='UNADMITTED_NO_CHILD'),indent=2)+'\n');print(sha(path),len(pins))
if __name__=='__main__':main(sys.argv[1])
