#!/usr/bin/env python3
from pathlib import Path
import hashlib,json,re,argparse
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();H=Path(__file__).resolve().parent;base=Path('/tmp/bendvy-packed-main-slot-both-v3');cur=Path('/tmp/bendvy-packed-paired-journal-both-v3');pair=Path('/tmp/bendvy-paired-journal-v2');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads((cur/'overlay.json').read_text());c=json.loads((cur/'cache-specialization.json').read_text());pins=m['sources'];digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert digest=='d437d8f7e97ae66764e470c58cada7182715b8724d9dd065d20e55417e01e744' and c==m['cacheSpecialization'] and c['runtimeClosure']==pins and c['specializedClosure']==pins and c['runtimeClosureSHA256']==digest and c['specializedClosureSHA256']==digest
changed=[]
for n,h in pins.items():
 assert sha(cur/n)==h
 if sha(base/n)!=h:changed.append(n)
assert changed==[n for n in pins if Path(n).name in ['held-adapter.bend','transaction.bend']];assert (cur/'experiments/s-integrate/transaction.bend').read_bytes()==(pair/'experiments/s-integrate/transaction.bend').read_bytes()
old=(base/'experiments/s-integrate/held-adapter.bend').read_text();new=(cur/'experiments/s-integrate/held-adapter.bend').read_text();blocks=lambda s:dict((x[1],x[0]) for x in re.finditer(r'^(?:def|type) (\w+).*?(?=\n(?:def|type) |\Z)',s,re.M|re.S));ob=blocks(old);nb=blocks(new);allowed=[n for n in ob if n in ['PrototypePackedMotionRowOwner','PrototypePackedHealthRowOwner'] or n.startswith('prototype_packed_row_') or n.startswith('prototype_packed_prototype_journalledger_health_') or n in ['prototype_packed_prototype_flatfold_motion_taken','prototype_packed_prototype_flatfold_motion_returned']];actual=[n for n in ob if ob[n].strip()!=nb[n].strip()];assert set(actual)<=set(allowed)
# No original public/current source route or callback is silently replaced.
assert all(ob[n].strip()==nb[n].strip() for n in ob if not n.startswith('prototype_packed_') and not n.startswith('PrototypePacked'))
heads=lambda s:re.findall(r'^(?:def|type) [^\n]+',s,re.M)
assert all(ob[n].splitlines()[0]==nb[n].splitlines()[0] for n in ob if n not in actual)
r={'scope':'Exact source/recipe confinement only, not universal semantics or authority proof','sourceClosure':digest,'sourcePins':pins,'onlyChangedModules':changed,'changedPrivateDefinitions':actual,'transactionByteExactPairedInput':True,'allOriginalPublicHeldDefinitionsByteExact':True,'allUnchangedHeldHeadersRetained':True,'privatePendingUndoHeaderAdaptation':True,'recipePins':{n:sha(H/n) for n in ['derive-paired.py','build-both.py','paired-fixture-run.py','paired-negative-controls.py','paired-mutants.py']}}
a.output.write_text(json.dumps(r,indent=2)+'\n')
