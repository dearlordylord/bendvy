"""No-child lossless full Native timeout packet verification."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda raw:hashlib.sha256(raw).hexdigest()
manifest=json.loads((HERE/'NATIVE-EVIDENCE-MANIFEST.json').read_text());raws={}
for row in manifest['members']:
 path=HERE/row['archive'];assert path.is_file()and not path.is_symlink();compressed=path.read_bytes();assert sha(compressed)==row['archiveSHA256'];raw=gzip.decompress(compressed);assert len(raw)==row['bytes']and sha(raw)==row['sha256'];assert row['source']not in raws;raws[row['source']]=raw
assert {str(p.relative_to(HERE))for p in(HERE/'native-evidence-v1').rglob('*.gz')}=={r['archive']for r in manifest['members']}
root=Path('/tmp/bendvy56-recursive-native-v1');get=lambda name:raws[str(root/name)]
plan=json.loads(get('plan.json'));receipt=json.loads(get('receipt.json'));summary=json.loads((HERE/'NATIVE-EXECUTION-RESULT.json').read_text());plan_sha=sha(get('plan.json'))
assert plan_sha==summary['planSHA256']==receipt['planSHA256']
assert receipt['status']=='INCOMPLETE'and receipt['error']=='ValueError: Owned child failed: emit'and receipt['guardFailures']==[]
assert len(receipt['commands'])==1 and len(receipt['guards'])==4
row=receipt['commands'][0];assert all(row[k]==v for k,v in plan['commands'][0].items());assert row['argv'][:3]==['/usr/bin/taskset','-c','5']and row['capSeconds']==30 and row['exit']is None and row['failure']=='child deadline'
assert row['runnerSHA256']==plan['pins']['/workspace/formal-proofs/bendvy/scripts/task_runner.py']
expected=dict(plan['pins']);expected[str(root/'plan.json')]=plan_sha
for stream in('stdout','stderr'):
 bound=row[stream];raw=raws[bound['path']];assert raw==b''and sha(raw)==bound['sha256']and bound['bytes']==0
for index,label in enumerate(['emit-pre','emit-acquired','emit-post','final']):
 if label=='emit-post':
  for stream in('stdout','stderr'):expected[row[stream]['path']]=row[stream]['sha256']
 bound=receipt['guards'][index];assert bound['path']==str(root/(label+'.guard.json'));raw=raws[bound['path']];assert sha(raw)==bound['sha256'];guard=json.loads(raw);assert guard['label']==label and guard['unchanged']is True and guard['actualPins']==expected and guard['actualResources']==plan['resourceInventory']
assert 'generatedSHA256'not in receipt and 'nativeSHA256'not in receipt
assert plan['generated']not in raws and plan['native']not in raws
print(json.dumps({'members':len(manifest['members']),'guards':4,'packet':'PASS','NativeQualification':'INCOMPLETE','stage':'emit deadline30','actualBackendChildren':0},indent=2))
