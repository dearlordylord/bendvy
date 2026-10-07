#!/usr/bin/env python3
"""Source-bound Node-only research receipts. No core adoption or proof gate."""
import hashlib,json,os,pathlib,sys,time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
from validate import validate
OUT=HERE/'evidence'/str(time.time_ns());OUT.mkdir(parents=True)
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
files=list(HERE.glob('*.mjs'))+list(HERE.glob('*.py'))+[pathlib.Path(task_runner.__file__).resolve()]
files+=list((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))
files+=list((ROOT/'.references/bevy/crates/bevy_ecs/src/relationship').glob('*.rs'))
files+=[ROOT/'.references/bend2/bend2/comp.ts',pathlib.Path('/home/node/.bend/bend2/base.bend')]
files+=[ROOT/'src/ecs'/name for name in ['column.bend','component.bend','commands.bend','world.bend','transaction.bend']]
PINS={str(p):sha(p) for p in files};r={'status':'INCOMPLETE','pins':PINS,'commands':[],'runtimeSeconds':5,'scope':'Node reference research only; no Bend implementation/law approval/proof/performance gate'}
def save():(OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
def guard():assert all(sha(p)==h for p,h in PINS.items()),'source drift'
def run(argv,label,expected=0):
 guard();code,out=task_runner.execute(list(map(str,argv)),5);guard();(OUT/(label+'.txt')).write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'log':label+'.txt','logSHA256':sha(OUT/(label+'.txt'))});save();assert code==expected,(label,code,out);return out
try:
 manifest=json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'];r['referenceHeads']={}
 for name,h in manifest.items():actual=run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],'head-'+name).strip();assert actual==h;r['referenceHeads'][name]=h
 run(['node','--version'],'node-version');run(['bend','version'],'bend-version');run(['bend','guide'],'bend-guide')
 for name,diagnostic in [('reference-development-v0','lookup.children is not a function'),('reference-development-v1','effect.run is not a function')]:out=run(['node',HERE/(name+'.mjs')],name,1);assert diagnostic in out
 observations=run(['node',HERE/'reference.mjs'],'reference');records=[json.loads(line) for line in observations.splitlines()];validate(records);r['observationsPerRoot']=38;r['nominalRoots']=2
 foreign=run(['node',HERE/'foreign-reference.mjs'],'foreign');foreignRecords=[json.loads(line) for line in foreign.splitlines()];assert [x['root'] for x in foreignRecords]==['Workshop','Other']
 for item in foreignRecords:
  obs=item['observations'];assert len(obs)==5;assert obs[0]['rows']==obs[-1]['rows'];assert obs[1]['rows']==obs[2]['rows']
  applied=obs[3]['rows'];assert applied[0]['target']['ok'] and applied[0]['target']['value']['value']==2;assert applied[1]['sources']['ok'] and [x['value'] for x in applied[1]['sources']['value']]==[1];assert not obs[3]['failures']
  assert [row['cells'] for row in applied]==[[11,111],[12,112]]
 r['status']='NODE_RELATION_REFERENCE_RESEARCH_PASS';guard()
except Exception as e:r['status']='FAIL';r['error']=repr(e)
finally:save()
print(OUT,r['status']);sys.exit(0 if r['status']=='NODE_RELATION_REFERENCE_RESEARCH_PASS' else 1)
