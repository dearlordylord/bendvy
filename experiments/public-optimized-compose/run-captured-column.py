"""Finite constant-None specialization/restoration controls; not provider acceptance."""
import argparse, pathlib, subprocess, hashlib, json, os
from freeze import ROOT

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner
from task_runner import run as _run_command

p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(exist_ok=False)
source=ROOT/'experiments/public-optimized-compose/captured-column-control.bend'
def inventory():return {str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(list((ROOT/'src/ecs').glob('*.bend'))+list(source.parent.glob('*.bend')))}
r={'scope':'Finite captured restoration and original constant-None seek equivalence; no World journal/provider/performance acceptance','sources':inventory(),'commands':[],'status':'INCOMPLETE'}
def run(label,cmd,cap):
 env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root');q=_run_command(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=env);(out/(label+'.stdout')).write_text(q.stdout);(out/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert q.returncode==0,q.stderr;return q.stdout
try:
 run('check',['bend',source,'--check-only'],5)
 observed=[]
 for backend in ['JS','Native']:
  target=out/('control.js' if backend=='JS' else 'control.c');run('emit-'+backend,['bend',source,'-o',target],30)
  if backend=='Native':run('compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/'control','-pthread','-lm'],120)
  v=json.loads(run('run-'+backend,['node',target] if backend=='JS' else [out/'control'],5));assert len(v)==23
  assert v[:4]==[[0,1,5,9,5,9,3,7,11,19]]*4
  assert v[4:6]==[[3,7,5,9,4,7,11,19]]*2
  assert v[6:8]==[[3,7,5,17,41,43,11,19]]*2
  assert v[8:10]==[[1,0,0,3,7,11,19]]*2
  assert v[10]==[999,999,0,0,3,7,999,999]
  for i in range(11,23,2):assert v[i]==v[i+1],(i,v[i:i+2])
  observed.append(v)
 assert observed[0]==observed[1];assert inventory()==r['sources'];r['status']='PASS';r['old_new_seek_pairs']=6;r['observations']=23
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
