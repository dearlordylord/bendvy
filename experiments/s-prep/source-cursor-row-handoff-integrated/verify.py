#!/usr/bin/env python3
"""Read-only source binding and original-definition preservation audit."""
from pathlib import Path
import argparse,json,hashlib,re
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--source',type=Path,default=Path('/tmp/bendvy-slot-host-v1'));p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();assert not a.output.exists();sha=lambda b:hashlib.sha256(b).hexdigest();inp=json.loads((H/'input-pins.json').read_text());assert sha((a.source/'overlay.json').read_bytes())==inp['manifestSHA256'] and sha((a.source/'cache-specialization.json').read_bytes())==inp['cacheSHA256']
core=a.candidate/'experiments/s-integrate';pins={str(f.relative_to(a.candidate)):sha(f.read_bytes()) for f in core.glob('*.bend')};m=json.loads((a.candidate/'overlay.json').read_text());c=json.loads((a.candidate/'cache-specialization.json').read_text());digest=sha(json.dumps(pins,sort_keys=True,separators=(',',':')).encode());assert len(pins)==29 and m['sources']==pins and m['cacheSpecialization']==c
for k in ['runtimeClosure','specializedClosure']:assert c[k]==pins
for k in ['runtimeClosureSHA256','specializedClosureSHA256']:assert c[k]==digest
changes=[k for k in pins if pins[k]!=inp['sources'][k]];assert set(changes)=={'experiments/s-integrate/'+x for x in ['query.bend','held-adapter.bend','measurement-bend.bend']}
for path,expected in inp['sources'].items():assert sha((a.source/path).read_bytes())==expected
for file in ['query.bend','held-adapter.bend']:assert (core/file).read_text().startswith((a.source/'experiments/s-integrate'/file).read_text())
def defs(s):
 matches=list(re.finditer(r'^(def|type|law|proof) ([A-Za-z0-9_.]+)',s,re.M));return {m[2]:s[m.start():matches[i+1].start() if i+1<len(matches) else len(s)].rstrip() for i,m in enumerate(matches)}
old=(a.source/'experiments/s-integrate/measurement-bend.bend').read_text();new=(core/'measurement-bend.bend').read_text();before,after=defs(old),defs(new);assert len(after)==len(before)+2;changed=[]
for n,body in before.items():
 target=after[n]
 if n in ['prototype_packed_motion_tick','prototype_packed_health_tick']:
  lane='motion' if 'motion' in n else 'health';assert target==body.replace('prototype_packed_'+lane+'_invoke,','prototype_handoff_'+lane+'_invoke,');changed.append(n)
 else:assert target==body,n
assert [x for x in old.splitlines() if x.startswith('import ')]==[x for x in new.splitlines() if x.startswith('import ')]
r={'status':'SOURCE29_CACHE_AND_ORIGINAL_DEFINITIONS_PASS','sourceClosure':digest,'sources':pins,'changedModules':changes,'queryHeldOriginalPrefixesExact':True,'unchangedOldMeasurementDefinitions':len(before)-2,'changedOldMeasurementDefinitions':changed,'newMeasurementDefinitions':['prototype_handoff_motion_invoke','prototype_handoff_health_invoke'],'scope':'Closed private diagnostic only; exposed Batch constructors/helper are not production confinement'};a.output.write_text(json.dumps(r,indent=2)+'\n');print(r['status'],digest)
