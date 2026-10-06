from pathlib import Path
import hashlib,json,re
H=Path(__file__).resolve().parent;B=Path('/tmp/bendvy-slot-host-v1');V=Path('/tmp/bendvy-slot-host-handoff-v7');R=Path('/tmp/bendvy-handoff-independent-v7');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((V/'overlay.json').read_text());c=json.loads((V/'cache-specialization.json').read_text());pins={str(p.relative_to(V)):sha(p) for p in (V/'experiments/s-integrate').glob('*.bend')};assert len(pins)==29 and pins==m['sources']==c['runtimeClosure']==c['specializedClosure'];assert m['cacheSpecialization']==c
closure=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure=='a9a2fa20913658b9561056e660803e3afd74870f321ff3a30c839e62fa44a56b'
for k in pins:assert (V/k).read_bytes()==(R/k).read_bytes()
for k in ['overlay.json','cache-specialization.json','handoff-source-pins.json']:assert (V/k).read_bytes()==(R/k).read_bytes()
changed=[k for k in pins if sha(B/k)!=pins[k]];assert set(Path(k).name for k in changed)=={'query.bend','held-adapter.bend','measurement-bend.bend'}
for n in ['query.bend','held-adapter.bend']:assert (V/'experiments/s-integrate'/n).read_text().startswith((B/'experiments/s-integrate'/n).read_text())
def defs(s):
 ms=list(re.finditer(r'^(?:def|type|law|proof) ([\w.]+)',s,re.M));return {m.group(1):s[m.start():ms[i+1].start() if i+1<len(ms) else len(s)].rstrip() for i,m in enumerate(ms)}
b=defs((B/'experiments/s-integrate/measurement-bend.bend').read_text());v=defs((V/'experiments/s-integrate/measurement-bend.bend').read_text())
for n,d in b.items():
 expected=d
 for lane in ['motion','health']:
  if n=='prototype_packed_'+lane+'_tick':expected=expected.replace('prototype_packed_'+lane+'_invoke,','prototype_handoff_'+lane+'_invoke,')
 assert v[n]==expected,n
assert set(v)-set(b)=={'prototype_handoff_motion_invoke','prototype_handoff_health_invoke'}
ha=(V/'experiments/s-integrate/held-adapter.bend').read_text();q=(V/'experiments/s-integrate/query.bend').read_text();assert 'prototype_handoff_array_inspect' not in q
for lane,slot in [('motion','Motion'),('health','Health')]:
 assert f'Array.size(Maybe<P.Prototype{slot}MainSlot>,columns)' in ha
 assert f'prototype_handoff_{lane}_shape_chosen(~client,selection,selected,undo,commands,pings,marks,total,(capacity <= size : U32),S.World{{ns,next,S.Rows{{columns,aux,metadata,capacity,depth,high}},pending,Some{{ledger}},mode}})' in ha
 assert f'prototype_cursor_flatfold_{lane}_loop(~client,ns,ids,PrototypeFlatFold{{ns,next,columns,aux,metadata,capacity,depth,high,pending,ledger,mode,selected,undo,commands,pings,marks,total}})' in ha
out={'status':'INDEPENDENT_V7_STATIC_REDERIVATION_SOURCE29_CACHE_PREFIX_TICK_PREFLIGHT_PASS','closure':closure,'sourcePins':pins,'recipeSHA256':sha(H/'reproduce-v7/derive.py'),'changed':changed,'oldMeasurementDefinitions':len(b),'scope':'Static source and exact reproduction only; dynamic callbacks/recovery/control acceptance separate'};(H/'v7-static.json').write_text(json.dumps(out,indent=2)+'\n');print(out['status'])
