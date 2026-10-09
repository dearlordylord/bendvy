"""Exact generic System full-consumer and second-schema DTOs, source-derived."""
import importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
PARENT=HERE.parent/'transport.py'
QUERY=str(ROOT/'experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend')
E=str(ROOT/'src/ecs/event-runtime.bend');W=str(ROOT/'src/ecs/world.bend')
def parser(role):
 assert role in ('full','second')
 import types
 source=globals().get('VERIFIED_SOURCES',{})
 raw=source[str(PARENT.resolve())] if source else PARENT.read_bytes()
 m=types.ModuleType('generic_system_parent');m.__file__=str(PARENT);m.__dict__['VERIFIED_SOURCES']=source
 exec(compile(raw,str(PARENT),'exec'),m.__dict__)
 # Preserve parent dependency location while binding new original nominal entry.
 p,t=m.parser();p.ENTRY=HERE/('main.bend' if role=='full' else 'second-schema.bend')
 if role=='full':return p,t
 p.records={
  'Report':('main',[('success','Observed'),('refused','Observed')]),
  'OwnerMeta':('main',[(k,typ) for k,typ in [('slot','String'),('clauses',['Clause']),('readerNamespace','U32'),('readerId','U32'),('expectedRegistry','U32'),('registryNamespace','U32'),('registryId','U32'),('name','String'),('access',['String']),('cursor','U32')]]),
  'WorldView':('main',[(k,typ) for k,typ in [('namespace','U32'),('nextId','U32'),('highWater','U32'),('live',['Bool']),('capacity','U32'),('depth','Nat'),('store',['U32']),('resources',['Bool']),('events',['Bool']),('pending','Nat'),('registrations',['RegistrationMeta']),('nextSystemId','U32'),('clock','U32')]]),
  'EventView':('main',[(k,typ) for k,typ in [('namespace','U32'),('batches',['BatchEvent']),('positions',['Position']),('nextReader','U32'),('tick','Nat'),('frameStart','Nat'),('boundary','Nat'),('capacity','Nat'),('dropped','Nat'),('values',['Bool'])]]),
  'Clause':(QUERY,[('name','String'),('mode','Mode')]),
  'BatchEvent':(E,[('tick','Nat'),('values',['Bool'])]),
  'Position':(E,[('id','U32'),('cursor','Nat'),('registeredAt','Nat')]),
  'RegistrationMeta':(W,[('id','U32'),('name','String'),('access',['String'])]),
 }
 p.sums={
  'Mode':(QUERY,{k:[] for k in ('Read','Write','Optional','With','Without','Added','Changed')}),
  'Observed':('main',{
   'Success':[('world','WorldView'),('events','EventView'),('owner','OwnerMeta'),('outputs',[['U32']])],
   'Refused':[('world','WorldView'),('events','EventView'),('owner','OwnerMeta'),('args',['U32'])],
   'BodyFailed':[('world','WorldView'),('events','EventView'),('owner','OwnerMeta'),('error','String'),('outputs',[['U32']])],
   'SetupRefused':[('world','WorldView'),('events','EventView')],
  }),
 }
 return p,'Report'
def render(role,value):
 p,t=parser(role);return p.render(t,value)
def parse(role,raw):
 assert type(raw) is bytes
 p,t=parser(role);r=p.Parser(raw.decode());value=r.read(t);r.literal('\n');assert r.i==len(r.text),'trailing bytes'
 assert (p.render(t,value)+'\n').encode()==raw,'noncanonical transport'
 return value
