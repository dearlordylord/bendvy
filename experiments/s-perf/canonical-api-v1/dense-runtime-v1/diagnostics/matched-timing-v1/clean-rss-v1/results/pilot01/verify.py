from pathlib import Path
import json,gzip,hashlib,sys
B=Path(sys.argv[1]) if len(sys.argv)>1 else Path('/tmp/bendvy-dense-clean-rss/experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/matched-timing-v1/clean-rss-v1/results/pilot01');d=json.loads((B/'RETENTION.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();rows={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(rows)==len(d['members']);seen={};context={};tools=set();guards=0;stats={}
for r in rows.values():
 if 'object' not in r:assert r['hashOnly']=='Installed tool/shared library identity only; not redistributed';continue
 p=B/r['object'];assert sha(p.read_bytes())==r['objectSHA256'] and p.name==r['sha256']+'.gz'
 if r['object'] not in seen:
  raw=gzip.decompress(p.read_bytes());seen[r['object']]=(sha(raw),len(raw))
 assert seen[r['object']]==(r['sha256'],r['bytes'])
def pin(path,h):assert (str(path),h) in rows,(path,h);context[str(path)]=h
def raw(path,h=None):
 path=str(path);h=h or context.get(path);choices=[r for (name,x),r in rows.items() if name==path and (h is None or x==h)];assert len(choices)==1,(path,h);return gzip.decompress((B/choices[0]['object']).read_bytes())
def obj(path,h=None):return json.loads(raw(path,h))
assert len(d['cases'])==3 and {c['kind']for c in d['cases']}=={'normal-js','normal-native','finite-controls'}
normal=[]
for case in d['cases']:
 q=Path(case['directory']);p=obj(q/'plan.json',case['planSHA256']);r=obj(q/'receipt.json',case['receiptSHA256']);assert sha(raw(q/'plan.json',case['planSHA256']))==r['planSHA256'];context={}
 for f,h in p['pins'].items():pin(f,h)
 for root,files in p['resourceRoots'].items():
  for f,h in files.items():name=str(Path(root)/f);pin(name,h);tools.add(name)
 tools.update(p['tools'].values())
 for g in r['guards']:
  pin(g['path'],g['sha256']);guard=obj(g['path']);assert guard['unchanged'];guards+=1
  for f,h in guard['actualPins'].items():pin(f,h)
 assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and len(r['commands'])==len(p['commands'])
 for a,e in zip(r['commands'],p['commands']):
  for k in ['label','argv','capSeconds']:assert a[k]==e[k]
  assert a['failure']is None and a['exit']==e.get('expectedExit',0)
  for k in ['stdout','stderr']:v=a[k];pin(v['path'],v['sha256']);assert len(raw(v['path']))==v['bytes']
 if case['kind'].startswith('normal-'):
  assert [x['label']for x in p['commands']]==['source-fresh','build','consumer','source-rss'];assert raw(q/'consumer.stderr')==b''
  canonical=raw(q/'consumer.stdout');assert canonical==gzip.decompress(raw(p['oracle']))and len(canonical)==226988 and sha(canonical)==p['oracleSHA256']=='0375eec332d8509226d2eafd8b5d48ac592f38caf6f89c30f449b9599d1a2ebf'
  rss=obj(p['cleanChildRSS']['path']);assert list(rss)==['launcherPeakRssKiB','childPeakRssKiB','exitCode']and all(type(x)is int and x>=0 for x in rss.values())and rss['exitCode']==0
  v=obj(q/'source-rss.stdout');assert v['status']=='CLEAN_CHILD_RSS_TRANSPORT_PASS'and len(v['sidecars'])==3
  for entry in v['sidecars']:assert sha(raw(entry['path']))==entry['sha256']and len(raw(entry['path']))==entry['bytes']
  predecessor=p['cleanChildRSS'];old=obj(predecessor['producerPlan'],predecessor['producerPlanSHA256']);assert raw(old['generated'])==raw(p['generated'])
  assert r['buildArtifactSHA256']==sha(raw(p['native']));normal.append(rss)
 else:
  assert [x['label']for x in p['commands']]==['source-transport','build','source-floor']
  text=raw(q/'source-transport.stdout').decode();assert text.splitlines()==['valid PASS','negative PASS','boolean PASS','child-failure PASS','missing PASS','existing-refused PASS','symlink-refused PASS']
  f=obj(p['floorControls']['output']);assert f==obj(q/'source-floor.stdout')and f['status']=='RETAINED_OBSERVER_FLOOR_CONTROLS_PASS'and len(f['rows'])==6
  assert [(x['mode'],x['child'])for x in f['rows']]==[(m,c)for m in ['small-parent','retained-192MiB-parent']for c in ['true','node-empty','touched32MiB']]
  for row in f['rows']:
   assert obj(row['rssPath'],row['rssSHA256'])==row['rss']and row['rss']['exitCode']==0
   assert row['viaLauncher']['argv'][:2]==[p['floorControls']['launcher'],row['rssPath']]and row['viaLauncher']['argv'][2:]==row['direct']['argv']
  large=f['rows'][3:];assert all(x['rss']['childPeakRssKiB']<x['direct']['outerWait4KiB']for x in large)and len({x['rss']['childPeakRssKiB']for x in large})>1
  assert sha(raw(p['floorControls']['launcher']))==p['floorControls']['launcherBuildArtifactSHA256']
assert len(normal)==2
# Independently check the archived producer bytes and import-only guard rehome.
recovery_paths=[name for name,h in rows if name.endswith('/clean-rss-v1/SOURCE-RECOVERY.json')];assert len(set(recovery_paths))==1
recovery=obj(recovery_paths[0]);assert recovery
for old,entry in recovery.items():
 original=raw(entry['archivedOriginal'],entry['sha256']);guard=raw(entry['guardImportRebase'],entry['guardSHA256'])
 oldprefix='/tmp/bendvy-dense-plan-once';newprefix=entry['guardImportRebase'].split('/source-epoch8f/')[0]+'/source-epoch8f'
 assert guard==original.replace(oldprefix.encode(),newprefix.encode())
for row in rows.values():
 if 'hashOnly'in row:assert row['actualPath']in tools
assert len(seen)==d['objects']==len(list((B/'objects').iterdir()));print('PASS',len(rows),'members',len(seen),'objects',guards,'guards; two full226988 canonical pilots, six finite floor controls and parser refusals; whole-child including warmup, no allocation/comparative summary',sha((B/'RETENTION.json').read_bytes()))
