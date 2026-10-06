import pathlib,json,hashlib
ALLOWED={'52b505c4d7c3a0b304659b48b0a892e6d0db973a3637bc033e03282792d52c6e'}
def verify(overlay):
 files={x.name:x.read_bytes() for x in (pathlib.Path(overlay)/'experiments/s-integrate').glob('*.bend')};assert len(files)==29
 pins={'experiments/s-integrate/'+n:hashlib.sha256(b).hexdigest() for n,b in files.items()};closure=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure in ALLOWED
 manifest=json.loads((pathlib.Path(overlay)/'overlay.json').read_text());cache=json.loads((pathlib.Path(overlay)/'cache-specialization.json').read_text());assert manifest['sources']==pins
 assert cache['runtimeClosureSHA256']==cache['specializedClosureSHA256']==closure
 assert cache['runtimeClosure']==cache['specializedClosure']==pins
 return files,pins,closure
