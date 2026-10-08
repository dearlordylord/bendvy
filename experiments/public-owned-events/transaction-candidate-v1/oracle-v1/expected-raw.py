"""Full pre-backend show_main term from independent expected Data DTO.
No program/compiler/output is executed or read. Names bind original source entry.
"""
from pathlib import Path
import json,os
HERE=Path(__file__).resolve().parent
ENTRY=Path('/workspace/formal-proofs/bendvy-worktrees/parity-63-loader-resolver/experiments/public-owned-events/transaction-candidate-v1/main.bend')
ROOT=Path('/workspace/formal-proofs/bendvy')
def ctor(file,name,fields):
 prefix='' if file=='Base' or file=='main' else os.path.relpath((ENTRY.parent/file if not file.startswith('/') else Path(file)).resolve(),ENTRY.parent.resolve())[:-5]+'.'
 return prefix+name+'{'+', '.join(fields)+'}'
O='observation.bend';W=str(ROOT/'src/ecs/world.bend');L=str(ROOT/'src/ecs/lifecycle.bend');T=str(ROOT/'src/ecs/transaction.bend')
records={
 'Batch':('main','Batch',[(k,'SeedView' if k in ['seeded','seedRefused'] else 'RunView') for k in ['seeded','seedRefused','success','failure','foreign']]),
 'SeedView':(O,'SeedView',[('world','Snapshot'),('owners','OwnersView')]),
 'RunView':(O,'RunView',[('outcome','Outcome'),('owners','OwnersView'),('recovered',['EventView']),('beforeFlush','Snapshot'),('afterFlush','Snapshot'),('final','Snapshot')]),
 'Snapshot':(O,'Snapshot',[('metadata','Metadata'),('live',['Bool']),('column','ColumnView'),('log',['EventView']),('marks',['U32']),('pending','U32')]),
 'Metadata':(O,'Metadata',[(k,t) for k,t in [('namespace','U32'),('nextId','U32'),('highWater','U32'),('capacity','U32'),('depth','Nat'),('events',['Unit']),('registrations',['RegistrationMeta']),('nextSystemId','U32'),('clock','U32')]]),
 'ColumnView':(O,'ColumnView',[('supported','Bool'),('slots',['MaybeCells']),('stamps',['Entry'])]),
 'EventView':(O,'EventView',[('tag','String'),('cells',['U32'])]),
 'OwnersView':(O,'OwnersView',[('seedPrevious',['MaybeCells']),('rejected',[['U32']]),('errors',['Error'])]),
 'Entry':(L,'Entry',[('id','U32'),('stamp','Stamp')]),
 'Stamp':(L,'Stamp',[('added','U32'),('changed','U32')]),
 'RegistrationMeta':(W,'RegistrationMeta',[('id','U32'),('name','String'),('access',['String'])]),
}
def render(t,x):
 if isinstance(t,list):assert isinstance(x,list);return '['+', '.join(render(t[0],v) for v in x)+']'
 if t=='U32':assert type(x) is int and 0<=x<2**32;return str(x)
 if t=='String':assert type(x) is str;return json.dumps(x)
 if t=='Nat':assert type(x) is dict and set(x)=={'nat'} and type(x['nat']) is int and x['nat']>=0;return str(x['nat'])+'n'
 if t=='Bool':assert type(x) is bool;return 'True{}' if x else 'False{}'
 if t in records:
  file,name,fields=records[t];assert set(x)=={k for k,_ in fields};return ctor(file,name,[render(ft,x[k]) for k,ft in fields])
 assert type(x) is dict and len(x)==1
 tag,value=next(iter(x.items()))
 if t=='MaybeCells':
  assert tag in ['Some','None']
  if tag=='None':assert value=={};return ctor('Base','None',[])
  return ctor('Base','Some',[render(['U32'],value)])
 if t=='Outcome':
  assert tag in ['Success','Failure']
  if tag=='Success':assert value=={};return ctor(T,tag,[])
  assert set(value)=={'error'};return ctor(T,tag,[render('String',value['error'])])
 if t=='Error':assert tag=='MissingEntity' and value=={};return ctor(W,tag,[])
 if t=='Unit':assert tag=='Unit' and value=={};return ctor('Base',tag,[])
 raise AssertionError(t)
if __name__=='__main__':(HERE/'expected.stdout').write_text(render('Batch',json.loads((HERE/'expected.json').read_text()))+'\n')
