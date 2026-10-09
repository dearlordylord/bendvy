"""Strict existing generic/registered transport with source-only entry rebinding."""
import types
from pathlib import Path
HERE=Path(__file__).resolve().parent
PARENT=HERE.parents[2]/'transport.py'
def parser(role):
 source=VERIFIED_SOURCES[str(PARENT)] if globals().get('VERIFIED_SOURCES') else PARENT.read_bytes()
 m=types.ModuleType('canonical_declaration_transport');m.__file__=str(PARENT);m.__dict__['VERIFIED_SOURCES']=globals().get('VERIFIED_SOURCES',{});exec(compile(source,str(PARENT),'exec'),m.__dict__)
 p,t=m.parser(role);p.ENTRY=HERE/'source/main.bend'
 original=HERE.parent/'source/declaration-read-v1/registered-v1'
 for key,(file,fields) in list(p.records.items()):
  if file in ('log.bend','direct-controls.bend'):p.records[key]=(str(original/file),fields)
 for key,(file,variants) in list(p.sums.items()):
  if file=='log.bend':p.sums[key]=(str(original/file),variants)
 p.records['DirectPayloadView']=(str(original/'observation.bend'),p.records['PayloadView'][1])
 p.records['DirectRowView']=(str(original/'observation.bend'),[('key','U32'),('payload','DirectPayloadView')])
 p.records['DirectLogView']=(str(original/'observation.bend'),[('seen',['U32']),('rows',['DirectRowView'])])
 p.records['DirectView']=(str(original/'direct-controls.bend'),[('log','DirectLogView'),('value','MaybeCells'),('errors',['Refusal']),('refused',['DirectRowView'])])
 old=p.name
 p.name=lambda path,tag:old(path,{'DirectPayloadView':'PayloadView','DirectRowView':'RowView','DirectLogView':'LogView'}.get(tag,tag))
 return p,t
def render(role,value):
 p,t=parser(role);return p.render(t,value)
def parse(role,raw):
 assert type(raw)is bytes;p,t=parser(role);r=p.Parser(raw.decode());value=r.read(t);r.literal('\n');assert r.i==len(r.text),'trailing bytes';assert(render(role,value)+'\n').encode()==raw,'noncanonical transport';return value
