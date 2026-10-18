from pathlib import Path
import gzip,hashlib,json,sys
b=Path(sys.argv[1]);d=json.loads((b/'RETENTION.json').read_text());m={r['actualPath']:r for r in d['members']};assert len(m)==len(d['members']);sha=lambda x:hashlib.sha256(x).hexdigest();seen=set();tools=set()
for r in m.values():
 if 'object'in r:
  p=b/r['object'];assert sha(p.read_bytes())==r['objectSHA256'];v=gzip.decompress(p.read_bytes());assert len(v)==r['bytes']and sha(v)==r['sha256'];seen.add(r['object'])
def raw(p):return gzip.decompress((b/m[str(p)]['object']).read_bytes())
def obj(p):return json.loads(raw(p))
def pin(p,h):assert m[str(p)]['sha256']==h
assert len(d['current'])==6;guards=0
for a in d['current']:
 q=Path(a['actualDirectory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==a['sha256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==a['receiptSHA256'];assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'
 for n,h in p['pins'].items():pin(n,h)
 for root,files in p['resourceRoots'].items():
  for n,h in files.items():s=str(Path(root)/n);pin(s,h);tools.add(s)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);v=obj(g['path']);assert v['unchanged'];guards+=1
  for n,h in v['actualPins'].items():pin(n,h)
 assert len(r['commands'])==len(p['commands'])
 for c,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert c[k]==e[k]
  assert c['exit']==0 and c['failure'] is None and c['stderr']['bytes']==0
  for stream in ['stdout','stderr']:pin(c[stream]['path'],c[stream]['sha256']);assert m[c[stream]['path']]['bytes']==c[stream]['bytes']
 actual=raw(q/'consumer.stdout');assert actual==gzip.decompress(raw(p['oracle']))and len(actual)==p['oracleBytes']and sha(actual)==p['oracleSHA256']
for r in m.values():
 if 'hashOnly'in r:assert r['actualPath']in tools
assert len(seen)==d['objects']==len(list((b/'objects').iterdir()))
print('PASS',len(m),'members',len(seen),'objects',guards,'guards; six public full consumers; manifest',sha((b/'RETENTION.json').read_bytes()))
