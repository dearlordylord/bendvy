"""No-child exact copied layout-cache capture/primary-error verification."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda raw:hashlib.sha256(raw).hexdigest()
manifest=json.loads((HERE/'EVIDENCE-MANIFEST.json').read_text());raws={}
for row in manifest['members']:
 path=HERE/row['archive'];assert path.is_file()and not path.is_symlink();compressed=path.read_bytes();assert sha(compressed)==row['archiveSHA256'];raw=gzip.decompress(compressed);assert len(raw)==row['bytes']and sha(raw)==row['sha256'];assert row['source']not in raws;raws[row['source']]=raw
assert {str(p.relative_to(HERE))for p in(HERE/'evidence').rglob('*.gz')}=={r['archive']for r in manifest['members']}
root=Path('/tmp/bendvy56-recursive-layout-cache-v1');get=lambda name:raws[str(root/name)]
plan=json.loads(get('plan.json'));receipt=json.loads(get('receipt.json'));summary=json.loads((HERE/'RESULT.json').read_text());plan_sha=sha(get('plan.json'))
assert plan_sha==summary['planSHA256']==receipt['planSHA256']
assert receipt['status']=='REFERENCE_CPU_PROFILE_CAPTURED'and receipt['qualifiesInstalledCompiler']is False and not receipt.get('error')and not receipt.get('guardFailures')
assert len(receipt['commands'])==1 and len(receipt['guards'])==4
row=receipt['commands'][0];assert row['argv']==plan['argv']and row['argv'][:3]==['/usr/bin/taskset','-c','5'];assert row['capSeconds']==plan['capSeconds']==30 and row['exit']==1 and row['failure']is None
assert row['runnerSHA256']==plan['pins']['/workspace/formal-proofs/bendvy/scripts/task_runner.py']
expected=dict(plan['pins']);expected[str(root/'plan.json')]=plan_sha
for stream in('stdout','stderr'):
 bound=row[stream];raw=raws[bound['path']];assert sha(raw)==bound['sha256']and len(raw)==bound['bytes']
profile=get('handler.cpuprofile');assert sha(profile)==receipt['profileSHA256'];data=json.loads(profile);assert len(data['samples'])==len(data['timeDeltas'])==receipt['profileSamples']==summary['profileSamples']
node_ids={x['id']for x in data['nodes']};assert len(node_ids)==len(data['nodes'])and all(x in node_ids for x in data['samples'])
for index,label in enumerate(['emit-pre','emit-acquired','emit-post','final']):
 if label=='emit-post':
  for stream in('stdout','stderr'):expected[row[stream]['path']]=row[stream]['sha256']
  expected[plan['profile']]=receipt['profileSHA256']
 bound=receipt['guards'][index];assert bound['path']==str(root/(label+'.guard.json'));raw=raws[bound['path']];assert sha(raw)==bound['sha256'];guard=json.loads(raw);assert guard['label']==label and guard['unchanged']is True and guard['actualPins']==expected
stderr=get('emit.stderr').decode();assert 'DiagnosticAbort: cooperative profiling cutoff'in stderr
stats=[json.loads(x[len('REFERENCE_LAYOUT_KEY_CACHE '):])for x in stderr.splitlines()if x.startswith('REFERENCE_LAYOUT_KEY_CACHE ')];assert stats==[summary['layoutCache']]and stats[0]['hits']>0 and stats[0]['misses']>0
phases=[json.loads(x[len('REFERENCE_PHASE '):])for x in stderr.splitlines()if x.startswith('REFERENCE_PHASE ')];assert phases==summary['phases']and not any(x['event']=='compile_book.end'for x in phases)
assert 'artifactSHA256'not in receipt and plan['output']not in raws and summary['compileCompleted']is False
print(json.dumps({'members':len(manifest['members']),'guards':4,'capture':'PASS','compilation':'INCOMPLETE cutoff25s','profileSamples':len(data['samples']),'cache':stats[0],'actualBackendChildren':0},indent=2))
