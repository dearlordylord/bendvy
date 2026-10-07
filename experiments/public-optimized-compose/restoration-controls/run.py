"""Actual closure affine quantity confinement, matched positive/negative."""
import pathlib,subprocess,hashlib,json

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command

base=pathlib.Path(__file__).resolve().parent;root=base.parents[2];records=[]
for name in ['positive','duplicate']:
 p=base/(name+'.bend');q=_run_command(['bend',str(p),'--check-only'],capture_output=True,text=True,timeout=5)
 if name=='positive':assert q.returncode==0,q.stderr
 else:assert q.returncode!=0 and 'restore (consumed more than once)' in q.stderr+q.stdout
 records.append({'case':name,'command':['bend',str(p),'--check-only'],'cap':5,'exit':q.returncode,'source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'stdout':q.stdout,'stderr':q.stderr})
sources={str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((root/'src/ecs').glob('*.bend'))};(base/'receipt.json').write_text(json.dumps({'status':'PASS','scope':'Affine restoration closure quantity only, not opaque raw constructors or performance','sources':sources,'cases':records},indent=2)+'\n');print('PASS')
