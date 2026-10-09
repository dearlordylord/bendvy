"""Strict existing generic/registered transport with source-only entry rebinding."""
import types
from pathlib import Path
HERE=Path(__file__).resolve().parent
PARENT=HERE.parent/'transport.py'
def parser(role):
 source=VERIFIED_SOURCES[str(PARENT)] if globals().get('VERIFIED_SOURCES') else PARENT.read_bytes()
 m=types.ModuleType('canonical_declaration_transport');m.__file__=str(PARENT);m.__dict__['VERIFIED_SOURCES']=globals().get('VERIFIED_SOURCES',{});exec(compile(source,str(PARENT),'exec'),m.__dict__)
 p,t=m.parser(role);p.ENTRY=HERE/'source/declaration-read-v1'/('main.bend'if role=='generic'else'registered-v1/main.bend')
 return p,t
def render(role,value):
 p,t=parser(role);return p.render(t,value)
def parse(role,raw):
 assert type(raw)is bytes;p,t=parser(role);r=p.Parser(raw.decode());value=r.read(t);r.literal('\n');assert r.i==len(r.text),'trailing bytes';assert(render(role,value)+'\n').encode()==raw,'noncanonical transport';return value
