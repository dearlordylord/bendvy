#!/usr/bin/env python3
"""Freeze concrete proposal sources/tools; no acceptance or execution authority."""
import argparse,hashlib,json,pathlib,subprocess,shutil,re
P=pathlib.Path('/workspace/formal-proofs/bendvy');H=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
a=argparse.ArgumentParser();a.add_argument('--overlay',type=pathlib.Path,required=True);a.add_argument('--output',type=pathlib.Path,required=True);args=a.parse_args()
m=json.load(open(args.overlay/'overlay.json'));assert all(sha(args.overlay/n)==h for n,h in m['sources'].items())
files={str(p):sha(p) for p in H.glob('*.py')}
for name in ['measure-run.py']:
 p=P/'experiments/s-perf'/name;files[str(p)]=sha(p)
for n in ['measurement-bend-run.py','measurement-samples-run.py','measurement-reference.mjs','measurement-samples-reference.mjs']:
 p=P/'experiments/s-integrate'/n;files[str(p)]=sha(p)
for name in ['bend','node','clang']:
 p=pathlib.Path(shutil.which(name)).resolve();files[str(p)]=sha(p)
base=pathlib.Path.home()/'.bend/bend2/base.bend';files[str(base)]=sha(base)
effects=P/'.references/bend2/bend2/effs'
for n in ['now.c','now.js']:
 p=effects/n;files[str(p)]=sha(p)
comp=P/'.references/bend2/bend2/comp.ts';assert 'io_tick' in comp.read_text();files[str(comp)]=sha(comp)
x={'status':'UNACCEPTED_EXECUTION_PROPOSAL','deadlineUTC':'2026-10-05T07:34:51Z','windowStartUTC':'2026-10-05T02:34:51Z','batch':16,'schemas':['Motion','Health'],'size':256,'workload':'dense','sourceOverlay':str(args.overlay),'sourceClosure':m['sources'],'proposalProtectedFiles':files,'candidateCommit':subprocess.check_output(['git','-C',str(P),'rev-parse','HEAD'],text=True).strip(),'accepted':False,'remainingCheckManifest':'Actual final cache rollback/ownership/invalidations gates must be supplied and independently reviewed; no authority inferred'}
with args.output.open('x') as f:f.write(json.dumps(x,indent=2)+'\n')
print(x['status'])
