"""Finite static descriptor evidence; verification launches no child."""
from pathlib import Path
import argparse,hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
ROLES={'unspecialized-bridge':'1791418425867402365','old-driver-base-failure':'1791418918417819611','runtime-plan-refusal':'1791419145234612012','static-match-failure':'1791419479872632589','static-positive':'1791419564000689168','driver-source':'1791419662637222273','old-cli-proposal':'1791419751933862154','cli':'1791419967763141254','matched-positive':'1791420042922977582','negative1':'1791420223050089558','negative2':'1791420224184999690'}
OUT=HERE/'binding-static-evidence-v1'
def sha(data):return hashlib.sha256(data).hexdigest()
def prepare():
 assert not OUT.exists();OUT.mkdir();objects=OUT/'objects';objects.mkdir();records={}
 def add(key,path):
  data=path.read_bytes();digest=sha(data);target=objects/digest
  if not target.exists():target.write_bytes(data)
  records[key]=digest
 for role,stamp in ROLES.items():
  base=ROOT/'.artifacts'/('inspect54-metadata-source-'+stamp);plan=json.loads((base/'plan.json').read_text());add(role+'/plan.json',base/'plan.json');index=Path(plan['sourceArchive']);add(role+'/source-archive.json',index)
  for source,record in json.loads(index.read_text()).items():
   obj=Path(record['object']);assert sha(obj.read_bytes())==record['sha256'];add(role+'/archived-source/'+source,obj)
  if (base/'receipt.json').exists():
   receipt=json.loads((base/'receipt.json').read_text());add(role+'/receipt.json',base/'receipt.json')
   for name,digest in receipt['logs'].items():assert sha((base/name).read_bytes())==digest;add(role+'/'+name,base/name)
 add('classification.json',HERE/'binding-static-classification.json');add('oracle.json',HERE/'BINDING-ALLFIELD-ORACLE.json');add('model.json',HERE/'BINDING-ALLFIELD-LITERAL-MODEL.json')
 (OUT/'index.json').write_text(json.dumps({'format':1,'records':records,'roles':ROLES,'scope':'Concrete static closed canonical descriptor source+CLI full8 and6 intended source refusals. Failed runtimePlan experiment and unspecialized import preserved with limited scope. No emittedJS/Native/mutant/proof/universal canonical truth/full54. Private environment/binaries excluded.'},indent=2)+'\n');print(sha((OUT/'index.json').read_bytes()))
def verify():
 index=json.loads((OUT/'index.json').read_text());records=index['records']
 def raw(key):return (OUT/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest,key
 for role in ROLES:
  plan=data(role+'/plan.json');assert sha(raw(role+'/source-archive.json'))==plan['sourceArchiveSHA256']
  for source,record in data(role+'/source-archive.json').items():assert sha(raw(role+'/archived-source/'+source))==record['sha256']
  if role+'/receipt.json' in records:
   receipt=data(role+'/receipt.json');assert receipt['planSHA256']==sha(raw(role+'/plan.json'))
   for name,digest in receipt['logs'].items():assert sha(raw(role+'/'+name))==digest
 for role in ['static-positive','driver-source','matched-positive','cli']:
  assert all(c['exit']==0 and c['failure'] is None for c in data(role+'/receipt.json')['commands'])
 for role in ['old-driver-base-failure','runtime-plan-refusal','static-match-failure']:assert data(role+'/receipt.json')['status']=='INCOMPLETE'
 assert 'old-cli-proposal/receipt.json' not in records
 assert data('cli/receipt.json')['status']=='FULL8_STATIC_DESCRIPTOR_CLI_IO_PASS'
 expected=data('oracle.json')['IOString'].encode();assert raw('cli/binding-static-driver-cli-io.stdout')==expected;assert data('oracle.json')['pureString']+'\n'==data('oracle.json')['IOString'];assert len(expected.decode().splitlines())==9
 join=data('cli/plan.json')['sourceJoin'];assert join['planSHA256']==sha(raw('driver-source/plan.json'));assert join['receiptSHA256']==sha(raw('driver-source/receipt.json'));assert join['sourceArchiveSHA256']==sha(raw('driver-source/source-archive.json'))
 archive=data('driver-source/source-archive.json')
 for source,digest in join['qualifiedClosure'].items():assert archive[source]['sha256']==digest;assert sha(raw('cli/archived-source/'+source))==digest
 for role in ['negative1','negative2']:
  r=data(role+'/receipt.json');assert r['status']=='RAW_NEGATIVE_REJECTIONS_PENDING_DIAGNOSTIC_REVIEW';assert all(c['exit']==1 and c['failure'] is None and c['classification']=='UNCLASSIFIED' for c in r['commands']);join=data(role+'/plan.json')['matchedPositive'];assert join['receiptSHA256']==sha(raw('matched-positive/receipt.json'));assert join['planSHA256']==sha(raw('matched-positive/plan.json'));assert join['sourceArchiveSHA256']==sha(raw('matched-positive/source-archive.json'))
 for c in data('classification.json')['negatives']:
  text=raw(c['cohort']+'/'+c['label']+'.stderr');assert sha(text)==c['stderrSHA256'];assert text.decode().count('Location:')==1;assert c['expected'] in text.decode() and c['observed'] in text.decode()
 assert len(data('classification.json')['negatives'])==6
 print('NO_CHILD_STATIC_SOURCE_CLI_CONTROLS_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
