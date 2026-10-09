"""No-child lossless O1 incomplete evidence joins."""
from pathlib import Path
import gzip,hashlib,json
D=Path(__file__).resolve().parent/'evidence-v1'
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((D/'MANIFEST.json').read_text());raw={}
for x in m['members']:
 z=(D/x['gzip']).read_bytes();b=gzip.decompress(z)
 assert sha(z)==x['gzipSHA256'] and sha(b)==x['sha256'] and len(b)==x['bytes']
 raw[x['name']]=b
assert set(x.name for x in D.glob('*.gz'))=={x['gzip'] for x in m['members']}
p=json.loads(raw['plan.json']);r=json.loads(raw['receipt.json'])
assert sha(raw['plan.json'])==r['planSHA256']=='d5f73fa25834748be6cb6794cfb5e9b444e5af1870eedcbff50afef213d7c549'
assert r['status']=='INCOMPLETE' and r['guardFailures']==[] and len(r['commands'])==1
c=r['commands'][0];assert c['failure']=='child deadline' and c['exit'] is None and c['capSeconds']==120
assert c['argv']==p['cohorts'][0]['commands'][0]['argv']
base=dict(p['pins']);base['/tmp/bendvy-debug56-held-clang-O1-v1/plan.json']=r['planSHA256']
for g in r['guards']:
 n=Path(g['path']).name;b=raw[n];assert sha(b)==g['sha256'];v=json.loads(b);expected=dict(base)
 if v['label'] in ['normal-O1-build-post','final']:
  for k in ['stdout','stderr']:expected[c[k]['path']]=c[k]['sha256']
 assert v['unchanged'] and v['actualPins']==expected
for k in ['stdout','stderr']:
 b=raw[Path(c[k]['path']).name];assert sha(b)==c[k]['sha256'] and len(b)==c[k]['bytes']
assert len(r['guards'])==4 and 'artifactLedger' not in r
print('PASS lossless8 members, exact plan, incomplete build, four complete evolving guards, both raw streams; no runtime acceptance')
