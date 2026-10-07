"""Check all compressed objects and replay complete retained oracles; no backend children."""
import gzip,hashlib,importlib.util,json,tarfile,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent

def sha(b):return hashlib.sha256(b).hexdigest()
def load(p,n):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
m=json.loads((HERE/'manifest.json').read_text());archive=HERE/m['archive']['path'];assert sha(archive.read_bytes())==m['archive']['sha256'];assert sha(gzip.decompress(archive.read_bytes()))==m['archive']['decodedTarSHA256']
for name,h in m['packageFiles'].items():assert sha((HERE/name).read_bytes())==h
with tempfile.TemporaryDirectory(prefix='hierarchy44-portable-') as directory:
 root=Path(directory);data={}
 with tarfile.open(archive,'r|gz') as tar:
  objects={}
  for member in tar:
   assert member.isfile() and member.name not in objects;objects[member.name]=tar.extractfile(member).read()
  assert len(objects)==len(m['files']);assert set(objects)=={x['path'] for x in m['files']}
  for row in m['files']:
   raw=objects[row['path']];assert sha(raw)==row['sha256'];assert not raw.startswith(b'\x7fELF');assert '__pycache__' not in row['path']
   if row.get('derived'):continue
   assert sha(raw)==row['sourceSHA256'];source=Path(row['source']);assert not source.is_absolute() and '..' not in source.parts;target=root/source;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(raw);data[row['source']]=raw
 candidate=root/'experiments/public-hierarchy/bend-candidate';controls=candidate/'controls-v1';C=load(candidate/'full-v1/compare.py','portable_full');M=load(controls/'mutant-oracle.py','portable_mutant');F=load(controls/'foreign-expected.py','portable_foreign');O=load(controls/'refusal-oracle.py','portable_refusals')
 reference=json.loads(data['experiments/public-hierarchy/evidence/reference-1791383596927418665/hierarchy.stdout']);comparisons=[]
 for source,raw in data.items():
  if not source.endswith('.stdout'):continue
  name=Path(source).name;text=raw.decode()
  if name in ('run-js.stdout','run-native.stdout'):comparisons.append(C.compare(text,reference))
  elif name in ('run-foreign-js.stdout','foreign-run-native.stdout'):comparisons.append(F.compare(text))
  elif name.endswith(('-run-js.stdout','-run-native.stdout')):
   if name.startswith(('omit-cycle-refusal-','omit-set-refusal-')):
    mutant='omit-cycle-refusal' if name.startswith('omit-cycle') else 'omit-set-refusal';mutated='-mutant-' in name;assert text==O.expected(mutant,mutated);comparisons.append(O.compare(text,mutant) if mutated else {'status':'COMPLETE_NORMAL_REFUSAL_BOTH_SCHEMA_PASS'})
   else:
    mutant=name.rsplit('-run-',1)[0];comparisons.append(M.compare(text,reference,mutant))
 assert len(comparisons)>=9
 negatives=json.loads(data['experiments/public-hierarchy/bend-candidate/controls-v1/development/preflight-1791391783410099373/negative-reconciliation-receipt.json']);assert negatives['status']=='FOUR_EXACT_CHECKER_REFUSALS_RECONCILED'
 for row in negatives['results']:
  name=row['case'];raw=data['experiments/public-hierarchy/bend-candidate/controls-v1/development/preflight-1791391783410099373/'+name+'.stderr'];assert sha(raw)==row['diagnosticSHA256']
 print(json.dumps({'status':'PORTABLE_EXACT_OBJECTS_AND_COMPLETE_ORACLES_PASS','objects':len(m['files']),'completeComparisons':len(comparisons),'negativeBindings':4,'backendExecutions':0,'acceptance':False}))
