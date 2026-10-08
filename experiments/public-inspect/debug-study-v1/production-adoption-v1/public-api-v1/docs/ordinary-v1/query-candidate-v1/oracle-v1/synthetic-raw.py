"""Reverse the complete pre-backend oracle into pinned show_main Data spelling.
No executable output is read. This is parser input, never runtime evidence.
"""
from pathlib import Path
import json,os
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
ENTRY=Path('/workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/scenario-main.bend')
def name(file,ctor):
 if file=='Base' or file=='main':return ctor
 path=ENTRY.parent/file if not file.startswith('/') else Path(file)
 return os.path.relpath(path.resolve(),ENTRY.parent.resolve())[:-5]+'.'+ctor
def named(file,ctor,args):return name(file,ctor)+'{'+', '.join(args)+'}'
DTO='scenario-dto.bend';APP='app.bend';DECL='declaration.bend';VIEW=str(ROOT/'experiments/public-simulation/bend-v1/owner-view.bend');WORLD=str(ROOT/'src/ecs/world.bend');CMP=str(ROOT/'src/ecs/component.bend');LIFECYCLE=str(ROOT/'src/ecs/lifecycle.bend');COMPOSE=str(ROOT/'src/ecs/compose.bend');SCH=str(ROOT/'src/ecs/schedule.bend');CODEC=str(ROOT/'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend')
# Each record lists all fields in source constructor order. A [T] type is a full List<T>.
records={
 'Report':('main','Report',[('plain','ScenarioReport'),('transient','ScenarioReport'),('constructed','ScenarioReport')]),
 'ScenarioReport':(DTO,'ScenarioReport',[('category','String'),('phases',['Snapshot'])]),
 'Snapshot':(DTO,'Snapshot',[('label','String'),('factoryNextNamespace','U32'),('world','WorldSnapshot'),('registries',['RegistrySnapshot']),('operation','Operation'),('descriptions',['MaybeDescription'])]),
 'WorldSnapshot':(DTO,'WorldSnapshot',[(k,t) for k,t in [('namespace','U32'),('nextId','U32'),('highWater','U32'),('capacity','U32'),('depth','Nat'),('liveBits',['Bool']),('resource','Unit'),('events',['Unit']),('pendingCount','U32'),('registrations',['RegistrationMeta']),('nextSystemId','U32'),('clock','U32'),('columns','Columns')]]),
 'Columns':(DTO,'Columns',[(k,'Column') for k in ['position','velocity','health']]),
 'Column':(DTO,'Column',[('storage','Storage'),('cells',['Cell'])]),
 'Cell':(DTO,'Cell',[('id','U32'),('payload','MaybeFull'),('stamp','Stamp')]),
 'FullCell':(VIEW,'FullCell',[('length','Nat'),('values',['U32'])]),
 'Stamp':(LIFECYCLE,'Stamp',[('added','U32'),('changed','U32')]),
 'RegistrationMeta':(WORLD,'RegistrationMeta',[('id','U32'),('name','String'),('access',['String'])]),
 'RegistrySnapshot':(DTO,'RegistrySnapshot',[(k,t) for k,t in [('namespace','U32'),('id','U32'),('name','String'),('access',['String']),('cursor','U32'),('slot','String'),('clauses',['Clause'])]]),
 'Clause':(DECL,'Clause',[('name','String'),('mode','Mode')]),
 'RowValues':(DTO,'RowValues',[('position','FullCell'),('velocityBefore','FullCell'),('health','Access')]),
 'RejectedArgs':(DTO,'RejectedArgs',[('fail','Bool'),('cursor','U32')]),
 'Description':(APP,'Description',[('namespace','U32'),('name','String'),('steps',['Step']),('systems',['Entry'])]),
 'Entry':(APP,'Entry',[('id','U32'),('name','String'),('slot','String'),('clauses',['Clause'])]),
}
# For named fields, require exact shape. For a single flattened field, render the whole tag value.
sums={
 'Operation':{'Observed':(DTO,[]),'Run':(DTO,[('result','Result')]),'PositionReplaced':(DTO,[('result','Status'),('previous','MaybeFull'),('incoming','MaybeFull')]),'RefusedRegistration':(DTO,[('args','RejectedArgs'),('foreignWorld','WorldSnapshot'),('registry','RegistrySnapshot')])},
 'Storage':{'Plain':(DTO,[]),'Transient':(DTO,[]),'Constructed':(DTO,[('codec','Codec')])},
 'Codec':{'ArrayValue':(CODEC,'Codec'),'Integer':(CODEC,[])},
 'MaybeFull':{'None':('Base',[]),'Some':('Base','FullCell')},
 'MaybeDescription':{'None':('Base',[]),'Some':('Base','Description')},
 'Access':{'Found':(CMP,'FullCell'),'ComponentAbsent':(CMP,[])},
 'Result':{'Done':('Base',['RowValues']),'Fail':('Base','Error')},
 'Error':{'UserError':(COMPOSE,'Unit')},
 'Status':{'Accepted':(WORLD,[])},
 'Step':{'Phase':(SCH,[('name','String')]),'System':(SCH,[('id','U32'),('condition','U32')]),'Barrier':(SCH,[])},
 'Unit':{'Unit':('Base',[])},
}
def render(t,x):
 if isinstance(t,list):
  assert isinstance(x,list);return '['+', '.join(render(t[0],a) for a in x)+']'
 if t=='String':assert isinstance(x,str);return json.dumps(x,ensure_ascii=True)
 if t=='U32':assert type(x) is int and 0<=x<2**32;return str(x)
 if t=='Nat':assert set(x)=={'nat'} and type(x['nat']) is int and x['nat']>=0;return str(x['nat'])+'n'
 if t=='Bool':assert type(x) is bool;return 'True{}' if x else 'False{}'
 if t=='Mode':assert x in ['Read','Write','Optional','With','Without','Added','Changed'];return named(DECL,x,[])
 if t in records:
  file,ctor,fields=records[t];assert set(x)=={k for k,_ in fields},(t,x.keys());return named(file,ctor,[render(ft,x[k]) for k,ft in fields])
 assert t in sums and type(x) is dict and len(x)==1,(t,x)
 tag,value=next(iter(x.items()));assert tag in sums[t],(t,tag)
 file,fields=sums[t][tag]
 if fields==[]:assert value=={};args=[]
 elif isinstance(fields,str):args=[render(fields,value)]
 elif fields and isinstance(fields[0],tuple):
  assert set(value)=={k for k,_ in fields};args=[render(ft,value[k]) for k,ft in fields]
 else:args=[render(fields,value)]
 return named(file,tag,args)
if __name__=='__main__':
 expected=json.loads((HERE/'expected.json').read_text());(HERE/'synthetic-complete.stdout').write_text(render('Report',expected)+'\n')
