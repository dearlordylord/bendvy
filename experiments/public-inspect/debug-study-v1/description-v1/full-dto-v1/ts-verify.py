"""Verify portable actual TS2 development evidence without subprocesses."""
from pathlib import Path
import json,hashlib,tarfile
H=Path(__file__).resolve().parent;E=H/'ts-evidence-v1';i=json.loads((E/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest()
assert sha((E/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(E/'objects.tar.gz') as tar:
 members=tar.getmembers();assert all(m.isfile() and len(m.name)==64 and all(c in '0123456789abcdef' for c in m.name) for m in members);assert len({m.name for m in members})==len(members)
 objects={m.name:tar.extractfile(m).read() for m in members}
assert set(objects)==set(i['records'].values());assert all(sha(b)==digest for digest,b in objects.items())
def data(path):return objects[i['records'][str(path)]]
pb=data(i['planPath']);rb=data(i['receiptPath']);assert sha(pb)=='7281cc169cc84647fd8aace1e618971a7518dcaf5adbec09d39a05dd479aac8c';assert sha(rb)=='9efcb8e84369351f423814c9715607973a6ce3d0c0932cdc0dc334082481126f'
def strict(left,right):
 if type(left) is not type(right):return False
 if isinstance(left,dict):return left.keys()==right.keys() and all(strict(left[k],right[k]) for k in left)
 if isinstance(left,list):return len(left)==len(right) and all(strict(a,b) for a,b in zip(left,right))
 return left==right
p=json.loads(pb);r=json.loads(rb);assert r['planSHA256']==sha(pb);assert r['status']=='DEVELOPMENT_ACTUAL_TS_FULL_DTO2_PASS_NOT_BEND_NOT_DELIVERY_NOT_FULL56';assert not r.get('guardFailures',[]);assert not r.get('failure');assert not r.get('primaryFailure');assert r['generated']=={}
assert len(p['commands'])==len(r['commands'])==1;c=p['commands'][0];actual=r['commands'][0];assert c['label']=='reference' and c['seconds']==5;assert c['argv']==['/usr/bin/taskset','-c','5','/home/node/.local/share/mise/installs/node/24.20.0/bin/node',p['stage']+'/study/reference.ts'];assert actual=={**c,'exit':0,'failure':None}
assert set(i['excluded'])=={p['environment'],'/usr/bin/taskset','/home/node/.local/share/mise/installs/node/24.20.0/bin/node'}
for path,digest in p['pins'].items():
 assert (i['records'].get(path) or i['excluded'].get(path,{}).get('sha256'))==digest
stage=p['stage'];staged={path[len(stage)+1:]:digest for path,digest in i['records'].items() if path.startswith(stage+'/')};assert staged==p['inventory']
assert p['environmentSHA256']==p['pins'][p['environment']]
base=str(Path(i['planPath']).parent);assert set(r['logs'])=={'reference.stdout','reference.stderr'}
for name,digest in r['logs'].items():assert sha(data(base+'/'+name))==digest
assert data(base+'/reference.stderr')==b'';rows=[json.loads(line) for line in data(base+'/reference.stdout').splitlines()];oracle=json.loads(data(stage+'/study/ORACLE.json'))['cases'];assert len(rows)==2 and strict([{'name':v['name'],'description':v['dto']} for v in rows],oracle);assert all(strict(v['beforeDTO'],v['afterDTO']) and strict(v['afterDTO'],v['dto']) for v in rows)
source='/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core';original=next(path for path in p['pins'] if path.endswith('/full-dto-v1/reference.ts'));originalOracle=next(path for path in p['pins'] if path.endswith('/full-dto-v1/ORACLE.json'));assert data(stage+'/study/reference.ts')==data(original).replace((source+'/src/').encode(),(stage+'/reference/src/').encode());assert data(stage+'/study/ORACLE.json')==data(originalOracle);assert data(stage+'/reference/package.json')==data(source+'/package.json');assert data(stage+'/study/package.json')==b'{"type":"module"}\n'
for name in p['inventory']:
 if name.startswith('reference/src/'):assert data(stage+'/'+name)==data(source+'/src/'+name[len('reference/src/'):])
assert data(original)==(H/'reference.ts').read_bytes();assert data(originalOracle)==(H/'ORACLE.json').read_bytes()
print('PASS: actual TS2 development full normalized DTOs/owner snapshots; 81 records, 46 objects; no Bend/full56/proof credit')
