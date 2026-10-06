#!/usr/bin/env python3
import pathlib,json,hashlib,sys,os,argparse
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','commands':[],'cases':[],'cpu':7,'scope':'Fresh finite actual emitted-helper immutable views/fullarrays/trueold plus secondstage order controls, not universal ownership proof'}
def run(argv,label):
 code,out=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'outputSHA256':sha(f)});assert code==0,out[-1000:];return out
try:
 for family in ['query','packed']:
  for schema in ['motion','health']:
   source=pathlib.Path('/tmp/bendvy-'+('direct-tuple-' if family=='query' else 'packed-paired-')+schema+'-nested.js');target=a.output/(family+'-'+schema+'.js');harness=H.parent.parent/'js-direct-tuple-fusion/snapshot-witness.cjs' if family=='query' else H.parent/'packed-witness.cjs';run(['node','--expose-internals',harness,source,target,schema],family+'-'+schema+'-derive');out=run(['node',target],family+'-'+schema+'-run');records=[json.loads(x) for x in out.splitlines()];assert len(records)==(1 if family=='query' else 4);r['cases'].append({'family':family,'schema':schema,'programSHA256':sha(source),'harnessSHA256':sha(harness),'derivedSHA256':sha(target),'records':len(records)})
 controls=a.output/'guard-controls.json';run(['node','--expose-internals',H/'guard-controls.cjs',controls],'order-guards');r['controlsSHA256']=sha(controls);r['status']='BOTH_FAMILIES_NESTED_FROZEN_VIEWS_TRUEOLD_ORDER_CONTROLS_PASS'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status']=='BOTH_FAMILIES_NESTED_FROZEN_VIEWS_TRUEOLD_ORDER_CONTROLS_PASS' else 1)
