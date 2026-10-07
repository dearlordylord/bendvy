"""Source-bound owned provider finite observations; no performance acceptance."""
import argparse,pathlib,subprocess,hashlib,json,os
from freeze import ROOT

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner
from task_runner import run as _run_command

p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(exist_ok=False)
base=ROOT/'experiments/public-optimized-compose';workshop=base/'workshop'
def inventory():return {str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(list((ROOT/'src/ecs').glob('*.bend'))+list(workshop.glob('*.bend')))}
r={'scope':'Complete copied Workshop observations and finite old/new provider pairs; not full-core or performance acceptance','sources':inventory(),'commands':[],'status':'INCOMPLETE'}
def run(label,cmd,cap):
 env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root');q=_run_command(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=env);(out/(label+'.stdout')).write_text(q.stdout);(out/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert q.returncode==0,q.stderr;return q.stdout
try:
 expected_path=base/'evidence/view-fusion/workshop-main-run-JS.stdout';expected=json.loads(expected_path.read_text());r['Workshop_oracle']={'path':str(expected_path.relative_to(ROOT)),'sha256':hashlib.sha256(expected_path.read_bytes()).hexdigest(),'scope':'Historical exact full observations; current reference source unchanged, no performance oracle'}
 for name in ['owned-provider-control','owned-main']:
  source=workshop/(name+'.bend');run(name+'-check',['bend',source,'--check-only'],5);observed=[]
  for backend in ['JS','Native']:
   target=out/(name+('.js' if backend=='JS' else '.c'));run(name+'-emit-'+backend,['bend',source,'-o',target],30)
   if backend=='Native':run(name+'-compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/name,'-pthread','-lm'],120)
   v=json.loads(run(name+'-run-'+backend,['node',target] if backend=='JS' else [out/name],5));observed.append(v)
   if name=='owned-main':assert v==expected;assert len(v['checkpoints'])==23
   else:
    assert len(v)==28
    for i in range(0,28,2):assert v[i]==v[i+1],(i,v[i:i+2])
    assert v[0][6]==15 and v[0][-6:]==[5,9,3,7,11,999],v[0]
  assert observed[0]==observed[1]
 assert inventory()==r['sources'];r['status']='PASS';r['provider_pairs']=14;r['Workshop_checkpoints']=23
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
