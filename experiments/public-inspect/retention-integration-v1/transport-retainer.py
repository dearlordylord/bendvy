"""Same complete transport, source-derived mutant entry namespace only."""
import types
from pathlib import Path
HERE=Path(__file__).resolve().parent
SOURCE=HERE/'transport.py'
def transport():
 p=types.ModuleType('retention_mutant_transport');p.__file__=str(SOURCE)
 p.__dict__['VERIFIED_SOURCES']=globals().get('VERIFIED_SOURCES',{})
 source=VERIFIED_SOURCES[str(SOURCE)]if globals().get('VERIFIED_SOURCES')else SOURCE.read_bytes()
 exec(compile(source,str(SOURCE),'exec'),p.__dict__);p.ENTRY=HERE/'mutant-retainer/main.bend';return p
def render(role,value):return transport().render(role,value)
def parse(role,raw):return transport().parse(role,raw)
