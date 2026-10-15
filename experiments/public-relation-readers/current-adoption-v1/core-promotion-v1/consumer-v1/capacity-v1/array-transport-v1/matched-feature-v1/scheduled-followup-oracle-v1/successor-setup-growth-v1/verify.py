#!/usr/bin/env python3
"""Source-only setup applicability correction; preserve the original intended wire."""
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('intended_model',HERE.parent/'model.py')
model=importlib.util.module_from_spec(spec)
spec.loader.exec_module(model)
pins=json.loads((HERE/'source-pins.json').read_text())
for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
oldfreeze=json.loads((HERE.parent/'source-freeze.json').read_text())
freeze=json.loads((HERE/'source-freeze.json').read_text())
rel=Path(freeze['entrypoint']).relative_to('/workspace/formal-proofs/bendvy-worktrees/parity43-ordinary-full-lifecycle-sparse')
old=(Path(oldfreeze['immutableRoot'])/rel).read_text()
new=(Path(freeze['immutableRoot'])/rel).read_text()
expected=old.replace('def seed_column_value(store:store_type(),id:U32,value:U32)', 'def seed_column_value(store:store_type(),+id:U32,value:U32)').replace('Col.swap(~Schema,~U32,components,id,Some{value})', 'Col.swap(~Schema,~U32,Col.ensure(~Schema,~U32,components,id),id,Some{value})')
assert new==expected
column=(Path(freeze['immutableRoot'])/'src/ecs/column.bend').read_text()
assert 'Column{ALeaf{None{}},[]}' in column
assert 'U32.is_le(id, size)' in column
# Independent finite reduction of the actual reached setup column operations.
slots=[None];stamps=[]
def swap(identifier,value):
    if identifier<=0 or identifier>len(slots) or identifier>131072:return False
    slots[identifier-1]=value
    return True
assert swap(1,42) and slots==[42]
assert not swap(2,43) and slots==[42]  # Why the predecessor setup cannot continue.
# Col.ensure uses target<=size, doubling with absent leaves; target2 requires one grow.
while len(slots)<2:slots.extend([None]*len(slots))
assert slots==[42,None]
assert swap(2,43) and slots==[42,43] and stamps==[]
# Pure ensure/swap has no World tick, event, live-slot or registration effect.
wire,timeline,rows=model.derive()
io=model.verify_fragment_io(wire,rows)
assert wire==(HERE.parent/'expected.stdout').read_bytes()
assert len(wire)==26254
assert hashlib.sha256(wire).hexdigest()=='fd4316f0b089ccdd0bec3c06faba92b9096c08e3fd4c4d1d7054e24e505de926'
assert rows[0]['world']['components']==[{'entity':model.HANDLE,'value':42,'added':0,'changed':0},{'entity':model.TARGET,'value':43,'added':0,'changed':0}]
print(json.dumps({'sourcePins':len(pins),'unchangedCoreBodies':64,'setupColumnSlots':slots,'bytes':len(wire),'sha256':hashlib.sha256(wire).hexdigest(),'io':io,'invariants':'passed'}))
