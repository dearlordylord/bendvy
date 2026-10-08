"""Portable, no-child finite byte/status/join verification; no backend replay."""
import pathlib, json, hashlib, tarfile, sys
HERE=pathlib.Path(__file__).resolve().parent
LIVE=HERE.parent
PLAN='5b6ef2f9444f1fac86fa28767b9d1d37e8699188eb56b78461a2e5c8e5cbe1f1'
RECONCILE='80f9968c4e697a5f1c489ea58e73fbeb1618c28075d8e3e7fad16b1487ffa93d'
def sha(data):return hashlib.sha256(data).hexdigest()
def verify():
 index=json.loads((HERE/'index.json').read_text());records=index['records'];archive=HERE/'objects.tar.gz';assert sha(archive.read_bytes())==index['objectsArchiveSHA256'];objects={}
 with tarfile.open(archive,'r:gz') as t:
  members=t.getmembers();expected={r['object'] for r in records.values()}
  assert len(members)==len(expected) and {m.name for m in members}==expected
  for m in members:
   assert m.isfile() and m.name.startswith('objects/')
   data=t.extractfile(m).read();assert sha(data)==m.name.split('/')[1];objects[m.name]=data
 for r in records.values():assert len(objects[r['object']])==r['bytes'] and sha(objects[r['object']])==r['sha256']
 def data(name):return objects[records[str(name)]['object']]
 def js(name):return json.loads(data(name))
 def by_sha(digest):return objects['objects/'+digest]
 for relative,r in index['liveSelected'].items():assert sha((LIVE/relative).read_bytes())==r['sha256']
 out=index['runtimeRoot'];p=js(out+'/execution-plan.json');r=js(out+'/receipt.json');derived=js(out+'/reconciliation-receipt-v2.json')
 assert sha(data(out+'/execution-plan.json'))==PLAN and r['planSHA256']==PLAN
 assert r['status']=='INCOMPLETE' and r['error']=='AssertionError: complete independent public/physical oracle mismatch' and r['guardFailures']==[]
 assert r['commands']==[{'label':'complete-emit-js','exit':0,'failure':None,'seconds':30},{'label':'complete-run-js','exit':0,'failure':None,'seconds':5}]
 labels=['verify-'+str(i)+'-ldd-'+n for i in range(5) for n in ['bend','node','python','taskset','clang']]
 assert p['executionProbeLabels']==labels and r['probeCount']==25
 assert set(r['probePins'])=={out+'/execution-probes/'+label+suffix for label in labels for suffix in ['.json','.stdout.raw','.stderr.raw']}
 for n,digest in r['probePins'].items():assert sha(data(n))==digest
 for label in labels:
  v=js(out+'/execution-probes/'+label+'.json');assert v['exit']==0 and v['failure'] is None and v['seconds']==5
 assert set(r['logs'])=={label+'.'+stream+'.raw' for label in ['complete-emit-js','complete-run-js'] for stream in ['stdout','stderr']}
 for n,digest in r['logs'].items():assert sha(data(out+'/'+n))==digest
 assert data(out+'/complete-run-js.stderr.raw')==b''
 for n,digest in r['generated'].items():assert sha(data(n))==digest
 assert derived['status']=='COMPLETE_DERIVED_SOURCE_BACKED_JS_RECONCILIATION' and derived['originalStatus']=='INCOMPLETE' and derived['backendReexecuted'] is False
 assert derived['planSHA256']==RECONCILE and derived['originalPlanSHA256']==PLAN and derived['originalReceiptSHA256']==sha(data(out+'/receipt.json'))
 corrected=by_sha(derived['fullOracleSHA256']);assert data(out+'/complete-run-js.stdout.raw')==corrected and len(corrected)==derived['bytes']==5077477
 reconciliation=js(index['reconciliationPlan']);assert sha(data(index['reconciliationPlan']))==RECONCILE
 assert reconciliation['subjectRawDigests']==r['logs']
 for n,digest in reconciliation['files'].items():assert sha(data(n))==digest
 for relative,digest in p['stageInventory'].items():assert sha(data(p['stage']+'/'+relative))==digest
 for source,join in index['rootDependencies'].items():assert sha(data(source))==join['sha256']==sha(data(join['root']))
 prep=js(out+'/prepare-receipt.json');assert prep['status']=='COMPLETE_ORDINARY_OWNED_JS_PREPARATION' and prep['probeCount']==5 and prep['configurationBefore']==prep['configurationAfter']==p['configurationStates']
 assert sha(data(out+'/prepare-receipt.json'))==p['preparationReceiptSHA256']
 prep_plan=js(out+'/preparation-plan.json')
 assert sha(data(out+'/preparation-plan.json'))==prep['preparationPlanSHA256']==p['preparationPlanSHA256']
 prep_labels=['prepare-ldd-'+n for n in ['bend','node','python','taskset','clang']]
 assert prep_plan['ordinaryProbeLabels']==prep_labels
 assert set(prep['probePins'])=={out+'/prepare-probes/'+label+suffix for label in prep_labels for suffix in ['.json','.stdout.raw','.stderr.raw']}
 for n,digest in prep['probePins'].items():assert sha(data(n))==digest
 for label in prep_labels:
  probe=js(out+'/prepare-probes/'+label+'.json')
  assert probe['exit']==0 and probe['failure'] is None and probe['seconds']==5
  assert probe['runnerSHA256']==prep_plan['inputs'][out.rsplit('/.artifacts/',1)[0]+'/scripts/task_runner.py']
 assert set(prep['logs'])=={'source-origin.stdout.raw','source-origin.stderr.raw'}
 for n,digest in prep['logs'].items():assert sha(data(out+'/'+n))==digest
 assert data(out+'/source-origin.stderr.raw')==b'' and prep['gitOrigin']['exit']==0 and prep['gitOrigin']['failure'] is None and prep['gitOrigin']['seconds']==5
 reference_plan=index['referencePlan'];reference_root=reference_plan.rsplit('/',1)[0]
 reference=js(reference_plan);reference_receipt=js(reference_root+'/receipt.json')
 assert sha(data(reference_plan))==reference_receipt['planSHA256']=='6948534b673287c624fc48f22d27b5f6eeff96f9d1b11892f3c6935924e093fe'
 assert reference_receipt['status']=='COMPLETE_PINNED_TS_PUBLIC_COMPONENT_PASS' and reference_receipt['exit']==0 and reference_receipt['failure'] is None
 assert reference_receipt.get('guardFailures',[])==[] and set(reference_receipt['logs'])=={'stdout.raw','stderr.raw'}
 for n,digest in reference_receipt['logs'].items():assert sha(data(reference_root+'/'+n))==digest
 assert data(reference_root+'/stderr.raw')==b''
 assert json.loads(data(reference_root+'/stdout.raw'))==json.loads(data(reference['oracle']))
 joins=json.loads((HERE/'ARCHIVED-PATH-JOINS.json').read_text())
 assert set(joins['excludedHashOnly'])=={'/usr/bin/taskset','/home/node/.local/share/mise/installs/node/24.20.0/bin/node'}
 for n,value in reference['inputs'].items():
  if isinstance(value,dict):
   for relative,digest in value.items():assert sha(data(n+'/'+relative))==digest
  elif n in records:assert sha(data(n))==value
  elif n in joins['archivedAliases']:assert sha(data(joins['archivedAliases'][n]))==value
  elif n in joins['supplementalSources']:
   source=joins['supplementalSources'][n];assert sha((HERE/source['file']).read_bytes())==source['sha256']==value
  else:assert joins['excludedHashOnly'][n]==value
 source_plan=js(joins['sourcePositivePlan']);source_receipt=js(joins['sourcePositiveReceipt']);source_root=joins['sourcePositivePlan'].rsplit('/',1)[0]
 assert sha(data(joins['sourcePositivePlan']))==reference['sourceJoin']['planSHA256']=='dc69a0a942e38fe8c40dde4edf7dc3bf33fe9dca0346797351a429e367519562'
 assert sha(data(joins['sourcePositiveReceipt']))==reference['sourceJoin']['receiptSHA256']=='fa25a9917a2201efe45c59e5ecdf20e5b01704bef5873a6109a71a14b2da5fb0'
 assert source_receipt['status']=='SOURCE_FEASIBILITY_PASS' and source_receipt['exit']==0 and source_receipt['planSHA256']==reference['sourceJoin']['planSHA256']
 assert source_receipt.get('guardFailures',[])==[] and set(source_receipt['logs'])=={'stdout.raw','stderr.raw'}
 for n,digest in source_receipt['logs'].items():assert sha(data(source_root+'/'+n))==digest
 assert source_plan['sourceArchive']==reference['sourceJoin']['sourceArchive']
 for relative,digest in reference['sourceJoin']['sourceArchive'].items():
  candidates=[name for name in [source_root+'/source/'+relative,source_root+'/'+relative] if name in records]
  assert len(candidates)==1 and sha(data(candidates[0]))==digest
 # Source-positive immutable historical archive objects are joined by exact digest.
 for name in records:
  if name.endswith('/plan.json') and 'development-history-v1' in name:
   plan=js(name)
   for relative,digest in plan.get('sourceArchive',{}).items():
    archive_root=name.rsplit('/',1)[0]
    candidates=[candidate for candidate in [archive_root+'/source/'+relative,archive_root+'/'+relative] if candidate in records]
    assert len(candidates)==1 and sha(data(candidates[0]))==digest
 return {'status':'FINITE_COMPONENT_TS_JS_RECONCILIATION_VERIFIED','records':len(records),'objects':len(objects),'bytes':len(corrected),'probeCount':25,'scope':index['scope']}
if __name__=='__main__':print(json.dumps(verify(),indent=2))
