#!/usr/bin/env python3
"""Node-only pinned State observations; fresh source-bound receipt, stdlib only."""
import argparse,hashlib,json,pathlib,subprocess,time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner
from task_runner import run as _run_command

HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[1]
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path);a=p.parse_args()
OUT=(a.output or ROOT/'.artifacts'/('component-state-reference-'+str(time.time_ns()))).resolve()
OUT.mkdir(parents=True,exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory(p):return {str(q.relative_to(p)):sha(q) for q in sorted(p.rglob('*')) if q.is_file()}
receipt={'status':'INCOMPLETE','commands':[],'sourceHashes':{q.name:sha(q) for q in HERE.iterdir() if q.suffix in {'.mjs','.py'}},'manifestHash':sha(ROOT/'.references/sources.json'),'referenceHeads':{}}
def save():(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
def run(cmd,name):
 try:r=_run_command([str(x) for x in cmd],cwd=ROOT,text=True,capture_output=True,timeout=5)
 except subprocess.TimeoutExpired:
  receipt['status']='INCONCLUSIVE_TIMEOUT';save();raise
 (OUT/(name+'.stdout')).write_text(r.stdout);(OUT/(name+'.stderr')).write_text(r.stderr)
 receipt['commands'].append({'command':[str(x) for x in cmd],'limit':5,'exit':r.returncode,'stdout':name+'.stdout','stderr':name+'.stderr'});save()
 assert r.returncode==0,(name,r.stdout,r.stderr)
 return r.stdout
pins=json.loads((ROOT/'.references/sources.json').read_text())['sources']
for name,pin in pins.items():
 path=ROOT/'.references'/name
 head=run(['git','-C',path,'rev-parse','HEAD'],'head-'+name).strip();assert head==pin['commit'];receipt['referenceHeads'][name]=head
 assert not run(['git','-C',path,'status','--porcelain','--untracked-files=no'],'clean-'+name).strip()
ref=ROOT/'.references/bevy-ts/packages/core/src';receipt['referenceSourceHashes']=inventory(ref)
receipt['nodeVersion']=run(['node','--version'],'node-version').strip()
lines=run(['node',HERE/'reference.mjs'],'reference').splitlines();rows=[json.loads(x) for x in lines]
assert len(rows)==54,len(rows)
assert next(x['value'] for x in rows if x['label']=='restore/legal')=={'ok':True}
assert next(x['value'] for x in rows if x['label']=='rollback')==[['ready',0,[11,22,33]]]
assert next(x['value'] for x in rows if x['label']=='graph-bypassed')==[['active',2,[11,22,33]]]
assert inventory(ref)==receipt['referenceSourceHashes'],'reference drift'
assert sha(ROOT/'.references/sources.json')==receipt['manifestHash'],'manifest drift'
assert all(sha(HERE/q)==h for q,h in receipt['sourceHashes'].items()),'fixture drift'
for name,head in receipt['referenceHeads'].items():assert run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],'head-after-'+name).strip()==head
receipt.update(status='PASS_REFERENCE_ONLY',observations=len(rows));save();print(OUT)
