#!/usr/bin/env python3
"""Quiet fresh Health reference, warmup plus eight complete worlds, runtime5."""
import argparse,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--generated-js',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();os.sched_setaffinity(0,{9});a.output.mkdir(exist_ok=False)
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
r={'status':'INCOMPLETE','schema':'Health','cpu':9,'runtimeLimitSeconds':5,'inputSHA256':sha(a.generated_js),'commands':[]}
def command(args):
 code,text=supervisor.execute(list(map(str,args)),5);r['commands'].append({'argv':list(map(str,args)),'exit':code,'limitSeconds':5});assert code==0,text[-1000:];return text
try:
 js=a.generated_js.read_text();old='return $health_batch$(256, 64);';assert js.count(old)==1;js=js.replace(old,'return $health_batch$(256, 8);',1);(a.output/'candidate.js').write_text(js)
 command([sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',a.output/'reference.mjs','--schema','Health','--batch','8'])
 outputs={}
 for role,file in [('TS','reference.mjs'),('JS','candidate.js')]:
  text=command(['node',a.output/file]);(a.output/(role+'.raw.txt')).write_text(text);outputs[role]=text
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
 ts=json.loads(outputs['TS']);records=[x for x in outputs['JS'].splitlines() if x.startswith('{')];assert len(records)==9 and len(ts['samples'])==8
 for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,'Health',False,256,world);assert V.normalized(json.loads(line),'Health')==world['final']
 r.update(status='NINE_FULL_HEALTH_WORLDS_PASS',allFullFieldsEqual=True,derivedPins={f:sha(a.output/f) for f in ['candidate.js','reference.mjs']},runnerPins={str(q):sha(q) for q in [Path(__file__),ROOT/'experiments/s-integrate/measurement-bend-run.py',ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py',ROOT/'experiments/s-prep/fivehour-connected-gates/supervisor.py']})
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r));sys.exit(0 if r['status']=='NINE_FULL_HEALTH_WORLDS_PASS' else 1)
