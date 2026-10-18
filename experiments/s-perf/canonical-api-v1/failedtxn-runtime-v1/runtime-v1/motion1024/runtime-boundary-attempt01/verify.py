from pathlib import Path
import json,gzip,hashlib,sys,statistics,io
b=Path(sys.argv[1]);sha=lambda x:hashlib.sha256(x).hexdigest();d=json.loads((b/'RETENTION.json').read_text());members={r['actualPath']:r for r in d['members']};assert len(members)==len(d['members']);seen={}
allowed=[b.resolve()]+[(b/x['manifest']).resolve().parent for x in d['objectDependencies']]
for dep in d['objectDependencies']:assert sha((b/dep['manifest']).read_bytes())==dep['sha256']
for r in members.values():
 if 'object' not in r:assert r['hashOnly']=='Installed tool/shared library identity only; not redistributed';continue
 p=(b/r['object']).resolve();assert p.parent.name=='objects' and p.parent.parent in allowed;assert p.name==r['sha256']+'.gz'
 if p not in seen:
  assert sha(p.read_bytes())==r['objectSHA256'];h=hashlib.sha256();n=0
  with gzip.open(p,'rb') as f:
   while chunk:=f.read(1048576):h.update(chunk);n+=len(chunk)
  seen[p]=(h.hexdigest(),n)
 assert seen[p]==(r['sha256'],r['bytes'])
def raw(path):return gzip.decompress((b/members[str(path)]['object']).read_bytes())
def obj(path):return json.loads(raw(path))
def pin(path,h):assert members[str(path)]['sha256']==h,(path,h)
for original,v in d['historicalPolicySnapshots'].items():pin(original,v['sha256']);pin(v['snapshot'],v['sha256']);assert members[original]['historicalSourceSnapshot']==v['snapshot']
assert len(d['cases'])==14;counts={};guards=0;compared=set();metrics={};tools=set()
for a in d['cases']:
 q=Path(a['actualDirectory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==a['planSHA256']==r['planSHA256'];assert sha(raw(q/'receipt.json'))==a['receiptSHA256'];assert not r.get('guardFailures',[])
 for path,h in p['pins'].items():pin(path,h)
 for root,files in p['resourceRoots'].items():
  for name,h in files.items():path=str(Path(root)/name);pin(path,h);tools.add(path)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);v=obj(g['path']);assert v['unchanged'];guards+=1
  for path,h in v['actualPins'].items():pin(path,h)
 assert len(p['commands'])==len(r['commands'])==1;c=r['commands'][0];e=p['commands'][0]
 for k in ['argv','label','capSeconds']:assert c[k]==e[k]
 for k in ['stdout','stderr']:
  v=c[k];pin(v['path'],v['sha256']);assert members[v['path']]['bytes']==v['bytes']
 kind=a['kind'];counts[kind]=counts.get(kind,0)+1;mp=str(q/'child-metrics.json')
 if kind.startswith('control-'):
  assert raw(c['stdout']['path'])==b'wrapper-control-out\n' and raw(c['stderr']['path'])==b'wrapper-control-err\n'
  if kind=='control-timeout':
   assert r['status']=='INCOMPLETE' and c['failure']=='child deadline' and c['exit'] is None and c['capSeconds']==1 and mp not in members
   # Identity record is retained; original execution cleanup was checked by root. Do not test later reused live PIDs.
   identities=obj(q/'timeout-pids.json');assert identities
  else:
   assert c['exit']=={'control-success':0,'control-exit7':7,'control-signal':-15}[kind] and c['failure'] is None
  continue
 assert raw(c['stderr']['path'])==b'';assert p['runtimeArguments']==['1024','64'];bt=p['boundaryTrial'];pin(bt['wrapper'],bt['wrapperSHA256']);assert bt['wrapperSHA256']=='243f6e4e9f52764bf44312ede48e97a5a6c32f9bc756c024a318103618d3485e';assert bt['childArgv'][1:3]==['-c','11']
 producer=p['producer']
 for field in ['plan','receipt','generated']:
  pin(producer[field],producer[field+'SHA256'])
 pr=obj(producer['receipt']);assert pr['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS' and pr['planSHA256']==producer['planSHA256']
 if p['role']=='native':pin(producer['native'],producer['nativeSHA256'])
 for path,h in p['foreignConsumption']['sidecars'].items():pin(path,h)
 output=members[c['stdout']['path']];oracle=members[p['oracle']];pair=(output['object'],oracle['object'])
 if pair not in compared:
  with gzip.open(b/output['object'],'rb') as actual,gzip.GzipFile(fileobj=io.BytesIO(raw(p['oracle']))) as expected:
   while chunk:=actual.read(1048576):assert chunk==expected.read(len(chunk))
   if kind=='complete30':assert expected.read(1)==b''
   else:assert expected.read(1)!=b''
  compared.add(pair)
 if kind=='deadline15':
  assert c['capSeconds']==15 and c['exit'] is None and c['failure']=='child deadline' and r['status']=='INCOMPLETE' and mp not in members
  assert (output['bytes'],output['sha256'])=={'js':(222312450,'44f610e9713ba940bd0e90e9e8b4427f77b0ef3750b7c68772a238f13cef1878'),'native':(300023808,'f117e7bfa198299fdca0bb8078e350c3e5c7522ec0ac2d243184433ed4009159')}[p['role']]
 else:
  assert kind=='complete30' and c['capSeconds']==30 and r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS' and c['exit']==0 and c['failure'] is None
  assert (output['bytes'],output['sha256'])==(444624902,'b46c21923f303fc17c04c31b6af7fef16b45223883356d81c3e94a9c469ed0de')
  m=obj(mp);assert m['argv']==bt['childArgv'] and m['childInheritsProcessGroup'] is True;assert m['elapsedSeconds']==(m['perfCounterEndNs']-m['perfCounterStartNs'])/1e9;assert m['returncode']==0;assert m['elapsedSeconds']>0 and m['userSeconds']>=0 and m['systemSeconds']>=0 and m['maxRssKiB']>0;metrics[str(q)]=(p,r,m)
assert counts=={'control-success':1,'control-exit7':1,'control-signal':1,'control-timeout':1,'deadline15':2,'complete30':8}
s=obj(d['summary']);assert s['selectedConsumerCapSeconds']==30 and len(s['rows'])==8
for row in s['rows']:
 q=Path(row['plan']).parent;pp,rr,mm=metrics[str(q)];pin(row['plan'],row['planSHA256']);pin(q/'receipt.json',row['receiptSHA256']);pin(row['metrics'],row['metricsSHA256'])
 for k in ['elapsedSeconds','userSeconds','systemSeconds','maxRssKiB']:assert row[k]==mm[k]
# Summary values are recomputed from the retained child metrics, independently of collector elapsed time.
for role in ['js','native']:
 values=[m['elapsedSeconds'] for p,r,m in metrics.values() if p['role']==role];assert len(values)==4
 assert s['stats'][role]['count']==4 and s['stats'][role]['minSeconds']==min(values) and s['stats'][role]['maxSeconds']==max(values) and s['stats'][role]['medianSeconds']==statistics.median(values)
 print(role,'min',min(values),'max',max(values),'median',statistics.median(values))
for x in d['drafts']:assert x['status']=='UNEXECUTED_RAW_ONLY';obj(x['path'])
for r in members.values():
 if 'hashOnly'in r:assert r['actualPath']in tools
assert len(list((b/'objects').iterdir()))==d['objects'];print('PASS',len(members),'members',len(seen),'objects',guards,'guards',counts,'manifest',sha((b/'RETENTION.json').read_bytes()))
