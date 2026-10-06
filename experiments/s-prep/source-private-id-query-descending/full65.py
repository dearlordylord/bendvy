#!/usr/bin/env python3
"""Fresh semantic full65 oracle, descriptive driver clocks are not accepted measurements."""
import pathlib,sys,json,hashlib,argparse,importlib.util,os
ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
from pins import verify
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--build',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--overlay',type=pathlib.Path,default=pathlib.Path('/tmp/bendvy-private-id-query-descending-v1'));a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});_,pins,closure=verify(a.overlay);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Fresh finite actual source JS/Native full65 semantics, no speed qualification','closure':closure,'source29':pins,'commands':[]}
def run(role,argv):
 code,out=supervisor.execute(list(map(str,argv)),5);path=a.output/(role+'.txt');path.write_text(out);r['commands'].append({'role':role,'argv':list(map(str,argv)),'limitSeconds':5,'exit':code,'outputSHA256':sha(path)});assert code==0,out[-1000:];return out
try:
 build=json.loads((a.build/'build.json').read_text());assert build['status']=='BUILD_PASS' and build['sourcePins']==pins and all(sha(a.build/n)==v for n,v in build['artifacts'].items());r['buildSHA256']=sha(a.build/'build.json')
 reference=a.output/'reference.mjs';source=ROOT/'experiments/s-integrate/measurement-samples-reference.mjs';run('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',source,'--output',reference,'--schema',a.schema,'--batch','64']);ts=json.loads(run('TS',['node',reference]));r['oraclePins']={'sourceSHA256':sha(source),'derivedSHA256':sha(reference)}
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 for role,argv in [('JS',['node',a.build/'batch.js']),('Native',[a.build/'batch-native','--threads','1','--gpu','off'])]:
  out=run(role,argv);records=[x for x in out.splitlines() if x.startswith('{')];assert len(records)==65
  for line,expected in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,a.schema,False,256,expected);assert v.normalized(json.loads(line),a.schema)==expected['final']
 r['status']='SOURCE_BOUND_JS_NATIVE_FULL65_ALL_FIELDS_PASS'
except BaseException as e:r['failure']=repr(e);raise
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
