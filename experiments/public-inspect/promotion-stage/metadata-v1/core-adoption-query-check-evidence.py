"""Finite static descriptor evidence; verification launches no child."""
from pathlib import Path
import argparse,hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
ROLES={'old-source-proposal':'1791427910014293923','source':'1791428590687026885','old-cli-proposal':'1791429163888903560','cli':'1791429196958512599'}
OUT=HERE/'core-adoption-query-check-evidence-v1'
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
 actual=json.loads((ROOT/'.artifacts/inspect54-metadata-source-1791429196958512599/plan.json').read_text());add('oracle.json',Path(actual['oracle']));add('inventory.json',HERE/'core-adoption-proposal-v1/QUERY-CHECK-STAGE-INVENTORY.json')
 (OUT/'index.json').write_text(json.dumps({'format':1,'records':records,'roles':ROLES,'scope':'Current-root copied-core actual source and CLI full74 cardinality plus full84 Check/genuine Sys/Schedule complete original oracles. Old unexecuted source/CLI proposals historical only. No emittedJSNative/mutant/retention/adoption/proof/universaltruth/full54. Privateenv/binaries excluded.'},indent=2)+'\n');print(sha((OUT/'index.json').read_bytes()))
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
 for role in ['source','cli']:assert all(c['exit']==0 and c['failure'] is None for c in data(role+'/receipt.json')['commands']) and len(data(role+'/receipt.json')['commands'])==2
 for role in ['old-source-proposal','old-cli-proposal']:assert role+'/receipt.json' not in records
 assert data('cli/receipt.json')['status']=='FULL74_84_CURRENT_ROOT_CLI_IO_PASS'
 plan=data('cli/plan.json');join=plan['sourceJoin'];assert join['planSHA256']==sha(raw('source/plan.json'));assert join['receiptSHA256']==sha(raw('source/receipt.json'));assert join['sourceArchiveSHA256']==sha(raw('source/source-archive.json'))
 archive=data('source/source-archive.json');cliArchive=data('cli/source-archive.json')
 for source,digest in join['qualifiedClosure'].items():assert archive[source]['sha256']==cliArchive[source]['sha256']==digest
 oracle=data('oracle.json')
 for name,count in [('cardinality',74),('check',84)]:
  expected=oracle[name].encode();label='adoption-'+name+'-io-main-cli-io';assert raw('cli/'+label+'.stdout')==expected;observed=data('cli/receipt.json')['oracleResults'][name];assert observed['actualSHA256']==observed['expectedSHA256']==sha(expected);assert observed['records']==count and observed['exactIOFinalLF'] is True
 inventory=data('inventory.json')
 for key,record in inventory['files'].items():
  candidates=[source for source in cliArchive if source.endswith('/query-check-stage-v1/'+key)];assert len(candidates)==1;assert cliArchive[candidates[0]]['sha256']==record['stageSHA256']
  if record['source'].startswith('/workspace/formal-proofs/bendvy/src/'):assert cliArchive[record['source']]['sha256']==record['sourceSHA256']==record['stageSHA256']
 print('NO_CHILD_CURRENT_ROOT_QUERY_CHECK_CLI_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
