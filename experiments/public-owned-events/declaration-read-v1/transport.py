"""Exact source-derived ordinary declaration DTOs; reviewed strict parser reused."""
import importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
PARSER=HERE.parent/'registered-read-v1/transport.py'
def parser(role):
 s=importlib.util.spec_from_file_location('declaration_'+role,PARSER);p=importlib.util.module_from_spec(s);s.loader.exec_module(p)
 if role=='registered':p.ENTRY=HERE/'registered-v1/main.bend';return p,'Batch'
 assert role=='generic';p.ENTRY=HERE/'main.bend'
 gm=str(ROOT/'experiments/public-owned-events/generic-scoped-read-v1/main.bend')
 gc=str(ROOT/'experiments/public-owned-events/generic-scoped-read-v1/controls.bend')
 p.records={
  'Report':('main',[('access',['String']),('observations','GenericReport')]),
  'GenericReport':(gm,[('payload','PayloadView'),('first','ObservationView'),('second','ObservationView')]),
  'PayloadView':(gm,[('cells',['Bool']),('label','String'),('sentinel',['U32'])]),
  'ObservationView':(gm,[('projection','Projection'),('scratch',['Bool']),('sentinel',['U32'])]),
  'Projection':(gc,[('value','Bool'),('label','String'),('markers',['U32'])]),
 }
 p.sums={};original=p.name
 p.name=lambda file,tag:original(file,'Report' if tag=='GenericReport' else tag)
 return p,'Report'
def render(role,value):
 p,t=parser(role);return p.render(t,value)
def parse(role,raw):
 assert type(raw) is bytes
 p,t=parser(role);reader=p.Parser(raw.decode());value=reader.read(t);reader.literal('\n');assert reader.i==len(reader.text),'trailing bytes'
 assert (p.render(t,value)+'\n').encode()==raw,'noncanonical transport'
 return value
