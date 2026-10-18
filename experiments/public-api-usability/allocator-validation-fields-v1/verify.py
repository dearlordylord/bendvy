from pathlib import Path
import json,gzip,hashlib,zipfile,sys
D=Path(sys.argv[1]);sha=lambda b:hashlib.sha256(b).hexdigest();m=json.loads((D/'MANIFEST.json').read_text());assert sha((D/'EVIDENCE.zip').read_bytes())==m['zipSHA256'];data={}
with zipfile.ZipFile(D/'EVIDENCE.zip')as z:
 assert set(z.namelist())=={r['member']for r in m['members']if'member'in r}
 for r in m['members']:
  if 'member'not in r:
   assert r['hashOnly']=='Installed ELF tool/shared-library identity, not redistributed';data[r['origin'],r['sha256']]=None;continue
  raw=z.read(r['member']);assert len(raw)==r['bytes']and sha(raw)==r['sha256'];data[r['origin'],r['sha256']]=raw
def raw(n,h=None):
 a=[v for(k,d),v in data.items()if k==str(n)and(h is None or h==d)];assert len(a)==1,(n,len(a));return a[0]
def obj(n,h=None):return json.loads(raw(n,h))
guards=0
for case in m['cases']:
 q=Path(case['directory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and sha(raw(q/'plan.json'))==r['planSHA256']
 for n,h in p['pins'].items():assert(n,h)in data
 for root,files in p['resourceRoots'].items():
  for rel,h in files.items():assert(str(Path(root)/rel),h)in data
 for g in r['guards']:
  x=obj(g['path'],g['sha256']);assert x['unchanged'];guards+=1
 for c in r['commands']:
  assert c['exit']==0 and c['failure']is None
  for k in ['stdout','stderr']:v=c[k];assert len(raw(v['path'],v['sha256']))==v['bytes']
 assert raw(q/'consumer.stderr')==b'';a=raw(q/'consumer.stdout');assert a==gzip.decompress(raw(p['oracle'],p['pins'][p['oracle']]))and(len(a),sha(a))==(p['oracleBytes'],p['oracleSHA256'])
print(json.dumps({'status':'PORTABLE_PASS','cases':len(m['cases']),'members':len(data),'guards':guards,'fullWorkshopBytes':231190,'fullIdentityBytes':23126,'scope':'Correctness and retained diagnostic bytes only; no performance gate acceptance'}))
