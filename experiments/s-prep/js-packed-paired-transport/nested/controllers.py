#!/usr/bin/env python3
import pathlib,json,hashlib,sys,os,argparse
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':7,'scope':'Fresh secondstage generated-JS exact current-source controller observations; no inherited gate or alias/refinement proof','commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,label):
 code,out=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'outputSHA256':sha(f)});save();assert code==0,out[-1000:];return out
try:
 catalog=json.loads((H/'input-pins.json').read_text());counts={'query':0,'packed':0}
 for digest,pin in catalog.items():
  if pin['mode'] in ['normal','motion','health']:continue
  label=pin['family']+'-'+pin['mode'];inp=pathlib.Path(pin['inputPath']);assert sha(inp)==digest;out=a.output/(label+'.js');run(['node','--expose-internals',H/'rewrite.cjs',inp,out],label+'-derive');before=run(['node',inp],label+'-before');after=run(['node',out],label+'-after');records=[json.loads(x) for x in before.splitlines()];assert len(records)==72 and before==after;counts[pin['family']]+=72;r['cases'].append({'label':label,'family':pin['family'],'schema':pin['schema'],'firststageSHA256':digest,'nestedSHA256':sha(out),'records':72});save()
 assert counts=={'query':576,'packed':576};r.update(status='BOTH_SOURCE_FAMILIES_FRESH_NESTED_CONTROLLERS_1152_RECORDS_EQUAL',records=counts)
except Exception as e:r.update(status='FAILED',error=repr(e))
save();print(json.dumps({'status':r['status'],'cases':len(r['cases']),'error':r.get('error')}));sys.exit(0 if r['status']=='BOTH_SOURCE_FAMILIES_FRESH_NESTED_CONTROLLERS_1152_RECORDS_EQUAL' else 1)
