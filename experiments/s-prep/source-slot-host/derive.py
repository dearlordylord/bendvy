#!/usr/bin/env python3
"""Append Slot-specialized authored Host families; originals remain byte-identical."""
import argparse, hashlib, json, pathlib, re, shutil
BASE=pathlib.Path('/tmp/bendvy-private-id-query-descending-v1')
EXPECTED='b0fdd6c41be12b34efc79e45edc98225c1b0158a51976b432a1646bfcae9e8f0'
MODULES=['systems','structural-invoker','audited-invoker','host']
def sha(b): return hashlib.sha256(b).hexdigest()
def blocks(s):
    starts=list(re.finditer(r'^(?:def|type) ([A-Za-z0-9_]+)',s,re.M))
    return [(m.group(1),s[m.start():starts[i+1].start() if i+1<len(starts) else len(s)]) for i,m in enumerate(starts)]
def names(s): return {n for n,b in blocks(s) if b.startswith('def ') and (n.startswith(('motion_','health_')) or n in ['MotionHost','HealthHost','WBundleMotion','WBundleHealth'])}
def specialize(s,local,external):
    for old,new in [('CC.Cache<T.Position,T.PositionView>','CP.PrototypeMotionMainSlot'),('CC.Cache<T.Vitals,T.VitalsView>','CP.PrototypeHealthMainSlot'),('CP.position_new','CP.prototype_slot_position_new'),('CP.vitals_new','CP.prototype_slot_vitals_new'),('CP.position_get','CP.prototype_slot_position_get'),('CP.vitals_get','CP.prototype_slot_vitals_get')]: s=s.replace(old,new)
    # Qualified references must be rewritten before local identifiers.
    for alias,ns in external.items():
        for n in sorted(ns,key=len,reverse=True): s=re.sub(r'\b'+re.escape(alias+'.'+n)+r'\b',alias+'.prototype_slot_host_'+n,s)
    for n in sorted(local,key=len,reverse=True): s=re.sub(r'(?<![\w.])'+re.escape(n)+r'\b','prototype_slot_host_'+n,s)
    # Transaction adapters already implement persistent Slot payloads.
    s=re.sub(r'\b(A|TA)\.(motion_|health_)([A-Za-z0-9_]+)',r'\1.prototype_packed_\2\3',s)
    return s
p=argparse.ArgumentParser();p.add_argument('--source',type=pathlib.Path,default=BASE);p.add_argument('--output',required=True);a=p.parse_args();BASE=a.source
out=pathlib.Path(a.output)
if out.exists(): raise SystemExit('output already exists')
root=BASE/'experiments/s-integrate';manifest=json.loads((BASE/'overlay.json').read_text());cache=json.loads((BASE/'cache-specialization.json').read_text())

pins={f.name:sha(f.read_bytes()) for f in sorted(root.glob('*.bend'))}
# Match the immutable runtime map before copying.
assert len(pins)==29
qualified={'experiments/s-integrate/'+n:v for n,v in pins.items()}
digest=lambda x:sha(json.dumps(x,sort_keys=True,separators=(',',':')).encode())
assert digest(qualified)==EXPECTED and manifest['sources']==qualified and manifest['cacheSpecialization']==cache
for key in ['runtimeClosure','specializedClosure']:
    assert cache[key]==qualified and cache[key+'SHA256']==EXPECTED
sources={m:(root/(m+'.bend')).read_text() for m in MODULES};maps={m:names(s) for m,s in sources.items()}
shutil.copytree(BASE,out)
receipts={}
for m,s in sources.items():
    ext={'U':maps['systems'],'IA':maps['audited-invoker'],'SI':maps['structural-invoker']}
    appended='\n# Private persistent Slot Host specialization; authored algorithms retained.\n'+''.join(specialize(b,maps[m],ext) for n,b in blocks(s) if n in maps[m])
    target=out/'experiments/s-integrate'/ (m+'.bend');target.write_text(s+appended)
    receipts[m]={'originalSHA256':sha(s.encode()),'outputSHA256':sha(target.read_bytes()),'definitions':sorted(maps[m])}
newpins={f.name:sha(f.read_bytes()) for f in sorted((out/'experiments/s-integrate').glob('*.bend'))}
# Rewrite the existing maps recursively, retaining the manifest format.
def update(x):
    if isinstance(x,dict):
        for k,v in list(x.items()):
            if isinstance(v,dict) and len(v)==29 and all(isinstance(z,str) and len(z)==64 for z in v.values()):
                x[k]={key:newpins[pathlib.Path(key).name] for key in v}
            else: update(v)
    elif isinstance(x,list):
        for v in x:update(v)
qualified_new={'experiments/s-integrate/'+n:v for n,v in newpins.items()}
for key in ['runtimeClosure','specializedClosure']:
    cache[key]=qualified_new;cache[key+'SHA256']=digest(qualified_new)
manifest['sources']=qualified_new;manifest['cacheSpecialization']=cache
# Rebind both exact29 maps and closure digests, including embedded cache receipt.
(out/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n');(out/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n')
(out/'slot-host-derivation.json').write_text(json.dumps({'base':str(BASE),'inputPins29':pins,'outputPins29':newpins,'modules':receipts},indent=2)+'\n')
assert digest(qualified_new)=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c'
print(digest(qualified_new))
