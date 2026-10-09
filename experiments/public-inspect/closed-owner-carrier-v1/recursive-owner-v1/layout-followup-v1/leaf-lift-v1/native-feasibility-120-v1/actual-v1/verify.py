from pathlib import Path
import json,gzip,hashlib
here=Path(__file__).resolve().parent;m=json.loads((here/'FILES.json').read_bytes());files={};ids={}
for r in m['members']:
 raw=gzip.decompress((here/r['object']).read_bytes());assert len(raw)==r['bytes'] and hashlib.sha256(raw).hexdigest()==r['sha256'];assert r['path'] not in files;files[r['path']]=raw;ids[r['path']]=r['sha256']
for r in m['externalIdentityOnly']:ids[r['path']]=r['sha256']
prefix=m['root']+'/';assert ids[prefix+'plan.json']==m['planSHA256'];p=json.loads(files[prefix+'plan.json']);r=json.loads(files[prefix+'receipt.json'])
assert all(ids[k]==v for k,v in p['pins'].items());assert len(p['sourceInventory'])==len(p['importClosure'])==46
assert [c['capSeconds']for c in p['commands']]==[120,120,5]
assert r['planSHA256']==m['planSHA256'] and r['status']=='INCOMPLETE' and 'Owned child failed: emit' in r['error']
assert len(r['commands'])==1 and len(r['guards'])==4
c=r['commands'][0];assert c['argv']==p['commands'][0]['argv'] and c['exit']is None and c['failure']=='child deadline'
for key in ('stdout','stderr'):
 s=c[key];assert s['published'] and files[s['path']]==b'' and ids[s['path']]==s['sha256']
a=c['childAccounting'];assert a['wallNs']==120820771473
for key in ('userSeconds','systemSeconds'):assert a[key]==a['after'][key]-a['before'][key] and a[key]>=0
assert p['generated'] not in files and p['native'] not in files
for g in r['guards']:
 assert ids[g['path']]==g['sha256'];v=json.loads(files[g['path']]);assert v['unchanged'] and all(ids[k]==h for k,h in v['actualPins'].items())
e=gzip.decompress(files[p['oracle']]);assert len(e)==5077477 and hashlib.sha256(e).hexdigest()==p['oracleSHA256']
print('PASS',len(files),'lossless members/fullsource-oracle/fourguards/emit120deadline/CPU-wall; no replay')
