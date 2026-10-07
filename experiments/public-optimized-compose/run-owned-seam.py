"""Finite selected-ID1 interface prototype; not a general owner adapter."""
import pathlib, hashlib, subprocess, json, os, argparse
from freeze import ROOT

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner
from task_runner import run as _run_command

parser=argparse.ArgumentParser();parser.add_argument('--output',type=pathlib.Path,required=True);args=parser.parse_args();out=args.output.resolve();out.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory():return {str(p.relative_to(ROOT)):sha(p) for p in sorted(list((ROOT/'src/ecs').glob('*.bend'))+[ROOT/'experiments/public-optimized-compose/owned-seam-control.bend'])}
r={'scope':'Finite ID1 heterogeneous owner seam; no production/general fallback/qualified performance','sources':inventory(),'commands':[],'status':'INCOMPLETE'}
env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root')
def run(label,cmd,cap):
 p=_run_command(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=env);(out/(label+'.stdout')).write_text(p.stdout);(out/(label+'.stderr')).write_text(p.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':p.returncode});assert p.returncode==0,p.stderr;return p.stdout
source=ROOT/'experiments/public-optimized-compose/owned-seam-control.bend'
try:
 run('check',['bend',source,'--check-only'],5)
 for backend in ['JS','Native']:
  target=out/('seam.js' if backend=='JS' else 'seam.c');run('emit-'+backend,['bend',source,'-o',target],30)
  if backend=='Native':run('compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/'seam','-pthread','-lm'],120)
  result=json.loads(run('run-'+backend,['node',target] if backend=='JS' else [out/'seam'],5));assert result==[[[0],[3,4],[5,7],[1,0]],[[1],[5,7],[1,0]]],result
 assert inventory()==r['sources'];r['status']='PASS'
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
