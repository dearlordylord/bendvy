#!/usr/bin/env python3
from pathlib import Path
import json,hashlib,argparse
p=argparse.ArgumentParser();p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();H=Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads((a.overlay/'overlay.json').read_text());c=json.loads((a.overlay/'cache-specialization.json').read_text());pins=m['sources'];digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert len(pins)==29 and c==m['cacheSpecialization'] and c['runtimeClosure']==pins and c['specializedClosure']==pins and c['runtimeClosureSHA256']==digest and c['specializedClosureSHA256']==digest
base=Path('/tmp/bendvy-packed-main-slot-motion-v4');frozen=Path('/tmp/bendvy-identity-handle-query-v3');changed=[]
for n,h in pins.items():
 assert sha(a.overlay/n)==h and (a.overlay/n).read_bytes().startswith((base/n).read_bytes()) and (a.overlay/n).read_bytes().startswith((frozen/n).read_bytes())
 if sha(a.overlay/n)!=sha(base/n):changed.append(n)
assert len(changed)==6
r={'scope':'Source29/current matching cache maps and both digests; all Motion-v4 and original public definitions retained byteexact. No capability/performance acceptance.','sourceClosure':digest,'changedFromMotion':changed,'MotionV4AllPrefixesByteExact':True,'originalPublicAllPrefixesByteExact':True,'sourcePins':pins,'recipePins':{n:sha(H/n) for n in ['derive-both.py','build-both.py','packed-health-payload.bend','packed-health-row.bend']}}
a.output.write_text(json.dumps(r,indent=2)+'\n')
