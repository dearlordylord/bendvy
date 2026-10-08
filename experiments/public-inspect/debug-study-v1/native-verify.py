"""Verify portable Native full16 capsule without tools or live original paths."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent;E=H/'native-evidence-v1';sha=lambda b:hashlib.sha256(b).hexdigest()
i=json.loads((E/'index.json').read_text());assert sha((E/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(E/'objects.tar.gz') as t:
 assert len(t.getnames())==len(set(t.getnames())) and set(t.getnames())==set(i['objects'])
 objects={n:t.extractfile(n).read() for n in t.getnames()}
assert all(sha(b)==h and len(b)==i['objects'][h] for h,b in objects.items())
assert all(h in objects for h in i['files'].values())
def at(key):return objects[i['files'][key]]
def path(n):return at(i['pathKeys'][n])
p=json.loads(at('cohort/plan.json'));r=json.loads(at('cohort/receipt.json'));prep=json.loads(at('cohort/prepare-receipt.json'))
assert sha(at('cohort/plan.json'))==r['planSHA256']=='1f23b233d64c5110eca91498e9c78ee00323f7d45aa59e936004f7823a7b5042'
assert r['status']=='NATIVE_FULL16_QUALIFIED_NOT_FULL56_NOT_PROOF_NOT_PERFORMANCE' and r.get('guardFailures',[])==[]
assert [c['seconds'] for c in r['commands']]==[30,120,5] and all(c['exit']==0 and c['failure'] is None for c in r['commands'])
assert [c['argv'] for c in r['commands']]==[c['argv'] for c in p['commands']]
assert r['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
assert prep['status']=='ORDINARY_PREPARATION_PASS_NO_BACKEND' and len(prep['probes'])==3
assert [q['argv'] for q in prep['probes']]==p['preparationProbeCommands']
for q in prep['probes']+r['ordinaryGuardProbes']:
 assert q['seconds']==5 and q['result']['exit']==0 and q['result']['failure'] is None
assert len(r['ordinaryGuardProbes'])==24
for label in ['emit','compile','candidate']:
 assert at('cohort/'+label+'.stderr')==b''
 for stream in ['stdout','stderr']:assert sha(at('cohort/'+label+'.'+stream))==r['logs'][label+'.'+stream]
assert at('cohort/emit.stdout')==at('cohort/compile.stdout')==b''
assert len(at('cohort/candidate.stdout'))==3335 and len(at('cohort/candidate.stdout').splitlines())==16
assert at('cohort/candidate.stdout')==at('cohort/stage/study/EXPECTED.stdout')
for n,h in p['inventory'].items():assert sha(at('cohort/stage/'+n))==h
assert {key[len('cohort/stage/'):]:h for key,h in i['files'].items() if key.startswith('cohort/stage/')}==p['inventory']
for n,h in p['rootJoins'].items():
 assert sha(path(n))==h
 relative=str(Path(n).relative_to('/workspace/formal-proofs/bendvy/src/ecs'))
 assert sha(at('cohort/stage/src/ecs/'+relative))==h
for n,h in p['pins'].items():
 if n in i['pathKeys']:assert sha(path(n))==h
 else:assert (n in i['excluded'] and i['excluded'][n]['sha256']==h) or n+'@'+h in i['historicalUnavailable']
for n,h in r['generated'].items():
 if n in i['pathKeys']:assert sha(path(n))==h
 else:assert i['excluded'][n]['sha256']==h
jp=json.loads(path(p['normalJSReuse']['plan']));jr=json.loads(path(p['normalJSReuse']['receipt']))
assert jr['planSHA256']==sha(path(p['normalJSReuse']['plan'])) and jr['status']=='DEVELOPMENT_PREFLIGHT_FULL16_PASS_NOT_DELIVERY'
jroot=str(Path(p['normalJSReuse']['receipt']).parent)
assert path(jroot+'/candidate.stdout')==at('cohort/candidate.stdout') and path(jroot+'/candidate.stderr')==b''
tr=jp['referenceReuse'];tsr=json.loads(path(tr['receipt']));tsp=str(Path(tr['receipt']).parent/'plan.json')
assert tsr['status']=='INCOMPLETE' and tsr['planSHA256']==sha(path(tsp)) and tsr['commands'][0]['label']=='reference' and tsr['commands'][0]['exit']==0 and tsr['commands'][0]['failure'] is None
assert sha(path(tr['raw']))==tsr['logs']['reference.stdout'] and len(path(tr['raw']).splitlines())==16
print('PASS portable Native full16 / actual JS16 / separate TS16-inside-INCOMPLETE; no child execution or full56 credit')
