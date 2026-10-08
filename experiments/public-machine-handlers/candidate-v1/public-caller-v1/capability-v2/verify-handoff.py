"""Read-only portable verification of selected caller archive/source/raw/oracle joins."""
import hashlib,io,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;D=H/'delivery-v2'
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((D/'manifest.json').read_text());old=Path(m['historicalRoot'])
assert all(sha((H/n).read_bytes())==h for n,h in m['source'].items())
assert sha((D/'REPORT.md').read_bytes())==m['reportSHA256']
blob=(D/m['archive']['name']).read_bytes();assert sha(blob)==m['archive']['sha256']
with tarfile.open(fileobj=io.BytesIO(blob),mode='r:gz') as t:
 assert all(f.isfile() for f in t.getmembers())
 assert len(t.getmembers())==len({f.name for f in t.getmembers()})
 files={f.name:t.extractfile(f).read() for f in t.getmembers()}
assert set(files)==set(m['archive']['members'])
for n,item in m['archive']['members'].items():assert sha(files[n])==item['sha256'] and len(files[n])==item['bytes']
def absolute(path):return str(Path(path).relative_to(old))
def raw(path):return files[absolute(path)]
def qualify(name,count,subjects,planSHA=None):
 p=json.loads(files[name+'/plan.json']);r=json.loads(files[name+'/receipt.json'])
 assert sha(files[name+'/plan.json'])==r['planSHA256']
 if planSHA:assert r['planSHA256']==planSHA
 assert r['probeCommandsExecuted']==count and len(r['commands'])==subjects
 assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
 stage=absolute(p['stage']);prefix=stage+'/'
 assert {n[len(prefix):] for n in files if n.startswith(prefix)}==set(p['inventory'])
 for rel,h in p['inventory'].items():assert sha(files[prefix+rel])==h
 assert set(r['probePins'])=={str(old/name/'execution-probes'/(label+'.'+ext)) for label in p['executionProbeLabels'] for ext in ['json','stdout','stderr']}
 assert {n for n in files if n.startswith(name+'/execution-probes/')}=={absolute(n) for n in r['probePins']}
 for path,h in r['probePins'].items():assert sha(raw(path))==h
 for rel,h in r['logs'].items():assert sha(files[name+'/'+rel])==h
 for c in p['commands']:assert files[name+'/'+c['label']+'.stderr']==b''
 for path,h in r.get('generated',{}).items():
  key=absolute(path)
  if key in files:assert sha(files[key])==h
 return p,r
authority='authority-source-1791432764067041420'
ap=json.loads(files[authority+'/plan.json']);ar=json.loads(files[authority+'/receipt.json']);ac=json.loads(files[authority+'/independent-classification.json'])
assert ar['planSHA256']==sha(files[authority+'/plan.json'])=='7c9c761df15eaf04f47649dcc1d3ca1c258a37d3e6ea3b54a8e0b62834b853c0'
assert ar['status']=='CURRENT_CAPABILITY_CALLER_MATCHED_SOURCE_AND_FOUR_RAW_REFUSALS_COLLECTED_UNCLASSIFIED'
assert ac['originalCollectorReceiptSHA256']==sha(files[authority+'/receipt.json'])
assert ac['status']=='INDEPENDENT_FULL_RAW_FOUR_INTENDED_REFUSALS_CLASSIFIED'
assert set(ac['classifications'])=={'negative-undeclared','negative-read-write','negative-cross-schema','negative-owner-duplication'}
assert ar['probeCommandsExecuted']==65 and len(ar['commands'])==6
astage=absolute(ap['stage']);aprefix=astage+'/'
assert {n[len(aprefix):] for n in files if n.startswith(aprefix)}==set(ap['inventory'])
for rel,h in ap['inventory'].items():assert sha(files[aprefix+rel])==h
assert [c['label'] for c in ap['commands']]==['main','authority-positive','negative-undeclared','negative-read-write','negative-cross-schema','negative-owner-duplication']
for command,result,exitcode in zip(ap['commands'],ar['commands'],[0,0,1,1,1,1]):
 assert result['exit']==exitcode and result['failure'] is None
 label=command['label'];source=files[absolute(command['argv'][4])]
 assert source==(H/(label+'.bend')).read_bytes()
 if exitcode==0:
  assert files[authority+'/'+label+'.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
  assert files[authority+'/'+label+'.stderr']==b''
 else:assert files[authority+'/'+label+'.stdout']==b''

assert set(ar['probePins'])=={str(old/authority/'execution-probes'/(label+'.'+ext)) for label in ap['executionProbeLabels'] for ext in ['json','stdout','stderr']}
for path,h in ar['probePins'].items():assert sha(raw(path))==h
for n,h in ar['logs'].items():assert sha(files[authority+'/'+n])==h
for label,c in ac['classifications'].items():
 assert c['classification']=='INDEPENDENTLY_REVIEWED_INTENDED_CONCRETE_TYPE_QUANTITY_REFUSAL'
 assert sha(files[authority+'/'+label+'.stdout'])==c['stdoutSHA256'] and sha(files[authority+'/'+label+'.stderr'])==c['stderrSHA256']
 assert sha((H/(label+'.bend')).read_bytes())==c['sourceSHA256']
oracle=json.loads((H/'expected-draft.json').read_text())['rows']
def pairs(items):
 d={}
 for k,v in items:assert k not in d;d[k]=v
 return d
def canonical(x):return json.dumps(x,sort_keys=True,separators=(',',':'))
js='cheap-js-1791432710709125093';p,r=qualify(js,25,2)
assert r['status']=='INDEPENDENT_CALLER_FOURTEEN_COMPLETE_JS_OBSERVATIONS_PASS'
observed=json.loads(files[js+'/caller-consume.stdout'],object_pairs_hook=pairs)
assert canonical(observed)==canonical(oracle)
a='native-runtime-A-1791433304208921455';b='native-runtime-B-1791433305186823405'
collected={};union=b''
for name,schema,count,subjects,digest in [(a,'A',25,2,'0e0284fc04506f9b5b25d35fd669b250ddb4596873dcd097aab86a83f7418a35'),(b,'B',45,4,'825d0c2f90f2df2bd014a73f29da5e41ae05259213e2315dc17e98f3716147ac')]:
 p,r=qualify(name,count,subjects,digest);assert r['status']=='CAPABILITY_CALLER_SCHEMA_'+schema+'_SEVEN_COMPLETE_NATIVE_OBSERVATIONS_PASS'
 body=files[name+'/caller-'+schema+'-run.stdout'];union+=body;rows=body.decode().splitlines();keys=[k for k in oracle if k.startswith(schema+'_')];assert len(rows)==len(keys)==7
 for key,line in zip(keys,rows):
  k,value=line.split('|',1);assert k==key;value=json.loads(value,object_pairs_hook=pairs);assert canonical(value)==canonical(oracle[k]);collected[k]=value
assert canonical(collected)==canonical(oracle)
full='native-full14-reconciliation-20261008';fr=json.loads(files[full+'/receipt.json'])
assert fr['status']=='CURRENT_CALLER_FOURTEEN_COMPLETE_NATIVE_OBSERVATIONS_RECONCILED'
assert files[full+'/full14.stdout']==union and sha(union)==fr['fullRawSHA256']
assert canonical(fr['observations'])==canonical(oracle)
for path,h in {**fr['sourcePlans'],**fr['sourceReceipts']}.items():assert sha(raw(path))==h
print('FINITE_CAPABILITY_CALLER_SOURCE_JS_NATIVE_ARCHIVE_AND_FULL14_ORACLE_JOINS_PASS')
