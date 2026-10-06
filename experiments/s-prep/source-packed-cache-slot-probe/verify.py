#!/usr/bin/env python3
import argparse,hashlib,json,re
from pathlib import Path
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--overlay',type=Path,required=True);p.add_argument('--build',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();base=Path('/tmp/bendvy-identity-handle-query-v3');old=json.loads((H/'input-pins.json').read_text());m=json.loads((a.overlay/'overlay.json').read_text());new=m['sources'];assert len(old)==len(new)==29 and set(old)==set(new)
closure=lambda d:hashlib.sha256(json.dumps(d,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure(old)=='0b3339e7fde4dc1af610ec76b1656b2f9c39748a546ba5929766d7445a51fa43'
for n,h in old.items():assert sha(base/n)==h
for n,h in new.items():assert sha(a.overlay/n)==h
cache=json.loads((a.overlay/'cache-specialization.json').read_text());assert cache==m['cacheSpecialization'] and cache['runtimeClosure']==new and cache['specializedClosure']==new and cache['runtimeClosureSHA256']==closure(new)
changed=[n for n in old if old[n]!=new[n]];expected=['cached-payload.bend','held-adapter.bend','host.bend','measurement-bend.bend','raw-boundaries.bend','transaction-dispatch-adapters.bend'];assert sorted(Path(n).name for n in changed)==sorted(expected)
rows=[]
for n in changed:
 original=(base/n).read_bytes();candidate=(a.overlay/n).read_bytes();assert candidate.startswith(original),n
 rows.append({'file':n,'originalSHA256':old[n],'candidateSHA256':new[n],'originalPrefixByteIdentical':True,'originalHeadersRetained':len(re.findall(rb'^(?:def|type) ',original,re.M))})
build=json.loads((a.build/'build.json').read_text());assert build['status']=='PRIVATE_PACKED_MOTION_SOURCE_BUILD_PASS' and build['sourcePins']==new
for n,h in build['generatedPins'].items():assert sha(a.build/n)==h
assert sha(a.build/'measurement-bend.bend')==build['preparedModuleSHA256'];source=(a.overlay/'experiments/s-integrate/measurement-bend.bend').read_text();assert 'prototype_packed_motion_loops' in source and 'prototype_packed_motion_frame' in source and 'prototype_packed_MotionBench{host:H.prototype_packed_MotionHost()' in source
r={'status':'PINNED_SOURCE29_ORIGINAL_PREFIXES_AND_PRIVATE_BUILD_PASS','sourceClosureSHA256':closure(new),'baselineClosureSHA256':closure(old),'changedModules':rows,'buildReceiptSHA256':sha(a.build/'build.json'),'sourcePins':new,'scope':'Source/build lineage only; Motion finite fullfields separate; Native counts/Health/authority/Tx/factory gates open'};a.output.write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
