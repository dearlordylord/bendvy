#!/usr/bin/env python3
import pathlib,json,hashlib,sys,os,argparse
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':7,'commands':[],'cases':[],'scope':'Fresh emitted actual-helper full-shape/Data snapshot/pending journal witness; no public capability or universal alias proof'}
def run(argv,label):
 code,out=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'limitSeconds':5,'exit':code,'outputSHA256':sha(f)});assert code==0,out[-1000:];return out
try:
 for schema in ['motion','health']:
  logs=[]
  for role,source in [('baseline',pathlib.Path('/tmp/bendvy-cursor-descending-'+schema+'-build-v1/batch.js')),('candidate',pathlib.Path('/tmp/bendvy-unused-row-'+schema+'.js'))]:
   out=a.output/(schema+'-'+role+'.js');run(['node','--expose-internals',H/'packed-witness.cjs',source,out,schema],schema+'-'+role+'-derive');text=run(['node',out],schema+'-'+role+'-run');records=[json.loads(x) for x in text.splitlines()];assert len(records)==4 and [x['length'] for x in records]==[1,2,4,8];logs.append(text);r['cases'].append({'schema':schema,'role':role,'sourceSHA256':sha(source),'derivedSHA256':sha(out),'records':4})
  assert logs[0]==logs[1],schema
 r['status']='BOTH_SCHEMAS_FROZEN_VIEWS_FULL_ARRAYS_TRUEOLD_PENDING_PAIRS_EQUAL';r['harnessSHA256']=sha(H/'packed-witness.cjs')
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status']=='BOTH_SCHEMAS_FROZEN_VIEWS_FULL_ARRAYS_TRUEOLD_PENDING_PAIRS_EQUAL' else 1)
