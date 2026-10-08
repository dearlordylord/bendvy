"""Finite complete reached-control evidence; default verifier launches no child."""
from pathlib import Path
import argparse,hashlib,json,runpy,sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
OUT=HERE/'binding-static-mutant-evidence-v2'
ROLES={'pure':'.artifacts/inspect54-metadata-source-1791424266679681999','cli':'.artifacts/inspect54-static-mutant-cli-1791424729771627281','js':'.artifacts/inspect54-static-mutant-js-1791425114088101873','native':'.artifacts/inspect54-static-mutant-native-1791425115667779854'}
HISTORY={'cli-unjoined':'.artifacts/inspect54-static-mutant-cli-1791424489500160052','js-unjoined':'.artifacts/inspect54-static-mutant-js-1791424870302982213','native-unjoined':'.artifacts/inspect54-static-mutant-native-1791424871447837195','js-finally-incomplete':'.artifacts/inspect54-static-mutant-js-1791425032293177146','native-finally-incomplete':'.artifacts/inspect54-static-mutant-native-1791425034242935619'}
def sha(data):return hashlib.sha256(data).hexdigest()
def prepare():
 assert not OUT.exists();OUT.mkdir();objects=OUT/'objects';objects.mkdir();records={}
 def add(key,path):
  data=path.read_bytes();digest=sha(data);target=objects/digest
  if not target.exists():target.write_bytes(data)
  records[key]=digest
 for role,path in ROLES.items():
  base=ROOT/path;plan=json.loads((base/'plan.json').read_text());receipt=json.loads((base/'receipt.json').read_text());add(role+'/plan.json',base/'plan.json');add(role+'/receipt.json',base/'receipt.json')
  wrapper=HERE/('binding-static-mutants.py' if role=='pure' else 'binding-static-mutant-cli.py' if role=='cli' else 'binding-static-mutant-backend.py');assert sha(wrapper.read_bytes())==plan['inputs'][str(wrapper)];add(role+'/actual-wrapper.py',wrapper)
  logroot=Path(receipt.get('logDirectory',base))
  for name,digest in receipt['logs'].items():assert sha((logroot/name).read_bytes())==digest;add(role+'/logs/'+name,logroot/name)
  if role in ['js','native']:
   add(role+'/source-inventory.json',Path(plan['sourceInventory']));add(role+'/oracle.json',Path(plan['oracle']))
   for file,digest in plan['inventory'].items():assert sha((Path(plan['stage'])/file).read_bytes())==digest;add(role+'/stage/'+file,Path(plan['stage'])/file)
   for file,digest in receipt['generated'].items():
    p=Path(file);assert sha(p.read_bytes())==digest
    if p.suffix!='.native':add(role+'/generated/'+p.name,p)
   for file,digest in receipt['probePins'].items():p=Path(file);assert sha(p.read_bytes())==digest;add(role+'/execution-probes/'+p.name,p)
   reuse=plan['snapshotReuse'];add(role+'/snapshot-prepare-receipt.json',Path(reuse['prepareReceipt']))
   for file,digest in reuse['prepareProbePins'].items():p=Path(file);assert sha(p.read_bytes())==digest;add(role+'/snapshot-prepare-probes/'+p.name,p)
  elif role=='pure':
   add(role+'/source-archive.json',Path(plan['sourceArchive']))
   for source,record in json.loads(Path(plan['sourceArchive']).read_text()).items():add(role+'/archived-source/'+source,Path(record['object']))
   for mutation in plan['mutations']:
    add(role+'/'+mutation['name']+'-inventory.json',Path(mutation['inventory']))
    for record in json.loads(Path(mutation['inventory']).read_text()):add(role+'/'+mutation['name']+'/stage/'+record['path'],Path(mutation['stage'])/record['path'])
 for role,path in HISTORY.items():
  base=ROOT/path;assert not (base/'receipt.json').exists();add('history/'+role+'/plan.json',base/'plan.json');add('history/'+role+'/wrapper.py',base/'unexecuted-wrapper.py' if role!='cli-unjoined' else base/'unexecuted-runner.py')
 add('provisional-v1-index.json',HERE/'binding-static-mutant-evidence-v1/index.json')
 for name in ['BINDING-STATIC-BACKEND-MUTANT-PROPOSAL.json','BINDING-ALLFIELD-ORACLE.json']:add(name,HERE/name)
 for name in ['binding-static-js-evidence-v1','binding-static-native-evidence-v1']:add(name+'/index.json',HERE/name/'index.json')
 index={'format':1,'records':records,'roles':ROLES,'history':HISTORY,'scope':'Two actual compiling and reached closed canonical descriptor defects, complete8 independent literal outputs across CLI/standaloneJS/Native. Lens4projection/order8metadata semanticrows; every other fullowner/resource/worldInstance field retained. Nativebinary/privateenv/toolbinaries excluded hashonly. No proof/universalcanonicaltruth/full54/policy adoption.'};(OUT/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(sha((OUT/'index.json').read_bytes()))
def verify():
 index=json.loads((OUT/'index.json').read_text());records=index['records']
 def raw(key):return (OUT/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest
 base=data('BINDING-ALLFIELD-ORACLE.json')['IOString'];models={m['name']:m for m in data('BINDING-STATIC-BACKEND-MUTANT-PROPOSAL.json')['mutants']}
 for role in ROLES:
  p=data(role+'/plan.json');r=data(role+'/receipt.json');assert r['planSHA256']==sha(raw(role+'/plan.json'));assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
  for name,digest in r['logs'].items():assert sha(raw(role+'/logs/'+name))==digest
  suffix='binding-static-mutants.py' if role=='pure' else 'binding-static-mutant-cli.py' if role=='cli' else 'binding-static-mutant-backend.py';matches=[digest for name,digest in p['inputs'].items() if name.endswith('/'+suffix)];assert matches==[sha(raw(role+'/actual-wrapper.py'))]
 assert data('pure/receipt.json')['status']=='SAFE_SOURCE_METADATA_PASS'
 for mutation in data('pure/plan.json')['mutations']:
  name=mutation['name'];assert sha(raw('pure/'+name+'-inventory.json'))==mutation['inventorySHA256']
  for record in data('pure/'+name+'-inventory.json'):assert sha(raw('pure/'+name+'/stage/'+record['path']))==record['stageSHA256']
 assert data('cli/receipt.json')['status']=='FULL8_STATIC_MUTANT_CLI_IO_REACHED_PASS'
 assert data('cli/plan.json')['sourceJoin']['planSHA256']==sha(raw('pure/plan.json'));assert data('cli/plan.json')['sourceJoin']['receiptSHA256']==sha(raw('pure/receipt.json'))
 for role,probes,caps in [('js',45,[30,5,30,5]),('native',65,[30,120,5,30,120,5])]:
  p=data(role+'/plan.json');r=data(role+'/receipt.json');assert r['status']=='FULL8_STATIC_MUTANT_EMITTED_REACHED_PASS';assert r['probeCount']==probes and [c['seconds'] for c in p['commands']]==caps
  assert p['joins']['CLI']['planSHA256']==sha(raw('cli/plan.json'));assert p['joins']['CLI']['receiptSHA256']==sha(raw('cli/receipt.json'));assert p['joins']['source']['planSHA256']==sha(raw('pure/plan.json'))
  for name,digest in r['generated'].items():
   if Path(name).suffix=='.native':assert len(digest)==64
   else:assert sha(raw(role+'/generated/'+Path(name).name))==digest
  for name,digest in r['probePins'].items():assert sha(raw(role+'/execution-probes/'+Path(name).name))==digest
  reuse=p['snapshotReuse'];assert reuse['prepareReceiptSHA256']==sha(raw(role+'/snapshot-prepare-receipt.json'));prep=data(role+'/snapshot-prepare-receipt.json');assert prep['probeCount']==5 and prep['configurationStable'] is True and prep['configurationBefore']==prep['configurationAfter']
  for name,digest in reuse['prepareProbePins'].items():assert sha(raw(role+'/snapshot-prepare-probes/'+Path(name).name))==digest
  for name,digest in p['inventory'].items():assert sha(raw(role+'/stage/'+name))==digest
  for record in data(role+'/source-inventory.json'):assert sha(raw(role+'/stage/'+record['path']))==record['stageSHA256']
  for name,m in models.items():
   expected=m['independentFullIOString'];key=role+'/logs/'+name+('-run-js.stdout' if role=='js' else '-run-native.stdout');assert raw(key).decode()==expected==raw('cli/logs/'+name+'-cli-io.stdout').decode();assert expected!=base and len(expected.splitlines())==9
   differences=[i for i,(a,b) in enumerate(zip(expected.splitlines(),base.splitlines())) if a!=b];assert len(differences)==m['expectedDifferentSemanticRows'];assert r['reached'][name]['differentSemanticRows']==differences
 for role in HISTORY:
  assert 'history/'+role+'/receipt.json' not in records
  p=data('history/'+role+'/plan.json');suffix='binding-static-mutant-cli.py' if role=='cli-unjoined' else 'binding-static-mutant-backend.py';matches=[digest for name,digest in p['inputs'].items() if name.endswith('/'+suffix)];assert matches==[sha(raw('history/'+role+'/wrapper.py'))]
 for name in ['binding-static-js-evidence-v1','binding-static-native-evidence-v1']:assert sha((HERE/name/'index.json').read_bytes())==sha(raw(name+'/index.json'))
 saved=sys.argv;sys.argv=[str(HERE/'binding-static-native-evidence.py')]
 try:runpy.run_path(str(HERE/'binding-static-native-evidence.py'),run_name='__main__')
 finally:sys.argv=saved
 print('NO_CHILD_STATIC_MUTANT_EVIDENCE_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
