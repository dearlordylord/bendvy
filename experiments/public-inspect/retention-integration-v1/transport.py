"""Strict complete retention DTO, using the existing source-loaded typed parser."""
import types
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
PARSER=ROOT/'experiments/public-owned-events/registered-read-v1/transport.py'
# Default is normal. A successor immutable copy fixes ENTRY to the mutant entry.
ENTRY=HERE/'main.bend'
E=str(ROOT/'src/ecs/event-runtime.bend');W=str(ROOT/'src/ecs/world.bend')
records={
 'Snapshot':('main',[(k,t)for k,t in [('label','String'),('metadata','Metadata'),('events',['U32']),('resource',['U32']),('clock','U32'),('nextId','U32'),('highWater','U32'),('worldCapacity','U32'),('depth','Nat'),('registrations',['RegistrationMeta']),('nextSystem','U32'),('inspectorCursor','MaybeNat'),('readerResult','Completion')]]),
 'Metadata':('main',[(k,t)for k,t in [('namespace','U32'),('batches',['BatchEvent']),('positions',['Position']),('nextReader','U32'),('tick','Nat'),('frameStart','Nat'),('boundary','Nat'),('capacity','Nat'),('dropped','Nat')]]),
 'Position':(E,[('id','U32'),('cursor','Nat'),('registeredAt','Nat')]),
 'BatchEvent':(E,[('tick','Nat'),('values',['U32'])]),
 'Reading':(E,[('values',['U32']),('lagged','Bool')]),
 'RegistrationMeta':(W,[('id','U32'),('name','String'),('access',['String'])]),
}
sums={
 'MaybeNat':('Base',{'None':[],'Some':[('value','Nat')]}),
 'Completion':('main',{'NoRead':[],'ReadSucceeded':[('value','Reading')],'ReadFailed':[('value','Reading')],'ReadRejected':[('args','Bool')]}),
}
def parser():
 p=types.ModuleType('retention_parser');p.__file__=str(PARSER)
 source=VERIFIED_SOURCES[str(PARSER)]if globals().get('VERIFIED_SOURCES')else PARSER.read_bytes()
 exec(compile(source,str(PARSER),'exec'),p.__dict__)
 p.ENTRY=ENTRY;p.records=records;p.sums=sums
 return p

def encode(t,x):
 if isinstance(t,list):assert type(x)is list;return [encode(t[0],v)for v in x]
 if t=='Nat':assert type(x)is int and x>=0;return {'nat':x}
 if t in ('String','Bool','U32'):return x
 assert type(x)is dict
 if t in records:
  _,fields=records[t];tag='Batch'if t=='BatchEvent'else t
  assert x.get('$')==tag and set(x)=={'$',*(k for k,_ in fields)}
  return {k:encode(ft,x[k])for k,ft in fields}
 _,variants=sums[t];tag=x.get('$');assert tag in variants;fields=variants[tag]
 assert set(x)=={'$',*(k for k,_ in fields)}
 return {tag:{k:encode(ft,x[k])for k,ft in fields}}
def decode(t,x):
 if isinstance(t,list):return [decode(t[0],v)for v in x]
 if t=='Nat':return x['nat']
 if t in ('String','Bool','U32'):return x
 if t in records:
  _,fields=records[t];return {'$':'Batch'if t=='BatchEvent'else t,**{k:decode(ft,x[k])for k,ft in fields}}
 _,variants=sums[t];tag,fieldsvalue=next(iter(x.items()));return {'$':tag,**{k:decode(ft,fieldsvalue[k])for k,ft in variants[tag]}}
def render(role,value):
 assert role=='generic';return parser().render(['Snapshot'],encode(['Snapshot'],value))
def parse(role,raw):
 assert role=='generic'and type(raw)is bytes
 p=parser();reader=p.Parser(raw.decode('utf-8'));x=reader.read(['Snapshot']);reader.literal('\n');assert reader.i==len(reader.text)
 value=decode(['Snapshot'],x);assert (render(role,value)+'\n').encode()==raw
 return value
