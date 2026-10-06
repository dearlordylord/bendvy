import pathlib,json,hashlib
ALLOWED={'31c4913910dd315fdaac8507364129c9957feacb91c9f4c7010a219a3cc1869f','0b3339e7fde4dc1af610ec76b1656b2f9c39748a546ba5929766d7445a51fa43'}
def verify(overlay):
 files={x.name:x.read_bytes() for x in (pathlib.Path(overlay)/'experiments/s-integrate').glob('*.bend')};assert len(files)==29
 pins={'experiments/s-integrate/'+n:hashlib.sha256(b).hexdigest() for n,b in files.items()};closure=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure in ALLOWED
 manifest=json.loads((pathlib.Path(overlay)/'overlay.json').read_text());cache=json.loads((pathlib.Path(overlay)/'cache-specialization.json').read_text());assert manifest['sources']==pins
 assert cache['runtimeClosureSHA256']==cache['specializedClosureSHA256']==closure
 assert cache['runtimeClosure']==cache['specializedClosure']==pins
 return files,pins,closure
