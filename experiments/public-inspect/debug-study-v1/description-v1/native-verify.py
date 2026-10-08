"""Verify portable Native description full9 capsule without tools or live original paths."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent;E=H/'native-evidence-v1';sha=lambda b:hashlib.sha256(b).hexdigest()
i=json.loads((E/'index.json').read_text());assert sha((E/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(E/'objects.tar.gz') as t:
 assert len(t.getnames())==len(set(t.getnames())) and set(t.getnames())==set(i['objects'])
 assert all(m.isfile() for m in t.getmembers())
 objects={n:t.extractfile(n).read() for n in t.getnames()}
assert all(sha(b)==h and len(b)==i['objects'][h] for h,b in objects.items())
assert all(h in objects for h in i['files'].values())
def at(key):return objects[i['files'][key]]
nested=json.loads(at('delivery/evidence-v1/index.json'));nestedraw=at('delivery/evidence-v1/objects.tar.gz')
assert sha(nestedraw)==nested['archiveSHA256']
with tarfile.open(fileobj=io.BytesIO(nestedraw)) as archive:
 assert len(archive.getnames())==len(set(archive.getnames())) and set(archive.getnames())==set(nested['objects'])
 assert all(m.isfile() for m in archive.getmembers())
 nestedobjects={m.name:archive.extractfile(m).read() for m in archive.getmembers()}
assert all(sha(b)==h and len(b)==nested['objects'][h] for h,b in nestedobjects.items())
def path(n):
 if n in i['pathKeys']:return at(i['pathKeys'][n])
 return nestedobjects[nested['files'][nested['pathKeys'][n]]]
p=json.loads(at('cohort/plan.json'));r=json.loads(at('cohort/receipt.json'));prep=json.loads(at('cohort/prepare-receipt.json'))
assert sha(at('cohort/plan.json'))==r['planSHA256']=='03d43379edc214b1194698e22c895c52084477f66b23fcfece5371b684563918'
assert r['status']=='NATIVE_DESCRIPTION_FULL9_QUALIFIED_NOT_FULL56_NOT_PROOF_NOT_PERFORMANCE' and r.get('guardFailures',[])==[]
assert sha(at('cohort/receipt.json'))=='114a402b399d42c5a370e1a648413621b3c9d8190cff4f5c5bc0f90717a0da7e'
assert set(r['logs'])=={label+'.'+stream for label in ['emit','compile','candidate'] for stream in ['stdout','stderr']}
assert [c['label'] for c in r['commands']]==['emit','compile','candidate']
assert all(all(c[k]==p['commands'][j][k] for k in p['commands'][j]) for j,c in enumerate(r['commands']))
assert [c['seconds'] for c in r['commands']]==[30,120,5] and all(c['exit']==0 and c['failure'] is None for c in r['commands'])
assert [c['argv'] for c in r['commands']]==[c['argv'] for c in p['commands']]
assert r['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
assert prep.get('guardFailures',[])==[]
assert prep['status']=='ORDINARY_PREPARATION_PASS_NO_BACKEND' and len(prep['probes'])==3
assert [q['argv'] for q in prep['probes']]==p['preparationProbeCommands']
for q in prep['probes']+r['ordinaryGuardProbes']:
 assert q['seconds']==5 and q['result']['exit']==0 and q['result']['failure'] is None
assert len(r['ordinaryGuardProbes'])==24
for label in ['emit','compile','candidate']:
 assert at('cohort/'+label+'.stderr')==b''
 for stream in ['stdout','stderr']:assert sha(at('cohort/'+label+'.'+stream))==r['logs'][label+'.'+stream]
assert at('cohort/emit.stdout')==at('cohort/compile.stdout')==b''
assert len(at('cohort/candidate.stdout'))==5688 and len(at('cohort/candidate.stdout').splitlines())==9
assert at('cohort/candidate.stdout')==at('cohort/stage/study/EXPECTED.stdout')
for n,h in p['inventory'].items():assert sha(at('cohort/stage/'+n))==h
assert {key[len('cohort/stage/'):]:h for key,h in i['files'].items() if key.startswith('cohort/stage/')}==p['inventory']
for n,h in p['rootJoins'].items():
 assert sha(path(n))==h
 relative=str(Path(n).relative_to('/workspace/formal-proofs/bendvy/src/ecs'))
 assert sha(at('cohort/stage/src/ecs/'+relative))==h
for n,h in {**p['pins'],**p['toolSnapshot']['pins']}.items():
 if n in i['pathKeys']:assert sha(path(n))==h
 else:assert (n in i['excluded'] and i['excluded'][n]['sha256']==h) or n+'@'+h in i['historicalUnavailable']
for n,h in r['generated'].items():
 if n in i['pathKeys']:assert sha(path(n))==h
 else:assert i['excluded'][n]['sha256']==h
jp=json.loads(path(p['normalJSReuse']['plan']));jr=json.loads(path(p['normalJSReuse']['receipt']))
assert jr['planSHA256']==sha(path(p['normalJSReuse']['plan'])) and jr['status']=='DEVELOPMENT_DESCRIPTION_FULL9_PASS_NOT_DELIVERY_NOT_FORMAT_PUBLICATION'
jroot=str(Path(p['normalJSReuse']['receipt']).parent)
assert path(jroot+'/candidate.stdout')==at('cohort/candidate.stdout') and path(jroot+'/candidate.stderr')==b''
assert sha(path(p['normalJSReuse']['plan']))=='a1a5af87ea5aba1dda8706f3ee392480f3e9a4f70462ee058d40f969373e05fd'
assert jr.get('guardFailures',[])==[]
assert [(c['label'],c['seconds'],c['exit'],c['failure']) for c in jr['commands']]==[('emit',30,0,None),('candidate',5,0,None)]
assert all(all(c[k]==jp['commands'][j][k] for k in jp['commands'][j]) for j,c in enumerate(jr['commands']))
assert set(jr['logs'])=={'emit.stdout','emit.stderr','candidate.stdout','candidate.stderr'}
assert all(sha(path(jroot+'/'+n))==h for n,h in jr['logs'].items())
assert path(jroot+'/emit.stdout')==b'' and path(jroot+'/emit.stderr') in [b'',b'bend 2.0.36 is available: run bend update\n']
assert {str(Path(n).relative_to(jp['stage'])):i['files'][key] for n,key in i['pathKeys'].items() if n.startswith(jp['stage']+'/')}==jp['inventory']
assert all(sha(path(str(Path(jp['stage'])/n)))==h for n,h in jp['inventory'].items())
for n,h in jp['pins'].items():
 if n in i['pathKeys']:assert sha(path(n))==h
 else:assert (n in i['excluded'] and i['excluded'][n]['sha256']==h) or n+'@'+h in i['historicalUnavailable']
assert all(sha(path(n))==h for n,h in jr['generated'].items())
tr=jp['referenceReuse'];tsr=json.loads(path(tr['receipt']));tsp=tr['plan']
assert sha(path(tsp))==tr['planSHA256']=='2ee2dce254e940d8521afc4842f026a9b3a350c0586abf03447b0eb31ebb6e97'
assert sha(path(tr['receipt']))==tr['receiptSHA256']
assert all(tsr['commands'][0][k]==json.loads(path(tsp))['commands'][0][k] for k in ['label','argv','seconds'])
assert tsr['status']=='DEVELOPMENT_REFERENCE_FULL9_PASS_NOT_DELIVERY' and tsr['planSHA256']==sha(path(tsp)) and tsr.get('guardFailures',[])==[]
assert len(tsr['commands'])==1 and tsr['commands'][0]['label']=='reference' and tsr['commands'][0]['seconds']==5 and tsr['commands'][0]['exit']==0 and tsr['commands'][0]['failure'] is None
assert set(tsr['logs'])=={'reference.stdout','reference.stderr'}
troot=str(Path(tr['receipt']).parent)
assert all(sha(path(troot+'/'+name))==digest for name,digest in tsr['logs'].items()) and path(troot+'/reference.stderr')==b''
rows=[json.loads(line) for line in path(troot+'/reference.stdout').splitlines()];oracle=json.loads(at('cohort/stage/study/ORACLE.json'))['cases']
assert len(rows)==9 and [row['scoped'] for row in rows]==oracle and all(row['before']==row['after'] for row in rows)
assert [json.loads(line) for line in at('cohort/candidate.stdout').splitlines()]==oracle
print('PASS portable Native description full9 / actual JS9 / separate actual TS9; no child execution or full56 credit')
