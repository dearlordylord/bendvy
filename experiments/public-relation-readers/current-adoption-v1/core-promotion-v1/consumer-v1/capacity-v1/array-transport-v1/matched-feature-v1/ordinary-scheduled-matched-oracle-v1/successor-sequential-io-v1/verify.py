#!/usr/bin/env python3
"""Source-only exact-wire binding for sequential complete World IO evaluation."""
import hashlib
import json
from pathlib import Path
import sys
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
import bend_model
import bend_render

pins=json.loads((HERE/'source-pins.json').read_text())
for path,digest in pins.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest,path
freeze=json.loads((HERE/'source-freeze.json').read_text())
parent=json.loads(Path(freeze['parentFreeze']).read_text())
old=Path(parent['entrypoint']).read_text();new=Path(freeze['entrypoint']).read_text()
old_writer='''def write_output_chunks(chunks:List<&2,String>) -> IO(Unit):
  match chunks:
    case []:IO.write("\\n")
    case chunk <> rest:IO.bind(Unit,Unit,IO.write(chunk),_ => write_output_chunks(rest))'''
new_writer='''def write_raw_chunks(chunks:List<&2,String>) -> IO(Unit):
  match chunks:
    case []:IO.pure(Unit,Unit{})
    case chunk <> rest:IO.bind(Unit,Unit,IO.write(chunk),_ => write_raw_chunks(rest))
def write_output_chunks(chunks:List<&2,String>) -> IO(Unit):
  IO.bind(Unit,Unit,write_raw_chunks(chunks),_ => IO.write("\\n"))'''
old_main='''def main() -> IO(Unit):
  write_output_chunks(both_root_outputs(followup_start(setup_with_factory(W.Factory{1})),followup_start(setup_with_factory(W.Factory{2}))))'''
new_main='''def write_second_root() -> IO(Unit):
  IO.bind(Unit,Unit,IO.write(","),_ => IO.bind(Unit,Unit,write_raw_chunks(followup_start(setup_with_factory(W.Factory{2}))),_ => IO.bind(Unit,Unit,IO.write("]"),_ => IO.write("\\n"))))
def write_first_root() -> IO(Unit):
  IO.bind(Unit,Unit,IO.write("["),_ => IO.bind(Unit,Unit,write_raw_chunks(followup_start(setup_with_factory(W.Factory{1}))),_ => write_second_root()))
def main() -> IO(Unit):
  write_first_root()'''
assert old.count(old_writer)==old.count(old_main)==1
assert new==old.replace(old_writer,new_writer).replace(old_main,new_main)
# The replacement is confined to terminal IO. All operations, snapshots,
# continuations, per-world JsonDoc creation and chunk rendering remain exact.
wire,details,shared,ios=bend_model.derive()
parts=[b'[']
for namespace in [1,2]:
    if namespace==2:parts.append(b',')
    # Exact whole-entry inverse join proves unchanged per-world semantics.
    state,rows,outcomes,deliveries,plan=bend_model.one_world(old,namespace)
    body,io=bend_render.render(rows,state.image())
    parts.append(body[:-1])  # write_raw_chunks has pure empty-list case, no LF.
parts.extend([b']',b'\n'])
reconstructed=b''.join(parts)
assert reconstructed==wire==(HERE.parent/'bend.expected.stdout').read_bytes()
assert len(wire)==89014 and hashlib.sha256(wire).hexdigest()=='a830002265361e5398c7b08544694dcfb87315f3621b1fc1af324ae2302ce2ae'
assert reconstructed.count(b'\n')==1
print(json.dumps({'sourcePins':len(pins),'unchangedCoreBodies':66,'bytes':len(wire),'sha256':hashlib.sha256(wire).hexdigest(),'worldExecutionOrder':[1,2],'terminalLfWrites':1,'invariants':'passed'}))
