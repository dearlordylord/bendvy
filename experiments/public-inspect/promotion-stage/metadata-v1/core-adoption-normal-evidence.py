"""Native finite receipt verifier; no backend or probe children."""
from pathlib import Path
import argparse,hashlib,json,runpy,sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
BASES={'js':ROOT/'.artifacts/inspect54-static-backend-1791428031043314041','native':ROOT/'.artifacts/inspect54-static-backend-1791429316797949634'}
OUT=HERE/'core-adoption-normal-evidence-v1'
def sha(data):return hashlib.sha256(data).hexdigest()
def prepare():
 assert not OUT.exists();OUT.mkdir();objects=OUT/'objects';objects.mkdir();records={}
 def add(key,path):
  data=path.read_bytes();digest=sha(data);target=objects/digest
  if not target.exists():target.write_bytes(data)
  records[key]=digest
 for role,BASE in BASES.items():
  plan=json.loads((BASE/'plan.json').read_text());receipt=json.loads((BASE/'receipt.json').read_text());prep=json.loads((BASE/'prepare-receipt.json').read_text())
  for name in ['plan.json','receipt.json','prepare-receipt.json','source-inventory.json','oracle.json','tracked-source.stdout','tracked-source.stderr']:add(role+'/'+name,BASE/name)
  for name,digest in receipt['logs'].items():p=Path(receipt['logDirectory'])/name;assert sha(p.read_bytes())==digest;add(role+'/logs/'+name,p)
  for label,ledger in [('prepare-probes',prep['probePins']),('execution-probes',receipt['probePins'])]:
   for name,digest in ledger.items():p=Path(name);assert sha(p.read_bytes())==digest;add(role+'/'+label+'/'+p.name,p)
  for name,digest in receipt['generated'].items():
   p=Path(name);assert sha(p.read_bytes())==digest
   if p.suffix in ['.c','.js']:add(role+'/generated/'+p.name,p)
  for record in json.loads(Path(plan['sourceInventory']).read_text())['files']:add(role+'/stage/'+record['path'],Path(plan['stage'])/record['path'])
 add('source-milestone-index.json',HERE/'core-adoption-current-root-evidence-v1/index.json')
 index={'format':1,'records':records,'scope':'Current-root proposed generic-core full8 actual standaloneJS/Native baseline. Five freshPREP resolverprobes each with explicitprepostconfig equality, JS25/Native35executionguards; separate bounded sourceorigin Git read. No broader74/84/mutant/retention/adoption/proof/universalcanonicaltruth/full54. Nativebinary/privateenv/toolbinaries excluded hashonly; generatedJS/C retained.'};(OUT/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(sha((OUT/'index.json').read_bytes()))
def verify():
 records=json.loads((OUT/'index.json').read_text())['records']
 def raw(key):return (OUT/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest
 milestone=HERE/'core-adoption-current-root-evidence-v1/index.json';assert sha(milestone.read_bytes())==sha(raw('source-milestone-index.json'));mi=json.loads(milestone.read_text());objects=milestone.parent/'objects'
 def old(key):return (objects/mi['records'][key]).read_bytes()
 archived=json.loads(old('driver-source/source-archive.json'))
 for role in BASES:
  plan=data(role+'/plan.json');receipt=data(role+'/receipt.json');prep=data(role+'/prepare-receipt.json');inventory=data(role+'/source-inventory.json')
  assert receipt['planSHA256']==sha(raw(role+'/plan.json'));assert receipt['status']=='FULL8_STATIC_DESCRIPTOR_EMITTED_PASS';assert all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
  assert [c['seconds'] for c in plan['commands']]==([30,5] if role=='js' else [30,120,5]);assert receipt['probeCount']==(25 if role=='js' else 35);assert prep['probeCount']==5
  assert prep['configurationBefore']==prep['configurationAfter']==plan['preparationConfigurationBefore']==plan['preparationConfigurationAfter'];assert prep['configurationStable'] is True
  for name,digest in receipt['logs'].items():assert sha(raw(role+'/logs/'+name))==digest
  for name,digest in receipt['generated'].items():
   if Path(name).suffix in ['.c','.js']:assert sha(raw(role+'/generated/'+Path(name).name))==digest
   else:assert role=='native' and Path(name).suffix=='.native' and len(digest)==64
  for label,ledger in [('prepare-probes',prep['probePins']),('execution-probes',receipt['probePins'])]:
   for name,digest in ledger.items():assert sha(raw(role+'/'+label+'/'+Path(name).name))==digest
  for record in inventory['files']:assert sha(raw(role+'/stage/'+record['path']))==record['sourceSHA256']==record['stageSHA256'];assert record['origin'] in ['tracked','selected-owned']
  for name,priorRole in [('sourceJoin','driver-source'),('cliJoin','cli')]:
   join=plan['joins'][name];assert join['planSHA256']==sha(old(priorRole+'/plan.json'));assert join['receiptSHA256']==sha(old(priorRole+'/receipt.json'))
  for source,digest in plan['joins']['sourceJoin']['qualifiedClosure'].items():
   assert archived[source]['sha256']==digest;matches=[record for record in inventory['files'] if source.endswith('/'+record['path'])];assert len(matches)==1;assert matches[0]['sourceSHA256']==matches[0]['stageSHA256']==digest
  expected=(data(role+'/oracle.json')['metadata']+'\n').encode();label='static-run-js' if role=='js' else 'metadata-run-native';assert raw(role+'/logs/'+label+'.stdout')==expected==old('cli/adoption-current-root-full8-cli-io.stdout')
 assert raw('js/logs/static-run-js.stdout')==raw('native/logs/metadata-run-native.stdout')
 jsRecords={record['path']:record['sourceSHA256'] for record in data('js/source-inventory.json')['files']};nativeRecords={record['path']:record['sourceSHA256'] for record in data('native/source-inventory.json')['files']};assert jsRecords==nativeRecords
 saved=sys.argv;sys.argv=[str(HERE/'core-adoption-current-root-evidence.py')]
 try:runpy.run_path(str(HERE/'core-adoption-current-root-evidence.py'),run_name='__main__')
 finally:sys.argv=saved
 print('NO_CHILD_CURRENT_ROOT_NORMAL_BACKENDS_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
