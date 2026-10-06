#!/usr/bin/env python3
import argparse,json,os,pathlib,sys
sys.path.insert(0,'/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates')
from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--core',required=True);p.add_argument('--output',required=True);p.add_argument('--receipt',required=True);a=p.parse_args()
os.sched_setaffinity(0,{7});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';d=pathlib.Path(a.output);r=[]
commands=[(['python3','/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-measurement/prepare-bend.py','--core',a.core,'--output',str(d),'--schema',a.schema,'--batch','64'],5),(['python3','/workspace/formal-proofs/bendvy/experiments/s-prep/static-schema-driver/materialize.py','--driver',str(d/'batch.bend'),'--schema',a.schema],5),(['bend',str(d/'batch.bend'),'--check-only'],15),(['bend',str(d/'batch.bend'),'-o',str(d/'batch.js')],30),(['bend',str(d/'batch.bend'),'-o',str(d/'batch.c')],30),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(d/'batch.c'),'-pthread','-lm','-o',str(d/'batch.native')],120)]
for argv,cap in commands:
 code,out=execute(argv,cap);r.append({'argv':argv,'exit':code,'output':out,'capSeconds':cap,'cpu':7});pathlib.Path(a.receipt).write_text(json.dumps(r,indent=2)+'\n');print(code,out[-1000:],flush=True)
 if code:sys.exit(1)
