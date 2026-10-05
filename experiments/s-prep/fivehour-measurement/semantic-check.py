#!/usr/bin/env python3
"""Validate every fresh world; clocks retained raw but not selected as metric."""
import argparse,hashlib,importlib.util,json
from pathlib import Path
import guard
guard.deadline(5);guard.protected()
R=guard.PROJECT;s=importlib.util.spec_from_file_location('v',R/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(s);s.loader.exec_module(V)
p=argparse.ArgumentParser();p.add_argument('--bend-output',type=Path,required=True);p.add_argument('--ts-output',type=Path,required=True);p.add_argument('--schema',default='Health');p.add_argument('--batch',type=int,default=64);p.add_argument('--evidence',type=Path,required=True);a=p.parse_args()
ts=json.load(open(a.ts_output));assert ts['batch']==a.batch and len(ts['samples'])==a.batch
lines=a.bend_output.read_text().splitlines();clock=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')];assert len(clock)==1
records=[x for x in lines if not x.startswith('BATCH-MILLISECONDS:')];assert len(records)==a.batch+1
worlds=[ts['warmup'],*ts['samples']];hashes=[]
for line,world in zip(records,worlds):
 checked=V.validate(line,a.schema,False,256,world);actual=json.loads(line);normalized=V.normalized(actual,a.schema);assert normalized==world['final'];hashes.append(checked['normalizedFinalSha256'])
r={'status':'EVERY_FULL_RECORD_WARMUP_AND_BATCH_PASS','batch':a.batch,'schema':a.schema,'fullFieldsComparedPerWorld':256,'records':len(records),'scope':'Semantic construction only; raw clocks not selected as performance metric','worldHashes':hashes,'rawInputs':{str(x):hashlib.sha256(x.read_bytes()).hexdigest() for x in [a.bend_output,a.ts_output]},'validatorSHA256':hashlib.sha256(Path(V.__file__).read_bytes()).hexdigest()}
with a.evidence.open('x') as f:f.write(json.dumps(r,indent=2)+'\n')
print(r['status'])
