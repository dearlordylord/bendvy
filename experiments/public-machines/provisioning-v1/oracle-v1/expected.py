"""Independent prospective model of 5852c268; no checker/runtime output inputs."""
import copy,json
from pathlib import Path
BODY=['machine.Flow.read','machine.Flow.next','machine.Level.next','component.cells.write','resource.owned.write','commands.spawn']
READ=['transition.Flow.read','transition.Level.read']
def listing(items): return '['+', '.join(map(str,items))+']'
def boolean(value): return str(value).lower()
def slot(value):
 if value is None:return 'missing'
 return value['current']+'(pending='+('none' if value['pending'] is None else value['pending']+':false')+',previous=none,changed=false)'
def registry(i,name,access,cursor=0):return {'id':i,'name':name,'access':access,'cursor':cursor}
def registry_text(r):return f"1:{r['id']}:{r['name']}:{listing(r['access'])}:{r['cursor']}"
class Model:
 def __init__(self,flow_only=False):
  self.next=1;self.high=0;self.capacity=1;self.depth=0;self.live=[False];self.cells=['none'];self.stamps=[];self.clock=0;self.queue=0
  self.flow=None;self.level=None;self.frame=0;self.tick=0;self.positions=[];self.frame_start=0
  self.users=[];self.attempts=[];self.deliveries=[];self.conditions=[];self.active=[];self.rows=[]
  self.registrations=[]
  if flow_only:self.flow_registry=self.register('flow-only',['machine.Flow.read'])
  else:
   self.hooks=[self.register('flow-hook',['machine.Flow.next','machine.Level.next']),self.register('level-hook',['machine.Flow.next'])]
   self.reader=self.register('retained-reader',READ)
 def register(self,name,access):
  value=registry(len(self.registrations)+1,name,access)
  self.registrations.insert(0,value)
  return value
 def fields(self,flow_only=False):
  positions=listing(f'{i}:{cursor}:{registered}' for i,cursor,registered in self.positions)
  stream=f'batches=[],positions={positions},dropped=0,frameStart={self.frame_start}'
  fields={'ns':'1','next':str(self.next),'high':str(self.high),'capacity':str(self.capacity),'depth':str(self.depth),'live':listing(map(boolean,self.live)),
   'cells':listing(self.cells)+':stamps='+listing(self.stamps),'owned':'[30, 130]','flow':slot(self.flow),'level':slot(self.level),
   'flowStream':stream,'levelStream':stream,'frame':str(self.frame),'tick':str(self.tick),'hooks':'[]','queue':str(self.queue),
   'registrations':listing(f"{r['id']}:{r['name']}:{listing(r['access'])}" for r in self.registrations),'nextSystem':str(len(self.registrations)+1),'componentClock':str(self.clock),'busEvents':'0'}
  if flow_only:fields['flowRegistry']=registry_text(self.flow_registry)
  else:
   fields.update(users=listing(f"{key}:{registry_text(r)}" for key,r in self.users),hookOwners='|'.join(map(registry_text,self.hooks)),
    readerOwners=listing([f"12:{registry_text(self.reader)}:flow=1:3:level=1:3"]),attempts=listing(self.attempts),deliveries=listing(self.deliveries),conditions=listing(self.conditions),active=listing(self.active))
  return fields
 def snapshot(self,label,status='ok',flow_only=False):self.rows.append({'label':label,'status':status,'fields':copy.deepcopy(self.fields(flow_only))})
 def named(self,actions):
  self.frame+=1;self.frame_start=self.tick;self.active=actions
 def body(self,key,name,operation):
  old=next((r for k,r in self.users if k==key),None)
  if old is None:old=self.register(name,BODY)
  self.users=[(key,old)]+[(k,r) for k,r in self.users if k!=key]
  self.tick+=1
  if operation=='Seed':
   self.next=2;self.high=1;self.capacity=2;self.depth=1;self.live=[False,False];self.queue=1
  elif operation=='OldPending':self.flow['pending']='Boot'
  elif operation=='FailingPublisher':
   # Successful tx_set increments clock; exact inverse restores owner/stamp
   # without rewinding that clock. Failed spawn still reserves its ID.
   self.clock+=1;self.next=3;self.high=2;self.capacity=4;self.depth=2;self.live=[False,True,False,False]
   self.attempts.append('failed-publisher')
 def read(self,fails=False):
  if not self.positions:self.positions=[[3,0,self.tick]]
  self.tick+=1
  if not fails:self.positions[0][1]=self.tick
  self.deliveries.append('retained-reader:flow=[]:level=[]:lagged=false,false')
 def frame_read(self,label,mutant=False,fails=False):
  if not mutant and (self.flow is None or self.level is None):self.snapshot(label,'machine-provision-rejected');return
  self.named(['Read:12:retained-reader:'+boolean(fails)]);self.read(fails);self.snapshot(label,'failed:reader-failed' if fails else 'ok')
 def gate(self,label,key,name,tree,passes):
  self.named([f'Gate:{key}:{name}:{tree}'])
  if passes:self.body(key,name,'Noop');self.conditions.append(name)
  self.snapshot(label)
 def install(self,which):setattr(self,which,{'current':'Boot' if which=='flow' else '0','pending':None})
