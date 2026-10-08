"""Portable read/hash/strict-oracle verification; launches no child."""
import hashlib
import json
from pathlib import Path
import tarfile
HERE=Path(__file__).resolve().parent
OWN=next(p for p in HERE.parents if (p/'AGENTS.md').is_file())
def sha(data):return hashlib.sha256(data).hexdigest()
def strict(actual,expected):
 assert type(actual) is type(expected)
 if isinstance(expected,dict):
  assert actual.keys()==expected.keys()
  for key in expected:strict(actual[key],expected[key])
 elif isinstance(expected,list):
  assert len(actual)==len(expected)
  for a,e in zip(actual,expected):strict(a,e)
 else:assert actual==expected

def main():
 selection=json.loads((HERE/'selection.json').read_bytes());prefix='experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-gate-v1/'
 required=['gate.bend','save.bend','consumer.bend','driver.bend','format.bend','output.bend','consumer-io.bend','generated-js.py','gate-import-only.diff','gate-source-join.json','source-development-v1/receipts.json','finite-gate-v1/build.py','finite-gate-v1/verify.py','finite-gate-v1/REPORT.md','finite-gate-v1/evidence.tar.gz','finite-gate-v1/index.json']
 assert all(prefix+p in selection['files'] for p in required)
 actual={str(p.relative_to(OWN)) for p in HERE.parent.rglob('*') if p.is_file() and p.name!='selection.json' and '__pycache__' not in p.parts}
 assert actual==set(selection['files'])
 for path,digest in selection['files'].items():
  assert path.startswith(prefix) and '..' not in Path(path).parts;assert sha((OWN/path).read_bytes())==digest
 index=json.loads((HERE/'index.json').read_bytes());objects={}
 with tarfile.open(HERE/'evidence.tar.gz','r:gz') as archive:
  for member in archive.getmembers():
   assert member.isfile() and member.name not in objects
   data=archive.extractfile(member).read();assert member.name=='objects/'+sha(data) and not data.startswith(b'\x7fELF');objects[member.name]=data
 records=index['records'];assert set(objects)=={r['object'] for r in records.values()}
 def read(path):
  row=records[str(path)];data=objects[row['object']];assert sha(data)==row['sha256'] and len(data)==row['bytes'];return data
 def j(path):return json.loads(read(path))
 for path in records:read(path)
 run=Path(index['run']);plan=j(run/'plan.json');receipt=j(run/'receipt.json');prep=j(run/'preparation.json')
 assert sha(read(run/'plan.json'))=='1eab0c1ebe3d92c2aca0eb10095f649e447b58c9fbb91838d154dae1b2afd774'
 assert sha(read(run/'receipt.json'))=='d529973b46ee299c1ca5e3f3bc9fee6aa90c49a167bbbdef419e54b5f85eee96'
 assert receipt['status']=='DEVELOPMENT_PASS' and prep['status']=='PREPARATION_PASS'
 assert receipt['planSHA256']==prep['planSHA256']==sha(read(run/'plan.json'))
 assert receipt.get('guardFailures',[])==prep.get('guardFailures',[])==[]
 identities=dict(plan['snapshot']['pins'])
 def resources(path,row):
  if row['kind']=='file':identities[path]=row['sha256']
  elif row['kind']=='directory':
   for name,child in row['inventory'].items():resources(path+'/'+name,child)
  elif row['kind']=='symlink':resources(row['resolvedPath'],row['resolved'])
 resources(plan['resourceRoots'][0],plan['installedMembership'])
 assert set(index['pinDispositions'])==set(plan['pins'])
 for path,digest in plan['pins'].items():
  disposition=index['pinDispositions'][path];assert disposition['sha256']==digest
  if disposition['kind']=='archived':assert sha(read(path))==digest
  elif disposition['kind']=='private-environment':assert path==plan['privateEnvironment'] and digest==plan['environmentSHA256']
  else:assert disposition['kind']=='installed-identity' and identities.get(path)==digest
 assert len(prep['commands'])==4 and [c['label'] for c in prep['commands']]==['prep-bend','prep-node','prep-taskset','prep-shell']
 labels=[g+'-'+n for g in ['before-emit','after-emit','before-consumer','after-consumer','final'] for n in ['bend','node','taskset','shell']]
 assert len(receipt['commands'])==22 and set(c['label'] for c in receipt['commands'])==set(labels+['emit','consumer'])
 for r,base in [(prep,run),(receipt,Path(receipt['rawDirectory']))]:
  for name,digest in r['logs'].items():assert sha(read(base/name))==digest
  for command in r['commands']:
   assert command['exit']==0 and command['failure'] is None
   for stream,row in command['streams'].items():
    name=command['label']+'.'+stream;assert sha(read(base/name))==row['sha256'] and len(read(base/name))==row['bytes']
 commands={c['label']:c for c in receipt['commands']}
 for expected in plan['commands']:
  command=commands[expected['label']];assert command['argv']==expected['argv'] and command['capSeconds']==expected['capSeconds']
 assert [c['capSeconds'] for c in plan['commands']]==[30,5]
 for path,row in receipt['generated'].items():assert sha(read(path))==row['sha256'] and len(read(path))==row['bytes']
 assert set(receipt['generated'])=={plan['artifact']}
 raw=Path(receipt['rawDirectory']);oracle=read(plan['oracle']);assert len(oracle)==23361 and sha(oracle)==plan['oracleSHA256']
 strict(json.loads(read(raw/'consumer.stdout')),json.loads(oracle));assert read(raw/'consumer.stderr')==b''
 candidate=Path(index['candidateRoot']);source=j(candidate/'source-development-v1/receipts.json');assert [r['exit'] for r in source]==[0,1,1,1]
 for r in source:
  for path,digest in r['sourcePins'].items():assert sha(read(path))==digest
 diagnostics=[read(candidate/'source-development-v1'/('negative-'+n+'.bend.stderr')) for n in ['schema','plain','owner']]
 assert b'F.Workshop' in diagnostics[0] and b'F.Garden' in diagnostics[0]
 assert b'expected : G.Gate' in diagnostics[1] and b'observed :' in diagnostics[1]
 assert b'consumed more than once' in diagnostics[2]
 join=j(candidate/'gate-source-join.json');original=read(join['original']);gate=read(join['candidate'])
 assert sha(original)==join['originalSHA256'] and sha(gate)==join['candidateSHA256']
 assert gate==original.replace(b'import ./reference-source/typed.bend as D',b'import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D')
 print('VERIFY PASS: exact candidate Gate source, negatives, 4 preparation and 22 execution commands, full 23361-byte oracle; finite JS only')
if __name__=='__main__':main()
