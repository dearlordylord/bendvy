"""Read-only exact current caller Native A/B reconciliation; no subprocesses."""
import argparse,base64,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def decode(x):
 if isinstance(x,dict):return base64.b64decode(x['rawBase64']) if set(x)=={'rawBase64'} else {k:decode(v) for k,v in x.items()}
 if isinstance(x,list):return [decode(v) for v in x]
 return x
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def configs(out,stage):
 paths=set()
 for root in [ROOT,Path.cwd(),out,stage,stage/'src/ecs',stage/'experiments/public-machine-handlers/candidate-v1',*[p.parent for p in stage.rglob('*.bend')]]:
  for parent in [root,*root.parents]:
   for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:paths.add(parent/name)
 for name in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json']:paths.add(Path('/home/node/.bend')/name)
 return {str(p):sha(p) if p.is_file() else None for p in paths}
def complete_oracle(raw,p):
 def pairs(items):
  d={}
  for k,value in items:
   assert k not in d,'duplicate JSON key';d[k]=value
  return d
 expected=json.loads(Path(p['oracle']).read_text())['rows'];keys=[k for k in expected if k.startswith(p['schema']+'_')]
 rows=raw.decode().splitlines();assert len(rows)==len(keys)==7
 observed={}
 for key,line in zip(keys,rows):
  name,body=line.split('|',1);assert name==key
  value=json.loads(body,object_pairs_hook=pairs,parse_constant=lambda x: (_ for _ in ()).throw(ValueError(x)))
  assert json.dumps(value,sort_keys=True,separators=(',',':'))==json.dumps(expected[key],sort_keys=True,separators=(',',':')),'complete JSON oracle mismatch: '+key
  observed[key]=value
 return observed

def qualify(directory,schema):
 plan=directory/'plan.json';receipt=directory/'receipt.json'
 assert sha(plan)=={'A':'0e0284fc04506f9b5b25d35fd669b250ddb4596873dcd097aab86a83f7418a35','B':'825d0c2f90f2df2bd014a73f29da5e41ae05259213e2315dc17e98f3716147ac'}[schema]
 p=decode(json.loads(plan.read_text()));r=json.loads(receipt.read_text())
 assert p['schema']==schema and r['status']=='CAPABILITY_CALLER_SCHEMA_'+schema+'_SEVEN_COMPLETE_NATIVE_OBSERVATIONS_PASS'
 assert r['planSHA256']==sha(plan)
 assert all(sha(f)==h for f,h in p['pins'].items())
 assert inventory(Path(p['stage']))==p['inventory'] and configs(directory,Path(p['stage']))==p['configurationStates']
 assert sha(p['privateEnvironment'])==p['environmentSHA256']
 labels=[c['label'] for c in p['commands']]
 assert set(r['logs'])=={label+'.'+ext for label in labels for ext in ['stdout','stderr']}
 assert all(sha(directory/n)==h for n,h in r['logs'].items())
 expectedProbes={str(directory/'execution-probes'/(label+'.'+ext)) for label in p['executionProbeLabels'] for ext in ['json','stdout','stderr']}
 assert set(r['probePins'])==expectedProbes
 assert {str(f) for f in (directory/'execution-probes').iterdir()}==expectedProbes
 assert all(sha(f)==h for f,h in r['probePins'].items())
 assert r['probeCommandsExecuted']==len(p['executionProbeLabels'])
 assert len(r['commands'])==len(p['commands'])
 for c,result in zip(p['commands'],r['commands']):
  assert result['exit']==0 and result['failure'] is None
  assert not (directory/(c['label']+'.stderr')).read_bytes()
 assert set(r['generated'])=={c['generated'] for c in p['commands'] if c.get('generated')}
 assert all(sha(f)==h for f,h in r['generated'].items())
 allowed={'plan.json','receipt.json','private-environment.json','stage','execution-probes',*r['logs'],*[Path(f).name for f in r['generated']]}
 assert {f.name for f in directory.iterdir()}==allowed
 raw=(directory/('caller-'+schema+'-run.stdout')).read_bytes();rows=complete_oracle(raw,p)
 assert rows==r['observations']
 return p,r,raw,rows
parser=argparse.ArgumentParser();parser.add_argument('--output',required=True);args=parser.parse_args()
a=HERE/'native-runtime-A-1791433304208921455';b=HERE/'native-runtime-B-1791433305186823405'
pa,ra,rawa,rowsa=qualify(a,'A');pb,rb,rawb,rowsb=qualify(b,'B')
assert pa['tools']==pb['tools'] and pa['environmentSHA256']==pb['environmentSHA256']
assert pa['oracle']==pb['oracle'] and sha(pa['oracle'])==pa['pins'][pa['oracle']]==pb['pins'][pb['oracle']]
expected=json.loads(Path(pa['oracle']).read_text())['rows'];observed={**rowsa,**rowsb}
assert len(observed)==14 and set(observed)==set(expected)
assert list(observed)==[k for schema in ['A','B'] for k in expected if k.startswith(schema+'_')]
assert json.dumps(observed,sort_keys=True,separators=(',',':'))==json.dumps(expected,sort_keys=True,separators=(',',':'))
out=Path(args.output);assert not out.exists();out.mkdir();(out/'full14.stdout').write_bytes(rawa+rawb)
result={'status':'CURRENT_CALLER_FOURTEEN_COMPLETE_NATIVE_OBSERVATIONS_RECONCILED','sourcePlans':{str(d/'plan.json'):sha(d/'plan.json') for d in [a,b]},'sourceReceipts':{str(d/'receipt.json'):sha(d/'receipt.json') for d in [a,b]},'fullRawSHA256':sha(out/'full14.stdout'),'oracleSHA256':sha(pa['oracle']),'observations':observed,'proofCredit':False,'completeIssue49':False,'adoptionCredit':False}
(out/'receipt.json').write_text(json.dumps(result,indent=2)+'\n');print(out/'receipt.json');print(sha(out/'receipt.json'))
