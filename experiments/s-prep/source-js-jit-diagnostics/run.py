#!/usr/bin/env python3
"""Read-only V8 JIT diagnostics on the exact retained nine-world driver."""
import argparse,gzip,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=11);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
sha=lambda b:hashlib.sha256(b).hexdigest()
src=ROOT/'experiments/s-prep/source-fold-noaux-join/profile';index=json.loads((src/'index.json').read_text())
r={'status':'INCOMPLETE','scope':'JIT diagnosis only; profiler driver unchanged, not performance acceptance','cpu':a.cpu,'recipeSHA256':sha(Path(__file__).read_bytes()),'commands':[]}
try:
 for name in ['bend.js','reference.mjs']:
  raw=gzip.decompress((src/(name+'.gz')).read_bytes());assert sha(raw)==index['files'][name]['decodedSHA256'];(a.output/name).write_bytes(raw)
 for role,name in [('TS','reference.mjs'),('JS','bend.js')]:
  argv=['node','--trace-opt','--trace-deopt',str(a.output/name)];c={'role':role,'argv':argv,'limitSeconds':5};r['commands'].append(c)
  code,out=supervisor.execute(argv,5);(a.output/(role+'.raw.txt')).write_text(out);c.update(exit=code,outputSHA256=sha(out.encode()));assert code==0
  lines=out.splitlines();observed=[x for x in lines if x.startswith('{')];(a.output/(role+'.observed.txt')).write_text('\n'.join(observed)+'\n')
  trace=[x for x in lines if 'deopt' in x or 'optimizing' in x or 'optimization' in x];(a.output/(role+'.jit.txt')).write_text('\n'.join(trace)+'\n')
 ts=json.loads((a.output/'TS.observed.txt').read_text());records=(a.output/'JS.observed.txt').read_text().splitlines();assert len(records)==9 and len(ts['samples'])==8
 spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,'Health',False,256,world);assert v.normalized(json.loads(line),'Health')==world['final']
 r.update(status='JIT_DIAGNOSIS_NINE_FULL_WORLDS_PASS',fullFieldsEqual=True,driverOriginIndexSHA256=sha((src/'index.json').read_bytes()))
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r));sys.exit(0 if r['status']=='JIT_DIAGNOSIS_NINE_FULL_WORLDS_PASS' else 1)
