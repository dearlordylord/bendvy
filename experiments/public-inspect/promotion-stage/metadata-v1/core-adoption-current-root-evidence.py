"""Finite static descriptor evidence; verification launches no child."""
from pathlib import Path
import argparse,hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
ROLES={'older-worker-positive':'1791426164318821101','older-worker-matched':'1791426296658501239','current-positive':'1791426674935743153','driver-source':'1791426905398043844','cli':'1791427564887666065','negative1':'1791426869281843764','negative2':'1791426871627761983'}
OUT=HERE/'core-adoption-current-root-evidence-v1'
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
 add('classification.json',HERE/'core-adoption-current-root-classification.json');add('oracle.json',HERE/'BINDING-ALLFIELD-ORACLE.json');add('model.json',HERE/'BINDING-ALLFIELD-LITERAL-MODEL.json')
 (OUT/'index.json').write_text(json.dumps({'format':1,'records':records,'roles':ROLES,'scope':'Current-root copied-core generic State source+actualCLI full8 and six independently classified source refusals. Older worker-byte positives preserved as historical provenance only. Seven production drafts unadopted; query/check74/84 and standaloneJSNative/mutants/retention fresh gates remain. No proof/universal canonical truth/full54. Private environment/binaries excluded.'},indent=2)+'\n');print(sha((OUT/'index.json').read_bytes()))
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
 for role in ['older-worker-positive','older-worker-matched','current-positive','driver-source','cli']:
  assert all(c['exit']==0 and c['failure'] is None for c in data(role+'/receipt.json')['commands'])
 assert data('cli/receipt.json')['status']=='FULL8_CURRENT_ROOT_CORE_CLI_IO_PASS'
 expected=data('oracle.json')['IOString'].encode();assert raw('cli/adoption-current-root-full8-cli-io.stdout')==expected;assert data('oracle.json')['pureString']+'\n'==data('oracle.json')['IOString'];assert len(expected.decode().splitlines())==9
 join=data('cli/plan.json')['sourceJoin'];assert join['planSHA256']==sha(raw('driver-source/plan.json'));assert join['receiptSHA256']==sha(raw('driver-source/receipt.json'));assert join['sourceArchiveSHA256']==sha(raw('driver-source/source-archive.json'))
 archive=data('driver-source/source-archive.json')
 for source,digest in join['qualifiedClosure'].items():assert archive[source]['sha256']==digest;assert sha(raw('cli/archived-source/'+source))==digest
 for role in ['negative1','negative2']:
  r=data(role+'/receipt.json');assert r['status']=='RAW_NEGATIVE_REJECTIONS_PENDING_DIAGNOSTIC_REVIEW';assert all(c['exit']==1 and c['failure'] is None and c['classification']=='UNCLASSIFIED' for c in r['commands']);join=data(role+'/plan.json')['matchedPositive'];assert join['receiptSHA256']==sha(raw('current-positive/receipt.json'));assert join['planSHA256']==sha(raw('current-positive/plan.json'));assert join['sourceArchiveSHA256']==sha(raw('current-positive/source-archive.json'))
 for role in ['negative1','negative2']:
  join=data(role+'/plan.json')['matchedPositive'];positiveArchive=data('current-positive/source-archive.json');negativeArchive=data(role+'/source-archive.json')
  for source,digest in join['qualifiedClosure'].items():assert positiveArchive[source]['sha256']==negativeArchive[source]['sha256']==digest
 for c in data('classification.json')['negatives']:
  text=raw(c['cohort']+'/'+c['label']+'.stderr');assert sha(text)==c['stderrSHA256'];assert text.decode().count('Location:')==1;assert c['expected'] in text.decode() and c['observed'] in text.decode()
 assert len(data('classification.json')['negatives'])==6
 archive=data('driver-source/source-archive.json')
 joins=[source for source in archive if source.endswith('/core-adoption-proposal-v1/CURRENT-ROOT-DEPENDENCY-JOIN.json')];assert len(joins)==1
 dependencyJoin=json.loads(raw('driver-source/archived-source/'+joins[0]));assert len(dependencyJoin['productionDependencies'])==13
 for record in dependencyJoin['productionDependencies']:
  actual=record['currentRootPath'];copied=[source for source in archive if source.endswith('/current-root-stage-v2/'+record['path'])];assert len(copied)==1
  assert archive[actual]['sha256']==archive[copied[0]]['sha256']==record['currentRootSHA256']==record['stageSHA256']
 for c in data('classification.json')['negatives']:
  text=raw(c['cohort']+'/'+c['label']+'.stderr').decode();assert 'Location: '+c['location'] in text;assert str(c['line'])+'>|' in text
 print('NO_CHILD_CURRENT_ROOT_SOURCE_CLI_CONTROLS_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
