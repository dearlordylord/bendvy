"""Standalone JS finite receipt verifier; no backend or probe children."""
from pathlib import Path
import argparse,hashlib,json,runpy,sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
BASE=ROOT/'.artifacts/inspect54-static-backend-1791429787223937815'
OUT=HERE/'core-adoption-query-check-js-evidence-v1'
def sha(data):return hashlib.sha256(data).hexdigest()
def prepare():
 assert not OUT.exists();OUT.mkdir();objects=OUT/'objects';objects.mkdir();records={}
 def add(key,path):
  data=path.read_bytes();digest=sha(data);target=objects/digest
  if not target.exists():target.write_bytes(data)
  records[key]=digest
 plan=json.loads((BASE/'plan.json').read_text());receipt=json.loads((BASE/'receipt.json').read_text());prep=json.loads((BASE/'prepare-receipt.json').read_text())
 for name in ['plan.json','receipt.json','prepare-receipt.json','source-inventory.json','oracle.json','tracked-source.stdout','tracked-source.stderr']:add(name,BASE/name)
 for name,digest in receipt['logs'].items():p=Path(receipt['logDirectory'])/name;assert sha(p.read_bytes())==digest;add('logs/'+name,p)
 for role,ledger in [('prepare-probes',prep['probePins']),('execution-probes',receipt['probePins'])]:
  for name,digest in ledger.items():p=Path(name);assert sha(p.read_bytes())==digest;add(role+'/'+p.name,p)
 for name,digest in receipt['generated'].items():p=Path(name);assert sha(p.read_bytes())==digest;add('generated/'+p.name,p)
 for record in json.loads(Path(plan['sourceInventory']).read_text())['files']:add('stage/'+record['path'],Path(plan['stage'])/record['path'])
 add('source-milestone-index.json',HERE/'core-adoption-query-check-evidence-v1/index.json')
 index={'format':1,'records':records,'scope':'Standalone emittedJS full74/84 current-root proposedgenericcore actualquery/cardinality and Check/genuineSysSchedule diagnostic baseline. Executionguards45/PREPsnapshot5 explicitprepostconfig equality, separate boundedGitorigin read. WholeCheck readonly boundary/gatedobservations/owners preserved by fulloriginaloracles. No Native/mutant/retention/adoption/proof/generaltruth/full54. Privateenv/toolbinary excluded.'};(OUT/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(sha((OUT/'index.json').read_bytes()))
def verify():
 records=json.loads((OUT/'index.json').read_text())['records']
 def raw(key):return (OUT/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest
 plan=data('plan.json');receipt=data('receipt.json');prep=data('prepare-receipt.json');assert receipt['planSHA256']==sha(raw('plan.json'));assert receipt['status']=='FULL74_84_CURRENT_ROOT_EMITTED_PASS';assert all(c['exit']==0 and c['failure'] is None for c in receipt['commands']);assert [c['seconds'] for c in plan['commands']]==[30,5,30,5];assert receipt['probeCount']==45 and prep['probeCount']==5
 for name,digest in receipt['logs'].items():assert sha(raw('logs/'+name))==digest
 for name,digest in receipt['generated'].items():assert sha(raw('generated/'+Path(name).name))==digest
 for role,ledger in [('prepare-probes',prep['probePins']),('execution-probes',receipt['probePins'])]:
  for name,digest in ledger.items():assert sha(raw(role+'/'+Path(name).name))==digest
 inventory=data('source-inventory.json')
 for record in inventory['files']:assert sha(raw('stage/'+record['path']))==record['sourceSHA256']==record['stageSHA256'];assert record['origin'] in ['tracked','selected-owned']
 milestonePath=HERE/'core-adoption-query-check-evidence-v1/index.json';assert sha(milestonePath.read_bytes())==sha(raw('source-milestone-index.json'));milestone=json.loads(milestonePath.read_text());objects=milestonePath.parent/'objects'
 def old(key):return (objects/milestone['records'][key]).read_bytes()
 for name,role in [('sourceJoin','source'),('cliJoin','cli')]:
  join=plan['joins'][name];assert join['planSHA256']==sha(old(role+'/plan.json'));assert join['receiptSHA256']==sha(old(role+'/receipt.json'));assert join['sourceArchiveSHA256']==sha(old(role+'/source-archive.json'))
 archived=json.loads(old('source/source-archive.json'))
 for source,digest in plan['joins']['sourceJoin']['qualifiedClosure'].items():
  assert archived[source]['sha256']==digest;matches=[record for record in inventory['files'] if source.endswith('/'+record['path'])];assert len(matches)==1;assert matches[0]['sourceSHA256']==matches[0]['stageSHA256']==digest
 for name in ['cardinality','check']:
  expected=(data('oracle.json')[name]+'\n').encode();assert raw('logs/'+name+'-run-js.stdout')==expected==old('cli/adoption-'+name+'-io-main-cli-io.stdout')
 assert prep['configurationBefore']==prep['configurationAfter']==plan['preparationConfigurationBefore']==plan['preparationConfigurationAfter'];assert prep['configurationStable'] is True
 saved=sys.argv;sys.argv=[str(HERE/'core-adoption-query-check-evidence.py')]
 try:runpy.run_path(str(HERE/'core-adoption-query-check-evidence.py'),run_name='__main__')
 finally:sys.argv=saved
 print('NO_CHILD_CURRENT_ROOT_QUERY_CHECK_JS_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
