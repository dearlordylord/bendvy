#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,sys,os,importlib.util
R=Path('/workspace/formal-proofs/bendvy');H=Path(__file__).resolve().parent
sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':10,'commands':[],'cases':[]}
def run(args,label):
 c,o=execute(list(map(str,args)),5);f=a.output/(label+'.txt');f.write_text(o);r['commands'].append({'argv':list(map(str,args)),'capSeconds':5,'exit':c,'outputSHA256':sha(f)});assert c==0,o[-1000:];return o
sp=importlib.util.spec_from_file_location('V',R/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(sp);sp.loader.exec_module(V)
try:
 for digest,pin in json.loads((H/'input-pins.json').read_text()).items():
  schema=pin['schema'];tsfile=a.output/(schema+'-reference.mjs');run([sys.executable,R/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',R/'experiments/s-integrate/measurement-samples-reference.mjs','--output',tsfile,'--schema',schema,'--batch','64'],schema+'-prepare');ts=json.loads(run(['node',tsfile],schema+'-TS'));candidate=a.output/(schema+'-candidate.js');run(['node','--expose-internals',H/'rewrite.cjs',pin['inputPath'],candidate],schema+'-derive')
  for role,program in [('parent',Path(pin['inputPath'])),('candidate',candidate)]:
   lines=[x for x in run(['node',program],schema+'-'+role).splitlines() if x.startswith('{')];assert len(lines)==65
   for line,expected in zip(lines,[ts['warmup'],*ts['samples']]):V.validate(line,schema,False,256,expected);assert V.normalized(json.loads(line),schema)==expected['final']
   r['cases'].append({'schema':schema,'role':role,'records':65,'programSHA256':sha(program)})
 r['status']='FRESH_BOTH_SCHEMAS_PARENT_CANDIDATE_FULL65_PASS'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r));sys.exit(0 if r['status'].endswith('_PASS') else 1)
