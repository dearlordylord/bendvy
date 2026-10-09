"""Exact source-derived generic scoped-reader DTO using the reviewed strict parser."""
import importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
path=HERE.parent/'registered-read-v1/transport.py'
s=importlib.util.spec_from_file_location('generic_reader_parser',path);p=importlib.util.module_from_spec(s);s.loader.exec_module(p)
p.ENTRY=HERE/'main.bend'
p.records={
 'Report':('main',[('payload','PayloadView'),('first','ObservationView'),('second','ObservationView')]),
 'PayloadView':('main',[('cells',['Bool']),('label','String'),('sentinel',['U32'])]),
 'ObservationView':('main',[('projection','Projection'),('scratch',['Bool']),('sentinel',['U32'])]),
 'Projection':('controls.bend',[('value','Bool'),('label','String'),('markers',['U32'])]),
}
p.sums={}
def render(t,value):return p.render(t,value)
def parse(raw):
 assert type(raw) is bytes
 parser=p.Parser(raw.decode('utf-8'));value=parser.read('Report');parser.literal('\n');assert parser.i==len(parser.text),'trailing bytes'
 assert (render('Report',value)+'\n').encode()==raw,'noncanonical transport'
 return value
