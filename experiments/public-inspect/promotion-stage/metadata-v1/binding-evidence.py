"""Portable byte evidence for qualified source/Node joins; no child execution."""
from pathlib import Path
import argparse,hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
SELECTED=[('positive','inspect54-metadata-source-1791417818592222565'),('witness-and-import-failure','inspect54-metadata-source-1791417654630269701'),('negative1','inspect54-metadata-source-1791417915686795545'),('negative2','inspect54-metadata-source-1791417917599823140')]
def sha(data):return hashlib.sha256(data).hexdigest()
def prepare():
 out=HERE/'binding-source-evidence-v1';assert not out.exists(),'immutable evidence destination already exists';out.mkdir();objects=out/'objects';objects.mkdir();records={};joins={}
 def add(key,path):
  data=path.read_bytes();digest=sha(data);target=objects/digest
  if not target.exists():target.write_bytes(data)
  records[key]=digest
 for role,dirname in SELECTED:
  base=ROOT/'.artifacts'/dirname;receipt=json.loads((base/'receipt.json').read_text());plan=json.loads((base/'plan.json').read_text());joins[role]={'receipt':role+'/receipt.json','plan':role+'/plan.json','status':receipt['status']}
  add(role+'/receipt.json',base/'receipt.json');add(role+'/plan.json',base/'plan.json')
  for name,digest in receipt['logs'].items():
   data=(base/name).read_bytes();assert sha(data)==digest;add(role+'/'+name,base/name)
  idx=Path(plan['sourceArchive']);add(role+'/source-archive.json',idx)
  for source,record in json.loads(idx.read_text()).items():
   obj=Path(record['object']);assert sha(obj.read_bytes())==record['sha256'];add(role+'/archived-source/'+source,obj)
 add('classification.json',HERE/'binding-classification.json')
 add('originalAPI.json',HERE/'BINDING-API-MANIFEST.json')
 add('currentAPI.json',HERE/'BINDING-API-MANIFEST-IMPORT-FIX.json')
 for path in sorted((HERE/'history-before-interned-alias').iterdir()):add('historical/'+path.name,path)
 index={'format':1,'records':records,'joins':joins,'scope':'Trustedcanonical declaration API source feasibility and6reviewerclassified refusals only. Originalpartialcohort retained, no actual grant projection/runtime/universalcallertruth/law/proof/full54. Local private environment/tool binaries excluded; source archives retain historical bytes.'}
 (out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(out);print(sha((out/'index.json').read_bytes()))
def verify():
 out=HERE/'binding-source-evidence-v1';index=json.loads((out/'index.json').read_text());records=index['records']
 def raw(key):return (out/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest,key
 for role,join in index['joins'].items():
  receipt=data(join['receipt']);plan=data(join['plan']);assert receipt['planSHA256']==sha(raw(join['plan']))
  for name,digest in receipt['logs'].items():assert sha(raw(role+'/'+name))==digest
  assert sha(raw(role+'/source-archive.json'))==plan['sourceArchiveSHA256']
  for source,record in data(role+'/source-archive.json').items():assert sha(raw(role+'/archived-source/'+source))==record['sha256']
 assert data('positive/receipt.json')['status']=='SAFE_BINDING_SOURCE_POSITIVES_PASS'
 assert data('positive/receipt.json')['commands']==[{'label':'positive','exit':0,'failure':None,'classification':'SOURCE_FEASIBILITY'}]
 original=data('witness-and-import-failure/receipt.json');assert original['status']=='INCOMPLETE';assert original['commands'][0]=={'label':'binding-witness','exit':0,'failure':None,'classification':'SOURCE_FEASIBILITY'};assert original['commands'][1]['exit']==1
 prior=data('positive/plan.json')['priorWitness'];assert prior['receiptSHA256']==sha(raw('witness-and-import-failure/receipt.json'));assert prior['planSHA256']==sha(raw('witness-and-import-failure/plan.json'))
 for role in ['negative1','negative2']:
  r=data(role+'/receipt.json');p=data(role+'/plan.json');assert r['status']=='RAW_BINDING_SOURCE_NEGATIVES_PENDING_REVIEW';assert len(r['commands'])==3
  assert all(c['exit']==1 and c['failure'] is None and c['classification']=='UNCLASSIFIED' for c in r['commands'])
  assert p['matchedPositive']['sha256']==sha(raw('positive/receipt.json'));assert p['matchedPositive']['planSHA256']==sha(raw('positive/plan.json'))
 for record in data('classification.json')['negatives']:
  key=record['cohort']+'/'+record['label']+'.stderr';assert sha(raw(key))==record['stderrSHA256'];text=raw(key).decode();assert text.count('Location:')==1;assert record['expected'] in text and record['observed'] in text
 assert len(data('classification.json')['negatives'])==6
 print('NO_CHILD_BINDING_SOURCE_EVIDENCE_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
