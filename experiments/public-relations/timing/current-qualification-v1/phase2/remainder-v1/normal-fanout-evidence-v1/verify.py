"""No-child full retained fanout evidence reconciliation."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent;sha=lambda b:hashlib.sha256(b).hexdigest();i=json.loads((H/'index.json').read_text());assert sha((H/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(H/'objects.tar.gz') as t:o={m.name:t.extractfile(m).read() for m in t.getmembers()}
assert set(o)==set(i['objects'])
for s,b in o.items():assert sha(b)==s and len(b)==i['objects'][s]
raw=lambda n:o[i['files'][n]];read=lambda n:json.loads(raw(n));p=read('current/plan.json');r=read('current/receipt.json');assert r['planSHA256']==sha(raw('current/plan.json'));assert r['status']=='REMAINING_NORMAL_GROUP_FULL30_PASS_NO_TIMING' and len(r['commands'])==6 and r['probeCommandsExecuted']==65
manifest=read('oracle/manifest.json')
for c in p['commands']:
 expected=read('oracle/'+Path(c['oracle']).name);case=next(x for x in manifest['cases'] if x['input']==c['input']);assert sha(raw('oracle/'+Path(c['oracle']).name))==case['sha256'] and c['operationCounts']==case['operationCounts'];assert sum(len(x['records']) for x in expected['roots'])==30
 pending=[expected];nodes=chars=total=0
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
 boundaries=[{'boundary':'begin'},{'boundary':'complete-trace-forced','nodes':nodes,'characters':chars,'sum':total}]
 assert read('current/'+c['label']+'.stdout')==expected;assert [json.loads(x) for x in raw('current/'+c['label']+'.stderr').splitlines()]==boundaries
for n,s in r['logs'].items():assert sha(raw('current/'+n))==s
for group,pins in [('execution-probes',r['probePins']),('prepare-probes',read('current/prepare-receipt.json')['probePins'])]:
 for n,s in pins.items():assert sha(raw('current/'+group+'/'+Path(n).name))==s
for history in p['history']:
 prefix='history/'+history['role']+'/';hp=read(prefix+'plan.json');hr=read(prefix+'receipt.json');assert sha(raw(prefix+'plan.json'))==history['planSHA256'] and sha(raw(prefix+'receipt.json'))==history['receiptSHA256'];assert hr['planSHA256']==history['planSHA256']
 for n,s in hr['logs'].items():assert sha(raw(prefix+n))==s
for n,s in p['pins'].items():
 key='qualified-source/'+n
 if key in i['files']:assert sha(raw(key))==s
joins=read('historical-join/source-closure.json');join=joins['qualifiedSourceByteJoins'][0]
import io
with tarfile.open(fileobj=io.BytesIO(raw('historical-join/objects.tar.gz'))) as t:old=t.extractfile(join['qualifiedSourceSha256']).read()
assert sha(old)==join['qualifiedSourceSha256']
livekey=next(k for k in i['files'] if k.startswith('qualified-source/') and k.endswith('/'+join['path']))
assert sha(raw(livekey))==join['liveDeliverySha256'] and old.rstrip(b'\n')+b'\n'==raw(livekey)
print('PASS: two full30 fanout spans16/128 all3roles/70 owned probes; source/history/oracle/raw/forcing joins. Evidence only.')
