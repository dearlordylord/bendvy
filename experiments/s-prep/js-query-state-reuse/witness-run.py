#!/usr/bin/env python3
import pathlib,json,hashlib,sys,os,argparse
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':10,'commands':[],'cases':[]}
def run(argv,label):
 code,out=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'outputSHA256':sha(f)});assert code==0,out[-1500:];return out
try:
 for schema in ['motion','health']:
  outputs=[]
  for role,inp in [('before',pathlib.Path('/tmp/bendvy-descending-generated-frozen-v1/'+schema+'-tuple.js')),('after',pathlib.Path('/tmp/bendvy-query-state-reuse-'+schema+'-v1.js'))]:
   out=a.output/(schema+'-'+role+'.js');run(['node','--expose-internals',H/'query-witness.cjs',inp,out],schema+'-'+role+'-derive');text=run(['node',out],schema+'-'+role+'-run');assert len(text.splitlines())==26;outputs.append(text);r['cases'].append({'schema':schema,'role':role,'inputSHA256':sha(inp),'derivedSHA256':sha(out),'records':26})
  assert outputs[0]==outputs[1]
 r.update(status='BOTH_SCHEMAS_ACTUAL_CURSOR_ORDER_SELECTION_FULL_OWNER_RETAINED_DATA_26_PASS')
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status'].endswith('26_PASS') else 1)
