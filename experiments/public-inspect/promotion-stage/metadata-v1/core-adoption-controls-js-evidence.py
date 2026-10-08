"""Native finite receipt verifier; no backend or probe children."""
from pathlib import Path
import argparse,hashlib,json,runpy,sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
BASES={name:ROOT/'.artifacts'/('inspect54-static-backend-'+stamp) for name,stamp in [('reader','1791431739635724864'),('lens-routing','1791431769386224750'),('metadata-order','1791431792408775211'),('retainer','1791431817010126995')]}
OUT=HERE/'core-adoption-controls-js-evidence-v1'
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
 add('source-milestone-index.json',HERE/'core-adoption-controls-cli-evidence-v1/index.json')
 index={'format':1,'records':records,'scope':'Current-root compilingcontrols standaloneJS fullreader75/lens8/order8 defectoracles and12/4/8exactsemanticrows plusgenuineSysretainer20. EachfreshPREP5/configequal+JS25guards/boundedGitoriginread; fullowners preserved. NoNative/proof/adoption/generaltruth/full54; privateenv/toolbinariesexcluded/generatedJSretained.'};(OUT/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(sha((OUT/'index.json').read_bytes()))
def verify():
 records=json.loads((OUT/'index.json').read_text())['records']
 def raw(key):return (OUT/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest
 milestone=HERE/'core-adoption-controls-cli-evidence-v1/index.json';assert sha(milestone.read_bytes())==sha(raw('source-milestone-index.json'));mi=json.loads(milestone.read_text());objects=milestone.parent/'objects'
 def old(key):return (objects/mi['records'][key]).read_bytes()
 for role in BASES:
  plan=data(role+'/plan.json');receipt=data(role+'/receipt.json');prep=data(role+'/prepare-receipt.json');inventory=data(role+'/source-inventory.json')
  assert receipt['planSHA256']==sha(raw(role+'/plan.json'));assert receipt['status']=='FULL_CURRENT_ROOT_CONTROL_EMITTED_PASS';assert len(receipt['commands'])==2 and all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
  assert [c['seconds'] for c in plan['commands']]==[30,5];assert receipt['probeCount']==25 and prep['probeCount']==5
  assert prep['configurationBefore']==prep['configurationAfter']==plan['preparationConfigurationBefore']==plan['preparationConfigurationAfter'];assert prep['configurationStable'] is True
  for name,digest in receipt['logs'].items():assert sha(raw(role+'/logs/'+name))==digest
  for name,digest in receipt['generated'].items():assert Path(name).suffix=='.js';assert sha(raw(role+'/generated/'+Path(name).name))==digest
  for label,ledger in [('prepare-probes',prep['probePins']),('execution-probes',receipt['probePins'])]:
   for name,digest in ledger.items():assert sha(raw(role+'/'+label+'/'+Path(name).name))==digest
  for record in inventory['files']:assert sha(raw(role+'/stage/'+record['path']))==record['sourceSHA256']==record['stageSHA256'];assert record['origin'] in ['tracked','selected-owned']
  for name,suffix in [('sourceJoin','source'),('cliJoin','cli')]:
   join=plan['joins'][name];assert join['planSHA256']==sha(old(role+'-'+suffix+'/plan.json'));assert join['receiptSHA256']==sha(old(role+'-'+suffix+'/receipt.json'));assert join['sourceArchiveSHA256']==sha(old(role+'-'+suffix+'/source-archive.json'))
  archived=json.loads(old(role+'-source/source-archive.json'))
  for source,digest in plan['joins']['sourceJoin']['qualifiedClosure'].items():
   assert archived[source]['sha256']==digest;matches=[record for record in inventory['files'] if source.endswith('/'+record['path'])];assert len(matches)==1;assert matches[0]['sourceSHA256']==matches[0]['stageSHA256']==digest
  expected=(data(role+'/oracle.json')[role]+'\n').encode();actual=raw(role+'/logs/'+role+'-run-js.stdout');assert actual==expected==old(role+'-cli/'+role+'-cli-io.stdout')
  if plan['baselineIOString'] is not None:
   rows=[i for i,(a,b) in enumerate(zip(actual.decode().splitlines(),plan['baselineIOString'].splitlines())) if a!=b];assert rows==plan['expectedDifferentRows']==receipt['reached'][role]['semanticRows'];assert receipt['reached'][role]['fullOracleSHA256']==sha(raw(role+'/oracle.json'))
 saved=sys.argv;sys.argv=[str(HERE/'core-adoption-controls-cli-evidence.py')]
 try:runpy.run_path(str(HERE/'core-adoption-controls-cli-evidence.py'),run_name='__main__')
 finally:sys.argv=saved
 print('NO_CHILD_CURRENT_ROOT_CONTROLS_JS_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
