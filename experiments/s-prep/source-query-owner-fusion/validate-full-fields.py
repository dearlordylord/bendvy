#!/usr/bin/env python3
"""Fresh TS full65 observed fields; no timing acceptance."""
import argparse,pathlib,json,subprocess,signal,os,hashlib,importlib.util
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--js',type=pathlib.Path,required=True);p.add_argument('--native',type=pathlib.Path);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Fresh source candidate full65 fields against independently executed pinned TS, no ratio/keep','schema':a.schema,'cpu':[8],'runtimeLimitSeconds':5,'commands':[],'candidatePins':{'JS':sha(a.js)}}
def run(args):
 v=subprocess.run(list(map(str,args)),capture_output=True,text=True,timeout=5);r['commands'].append({'argv':list(map(str,args)),'limitSeconds':5,'exit':v.returncode});assert v.returncode==0,v.stderr;return v.stdout
try:
 run(['python3',ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',a.output/'reference.mjs','--schema',a.schema,'--batch','64']);ts=run(['node',a.output/'reference.mjs']);(a.output/'TS.json').write_text(ts);observed=json.loads(ts);assert len(observed['samples'])==64
 spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
 for backend,args in [('JS',['node',a.js])]+([('Native',[a.native,'--threads','1','--gpu','off'])] if a.native else []):
  output=run(args);(a.output/(backend+'.txt')).write_text(output);lines=[x for x in output.splitlines() if x.startswith('{')];assert len(lines)==65
  for line,world in zip(lines,[observed['warmup'],*observed['samples']]):V.validate(line,a.schema,False,256,world);assert V.normalized(json.loads(line),a.schema)==world['final']
  r.setdefault('backends',{})[backend]={'records':65,'allFullFieldsEqual':True};r['candidatePins'][backend]=sha(a.js if backend=='JS' else a.native)
 r.update(status='FRESH_FULL65_FIELDS_PASS',referencePin=sha(a.output/'reference.mjs'),validatorPin=sha(ROOT/'experiments/s-integrate/measurement-bend-run.py'))
except Exception as e:r.update(status='FAILED',error=repr(e));raise
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
