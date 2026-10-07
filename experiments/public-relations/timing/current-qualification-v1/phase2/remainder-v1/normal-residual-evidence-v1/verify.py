"""No-child population failure and separate Native128 evidence reconciliation."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent;sha=lambda b:hashlib.sha256(b).hexdigest()
def capsule(h):
 i=json.loads((h/'index.json').read_text());assert sha((h/'objects.tar.gz').read_bytes())==i['archiveSHA256']
 with tarfile.open(h/'objects.tar.gz') as t:o={m.name:t.extractfile(m).read() for m in t.getmembers()}
 assert set(o)==set(i['objects'])
 for s,b in o.items():assert sha(b)==s and len(b)==i['objects'][s]
 return i,lambda n:o[i['files'][n]]
i,raw=capsule(H);_,depth=capsule(H.parent/'normal-depth-evidence-v1');read=lambda n:json.loads(raw(n));manifest=read('oracle/manifest.json')
for group,count in [('population',20),('native128',15)]:
 p=read(group+'/plan.json');r=read(group+'/receipt.json');assert r['planSHA256']==sha(raw(group+'/plan.json')) and r['probeCommandsExecuted']==count
 for name,s in r['logs'].items():assert sha(raw(group+'/'+name))==s
 for name,s in r['probePins'].items():assert sha(raw(group+'/execution-probes/'+Path(name).name))==s
 if group=='population':
  assert r['status']=='INCOMPLETE' and r['error']=='child deadline' and r['commands']==[{'label':'0-ts','exit':0,'failure':None}]
  c=p['commands'][0];case=next(x for x in manifest['cases'] if x['input']==c['input']);oracle=raw('oracle/'+Path(c['oracle']).name);assert sha(oracle)==case['sha256'] and raw(group+'/0-ts.stdout')==oracle
  expected=json.loads(oracle);assert sum(len(x['records']) for x in expected['roots'])==30
  assert raw(group+'/0-js.stdout')==b'' and raw(group+'/0-js.stderr')==b'{"boundary":"begin"}\n'
  assert all(group+'/'+label+'.stdout' not in i['files'] for label in ['0-native','1-ts','1-js','1-native'])
  prep=read(group+'/prepare-receipt.json');assert prep['probeCommandsExecuted']==5
  for name,s in prep['probePins'].items():assert sha(raw(group+'/prepare-probes/'+Path(name).name))==s
 else:
  assert len(p['commands'])==1 and r['commands']==[{'label':'2-native','exit':0,'failure':None}] and r['status']=='REMAINING_NORMAL_GROUP_FULL30_PASS_NO_TIMING'
  assert raw(group+'/2-native.stdout')==depth('current/2-ts.stdout')==raw('oracle/'+Path(p['commands'][0]['oracle']).name)
  assert raw(group+'/2-native.stderr')==depth('current/2-ts.stderr')
  assert p['retainedPartialDepth']['receiptSHA256']==sha(depth('current/receipt.json')) and p['retainedPartialDepth']['planSHA256']==sha(depth('current/plan.json'))
for n,s in read('population/plan.json')['pins'].items():
 key='qualified-source/'+n
 if key in i['files']:assert sha(raw(key))==s
print('PASS evidence only: population TS full30/JS Begin-only timeout/unexecuted remainder; separate Native128 full30 and15guards, no wholegroup acceptance.')
