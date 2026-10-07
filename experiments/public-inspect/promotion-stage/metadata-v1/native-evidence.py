"""No-child finite Native evidence freezer/verifier; excludes native binaries/env."""
from pathlib import Path
import argparse,hashlib,json
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
RUN=ROOT/'.artifacts/inspect54-metadata-native-log-fix-1791416421718372305'
def sha(data):return hashlib.sha256(data).hexdigest()
def prepare():
 receipt=json.loads((RUN/'receipt.json').read_text());assert receipt['status']=='FULL24_METADATA_NATIVE_IO_PASS';assert receipt['probeCount']==35
 out=HERE/'native-evidence-v2';assert not out.exists();out.mkdir();objects=out/'objects';objects.mkdir();records={};excluded={}
 def add(key,path):
  data=path.read_bytes();digest=sha(data);target=objects/digest
  if not target.exists():target.write_bytes(data)
  records[key]=digest
 plan=json.loads((RUN/'plan.json').read_text());prep=Path(plan['reusedPreparation']['receipt']);original=Path(plan['reusedPreparation']['plan']);add('receipt.json',RUN/'receipt.json');add('plan.json',RUN/'plan.json');add('prepare-receipt.json',prep);add('history-original-plan.json',original);add('history-prechild-failure.json',original.parent/'observed-prechild-failure.json');add('source-inventory.json',RUN/'source-inventory.json');add('oracle.json',Path(plan['oracle']))
 for name,digest in receipt['logs'].items():f=Path(receipt['logDirectory'])/name;assert sha(f.read_bytes())==digest;add('logs/'+name,f)
 for field in [receipt,json.loads(prep.read_text())]:
  for file,digest in field['probePins'].items():
   f=Path(file);assert sha(f.read_bytes())==digest;add('probes/'+str(Path(f.parent.name)/f.name),f)
 for file,digest in receipt['generated'].items():
  f=Path(file);assert sha(f.read_bytes())==digest
  if f.suffix=='.native':excluded[file]={'sha256':digest,'reason':'generated Native binary excluded; hash-only receipt provenance'}
  else:add('generated/'+f.name,f)
 for relative,digest in plan['inventory'].items():
  f=Path(plan['stage'])/relative;assert sha(f.read_bytes())==digest;add('stage/'+relative,f)
 for key in ['tracked-source.stdout','tracked-source.stderr']:add(key,original.parent/key)
 for name,join in plan['joins'].items():
  r=Path(join['receipt']);pp=r.parent/'plan.json';add('joins/'+name+'/receipt.json',r);add('joins/'+name+'/plan.json',pp)
  for logfile,digest in json.loads(r.read_text())['logs'].items():f=r.parent/logfile;assert sha(f.read_bytes())==digest;add('joins/'+name+'/'+logfile,f)
 excluded[plan['privateEnvironment']]={'sha256':plan['environmentSHA256'],'reason':'private environment bytes excluded'}
 for file,digest in plan['tools']['pins'].items():excluded[file]={'sha256':digest,'reason':'tool/library/resource file pinned metadata only'}
 index={'format':1,'records':records,'hashOnlyExclusions':excluded,'scope':'Full24 Native diagnostic metadata and actualArray owner cells, exactIO LF; no automatic opaquePlan declaration truth/World callbacks/proof/full54.'};(out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(out);print(sha((out/'index.json').read_bytes()))
def verify():
 out=HERE/'native-evidence-v2';index=json.loads((out/'index.json').read_text());records=index['records']
 def raw(key):return (out/'objects'/records[key]).read_bytes()
 def data(key):return json.loads(raw(key))
 for key,digest in records.items():assert sha(raw(key))==digest,key
 receipt=data('receipt.json');plan=data('plan.json');assert receipt['planSHA256']==sha(raw('plan.json'));assert receipt['status']=='FULL24_METADATA_NATIVE_IO_PASS';assert receipt['probeCount']==len(plan['executionProbeLabels'])==35
 assert sha(raw('history-original-plan.json'))==plan['reusedPreparation']['planSHA256']
 assert sha(raw('prepare-receipt.json'))==plan['reusedPreparation']['receiptSHA256']
 assert data('history-prechild-failure.json')['backendCommandsExecuted']==0
 assert data('history-prechild-failure.json')['executionProbeRecords']==[]
 assert data('prepare-receipt.json')['status']=='OWNED_TOOL_SNAPSHOT_COMPLETE';assert data('prepare-receipt.json')['probeCount']==5
 assert [(c['exit'],c['failure']) for c in receipt['commands']]==[(0,None)]*3
 assert [c['seconds'] for c in plan['commands']]==[30,120,5]
 for name,digest in receipt['logs'].items():assert sha(raw('logs/'+name))==digest
 assert raw('logs/metadata-run-native.stdout')==(data('oracle.json')['metadata']+'\n').encode()
 assert len(data('oracle.json')['metadata'].splitlines())==24
 assert raw('logs/metadata-run-native.stdout')==raw('joins/jsJoin/metadata-run-js.stdout')
 for command in plan['commands']:assert command['argv'][1:3]==['-c','5']
 assert plan['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
 for relative,digest in plan['inventory'].items():assert sha(raw('stage/'+relative))==digest
 for original,digest in receipt['generated'].items():
  if Path(original).suffix=='.native':assert index['hashOnlyExclusions'][original]['sha256']==digest
  else:assert sha(raw('generated/'+Path(original).name))==digest
 for role,r in [('execution-probes',receipt),('prepare-probes',data('prepare-receipt.json'))]:
  for original,digest in r['probePins'].items():assert sha(raw('probes/'+str(Path(role)/Path(original).name)))==digest
 for name,join in plan['joins'].items():
  assert sha(raw('joins/'+name+'/receipt.json'))==join['sha256'];assert sha(raw('joins/'+name+'/plan.json'))==join['planSHA256']
  for logfile,digest in data('joins/'+name+'/receipt.json')['logs'].items():assert sha(raw('joins/'+name+'/'+logfile))==digest
 print('NO_CHILD_FULL24_NATIVE_METADATA_EVIDENCE_PASS',len(records),'records',len(set(records.values())),'objects')
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');a=p.parse_args()
if a.prepare:prepare()
else:verify()