def scenario(mutant=False):
 m=Model();m.snapshot('missing-initial');m.frame_read('required-reader-missing',mutant)
 m.gate('missing-state-exists',22,'exists','FlowExists',False)
 m.gate('true-or-missing',20,'true-or','or(true,Flow=Boot)',True)
 m.gate('negated-missing',20,'not','not(Level=0)',True)
 m.install('flow');m.snapshot('flow-installed')
 m.gate('present-state-exists',22,'exists','FlowExists',True)
 m.frame_read('reader-level-missing',mutant)
 m.gate('flow-only-false-gate',20,'flow-only','Flow=Play',False)
 m.install('level');m.snapshot('level-installed');m.frame_read('reader-retry',mutant)
 m.named(['Body:1:seed:Seed','Deferred']);m.body(1,'seed','Seed')
 # Deferred activation doesn't tick component clock; populate_cells replace does.
 m.live[1]=True;m.queue=0;m.clock+=1;m.cells=['[10, 99]'];m.stamps=[f'1:{m.clock}:{m.clock}'];m.tick+=1;m.snapshot('seed')
 m.named(['Body:2:old:OldPending']);m.body(2,'old','OldPending');m.snapshot('old-pending')
 m.named(['Body:3:fails:FailingPublisher:planned']);m.body(3,'fails','FailingPublisher');m.snapshot('failed-publisher','failed:planned')
 m.frame_read('failed-reader',mutant,True);m.frame_read('failed-reader-retry',mutant)
 m.snapshot('private-occupied-control','occupied-incoming:Pause')
 assert len(m.rows)==17
 return m.rows
def flow_only():
 m=Model(True);m.snapshot('registered-missing',flow_only=True);m.snapshot('false-gate-missing','gate-skipped',True);m.snapshot('required-flow-missing','required-flow-missing',True)
 m.install('flow');m.snapshot('install',flow_only=True);m.flow_registry['cursor']=m.clock;m.snapshot('flow-only-level-absent','current:Boot',True)
 return m.rows
def expected(role='normal'):
 rows=flow_only() if role=='flow-only' else scenario(role=='mutant')
 return {schema:copy.deepcopy(rows) for schema in ['A','B']}
def render(model):
 return '\n'.join(part for schema,rows in model.items() for part in ['SCHEMA='+schema,*[r['label']+'|'+r['status']+'|'+ ';'.join(k+'='+v for k,v in r['fields'].items()) for r in rows]])+'\n'
if __name__=='__main__':
 here=Path(__file__).resolve().parent
 for role,prefix in [('normal','expected'),('mutant','mutant-expected'),('flow-only','flow-only-expected')]:
  model=expected(role);(here/(prefix+'.json')).write_text(json.dumps(model,indent=2)+'\n');(here/(prefix+'.stdout')).write_text(render(model))
