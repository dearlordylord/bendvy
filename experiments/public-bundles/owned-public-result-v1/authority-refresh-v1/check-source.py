"""Preparation adapter to unchanged source capture; no new child runner."""
from pathlib import Path
import fcntl, hashlib, importlib.util, json, os, sys
ROOT=Path('/workspace/formal-proofs/bendvy'); HERE=Path(__file__).resolve().parent
CAPTURE=ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/check-source.py'
HELPER=ROOT/'scripts/task_runner.py'; TOOL=Path('/home/node/.bend/bin/bend-2.0.35')
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); return m
def main():
 label,attempt=sys.argv[1:]; basis=json.loads((HERE/'SOURCE-INVENTORY.json').read_text()); assert label in basis['labels']
 entry=HERE/'source/experiments/public-bundles/owned-public-result-v1/negatives'/f'{label}.bend'
 sources=[HERE/'source'/n for n in basis['sourceFiles']]
 resources=sorted(p for p in Path('/home/node/.bend/bend2').rglob('*') if p.is_file())
 assert all(sha(HERE/'source'/n)==h for n,h in basis['sourceFiles'].items())
 assert all(sha(n)==h for n,h in basis['rootJoins'].items())
 cap=load('bundle41_source_capture',CAPTURE); runner=load('bundle41_source_runner',HELPER)
 out=HERE/'checks'/attempt; out.parent.mkdir(exist_ok=True)
 pinfiles=[*sources,*resources,*map(Path,basis['rootJoins']),HELPER,CAPTURE,ROOT/'scripts/bend-check',TOOL,Path('/home/node/.bend/bend2/base.bend'),Path('/usr/bin/timeout'),Path('/usr/bin/taskset'),Path(__file__),HERE/'SOURCE-INVENTORY.json']
 pins=cap.prepare_attempt(out,pinfiles)
 configs={str(p/name):(sha(p/name) if (p/name).is_file() else None) for source in [*sources,*resources,CAPTURE,TOOL,ROOT/'scripts/bend-check'] for p in [source.parent,*source.parent.parents] for name in ['bend.json','bend.config.json','check.json','package.json','bunfig.toml']}
 bindir=HERE/'tool-path'; assert (bindir/'bend').is_symlink() and (bindir/'bend').resolve()==TOOL
 env=dict(os.environ,PATH=str(bindir)+':/usr/bin:/bin',BEND_NO_TELEMETRY='1'); private=out/'private-environment.json'; private.write_text(json.dumps(env,sort_keys=True)+'\n'); private.chmod(0o600)
 configuration=dict(configs); envsha=sha(private)
 argv=['/usr/bin/taskset','-c','5',str(ROOT/'scripts/bend-check'),str(entry)]
 def guard():
  assert all(sha(p)==h for p,h in pins.items())
  assert sorted(p for p in Path('/home/node/.bend/bend2').rglob('*') if p.is_file())==resources
  assert (bindir/'bend').resolve()==TOOL and sha(private)==envsha
  assert all((sha(p) if Path(p).is_file() else None)==h for p,h in configuration.items())
  assert {str(p.relative_to(HERE/'source')):sha(p) for p in (HERE/'source').rglob('*') if p.is_file()}==basis['sourceFiles']
 def guarded_execute(command,seconds,**kwargs):
  return runner.execute_result(command,seconds,env=env,**kwargs)
 (out/'PLAN.json').write_text(json.dumps(dict(label=label,entrypoint=str(entry),argv=argv,seconds=5,configuration=configuration,environmentSHA256=envsha,toolLiteral=str(bindir/'bend'),toolResolved=str(TOOL),sourceInventorySHA256=sha(HERE/'SOURCE-INVENTORY.json')),indent=2)+'\n')
 with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX)
  try:
   guard(); (out/'pre.json').write_text(json.dumps(dict(unchanged=True,pins=pins),indent=2)+'\n')
   result=cap.capture(out,argv,guarded_execute); print(json.dumps(dict(label=label,exit=result.get('exit'),failure=result.get('failure'))))
  finally:
   try: guard(); post=dict(unchanged=True)
   except Exception as error: post=dict(unchanged=False,error=str(error)); raise
   finally: (out/'post.json').write_text(json.dumps(post)+'\n')
if __name__=='__main__': main()
