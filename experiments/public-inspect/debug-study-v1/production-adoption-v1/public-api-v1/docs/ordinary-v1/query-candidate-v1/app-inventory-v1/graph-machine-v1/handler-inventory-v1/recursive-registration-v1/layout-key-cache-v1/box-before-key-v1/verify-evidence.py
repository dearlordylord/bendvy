"""No-child exact copied BOX control artifact/profile/guard verification."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda raw:hashlib.sha256(raw).hexdigest()
manifest=json.loads((HERE/'EVIDENCE-MANIFEST.json').read_text());raws={}
for row in manifest['members']:
 path=HERE/row['archive'];assert path.is_file()and not path.is_symlink();compressed=path.read_bytes();assert sha(compressed)==row['archiveSHA256'];raw=gzip.decompress(compressed);assert len(raw)==row['bytes']and sha(raw)==row['sha256'];assert row['source']not in raws;raws[row['source']]=raw
assert {str(p.relative_to(HERE))for p in(HERE/'evidence').rglob('*.gz')}=={r['archive']for r in manifest['members']}
root=Path('/tmp/bendvy56-box-controls-v1');get=lambda name:raws[str(root/name)]
plan=json.loads(get('plan.json'));receipt=json.loads(get('receipt.json'));summary=json.loads((HERE/'RESULT.json').read_text());plan_sha=sha(get('plan.json'))
assert plan_sha==summary['planSHA256']==receipt['planSHA256']
assert receipt['status']=='REFERENCE_CPU_PROFILE_CAPTURED'and receipt['qualifiesInstalledCompiler']is False and not receipt.get('error')and not receipt.get('guardFailures')
assert len(receipt['commands'])==1 and len(receipt['guards'])==4
row=receipt['commands'][0];assert row['argv']==plan['argv']and row['argv'][:3]==['/usr/bin/taskset','-c','5'];assert row['capSeconds']==plan['capSeconds']==30 and row['exit']==0 and row['failure']is None
assert row['runnerSHA256']==plan['pins']['/workspace/formal-proofs/bendvy/scripts/task_runner.py']
expected=dict(plan['pins']);expected[str(root/'plan.json')]=plan_sha
for stream in('stdout','stderr'):
 bound=row[stream];raw=raws[bound['path']];assert sha(raw)==bound['sha256']and len(raw)==bound['bytes']
profile=get('controls.cpuprofile');assert sha(profile)==receipt['profileSHA256'];data=json.loads(profile);assert len(data['samples'])==len(data['timeDeltas'])==receipt['profileSamples']==summary['profileSamples']
node_ids={x['id']for x in data['nodes']};assert len(node_ids)==len(data['nodes'])and all(x in node_ids for x in data['samples'])
artifact=get('controls-report.json');assert sha(artifact)==receipt['artifactSHA256']
for index,label in enumerate(['emit-pre','emit-acquired','emit-post','final']):
 if label=='emit-post':
  for stream in('stdout','stderr'):expected[row[stream]['path']]=row[stream]['sha256']
  expected[plan['profile']]=receipt['profileSHA256'];expected[plan['output']]=receipt['artifactSHA256']
 bound=receipt['guards'][index];assert bound['path']==str(root/(label+'.guard.json'));raw=raws[bound['path']];assert sha(raw)==bound['sha256'];guard=json.loads(raw);assert guard['label']==label and guard['unchanged']is True and guard['actualPins']==expected
report=json.loads(artifact);names=['array','nested-array','io-op','recursive-list','recursive-owner','mutual-recursion','family-cycle','parameter-products'];assert report['status']==summary['status']=='CONTROL_PASS'and report['active']is None and report['error']is None
assert [x['name']for x in report['cases']]==names==[x['name']for x in summary['cases']]
for case,observed in zip(report['cases'],summary['cases']):
 digest=sha(case['emittedC'].encode());assert digest==case['baselineCSHA256']==case['optimizedCSHA256']==observed['fullCSHA256'];assert len(case['emittedC'].encode())==observed['fullCBytes']
 for field in('layout','ioOpLayout','openElementError'):assert case[field]==observed[field]
 assert case['openElementError']=='an open Array element type';assert set(json.loads(case['layout']))=={'ks','arms'}
stderr=get('emit.stderr').decode();passed=[json.loads(x[len('BOX_CONTROL_PASS '):])for x in stderr.splitlines()if x.startswith('BOX_CONTROL_PASS ')];assert [x['name']for x in passed]==names
bound=[json.loads(x[len('BOX_CONTROL_BOUND_VAR '):])for x in stderr.splitlines()if x.startswith('BOX_CONTROL_BOUND_VAR ')];assert [x['name']for x in bound]==names
assert all(x['before']==x['after']=={'index':-1,'head':'ADT'}for x in bound)
print(json.dumps({'members':len(manifest['members']),'guards':4,'controls':'CONTROL_PASS','cases':len(names),'exactLayoutsFullC':'PASS','openArrayRefusal':'PASS','boundVarState':'PASS','profileSamples':len(data['samples']),'actualBackendChildren':0},indent=2))
