"""Reconcile selected reference objects and exact complete oracle; no children."""
import gzip,hashlib,importlib.util,json,tarfile,tempfile
from pathlib import Path
H=Path(__file__).resolve().parent;m=json.loads((H/'manifest.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();b=(H/m['archive']['path']).read_bytes();assert sha(b)==m['archive']['sha256'];assert sha(gzip.decompress(b))==m['archive']['decodedTarSHA256'];assert sha((H/'REPORT.md').read_bytes())==m['reportSHA256']
with tarfile.open(H/m['archive']['path'],'r|gz') as tar:
 objects={}
 for member in tar:
  assert member.isfile() and member.name not in objects;objects[member.name]=tar.extractfile(member).read()
assert set(objects)=={r['path'] for r in m['objects']}
for row in m['objects']:
 raw=objects[row['path']];assert sha(raw)==row['sha256'] and len(raw)==row['bytes'];assert not raw.startswith(b'\x7fELF');assert '__pycache__' not in row['path']
 if row['path'].endswith('plan.json'):assert 'environment' not in json.loads(raw)
prefix='experiments/public-machine-handlers/';success=prefix+'evidence/reference-1791394944238109342/';receipt=json.loads(objects[success+'receipt.json']);assert sha(objects[success+'receipt.json'])==m['retainedSuccessReceiptSHA256'];assert sha(objects[success+'plan.json'])==receipt['planSHA256']
with tempfile.TemporaryDirectory(prefix='handlers49-oracle-') as directory:
 p=Path(directory)/'oracle.py';p.write_bytes(objects[prefix+'oracle.py']);s=importlib.util.spec_from_file_location('portable_handler_oracle',p);oracle=importlib.util.module_from_spec(s);s.loader.exec_module(oracle);actual=json.loads(objects[success+'reference.stdout']);assert actual==json.loads(objects[success+'expected.json']);comparison=oracle.compare(actual)
for name in ['reference-1791394873358923401','reference-1791394918503308294','reference-1791394944238109342']:
 base=prefix+'evidence/'+name+'/';r=json.loads(objects[base+'receipt.json']);assert sha(objects[base+'plan.json'])==r['planSHA256']
 for file,h in r['logs'].items():assert sha(objects[base+file])==h
print(json.dumps({'status':'SELECTED_REFERENCE_OBJECTS_AND_COMPLETE_ORACLE_PASS','objects':len(objects),'comparison':comparison,'backendExecutions':0,'nominalRootsTested':False}))
