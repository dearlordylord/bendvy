"""Strict existing generic/registered transport with source-only entry rebinding."""
import importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
PARENT=Path('/workspace/formal-proofs/bendvy/experiments/public-owned-events/declaration-read-v1/transport.py')
def parser(role):
 spec=importlib.util.spec_from_file_location('canonical_declaration_transport',PARENT);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 p,t=m.parser(role);p.ENTRY=HERE/'source/declaration-read-v1'/('main.bend'if role=='generic'else'registered-v1/main.bend')
 return p,t
def render(role,value):
 p,t=parser(role);return p.render(t,value)
def parse(role,raw):
 assert type(raw)is bytes;p,t=parser(role);r=p.Parser(raw.decode());value=r.read(t);r.literal('\n');assert r.i==len(r.text),'trailing bytes';assert(render(role,value)+'\n').encode()==raw,'noncanonical transport';return value
