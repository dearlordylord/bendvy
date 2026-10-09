"""Existing System DTO inventory; exact import-only nominal rebinding."""
import types
from pathlib import Path
HERE=Path(__file__).resolve().parent
PARENT=HERE.parents[2]/'system-event-v1/generic-v1/transport.py'
FIXTURE=HERE/'source/declaration-read-v1/registered-v1'
def parser(role):
 source=globals().get('VERIFIED_SOURCES',{})
 raw=source[str(PARENT.resolve())] if source else PARENT.read_bytes()
 m=types.ModuleType('reached_system_transport');m.__file__=str(PARENT);m.__dict__['VERIFIED_SOURCES']=source
 exec(compile(raw,str(PARENT),'exec'),m.__dict__)
 p,t=m.parser(role)
 p.ENTRY=HERE/'source/system-event-v1/generic-v1'/('main.bend' if role=='full' else 'second-schema.bend')
 if role=='full':
  p.records={k:(str(FIXTURE/Path(f).name) if Path(f).name in ('observation.bend','fixture.bend','direct-controls.bend','log.bend') else f,fields) for k,(f,fields) in p.records.items()}
  p.sums={k:(str(FIXTURE/Path(f).name) if Path(f).name in ('fixture.bend','log.bend') else f,variants) for k,(f,variants) in p.sums.items()}
 return p,t
def render(role,value):
 p,t=parser(role);return p.render(t,value)
def parse(role,raw):
 assert type(raw)is bytes
 p,t=parser(role);r=p.Parser(raw.decode());v=r.read(t);r.literal('\n');assert r.i==len(r.text),'trailing bytes'
 assert (p.render(t,v)+'\n').encode()==raw,'noncanonical transport'
 return v
