from pathlib import Path
import gzip,json,hashlib
h=Path(__file__).resolve().parent;m=json.loads((h/'FILES.json').read_bytes());f={};ids={}
for row in m['members']:
 raw=gzip.decompress((h/row['object']).read_bytes());assert len(raw)==row['bytes']and hashlib.sha256(raw).hexdigest()==row['sha256'];assert row['path']not in f;f[row['path']]=raw;ids[row['path']]=row['sha256']
for row in m['externalIdentityOnly']:assert row['path']not in ids;ids[row['path']]=row['sha256']
index=json.loads(f[m['index']]);p=json.loads(f[index['plan']]);r=json.loads(f[str(Path(index['plan']).parent/'receipt.json')]);assert ids[index['plan']]==index['sha256']==r['planSHA256']=='9461187ecfa8078428751c1b5a4f18569ecd241c9df571cf45ce457d5eb5aa30'
assert all(ids[k]==v for k,v in p['pins'].items())
for root,inv in p['resourceRoots'].items():assert all(ids[str(Path(root)/k)]==v for k,v in inv.items())
assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and not r.get('error')and not r.get('guardFailures')
assert len(p['sourceInventory'])==46 and all(ids[str(Path(p['stage'])/k)]==v for k,v in p['sourceInventory'].items())
assert len(p['commands'])==len(r['commands'])==2 and [x['label']for x in r['commands']]==['build','consumer']
assert p['commands'][0]['capSeconds']==120 and '-O0'in p['commands'][0]['argv']and p['commands'][1]['capSeconds']==5
for c,q in zip(r['commands'],p['commands']):
 assert c['argv']==q['argv']and c['capSeconds']==q['capSeconds']and c['exit']==0 and c['failure']is None
 for key in ['stdout','stderr']:
  v=c[key];assert v['published']and ids[v['path']]==v['sha256']and len(f[v['path']])==v['bytes']
 assert f[c['stderr']['path']]==b''
assert len(r['guards'])==7
for row in r['guards']:
 assert ids[row['path']]==row['sha256'];g=json.loads(f[row['path']]);assert g['unchanged']and all(ids[k]==v for k,v in g['actualPins'].items())
prior=p['retainedC'];old=json.loads(f[prior['receipt']]);assert ids[prior['plan']]==prior['planSHA256']==r['retainedCPlanSHA256']==old['planSHA256'];assert old['commands'][0]['label']=='emit'and old['commands'][0]['exit']==0 and old['commands'][0]['failure']is None
assert ids[p['generated']]==prior['sha256']==old['emitArtifactSHA256']==r['emitArtifactSHA256']=='f34a985bbe6a69dacfb1109cdc169aa1cb9e83aab2accf842a9f7a497a333143';assert ids[p['native']]==r['buildArtifactSHA256']
raw=f[r['commands'][1]['stdout']['path']];expected=gzip.decompress(f[p['oracle']]);assert raw==expected and len(raw)==p['oracleBytes']==5077477 and hashlib.sha256(raw).hexdigest()==p['oracleSHA256']==r['wholeOracleSHA256']=='810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'
print('PASS',len(f),'lossless members/exact retained C lineage/O0 build+whole5077477 Native output/seven guards; no replay/performance or stock compiler claim')
