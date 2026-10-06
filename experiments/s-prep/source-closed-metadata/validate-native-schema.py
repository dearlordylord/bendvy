#!/usr/bin/env python3
"""Finite full65 semantic observation only; emitted clocks are not measurements."""
import argparse,hashlib,importlib.util,json,os,pathlib,sys
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--binary',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9})
root=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(root/'experiments/s-prep/fivehour-connected-gates'));import supervisor
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Finite full65 schema fields only; no elapsed qualification or universal refinement','schema':a.schema,'cpu':9,'commands':[],'binarySHA256':sha(a.binary),'runnerSHA256':sha(pathlib.Path(__file__))}
def run(argv,name):
 code,out=supervisor.execute([str(x) for x in argv],5);(a.output/(name+'.txt')).write_text(out);r['commands'].append({'argv':[str(x) for x in argv],'capSeconds':5,'exit':code,'outputSHA256':sha(a.output/(name+'.txt'))});assert code==0,out[-1000:];return out
try:
 reference=a.output/'reference.mjs';source=root/'experiments/s-integrate/measurement-samples-reference.mjs'
 run([sys.executable,root/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',source,'--output',reference,'--schema',a.schema,'--batch','64'],'prepare')
 ts=json.loads(run(['node',reference],'ts'));native=run([a.binary,'--threads','1','--gpu','off'],'native');records=[x for x in native.splitlines() if x.startswith('{')];assert len(records)==65
 spec=importlib.util.spec_from_file_location('validator',root/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 assert ts['schema']==a.schema and ts['count']==256 and ts['iterations']==64 and len(ts['samples'])==64
 for record,expected in zip(records,[ts['warmup'],*ts['samples']]):
  v.validate(record,a.schema,False,256,expected);assert v.normalized(json.loads(record),a.schema)==expected['final']
 r.update(status='PASS_FULL65',allFullFieldsEqual=True,worlds=65,referenceSourceSHA256=sha(source),referenceSHA256=sha(reference),validatorSHA256=sha(root/'experiments/s-integrate/measurement-bend-run.py'))
except Exception as e:r['error']=repr(e)
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r));sys.exit(0 if r['status']=='PASS_FULL65' else 1)
