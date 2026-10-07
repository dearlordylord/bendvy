"""Portable byte evidence for qualified source/Node joins; no child execution."""
from pathlib import Path
import argparse,hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
SELECTED=[('owner-witness-pass','inspect54-metadata-source-1791412829622716229'),('source-computed-failure1','inspect54-metadata-source-1791412529244790543'),('source-computed-failure2','inspect54-metadata-source-1791412800977787319'),('node-pass','inspect54-metadata-node-1791414628140882168'),('source-pass','inspect54-metadata-source-1791414910148399369'),('node-import-failure','inspect54-metadata-node-1791413772530184396'),('node-oracle-failure','inspect54-metadata-node-1791414207348716759'),('source-quantity-failure1','inspect54-metadata-source-1791414635072836135'),('source-quantity-failure2','inspect54-metadata-source-1791414884364181417')]
def sha(data):return hashlib.sha256(data).hexdigest()
def prepare():
 out=HERE/'node-source-evidence-v2';assert not out.exists(),'immutable evidence destination already exists';out.mkdir();objects=out/'objects';objects.mkdir();records={};joins={}
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
 add('oracle.json',HERE/'oracle.json')
 for path in sorted((HERE/'history-before-interned-alias').iterdir()):add('historical/'+path.name,path)
 index={'format':1,'records':records,'joins':joins,'scope':'Exact complete24 actual TS metadata/source feasibility only. No Bend runtime/backend/automatic Plan declaration coupling/law/proof/full54. Local private environment/tool binaries excluded; source archives retain historical bytes.'}
 (out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(out);print(sha((out/'index.json').read_bytes()))
def verify():
 out=HERE/'node-source-evidence-v2';index=json.loads((out/'index.json').read_text());records=index['records']
 def raw(key):return (out/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest,key
 for role,join in index['joins'].items():
  receipt=data(join['receipt']);plan=data(join['plan']);assert receipt['planSHA256']==sha(raw(join['plan']))
  for name,digest in receipt['logs'].items():assert sha(raw(role+'/'+name))==digest
  for source,record in data(role+'/source-archive.json').items():assert sha(raw(role+'/archived-source/'+source))==record['sha256']
 assert data('node-pass/receipt.json')['status']=='COMPLETE_ACTUAL_TS_METADATA_PASS'
 assert data('source-pass/receipt.json')['status']=='SAFE_SOURCE_METADATA_PASS'
 assert json.loads(raw('node-pass/actual-ts-metadata.stdout'))==data('oracle.json')['TS']
 assert len(data('oracle.json')['TS']['observations'])==24
 assert data('node-oracle-failure/receipt.json')['status']=='INCOMPLETE'
 assert data('node-import-failure/receipt.json')['status']=='INCOMPLETE'
 print('NO_CHILD_NODE_SOURCE_EVIDENCE_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
