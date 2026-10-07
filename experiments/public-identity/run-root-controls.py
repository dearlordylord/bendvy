#!/usr/bin/env python3
"""Finite discovery controls; expected failure is not identity acceptance."""
import hashlib,json,os,pathlib,subprocess,time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner
from task_runner import run as _run_command

ROOT=pathlib.Path(__file__).resolve().parents[2]
OUT=ROOT/'.artifacts'/('identity-root-controls-'+str(time.time_ns()))
OUT.mkdir(parents=True)
ENV=os.environ.copy()
ENV['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
FILES=[ROOT/'src/ecs/world.bend',pathlib.Path(__file__),ROOT/'experiments/public-identity/root-collision.bend',ROOT/'experiments/public-identity/shared-root-control.bend']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
receipt={'scope':'Finite independently created same-schema root discovery; not issue38 acceptance','sources':{str(p.relative_to(ROOT)):sha(p) for p in FILES},'commands':[]}
def guard():
 assert all(sha(ROOT/k)==v for k,v in receipt['sources'].items()),'Source drift'
def run(argv,cap):
 guard();p=_run_command(list(map(str,argv)),cwd=ROOT,env=ENV,capture_output=True,timeout=cap)
 receipt['commands'].append({'argv':list(map(str,argv)),'limitSeconds':cap,'exit':p.returncode,'stdout':p.stdout.decode(),'stderr':p.stderr.decode()})
 assert p.returncode==0,receipt['commands'][-1]
 guard();return p.stdout
try:
 for name,expected in [('root-collision','independent-root collision: foreign handle accepted'),('shared-root-control','shared-root control: foreign handle rejected')]:
  source=ROOT/'experiments/public-identity'/(name+'.bend')
  run(['timeout','5','bend',source],6)
  run(['bend',source,'-o',OUT/(name+'.js')],30)
  run(['bend',source,'-o',OUT/(name+'.c')],30)
  run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',OUT/(name+'.c'),'-pthread','-lm','-o',OUT/name],120)
  for backend,argv in [('JS',['node',OUT/(name+'.js')]),('Native',[OUT/name,'--threads','1','--gpu','off'])]:
   stdout=run(argv,5);assert stdout.decode().strip()==expected,(name,backend,stdout)
   (OUT/(name+'-'+backend+'.stdout')).write_bytes(stdout)
 receipt['status']='EXPECTED_IDENTITY_FAILURE_CONFIRMED'
 receipt['finding']='Separate public factory() roots both allocate namespace1/entity1. World.valid accepts the foreign handle after both actual worlds activate entity1. Shared affine factory control rejects it.'
 receipt['requiredNextGate']='Independent-root canonical identity creation, explicit trusted raw-constructor boundary and actual public lookup/command refusal controls; no language-wide/global identity claim.'
finally:
 (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 print(OUT)
