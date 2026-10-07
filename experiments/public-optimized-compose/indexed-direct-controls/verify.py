#!/usr/bin/env python3
"""Checker-only owned-plan confinement gate; no backend or timing work."""
import argparse,hashlib,json,pathlib,shutil,subprocess,tempfile,time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command

ROOT=pathlib.Path(__file__).resolve().parents[3];HERE=pathlib.Path(__file__).resolve().parent
parser=argparse.ArgumentParser();parser.add_argument('--output',type=pathlib.Path);args=parser.parse_args()
OUT=(args.output or ROOT/'.artifacts'/('owned-plan-controls-'+str(time.time_ns()))).resolve();OUT.mkdir(parents=True,exist_ok=False)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
sources=list((ROOT/'src/ecs').glob('*.bend'))+[HERE.parent/'owned-seam-control.bend',HERE.parent/'refusal-control.bend']+list(HERE.glob('*.bend'))+[HERE/'verify.py']
receipt={'status':'INCOMPLETE','sourceHashes':{str(p.relative_to(ROOT)):sha(p) for p in sorted(sources)},'commands':[]}
def save():(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
with tempfile.TemporaryDirectory(prefix='owned-plan-controls-') as td:
 td=pathlib.Path(td);(td/'src').mkdir();shutil.copytree(ROOT/'src/ecs',td/'src/ecs');dest=td/'experiments/public-optimized-compose/owned-controls';shutil.copytree(HERE,dest,ignore=shutil.ignore_patterns('evidence','__pycache__'))
 for name in ['owned-seam-control.bend','refusal-control.bend']:shutil.copy2(HERE.parent/name,dest.parent/name)
 checks={
  'positive':[],
  'negative-duplicate':['- expected : row','- observed : row (consumed more than once)','Location: duplicated'],
  'negative-specialize':['- expected : S.Row','- observed : body~H','Location: body','S.get(row)'],
  'negative-undeclared':['- expected : S.Other','- observed : body~H','Location: body','S.other_project(row)'],
  'negative-write-read':['- expected : Cap.Write<body~H, P.Payload, P.View>','- observed : Cap.Read<body~H, P.View>','Location: body'],
  'negative-cross-schema':['- expected : @_:Q.Frame<Other, S.Store, Unit, Unit>','- observed : @frame:Q.Frame<P.Schema, S.Store, Unit, Unit>','Location: probe']}
 for name,needles in checks.items():
  cmd=['timeout','5','bend',str(dest/(name+'.bend')),'--check-only'];p=_run_command(cmd,cwd=td,text=True,capture_output=True,timeout=7)
  (OUT/(name+'.stdout')).write_text(p.stdout);(OUT/(name+'.stderr')).write_text(p.stderr)
  receipt['commands'].append({'command':cmd,'limit':5,'exit':p.returncode,'stdout':name+'.stdout','stderr':name+'.stderr'});save();text=p.stdout+p.stderr
  if not needles:assert p.returncode==0 and 'ALL PROOFS CHECK' in text,(name,text)
  else:assert p.returncode==1 and '- message  :' not in text and all(x in text for x in needles),(name,text)
assert all(sha(ROOT/name)==h for name,h in receipt['sourceHashes'].items()),'Source drift; rerun stable closure'
receipt['status']='PASS';receipt['scope']='Checker-only closed instantiated owned plan callbacks; no runtime mutation, proof or performance acceptance';save();print(json.dumps({'status':'PASS','cases':len(checks),'output':str(OUT)}))
