from pathlib import Path
import gzip,hashlib,json,sys
L=Path(sys.argv[1]);d=json.loads((L/'RETENTION.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();members={(r['actualPath'],r['sha256']):r for r in d['members']};assert len(members)==len(d['members']);seen={};context={};tools=set();guards=0;outputs={}
for r in members.values():
 if'object'not in r:assert r['hashOnly']=='Installed tool/shared library identity only; not redistributed';continue
 p=L/r['object'];assert p.resolve().is_relative_to(L.resolve())and sha(p.read_bytes())==r['objectSHA256']and p.name==r['sha256']+'.gz'
 if r['object']not in seen:
  raw=gzip.decompress(p.read_bytes());seen[r['object']]=(sha(raw),len(raw))
 assert seen[r['object']]==(r['sha256'],r['bytes'])
assert len(seen)==d['objects']==len(list((L/'objects').iterdir()))
def pin(name,h):assert(str(name),h)in members,(name,h);context[str(name)]=h
def raw(name):
 name=str(name);rs=[r for(p,h),r in members.items()if p==name and(name not in context or h==context[name])];assert len(rs)==1,(name,len(rs));return gzip.decompress((L/rs[0]['object']).read_bytes())
def obj(name):return json.loads(raw(name))
assert len(d['cases'])==7
for case in d['cases']:
 q=Path(case['directory']);p=obj(q/'plan.json');r=obj(q/'receipt.json');assert sha(raw(q/'plan.json'))==case['planSHA256']==r['planSHA256']and sha(raw(q/'receipt.json'))==case['receiptSHA256'];assert not r.get('guardFailures',[])
 for name,h in p['pins'].items():pin(name,h)
 for root,files in p['resourceRoots'].items():
  for rel,h in files.items():name=str(Path(root)/rel);pin(name,h);tools.add(name)
 tools.update(p['tools'].values());assert len(r['commands'])==len(p['commands'])
 for g in r['guards']:
  pin(g['path'],g['sha256']);g=obj(g['path']);assert g['unchanged'];guards+=1
  for name,h in g['actualPins'].items():pin(name,h)
 for command,declared in zip(r['commands'],p['commands']):
  assert all(command[k]==declared[k]for k in ['label','argv','capSeconds']);assert command['failure']is None and command['exit']==declared.get('expectedExit',0)
  for key in ['stdout','stderr']:v=command[key];pin(v['path'],v['sha256']);assert len(raw(v['path']))==v['bytes']
  for token in declared.get('stderrContains',[]):assert token.encode()in raw(q/(command['label']+'.stderr'))
 kind=case['kind']
 if kind=='authority':assert r['status']=='COMPLETE_SOURCE_CONTROL_PASS'and[x['exit']for x in r['commands']]==[0,1,1,1];continue
 assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and raw(q/'consumer.stderr')==b'';actual=raw(q/'consumer.stdout');gold=gzip.decompress(raw(p['oracle']));assert actual==gold and len(actual)==p['oracleBytes']and sha(actual)==p['oracleSHA256'];outputs[kind,case['role']]=actual
for r in members.values():
 if'object'not in r:assert r['actualPath']in tools
expected={'workshop':(4468,'8b42644395353528bd7272329ad6286d07619f3f8e20712ae12905bf607b15ee'),'garden':(4466,'787a6e49f516f07dc5aec522f2445bbd6cc4b39a6d919f01d54ea293eda7e4fd'),'refusal':(1276,'b34f744302dad830833020a5a7792fae6b106f3f2e67c2997aa4c00ea4f9ea16')}
for kind,(size,h)in expected.items():
 a=outputs[kind,'js'];assert a==outputs[kind,'native']and(len(a),sha(a))==(size,h)
root=next(Path(r['actualPath']).parent.parent for r in members.values()if r['actualPath'].endswith('/oracle/refusal-model.py'))
for rel,arg,expected in [('oracle/amendment01/model.py','Workshop',outputs['workshop','js']),('oracle/amendment01/model.py','Garden',outputs['garden','js']),('oracle/refusal-model.py',None,outputs['refusal','js'])]:
 ns={'__name__':'model_control','__file__':str(root/rel)};exec(compile(raw(root/rel),str(root/rel),'exec'),ns);assert ns['generate'](*([]if arg is None else[arg]))==expected
old=Path('/tmp/bendvy73-captured-query-workshop-actual01/normal/js');p=obj(old/'plan.json');r=obj(old/'receipt.json');assert r['status']=='INCOMPLETE'and r['planSHA256']==sha(raw(old/'plan.json'));assert raw(old/'consumer.stdout')==outputs['workshop','js']and raw(old/'consumer.stderr')==b'';assert gzip.decompress(raw(p['oracle']))!=outputs['workshop','js']
assert not any(x['actualPath']=='/tmp/bendvy73-captured-query-workshop-actual01/normal/native/receipt.json'for x in members.values())
print(json.dumps({'status':'PORTABLE_PASS','cases':7,'backendStreams':6,'sourceExpectedExits':[0,1,1,1],'guards':guards,'members':len(members),'objects':len(seen),'independentModelsReproduced':3,'workshopBytes':4468,'gardenBytes':4466,'refusalBytes':1276,'failedOriginalPreserved':True,'nativeOriginalUnexecuted':True}))
