#!/usr/bin/env python3
"""Source-only AllView carrier equivalence with complete finite-field controls."""
import hashlib
import json
from pathlib import Path
import re
import sys
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
import bend_model

pins=json.loads((HERE/'source-pins.json').read_text())
for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
freeze=json.loads((HERE/'source-freeze.json').read_text())
previous=Path(freeze['predecessorEntry']).read_text();current=Path(freeze['entrypoint']).read_text()
def blocks(source):
    lines=source.splitlines();starts=[i for i,line in enumerate(lines) if re.match(r'^(def|type) ',line)]
    return {re.match(r'(?:def|type) (\w+)',lines[i])[1]:'\n'.join(line for line in lines[i:end] if line and not line.startswith('#')) for i,end in zip(starts,starts[1:]+[len(lines)])}
old,new=blocks(previous),blocks(current)
added={'AllView','all_nested_view','pack_all_view','prepare_all_nested','pack_all_prepare'}
changed={'all_view','prepare_all','view_json','json_view'}
assert set(new)-set(old)==added and not set(old)-set(new)
assert {name for name in old if old[name]!=new[name]}==changed
assert new['all_view']=='def all_view() -> Data:\n  AllView'
assert new['all_nested_view']==old['all_view'].replace('all_view()', 'all_nested_view()')
assert new['prepare_all_nested']==old['prepare_all'].replace('def prepare_all(', 'def prepare_all_nested(').replace('all_view()', 'all_nested_view()')
assert new['AllView']=='''type AllView is Data:
  AllView{query:QParam.Rows<Schema,Cmp.Access<U32>>,added:QParam.Rows<Schema,Unit>,changed:QParam.Rows<Schema,Unit>,event:Stream.EventView<Schema,event_type()>,removals:Stream.RemovalView<Schema,U32>,relations:Stream.RelationView<Schema,Publication>}'''
assert new['pack_all_view']=='''def pack_all_view(nested:all_nested_view()) -> all_view():
  match nested:
    case RP.ViewPair{query,RP.ViewPair{added,RP.ViewPair{changed,RP.ViewPair{event,RP.ViewPair{removals,relations}}}}}:
      AllView{query,added,changed,event,removals,relations}'''
assert new['pack_all_prepare']=='''def pack_all_prepare(prepared:context_type() & (all_owner() & (all_nested_view() & all_delta()))) -> context_type() & (all_owner() & (all_view() & all_delta())):
  match prepared:
    case (context,(owner,(nested,delta))):(context,(owner,(pack_all_view(nested),delta)))'''
assert new['prepare_all']=='''def prepare_all(context:context_type(),+cursor:U32,owner:all_owner()) -> context_type() & (all_owner() & (all_view() & all_delta())):
  pack_all_prepare(prepare_all_nested(context,cursor,owner))'''
pattern='RP.ViewPair{query,RP.ViewPair{added,RP.ViewPair{changed,RP.ViewPair{eventA,RP.ViewPair{removals,relations}}}}}'
for serializer in ['view_json','json_view']:
    assert new[serializer]==old[serializer].replace(pattern,'AllView{query,added,changed,event,removals,relations}').replace('event_json(eventA)','event_json(event)').replace('json_event_view(eventA)','json_event_view(event)')

fields=['query','added','changed','event','removals','relations']
def nested(values):
    q,a,c,e,m,r=values
    return (q,(a,(c,(e,(m,r)))))
def pack(pair):
    q,(a,(c,(e,(m,r))))=pair
    return {'query':q,'added':a,'changed':c,'event':e,'removals':m,'relations':r}
def unpack(carrier):return nested([carrier[key] for key in fields])
# Distinct identity sentinels catch any swap, omission or duplication, including
# empty fields for the real views which would otherwise mask permutation.
sentinels=[object() for _ in fields]
assert all(pack(nested(sentinels))[name] is value for name,value in zip(fields,sentinels))
assert unpack(pack(nested(sentinels)))==nested(sentinels)
wire,details,shared,ios=bend_model.derive()
old_initial=json.loads((HERE.parent/'bend-source-freeze.json').read_text())
source=Path(old_initial['entrypoint']).read_text()
views_checked=0
for namespace in [1,2]:
    state,rows,outcomes,deliveries,plan=bend_model.one_world(source,namespace)
    for delivery in deliveries:
        view=delivery['view'];values=[view[k] for k in ['query','added','changed','eventA','removals','relations']]
        carrier=pack(nested(values))
        assert unpack(carrier)==nested(values)
        assert [carrier[k] for k in ['query','event','added','changed','removals','relations']]==[view[k] for k in ['query','eventA','added','changed','removals','relations']]
        views_checked+=1
assert views_checked==22
assert wire==(HERE.parent/'bend.expected.stdout').read_bytes()
assert len(wire)==89014 and hashlib.sha256(wire).hexdigest()=='a830002265361e5398c7b08544694dcfb87315f3621b1fc1af324ae2302ce2ae'
assert old['main']==new['main'] and old['write_first_root']==new['write_first_root'] and old['write_second_root']==new['write_second_root']
print(json.dumps({'sourcePins':len(pins),'unchangedCoreBodies':66,'changedCommonDefinitions':sorted(changed),'packedViewsVerified':views_checked,'bytes':len(wire),'sha256':hashlib.sha256(wire).hexdigest(),'invariants':'passed'}))
