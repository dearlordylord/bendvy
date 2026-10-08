"""Portable no-child checks of finite complete Check diagnostic controls."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
with tarfile.open(H/'evidence.tar.gz') as t:
 members=t.getmembers();assert len({m.name for m in members})==len(members) and all(m.isfile() for m in members);raw={m.name:t.extractfile(m).read() for m in members}
assert raw['index.json']==(H/'index.json').read_bytes();i=json.loads(raw['index.json']);rows={r['name']:r for r in i['records']};assert len(rows)==len(i['records']) and set(raw)=={'index.json'}|{'objects/'+r['SHA256'] for r in rows.values()}
f={}
for n,row in rows.items():
 b=raw['objects/'+row['SHA256']];assert sha(b)==row['SHA256'] and len(b)==row['bytes'];f[n]=b
prefix='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/'
def path(n):return 'worktree/'+n[len(prefix):] if n.startswith(prefix) else 'external/'+n.lstrip('/')
def obj(n):return json.loads(f[n])
a=i['actual'];p=obj(a+'/plan.json');r=obj(a+'/receipt.json');q=obj(a+'/prepare-receipt.json')
assert sha(f[a+'/plan.json'])=='69ffb7f1a432d152b6b47d5829b7092ce9a7538355eb2c4ee2ae6755f11d9f76'==r['planSHA256']
assert sha(f[a+'/receipt.json'])=='c6e0baada28d82ab35635874f26c2782b277316fc66db24a8c3bf07e53b79fbd'
assert sha(f[a+'/prepare-receipt.json'])=='2bfd28b283c51397ff691f95dd86b51f559fc37cc86f033a3ce853e961005c19'
assert r['status']=='DEVELOPMENT_FOUR_REACHED_CHECK_CONTROLS_FULL192_DIAGNOSTICS_JS_PASS_NOT_FULL55' and not r.get('guardFailures')
assert q['status']=='OWNED_JS_PREPARATION_PASS' and not q.get('guardFailures') and q['probeCommandsExecuted']==4
plans=[json.loads(b) for n,b in f.items() if n.endswith('/plan.json') and 'pins' in json.loads(b)]
private={q['privateEnvironment']:q['environmentSHA256'] for q in plans if 'privateEnvironment' in q}
for n,row in i['excluded'].items():
 if n in private:assert row['reason']=='private environment identity only' and row['SHA256']==private[n]
 elif n=='/home/node/.npmrc':assert row['reason']=='private participating configuration identity only' and p['configuration'][n]['SHA256']==row['SHA256']
 else:assert row['reason']=='installed ELF identity only' and p['tools']['pins'][n]==row['SHA256']
controlManifest=next(n for n in p['pins'] if n.endswith('/reached-check-controls-v1/source-oracle-manifest.json'))
controlPrefix=str(Path(controlManifest).parent)+'/'
failurePrefix=path(controlPrefix+'review-eb78-undefined-String-show')
with tarfile.open(fileobj=io.BytesIO(f[failurePrefix+'/four-closures.tar.gz'])) as old:
 members=old.getmembers();assert len(members)==232 and len({m.name for m in members})==232 and all(m.isfile() for m in members)
 oldSources={m.name:old.extractfile(m).read() for m in members}
def pinbytes(n,d,old=False):
 if path(n) in f and sha(f[path(n)])==d:return f[path(n)]
 if old and n.startswith(controlPrefix):
  rel=n[len(controlPrefix):]
  if rel in oldSources:assert sha(oldSources[rel])==d;return oldSources[rel]
  if rel in ('collector.py','collector-proposal.json','source-oracle-manifest.json'):
   b=f[failurePrefix+'/'+rel];assert sha(b)==d;return b
 assert i['excluded'][n]['SHA256']==d
 return None
for name,bytes_ in f.items():
 if not name.endswith('/plan.json'):continue
 plan=json.loads(bytes_)
 if 'pins' not in plan:continue
 old=sha(bytes_)=='eb78cdf3b60f0ac5cc9c63052d51d3c3ba5bea7fdb0bb9d9879562f6576a4e80'
 for n,d in plan['pins'].items():pinbytes(n,d,old)
assert private[p['privateEnvironment']]==p['environmentSHA256']
stagePrefix=path(p['stage'])+'/'
assert {n[len(stagePrefix):] for n in f if n.startswith(stagePrefix)}==set(p['inventory'])
for n,d in p['inventory'].items():assert sha(f[stagePrefix+n])==d
for row in p['stageImportJoins']:
 assert sha(f[path(row['source'])])==sha(f[path(row['copy'])]) and sha(f[path(row['originalTarget'])])==sha(f[path(row['actualTarget'])])==row['SHA256']
def probes(record,labels,directory):
 expected={str(Path(directory)/(label+suffix)) for label in labels for suffix in ('.json','.stdout','.stderr')}
 assert set(record['probePins'])==expected and record['probeCommandsExecuted']==len(labels)
 assert {n for n in f if n.startswith(path(directory)+'/')}=={path(n) for n in expected}
 for n,d in record['probePins'].items():assert sha(f[path(n)])==d
 for label in labels:
  tool=label.rsplit('-',1)[-1];meta=obj(path(str(Path(directory)/(label+'.json'))))
  assert meta['argv']==[p['tools']['taskset'],'-c','5',p['tools']['ldd'],p['tools']['tools'][tool]] and meta['seconds']==5 and meta['exit']==0 and meta['failure'] is None and meta.get('collectionError') is None
  assert meta['runnerSHA256']==p['pins'][prefix+'scripts/task_runner.py']
probes(q,['prepare-'+n for n in ('bend','node','python','taskset')],prefix+a[len('worktree/'):]+'/prepare-probes')
probes(r,p['executionProbeLabels'],prefix+a[len('worktree/'):]+'/execution-probes')
assert p['executionProbeLabels']==['guard-'+str(k)+'-'+n for k in range(17) for n in ('bend','node','python','taskset')]
assert len(p['commands'])==len(r['commands'])==8
assert set(r['logs'])=={c['label']+s for c in p['commands'] for s in ('.stdout','.stderr')}
for n,d in r['logs'].items():assert sha(f[a+'/'+n])==d
notice=f[path(prefix+'experiments/public-relations/inspector-extension-study-v1/pinned-bend-notice.bytes')]
assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
assert set(r['generated'])=={c['artifact'] for c in p['commands'] if 'artifact' in c}
for n,d in r['generated'].items():assert n.endswith('.js') and sha(f[path(n)])==d
names=('normal','outgoing-filter-negated','incoming-order-reversed','world-valid-omitted')
def strict(v):
 if isinstance(v,dict):return ('dict',tuple((k,strict(x)) for k,x in sorted(v.items())))
 if isinstance(v,list):return ('list',tuple(map(strict,v)))
 return (type(v).__name__,v)
def differences(a,b,p=''):
 if type(a)!=type(b):return [{'path':p,'normal':a,'mutant':b}]
 if isinstance(a,dict):
  result=[]
  for key in sorted(a.keys()|b.keys()):
   if key not in a or key not in b:result.append({'path':p+'/'+key,'normal':a.get(key),'mutant':b.get(key)})
   else:result+=differences(a[key],b[key],p+'/'+key)
  return result
 if isinstance(a,list):
  if len(a)!=len(b):return [{'path':p,'normal':a,'mutant':b}]
  return [d for k,(x,y) in enumerate(zip(a,b)) for d in differences(x,y,p+'/'+str(k))]
 return [] if a==b else [{'path':p,'normal':a,'mutant':b}]
normal=None
for k,(pc,rc) in enumerate(zip(p['commands'],r['commands'])):
 name=names[k//2];emit=k%2==0
 assert pc['variant']==name and pc['label']==('emit-' if emit else 'js-')+name and all(pc[key]==rc[key] for key in pc) and rc['status']=='QUALIFIED' and rc['exit']==0 and rc['failure'] is None
 assert pc['seconds']==(30 if emit else 5) and pc['argv'][:4]==['taskset','-c','5','bend' if emit else 'node']
 out=f[a+'/'+pc['label']+'.stdout'];err=f[a+'/'+pc['label']+'.stderr']
 if emit:
  assert out==b'' and err in (b'',notice) and pc['argv'][-2:]==['-o',pc['artifact']]
  assert path(pc['argv'][4]) in f and sha(f[path(pc['argv'][4])])==p['pins'][pc['argv'][4]]
 else:
  assert pc['argv'][4]==p['commands'][k-1]['artifact'] and err==b''
  text=out.decode();actual,end=json.JSONDecoder().raw_decode(text);assert text[end:]=='\n'
  expected=obj(path(pc['oracle']));assert strict(actual)==strict(expected) and rc['fullOracleMatched'] and rc['oracleSHA256']==sha(f[path(pc['oracle'])])
  assert len(actual['schemas'])==2 and sum(len(ph['queries']) for schema in actual['schemas'] for ph in schema['phases'])==192
  assert all(schema['phaseChecks']==[{'done':name=='normal'}]*3 for schema in actual['schemas'])
  if name=='normal':normal=actual
  else:
   witnessPath=str(Path(pc['oracle']).parent/'expected-witnesses.json');witness=obj(path(witnessPath));assert strict(differences(normal,actual))==strict(witness) and len(witness)==(334,372,588)[k//2-1]==rc['witnesses'] and rc['witnessSHA256']==sha(f[path(witnessPath)])
# Source feasibility prerequisite and retained failed source attempt stay distinct.
s='worktree/.artifacts/check-relation55-reached-controls-source-1791461742993446675';sp=obj(s+'/plan.json');sr=obj(s+'/receipt.json')
assert sha(f[s+'/plan.json'])==p['sourcePlanSHA256']=='d44d63ed30f13a934be3ed14c205e84aed1d44fda93c397f9a1174f4a3c338f3'
assert sha(f[s+'/receipt.json'])==p['sourceReceiptSHA256']=='2d3ec9bb271a098c3c9fd8c804724fdbaf739dcbaad0672807450a2b258b3ee6'
assert sr['status']=='DEVELOPMENT_FOUR_CHECK_CONTROL_SOURCES_FEASIBLE_NOT_RUNTIME' and not sr.get('guardFailures') and len(sr['commands'])==4
assert set(sr['logs'])=={n+s for n in names for s in ('.stdout','.stderr')}
for n,d in sr['logs'].items():assert sha(f[s+'/'+n])==d
for pc,rc in zip(sp['commands'],sr['commands']):
 assert all(pc[key]==rc[key] for key in pc) and pc['argv'][-1]=='--check-only' and pc['seconds']==5 and pc['argv'][1:3]==['-c','5'] and rc['exit']==0 and rc['failure'] is None
 assert f[s+'/'+pc['label']+'.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and f[s+'/'+pc['label']+'.stderr'] in (b'',notice)
root=H
while not (root/'experiments').is_dir():root=root.parent
selected=json.loads((H/'delivery-files.json').read_text())
for row in selected['files']:assert sha((root/row['path']).read_bytes())==row['SHA256']
x=H.parent;manifest=json.loads((x/'source-oracle-manifest.json').read_text())
for row in manifest['normalAndVariants']:
 for source in row['sources']:assert sha((root/source['path']).read_bytes())==source['SHA256']==sha(f['worktree/'+source['path']])
 assert sha((root/row['oracle']['path']).read_bytes())==row['oracle']['SHA256']==sha(f['worktree/'+row['oracle']['path']])
failed='worktree/'+str((x/'review-eb78-undefined-String-show').relative_to(root))
fp=obj(failed+'/plan.json');fr=obj(failed+'/receipt.json');assert sha(f[failed+'/plan.json'])==fr['planSHA256']==manifest['retainedFailure']['planSHA256'] and sha(f[failed+'/receipt.json'])==manifest['retainedFailure']['receiptSHA256'];assert fr['status']=='INCOMPLETE' and not fr.get('guardFailures') and len(fr['commands'])==1 and fr['commands'][0]['label']=='normal' and fr['commands'][0]['exit']==1 and fr['commands'][0]['failure'] is None
for n,d in fr['logs'].items():assert sha(f[failed+'/'+n])==d
assert f[failed+'/normal.stdout']==b'' and b'observed : String.show' in f[failed+'/normal.stderr']
assert sha(f[failed+'/four-closures.tar.gz'])==manifest['retainedFailure']['fourClosureArchiveSHA256']
print('PASS: full normal+three Check controls JS; exact334/372/588 reached witnesses; source failure retained; no Native/proof/performance/full55 claim')
