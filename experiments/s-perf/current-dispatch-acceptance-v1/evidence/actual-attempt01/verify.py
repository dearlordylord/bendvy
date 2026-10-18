from pathlib import Path
import gzip,hashlib,json,sys,tempfile,subprocess
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
assert len(d['cases'])==5
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
normal=outputs['normal','js'];counter=outputs['inverse','js'];assert normal==outputs['normal','native']and counter==outputs['inverse','native']and normal!=counter
assert(len(normal),sha(normal))==(3401,'8f972be7029025b4cb249031159fef31677978ae47790137cb719348581a6d96')
assert(len(counter),sha(counter))==(3403,'c180f7bb0ab1e1c64bc8a95682f170c6f8a24ab3dbbb98079e22c85ebc1c798a')
root=next(Path(r['actualPath']).parent for r in members.values()if r['actualPath'].endswith('/oracle/model.py')and'/controls/inverse-order/source/'not in r['actualPath'])
with tempfile.TemporaryDirectory(prefix='dispatch-portable-model-')as tmp:
 t=Path(tmp)
 for name in ['dense_state.py','model.py','counter-model.py']:(t/name).write_bytes(raw(root/name))
 for name,expected in [('model.py',normal),('counter-model.py',counter)]:
  code='import runpy,sys;sys.stdout.buffer.write(runpy.run_path('+repr(name)+',run_name="model-control")["generate"]())';result=subprocess.run([sys.executable,'-c',code],cwd=t,capture_output=True,timeout=120);assert result.returncode==0 and result.stderr==b''and result.stdout==expected
# Prove the retained private closure changes exactly the reached rollback body.
basis=obj(root.parent/'SOURCE-BASIS.json');changes=obj(root.parent/'CONTROLS-BASIS.json')['mutation']['changes'];assert len(changes)==1
for path,h in {**basis['sourceInventory'],**basis['foreign']}.items():
 original=raw(path)
 # Derive relocation only from the single source-bound path pair.
 oldroot=changes[0]['original'].removesuffix('/src/ecs/transaction.bend');newroot=changes[0]['mutant'].removesuffix('/src/ecs/transaction.bend');newpath=newroot+path.removeprefix(oldroot);copied=raw(newpath)
 if path==changes[0]['original']:assert copied==original.replace(b'rollback(~W, rest, inverse(world))',b'inverse(rollback(~W, rest, world))')and copied!=original
 else:assert copied==original
print(json.dumps({'status':'PORTABLE_PASS','cases':5,'backendStreams':4,'sourceExpectedExits':[0,1,1,1],'guards':guards,'members':len(members),'objects':len(seen),'normalBytes':len(normal),'counterBytes':len(counter),'normalRejectedByBothDefectRoles':True,'independentModelsReproduced':2,'privateClosureDifferences':1}))
