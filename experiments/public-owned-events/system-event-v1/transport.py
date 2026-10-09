"""Strict complete System owner DTO; source-derived nominal paths, no defaults."""
import importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
PARSER=HERE.parent/'registered-read-v1/transport.py'
FIXTURE=ROOT/'experiments/public-owned-events/declaration-read-v1/registered-v1'
QUERY=str(ROOT/'experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend')
def parser(role='system'):
 assert role=='system'
 spec=importlib.util.spec_from_file_location('system_dto',PARSER);p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
 p.ENTRY=HERE/'main.bend'
 p.records={k:(str(FIXTURE/f) if f in ('observation.bend','fixture.bend','direct-controls.bend','log.bend') else f,fields) for k,(f,fields) in p.records.items()}
 p.sums={k:(str(FIXTURE/f) if f in ('fixture.bend','log.bend') else f,variants) for k,(f,variants) in p.sums.items()}
 p.records['State']=p.records.pop('Snapshot')
 p.records['Snapshot']=('main',[('fastOwner','OwnerMeta'),('slowOwner','OwnerMeta'),('state','State')])
 p.records['OwnerMeta']=('main',[('slot','String'),('clauses',['Clause'])])
 p.records['Clause']=(QUERY,[('name','String'),('mode','Mode')])
 p.sums['Mode']=(QUERY,{k:[] for k in ('Read','Write','Optional','With','Without','Added','Changed')})
 original=p.name;p.name=lambda file,tag:original(file,'Snapshot' if tag=='State' else tag)
 return p,'Batch'
def render(role,value):
 p,t=parser(role);return p.render(t,value)
def parse(role,raw):
 assert type(raw) is bytes
 p,t=parser(role);r=p.Parser(raw.decode());value=r.read(t);r.literal('\n');assert r.i==len(r.text),'trailing bytes'
 assert (p.render(t,value)+'\n').encode()==raw,'noncanonical transport'
 return value
