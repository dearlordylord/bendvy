#!/usr/bin/env python3
import hashlib,json
from pathlib import Path
P=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for item in json.loads((P/'input-pins.json').read_text()):
 for name,pin in item['files'].items(): assert sha(Path(name))==pin,name
 root=Path(item['sourceRoot']); manifest=json.loads((root/'overlay.json').read_text());cache=json.loads((root/'cache-specialization.json').read_text())
 assert manifest['cacheSpecialization']==cache
 assert len(item['sources'])==29 and manifest['sources']==item['sources']
 for name,pin in item['sources'].items():assert sha(root/name)==pin,name
 assert cache['runtimeClosure']==cache['specializedClosure']==item['sources']
 digest=hashlib.sha256(json.dumps(item['sources'],sort_keys=True,separators=(',',':')).encode()).hexdigest()
 assert cache['runtimeClosureSHA256']==cache['specializedClosureSHA256']==digest
 build=json.loads((Path(item['build'])/'build.json').read_text());assert build['status']=='BUILD_PASS' and build['sourcePins']==item['sources']
 for name,pin in build['artifacts'].items():assert sha(Path(item['build'])/name)==pin,name
 assert all(c['exit']==0 for c in build['commands'])
print('EXACT_TWO_V8_SOURCE29_CACHE_AND_BUILD_BINDINGS_PASS')
