from pathlib import Path
import json,gzip,hashlib
h=Path(__file__).resolve().parent;m=json.loads((h/'FILES.json').read_bytes());f={};ids={}
for x in m['members']:
 raw=gzip.decompress((h/x['object']).read_bytes());assert len(raw)==x['bytes']and hashlib.sha256(raw).hexdigest()==x['sha256'];assert x['path']not in f;f[x['path']]=raw;ids[x['path']]=x['sha256']
for x in m['externalIdentityOnly']:assert x['path']not in ids;ids[x['path']]=x['sha256']
index=json.loads(f[m['index']]);summary=json.loads((h/'SUMMARY.json').read_bytes());assert len(index['plans'])==2
expectedPlans={'drop':'6fc49aab630baa48852b9ce85027a44c3199bd7468304dd9d4b7aee3122c3fde','reorder':'1726c42608afe2cd50ba58b4d38d9f246f56170e110950834fe55685b3d8242a'}
for row,stored in zip(index['plans'],summary):
 p=json.loads(f[row['plan']]);r=json.loads(f[str(Path(row['plan']).parent/'receipt.json')]);assert ids[row['plan']]==row['sha256']==r['planSHA256']==expectedPlans[row['name']]
 assert all(ids[k]==v for k,v in p['pins'].items())
 for root,inv in p['resourceRoots'].items():assert all(ids[str(Path(root)/k)]==v for k,v in inv.items())
 assert len(p['sourceInventory'])==46 and all(ids[str(Path(p['stage'])/k)]==v for k,v in p['sourceInventory'].items())
 assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and r['wholeBaselineRejected']and not r.get('error')and not r.get('guardFailures')
 assert len(r['commands'])==len(p['commands'])==3 and [c['label']for c in r['commands']]==['emit','build','consumer']
 assert [c['capSeconds']for c in r['commands']]==[30,120,5]and '-O0'in p['commands'][1]['argv']
 for c,q in zip(r['commands'],p['commands']):
  assert c['argv']==q['argv']and c['capSeconds']==q['capSeconds']and c['exit']==0 and c['failure']is None
  for k in ['stdout','stderr']:
   v=c[k];assert v['published']and ids[v['path']]==v['sha256']and len(f[v['path']])==v['bytes']
  if c['label']!='emit':assert f[c['stderr']['path']]==b''
 assert len(r['guards'])==10
 for x in r['guards']:
  assert ids[x['path']]==x['sha256'];g=json.loads(f[x['path']]);assert g['unchanged']and all(ids[k]==v for k,v in g['actualPins'].items())
 assert ids[p['generated']]==r['emitArtifactSHA256']and ids[p['native']]==r['buildArtifactSHA256']
 raw=f[r['commands'][-1]['stdout']['path']];counter=gzip.decompress(f[p['oracle']]);baseline=gzip.decompress(f[p['baselineOracle']]);assert raw==counter and len(raw)==p['oracleBytes']and hashlib.sha256(raw).hexdigest()==p['oracleSHA256']==r['wholeOracleSHA256'];assert raw!=baseline and len(baseline)==5077477 and hashlib.sha256(baseline).hexdigest()=='810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'
 for key in ['priorCompleteJS','priorCompleteNormalNative']:
  old=p[key];assert ids[old['plan']]==old['planSHA256']and ids[old['receipt']]==old['receiptSHA256'];previous=json.loads(f[old['receipt']]);assert previous['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and previous['planSHA256']==old['planSHA256']
 assert stored=={'name':row['name'],'planSHA256':row['sha256'],'commands':3,'guards':10,'status':r['status'],'wholeOracleSHA256':r['wholeOracleSHA256'],'wholeBaselineRejected':True}
print('PASS',len(f),'lossless members/two full reached Native countermodels+whole baseline refusals/six commands/twenty guards/C+ELF/current-input joins; no replay/performance or stock compiler claim')
