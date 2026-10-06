#!/usr/bin/env python3
from pathlib import Path
import json,sys,os,argparse,hashlib
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','commands':[],'cases':[],'scope':'Trusted emitted private Fold helper finite witness, not public construction or universal alias refinement'}
def run(args,label):
 code,out=execute(list(map(str,args)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,args)),'cap':5,'exit':code,'outputSHA':sha(f)});assert code==0,out[-1500:];return out
try:
 for schema in ['motion','health']:
  logs=[]
  for role,program in [('parent',Path('/tmp/bendvy-descending-generated-frozen-v1')/(schema+'-tuple.js')),('candidate',(Path('/tmp/bendvy-restore-envelope-frozen-v1')/(schema+'.js')))]:
   derived=a.output/(schema+'-'+role+'.js');run(['node','--expose-internals',H/'exception-witness.cjs',program,derived,schema],schema+'-'+role+'-derive');out=run(['node',derived],schema+'-'+role+'-run');records=[json.loads(x) for x in out.splitlines()];assert len(records)==len({x['stage'] for x in records});logs.append(sorted(records,key=lambda x:x['stage']));r['cases'].append({'schema':schema,'role':role,'programSHA':sha(program),'derivedSHA':sha(derived),'records':len(records)})
  assert logs[0]==logs[1],schema
 r['status']='BOTH_SCHEMAS_CONSTRUCTOR_PUBLICATION_FLUSH_BOUNDARY_RECORDS_PASS'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status'].endswith('_PASS') else 1)
