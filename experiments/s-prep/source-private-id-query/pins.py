import pathlib,json,hashlib
ALLOWED={'bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94'}
def verify(overlay):
 files={x.name:x.read_bytes() for x in (pathlib.Path(overlay)/'experiments/s-integrate').glob('*.bend')};assert len(files)==29
 pins={'experiments/s-integrate/'+n:hashlib.sha256(b).hexdigest() for n,b in files.items()};closure=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure in ALLOWED
 manifest=json.loads((pathlib.Path(overlay)/'overlay.json').read_text());cache=json.loads((pathlib.Path(overlay)/'cache-specialization.json').read_text());assert manifest['sources']==pins and manifest['cacheSpecialization']==cache
 assert cache['runtimeClosureSHA256']==cache['specializedClosureSHA256']==closure
 assert cache['runtimeClosure']==cache['specializedClosure']==pins
 return files,pins,closure
