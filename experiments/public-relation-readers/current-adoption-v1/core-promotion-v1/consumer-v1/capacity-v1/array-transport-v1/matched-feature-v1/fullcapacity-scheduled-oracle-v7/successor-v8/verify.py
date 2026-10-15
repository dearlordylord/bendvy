#!/usr/bin/env python3
"""Source-only V8 ordered-write equivalence to the independently derived V7 wire."""
import hashlib
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('v7_model',HERE.parent/'derive.py')
model=importlib.util.module_from_spec(spec)
spec.loader.exec_module(model)
pins=json.loads((HERE/'source-pins.json').read_text())
for path,digest in pins.items():
    assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
old=Path('/tmp/bendvy43-fullcapacity-v7-oracle-source01')
freeze=json.loads((HERE/'source-freeze.json').read_text())
entry=Path(freeze['entrypoint']).relative_to('/workspace/formal-proofs/bendvy-worktrees/parity43-ordinary-full-lifecycle-sparse')
v8=(Path(freeze['immutableRoot'])/entry).read_text()
v7=(old/entry.with_name(entry.name.replace('-v8.bend','-v7.bend'))).read_text()
# Every ECS operation, observer and serializer before the final pipeline is exact.
assert v7.split('def schedule_finished_state(')[0]==v8.split('def output_one(')[0]
assert 'case (_,image):["{\\"steps\\":",observations_json(observations),",\\"trace\\":",strings_json(trace),",\\"final\\":",image,"}"]' in v8
assert 'case []:IO.write("\\n")' in v8
assert 'case chunk <> rest:IO.bind(Unit,Unit,IO.write(chunk),_ => write_output_chunks(rest))' in v8
assert v8.endswith('  write_output_chunks(scheduled_start(setup()))\n')
assert 'IO.print(' not in v8
model.verify_pins()
wire=model.derive()
body=wire[:-1].decode()
a=body.index(',"trace":'); b=body.rindex(',"final":')
chunks=['{"steps":',body[len('{"steps":'):a],',"trace":',body[a+len(',"trace":'):b],',"final":',body[b+len(',"final":'):-1],'}']
# Source IO.bind visits head before tail; base case writes precisely one LF.
written=b''.join(chunk.encode() for chunk in chunks)+b'\n'
assert len(chunks)==7 and written==wire
assert len(written)==67573993
assert hashlib.sha256(written).hexdigest()=='804d5dbf564e859ece28200e92fe147cdad070b4db4a37392526c2fd5262520b'
print(json.dumps({'sourcePins':len(pins),'unchangedCoreBodies':64,'chunks':7,'bytes':len(written),'sha256':hashlib.sha256(written).hexdigest(),'invariants':'passed'}))
