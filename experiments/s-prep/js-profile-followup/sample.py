#!/usr/bin/env python3
"""Retain phase sampling provenance and fresh full nine-world validation; no clock comparison."""
import sys,os,json,hashlib,importlib.util,argparse
from pathlib import Path
R=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--profile-dir',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{7});d=a.profile_dir;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':7,'schema':a.schema,'commands':[],'scope':'Sampled phase allocation attribution; includes collected objects; inlined sites can move; no exact memory or elapsed claim'}
def run(args):
 code,out=execute(list(map(str,args)),5);r['commands'].append({'argv':list(map(str,args)),'cap':5,'exit':code});assert code==0,out[-1000:];return out
try:
 sampler=R/'experiments/s-prep/js-profile/heap-sampling-probe.py';summary=R/'experiments/s-prep/js-profile/heap-sampling-summary.py';run([sys.executable,sampler,'--input',d/'bend.js','--output',d/'sampled.cjs','--profile',d/'allocation.heapprofile']);raw=run(['node',d/'sampled.cjs']);(d/'sampled.raw.txt').write_text(raw)
 spec=importlib.util.spec_from_file_location('V',R/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V);ts=json.loads((d/'TS.observed.txt').read_text());lines=[x for x in raw.splitlines() if x.startswith('{')];assert len(lines)==9
 for line,world in zip(lines,[ts['warmup'],*ts['samples']]):V.validate(line,a.schema,False,256,world);assert V.normalized(json.loads(line),a.schema)==world['final']
 run([sys.executable,summary,d/'allocation.heapprofile','--output',d/'heap-summary.json']);r.update(status='NINE_FULL_WORLDS_SAMPLING_PASS',files={str(p):sha(p) for p in [d/'bend.js',d/'sampled.cjs',d/'allocation.heapprofile',d/'heap-summary.json',sampler,summary]},worlds=9)
except Exception as e:r.update(status='FAILED',error=repr(e))
(d/'sampling-evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status'].endswith('_PASS') else 1)
