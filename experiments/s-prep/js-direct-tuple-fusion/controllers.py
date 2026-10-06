#!/usr/bin/env python3
import argparse,json,pathlib,hashlib,os,sys
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':7,'scope':'Fresh exact current-source generated-JS full72 observations; no inherited mutation/authority acceptance','commands':[],'cases':[],'catalogSHA256':sha(H/'input-pins.json')}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,label):
 code,out=execute(list(map(str,argv)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'capSeconds':5,'exit':code,'outputSHA256':sha(f)});save();assert code==0,out[-1000:];return out
try:
 catalog=json.loads((H/'input-pins.json').read_text())
 for digest,pin in catalog.items():
  if 'getter' not in pin:continue
  source=pathlib.Path(pin['inputPath']);assert sha(source)==digest;label=source.stem;target=a.output/(label+'.js');run(['node','--expose-internals',H/'rewrite.cjs',source,target],label+'-rewrite')
  before=run(['node',source],label+'-before');after=run(['node',target],label+'-after');records=[json.loads(x) for x in before.splitlines()];assert len(records)==72 and before==after
  stored=source.with_name(label+'-rewritten.txt');assert stored.read_text()==before
  r['cases'].append({'label':label,'inputSHA256':digest,'outputSHA256':sha(target),'recipeSHA256':sha(pathlib.Path(str(target)+'.recipe.json')),'records':72,'storedCurrentInputCompared':True});save()
 assert len(r['cases'])==8;r.update(status='ALL_EIGHT_FRESH_CONTROLLERS_576_FULL_RECORDS_EQUAL',records=576)
except Exception as e:r.update(status='FAILED',error=repr(e))
save();print(json.dumps({'status':r['status'],'cases':len(r['cases']),'error':r.get('error')}));sys.exit(0 if r['status']=='ALL_EIGHT_FRESH_CONTROLLERS_576_FULL_RECORDS_EQUAL' else 1)
