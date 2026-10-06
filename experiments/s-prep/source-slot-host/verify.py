#!/usr/bin/env python3
"""Verify exact29 source/cache lineage and unchanged authored original prefixes."""
import argparse,hashlib,json,pathlib,re
p=argparse.ArgumentParser();p.add_argument('overlay',type=pathlib.Path);a=p.parse_args();h=pathlib.Path(__file__).resolve().parent
expected=json.loads((h/'output-pins.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();root=a.overlay/'experiments/s-integrate'
actual={f.name:sha(f.read_bytes()) for f in root.glob('*.bend')};assert actual==expected['outputPins29'] and len(actual)==29
qualified={'experiments/s-integrate/'+n:v for n,v in actual.items()};digest=sha(json.dumps(qualified,sort_keys=True,separators=(',',':')).encode())
c=json.loads((a.overlay/'cache-specialization.json').read_text());m=json.loads((a.overlay/'overlay.json').read_text());assert m['sources']==qualified and m['cacheSpecialization']==c
for k in ['runtimeClosure','specializedClosure']:assert c[k]==qualified and c[k+'SHA256']==digest
changed=set(expected['modules']);assert {n[:-5] for n,v in actual.items() if v!=expected['inputPins29'][n]}==changed
for name,r in expected['modules'].items():
 s=(root/(name+'.bend')).read_bytes();prefix=s.split(b'\n# Private persistent Slot Host specialization; authored algorithms retained.\n')[0];assert sha(prefix)==r['originalSHA256']
 for name in r['definitions']:assert s.count(('\ndef prototype_slot_host_'+name+'(').encode())==1
 # Mechanical round-trip: payload type/factory and private-name adaptation only.
 def defs(text):
  at=list(re.finditer(r'^(?:def|type) ([A-Za-z0-9_]+)',text,re.M))
  return {m.group(1):text[m.start():at[i+1].start() if i+1<len(at) else len(text)] for i,m in enumerate(at)}
 olddefs=defs(prefix.decode());newdefs=defs(s.decode())
 for n in r['definitions']:
  new=newdefs['prototype_slot_host_'+n]
  new=new.replace('prototype_slot_host_','')
  new=re.sub(r'\b(A|TA)\.prototype_packed_(motion_|health_)',r'\1.\2',new)
  for after,before in [('CP.PrototypeMotionMainSlot','CC.Cache<T.Position,T.PositionView>'),('CP.PrototypeHealthMainSlot','CC.Cache<T.Vitals,T.VitalsView>'),('CP.prototype_slot_position_new','CP.position_new'),('CP.prototype_slot_vitals_new','CP.vitals_new'),('CP.prototype_slot_position_get','CP.position_get'),('CP.prototype_slot_vitals_get','CP.vitals_get')]:new=new.replace(after,before)
  assert new.strip()==olddefs[n].strip(),(name,n,'authored algorithm changed')
print(json.dumps({'status':'SOURCE_BINDING_PASS','closure':digest,'sourceCount':len(actual),'changedModules':sorted(changed),'originalPrefixes':'byte-identical'},indent=2))
