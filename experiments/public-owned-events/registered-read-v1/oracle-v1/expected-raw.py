"""Complete typed raw spelling from independent neutral oracle; no output inputs."""
from pathlib import Path
import json,os
HERE=Path(__file__).resolve().parent
ENTRY=Path('/workspace/formal-proofs/bendvy-worktrees/parity-63-loader-resolver/experiments/public-owned-events/registered-read-v1/main.bend')
ROOT=Path('/workspace/formal-proofs/bendvy')
L=lambda t:[t]
records={
 'Batch':('main','Batch',[(k,'Trace' if k in ['standard','capacity'] else 'DirectView') for k in ['standard','capacity','missing','duplicateRows','duplicatePublication','ownedOutput']]),
 'Snapshot':('observation.bend','Snapshot',[('label','String'),('runtime','RuntimeView'),('fast','ReaderView'),('slow','ReaderView'),('reads',L('Completion')),('retired',L('RowView')),('refused',L('RowView')),('errors',L('Refusal')),('ok','Bool')]),
 'RuntimeView':('observation.bend','RuntimeView',[('namespace','U32'),('statuses',L('ReaderStatus')),('world','WorldMeta'),('batches',L('EventBatch')),('positions',L('Position')),('nextReader','U32'),('tick','Nat'),('frameStart','Nat'),('boundary','Nat'),('capacity','Nat'),('droppedThrough','Nat'),('log','LogView')]),
 'WorldMeta':('fixture.bend','WorldMeta',[(k,t) for k,t in [('namespace','U32'),('nextId','U32'),('highWater','U32'),('capacity','U32'),('depth','Nat'),('events',L('U32')),('registrations',L('RegistrationMeta')),('nextSystemId','U32'),('clock','U32')]]),
 'ReaderView':('observation.bend','ReaderView',[(k,'String' if k=='name' else L('String') if k=='access' else 'U32') for k in ['namespace','id','registryId','registryNamespace','actualRegistryId','name','access','cursor']]),
 'LogView':('observation.bend','LogView',[('seen',L('U32')),('rows',L('RowView'))]),
 'RowView':('observation.bend','RowView',[('key','U32'),('payload','PayloadView')]),
 'PayloadView':('observation.bend','PayloadView',[('cells',L('U32')),('sentinel',L('U32'))]),
 'View':('fixture.bend','View',[('name','String'),('keys',L('U32')),('packets',L('PacketView')),('lagged','Bool'),('errors',L('Refusal'))]),
 'PacketView':('fixture.bend','PacketView',[('key','U32'),('cells',L('U32'))]),
 'Request':('fixture.bend','Request',[('name','String'),('fail','Bool')]),
 'DirectView':('direct-controls.bend','DirectView',[('log','LogView'),('value','MaybeValues'),('errors',L('Refusal')),('refused',L('RowView'))]),
 'ReaderStatus':(str(ROOT/'src/ecs/event-runtime.bend'),'ReaderStatus',[('id','U32'),('cursor','Nat'),('registeredAt','Nat'),('unread','Nat'),('lagged','Bool')]),
 'Position':(str(ROOT/'src/ecs/event-runtime.bend'),'Position',[('id','U32'),('cursor','Nat'),('registeredAt','Nat')]),
 'EventBatch':(str(ROOT/'src/ecs/event-runtime.bend'),'Batch',[('tick','Nat'),('values',L('U32'))]),
 'RegistrationMeta':(str(ROOT/'src/ecs/world.bend'),'RegistrationMeta',[('id','U32'),('name','String'),('access',L('String'))]),
}
sums={'Trace':{'Trace':('main',[('snapshots',L('Snapshot'))])},'Completion':{'ReadSucceeded':('fixture.bend',[('view','View')]),'ReadBodyFailed':('fixture.bend',[('error','ReadError')]),'ReadRejected':('fixture.bend',[('request','Request')])},'ReadError':{'ReadFailed':('fixture.bend',[('view','View')])},'Refusal':{k:('log.bend',[('key','U32')]) for k in ['DuplicateKey','MissingKey']},'MaybeValues':{'None':('Base',[]),'Some':('Base',L('U32'))}}
def named(file,ctor,args):
 prefix='' if file in ['main','Base'] else os.path.relpath((ENTRY.parent/file).resolve(),ENTRY.parent.resolve())[:-5]+'.'
 return prefix+ctor+'{'+', '.join(args)+'}'
def render(t,x):
 if isinstance(t,list):assert type(x)is list;return '['+', '.join(render(t[0],v) for v in x)+']'
 if t=='U32':assert type(x)is int and 0<=x<2**32;return str(x)
 if t=='Nat':assert set(x)=={'nat'} and type(x['nat'])is int and x['nat']>=0;return str(x['nat'])+'n'
 if t=='Bool':assert type(x)is bool;return 'True{}' if x else 'False{}'
 if t=='String':assert type(x)is str;return json.dumps(x)
 if t in records:
  f,c,fields=records[t];assert set(x)=={k for k,_ in fields};return named(f,c,[render(ft,x[k]) for k,ft in fields])
 assert t in sums and type(x)is dict and len(x)==1
 tag,value=next(iter(x.items()));f,fields=sums[t][tag]
 if fields==[]:assert value=={};args=[]
 elif isinstance(fields[0],tuple):assert set(value)=={k for k,_ in fields};args=[render(ft,value[k]) for k,ft in fields]
 else:args=[render(fields,value)]
 return named(f,tag,args)
if __name__=='__main__':(HERE/'expected.stdout').write_text(render('Batch',json.loads((HERE/'expected.json').read_text()))+'\n')
