"""Portable byte evidence for qualified source/Node joins; no child execution."""
from pathlib import Path
import argparse,hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
SELECTED=[('js-pass','inspect54-metadata-source-1791415205359920193'),('controls-raw','inspect54-metadata-source-1791415207023352822'),('source-pass','inspect54-metadata-source-1791414910148399369'),('node-pass','inspect54-metadata-node-1791414628140882168')]
def sha(data):return hashlib.sha256(data).hexdigest()
def prepare():
 out=HERE/'js-static-evidence-v1';assert not out.exists(),'immutable evidence destination already exists';out.mkdir();objects=out/'objects';objects.mkdir();records={};joins={}
 def add(key,path):
  data=path.read_bytes();digest=sha(data);target=objects/digest
  if not target.exists():target.write_bytes(data)
  records[key]=digest
 for role,dirname in SELECTED:
  base=ROOT/'.artifacts'/dirname;receipt=json.loads((base/'receipt.json').read_text());plan=json.loads((base/'plan.json').read_text());joins[role]={'receipt':role+'/receipt.json','plan':role+'/plan.json','status':receipt['status']}
  add(role+'/receipt.json',base/'receipt.json');add(role+'/plan.json',base/'plan.json')
  for name,digest in receipt['logs'].items():
   data=(base/name).read_bytes();assert sha(data)==digest;add(role+'/'+name,base/name)
  for file,digest in receipt.get('generated',{}).items():
   f=Path(file);assert sha(f.read_bytes())==digest;add(role+'/generated/'+f.name,f)
  idx=Path(plan['sourceArchive']);add(role+'/source-archive.json',idx)
  for source,record in json.loads(idx.read_text()).items():
   obj=Path(record['object']);assert sha(obj.read_bytes())==record['sha256'];add(role+'/archived-source/'+source,obj)
 add('oracle.json',HERE/'oracle.json')
 add('classification.json',HERE/'static-classification.json')
 for path in sorted((HERE/'history-before-interned-alias').iterdir()):add('historical/'+path.name,path)
 index={'format':1,'records':records,'joins':joins,'scope':'Full24 standaloneJS metadata/actualArray cells and reviewer-classified source controls only. No Native/automatic Plan declaration coupling/law/proof/full54. Local private environment/tool binaries excluded; source archives retain historical bytes.'}
 (out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(out);print(sha((out/'index.json').read_bytes()))
def verify():
 out=HERE/'js-static-evidence-v1';index=json.loads((out/'index.json').read_text());records=index['records']
 def raw(key):return (out/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest,key
 for role,join in index['joins'].items():
  receipt=data(join['receipt']);plan=data(join['plan']);assert receipt['planSHA256']==sha(raw(join['plan']))
  for name,digest in receipt['logs'].items():assert sha(raw(role+'/'+name))==digest
  for file,digest in receipt.get('generated',{}).items():assert sha(raw(role+'/generated/'+Path(file).name))==digest
  for source,record in data(role+'/source-archive.json').items():assert sha(raw(role+'/archived-source/'+source))==record['sha256']
 assert data('node-pass/receipt.json')['status']=='COMPLETE_ACTUAL_TS_METADATA_PASS'
 assert data('source-pass/receipt.json')['status']=='SAFE_SOURCE_METADATA_PASS'
 assert json.loads(raw('node-pass/actual-ts-metadata.stdout'))==data('oracle.json')['TS']
 assert len(data('oracle.json')['TS']['observations'])==24
 assert data('js-pass/receipt.json')['status']=='COMPLETE_METADATA_JS_DEVELOPMENT_PASS'
 assert raw('js-pass/metadata-run-js.stdout')==data('oracle.json')['BendIOStringWithExactLF'].encode()
 assert data('controls-raw/receipt.json')['status']=='RAW_STATIC_METADATA_CONTROLS_PENDING_DIAGNOSTIC_REVIEW'
 for record in data('classification.json')['negatives']:
  assert sha(raw('controls-raw/'+record['label']+'.stderr'))==record['stderrSHA256']
  assert record['expected'] in raw('controls-raw/'+record['label']+'.stderr').decode()
  assert record['observed'] in raw('controls-raw/'+record['label']+'.stderr').decode()
 print('NO_CHILD_JS_STATIC_METADATA_EVIDENCE_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
