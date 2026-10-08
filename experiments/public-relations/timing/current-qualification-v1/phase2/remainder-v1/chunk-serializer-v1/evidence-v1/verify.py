"""Reconcile retained finite serializer evidence without executing child processes."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent;sha=lambda b:hashlib.sha256(b).hexdigest();i=json.loads((H/'index.json').read_text());assert sha((H/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(H/'objects.tar.gz') as t:o={m.name:t.extractfile(m).read() for m in t.getmembers()}
assert set(o)==set(i['objects'])
for s,b in o.items():assert sha(b)==s and len(b)==i['objects'][s]
raw=lambda n:o[i['files'][n]];read=lambda n:json.loads(raw(n))
def force(v):
 pending=[v];nodes=chars=total=0
 while pending:
  v=pending.pop();nodes=(nodes+1)&0xffffffff
  if v is None:total+=1
  elif isinstance(v,bool):total+=5 if v else 4
  elif isinstance(v,int):total+=2+v
  elif isinstance(v,str):total+=3;chars+=len(v);total+=sum(map(ord,v))
  elif isinstance(v,list):total+=6;pending.extend(reversed(v))
  else:
   total+=7
   for k,x in reversed(list(v.items())):pending.extend([x,k])
  total&=0xffffffff;chars&=0xffffffff
 return [{'boundary':'begin'},{'boundary':'complete-trace-forced','nodes':nodes,'characters':chars,'sum':total}]
pr=read('pure/receipt.json');assert pr['status']=='PURE_FIVE_FIELD_CONTROLS_DEVELOPMENT_PASS_NOT_PROOF' and pr['planSHA256']==sha(raw('pure/plan.json'));assert raw('pure/controls.stdout')==raw('authored/expected-controls.stdout');assert raw('pure/controls.stderr') in [b'',raw('authored/pinned-notice.stderr')]
for n,s in pr['logs'].items():assert sha(raw('pure/'+n))==s
manifests=[read('oracle/remainder-manifest.json'),read('oracle/initial-manifest.json')]
for role,status,count,probes in [('first','CHUNK_DEPTH128_COMPLETE30_JS_PASS_NO_TIMING',2,20),('extension','CHUNK_BOUNDED_CONTROLS_JS_PASS_NO_TIMING',7,60)]:
 p=read(role+'/plan.json');r=read(role+'/receipt.json');assert r['planSHA256']==sha(raw(role+'/plan.json')) and r['status']==status and len(r['commands'])==count and r['probeCommandsExecuted']==probes;assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
 for c in p['commands']:
  if 'oracle' in c or 'forcedOracle' in c:
   name=Path(c.get('oracle',c.get('forcedOracle'))).name;expected=read('oracle/'+name);assert sum(len(x['records']) for x in expected['roots'])==30;case=next(x for m in manifests for x in m['cases'] if Path(x['expected']).name==name);assert sha(raw('oracle/'+name))==case['sha256'];assert [json.loads(x) for x in raw(role+'/'+c['label']+'.stderr').splitlines()]==force(expected)
   if 'oracle' in c:assert read(role+'/'+c['label']+'.stdout')==expected
  if 'refusal' in c:
   assert raw(role+'/'+c['label']+'.stdout')==c['refusal'].encode()
   if 'forcedOracle' not in c:assert raw(role+'/'+c['label']+'.stderr')==b''
 for n,s in r['logs'].items():assert sha(raw(role+'/'+n))==s
 prep=read(role+'/prepare-receipt.json');assert prep['status']=='OWNED_TOOL_PREPARATION_PASS' and prep['probeCommandsExecuted']==4
 for group,pins in [('execution-probes',r['probePins']),('prepare-probes',prep['probePins'])]:
  for n,s in pins.items():assert sha(raw(role+'/'+group+'/'+Path(n).name))==s
 for path,s in p['pins'].items():
  key='qualified-source/'+path.split('/parity-42-relations/',1)[-1]
  if key in i['files']:assert sha(raw(key))==s
hp=read('historical-depth/plan.json');hr=read('historical-depth/receipt.json');assert hr['status']=='INCOMPLETE' and hr['planSHA256']==sha(raw('historical-depth/plan.json'));assert raw('historical-depth/2-js.stdout')==b'';assert raw('historical-depth/2-js.stderr')==raw('historical-depth/2-ts.stderr');assert len(hr['commands'])==7 and hr['probeCommandsExecuted']==80
for n,s in hr['logs'].items():assert sha(raw('historical-depth/'+n))==s
assert read('failed-preparation/prepare-receipt.json')['probeCommandsExecuted']==0
assert raw('exhaustion-source/source.stdout')==b'' and b'Error: 9 defs rely on unsafe or foreign code:' in raw('exhaustion-source/source.stderr')
print('PASS: retained finite full30 serializer cases/pure controls/refusals/source/history/probes; no backend rerun, Native, population1024, proof or timing qualification.')
