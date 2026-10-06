import hashlib,json,pathlib
CLOSURE='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c'
def verify(overlay):
 root=pathlib.Path(overlay);files={f.name:f.read_bytes() for f in (root/'experiments/s-integrate').glob('*.bend')};assert len(files)==29
 pins={'experiments/s-integrate/'+n:hashlib.sha256(b).hexdigest() for n,b in files.items()};closure=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure==CLOSURE
 m=json.loads((root/'overlay.json').read_text());c=json.loads((root/'cache-specialization.json').read_text());assert m['sources']==pins and m['cacheSpecialization']==c
 for k in ['runtimeClosure','specializedClosure']:assert c[k]==pins and c[k+'SHA256']==closure
 return files,pins,closure
