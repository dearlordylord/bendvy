#!/usr/bin/env python3
from replay import ROOT,HERE,R,P,metrics,check,load
import pathlib,json,hashlib,shutil
import argparse
parser=argparse.ArgumentParser();parser.add_argument('--plain',action='store_true');args=parser.parse_args()
root=pathlib.Path('/tmp/prep22-tx-quiet-probe');root.mkdir(exist_ok=True);dest=R.materialize(root)
quiet=ROOT/'experiments/s-perf/failure-indexed-overlay/experiments/s-integrate'
for p in quiet.glob('*.bend'):(dest/p.name).write_bytes(p.read_bytes())
for name in ['storage','identity','commands','query','observations','host']:
 p=ROOT/'experiments/s-perf/candidate'/(name+'.bend');(dest/p.name).write_bytes(p.read_bytes())
for name in ['failure-indexed-checks','failure-indexed-service-guard']:
 p=ROOT/'experiments/s-perf'/(name+'.bend');t=p.read_text().replace('./failure-indexed-overlay/experiments/s-integrate/','./');(dest/p.name).write_text(t)
for p in dest.glob('*.bend'):
 t=p.read_text().replace('../../../failure-indexed-service-guard.bend','./failure-indexed-service-guard.bend').replace('../../../failure-indexed-checks.bend','./failure-indexed-checks.bend');p.write_text(t)
if not args.plain:P.prepare(dest)
entry=dest/'measurement-failure-driver.bend';e={'sources':{str(pathlib.Path(p).relative_to(root)):h for p,h in R.closure(entry).items()}}
try:
 e['checker']=R.run(['taskset','-c','8','bend',entry,'--check-only']);js=root/'quiet.js';R.run(['taskset','-c','8','bend',entry,'-o',js],30)
 text=R.run(['taskset','-c','8','node',js,'0','1024','64'])[0];public='\n'.join(l for l in text.splitlines() if not l.startswith('txdiag:'))+'\n'
 V=load('quiet_validation',ROOT/'experiments/s-perf/failure-validate.py');ref=json.loads(R.run(['taskset','-c','8','node',ROOT/'experiments/s-integrate/measurement-reference.mjs','Motion','failed-transaction','1024'])[0]);e['validation']=V.validate(public,ref);e['metrics']=check(metrics(text),'failure') if not args.plain else {'activeTxMetrics':'not instrumented baseline'};e['status']='PASS'
except Exception as exc:e.update(status='BOUNDED_FAILURE',error=str(exc))
(HERE/('quiet-baseline-attempt.json' if args.plain else 'quiet-probe-evidence.json')).write_text(json.dumps(e,indent=2)+'\n');print(e['status']);print(e.get('error',''))
