#!/usr/bin/env python3
"""Validate the phase-only sampling derivation against the already observed independent TS nine-world trace."""
from pathlib import Path
import argparse,os,sys,json,hashlib,importlib.util
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);a=p.parse_args()
root=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(root/'experiments/s-prep/fivehour-connected-gates'));import supervisor
os.sched_setaffinity(0,{10});d=a.directory;argv=['node',str(d/'heap.js')];code,out=supervisor.execute(argv,5);(d/'heap.raw.txt').write_text(out)
r={'status':'INCOMPLETE','commands':[{'argv':argv,'limitSeconds':5,'exit':code}],'inputSHA256':hashlib.sha256((d/'heap.js').read_bytes()).hexdigest(),'sourceProfileSHA256':hashlib.sha256((d/'evidence.json').read_bytes()).hexdigest(),'scope':'Existing phase hook heap diagnostic with all9 fullworlds; not exact physical allocation or time acceptance'}
try:
 assert code==0,out[-1000:]
 ts=json.loads((d/'TS.observed.txt').read_text());records=[line for line in out.splitlines() if line.startswith('{')];assert len(records)==9
 spec=importlib.util.spec_from_file_location('validator',root/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,'Health',False,256,world);assert v.normalized(json.loads(line),'Health')==world['final']
 r.update(status='SAMPLED_HEAP_AND_NINE_FULL_WORLDS_PASS',allFullFieldsEqual=True)
except Exception as e:r.update(status='FAILED',error=repr(e))
(d/'heap-evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
