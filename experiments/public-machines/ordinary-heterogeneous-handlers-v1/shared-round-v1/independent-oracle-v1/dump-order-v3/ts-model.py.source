"""Independent finite TS public Runtime model, including semantic debug traces."""
import copy
import json

class Model:
 def __init__(self):
  self.frame=0;self.tick=0;self.start=0;self.boundary=0;self.schedule=0;self.path=[]
  self.cells=None;self.owned=[11,12];self.trace=[];self.pending=[];self.local=[0]*6;self.attempts=[]
  self.machine={'First':{'current':'Cold'},'Second':{'current':0}}
  self.logs={};self.readers={};self.cursor={};self.registered={};self.records=[];self.traces=[];self.delivered=[[],[]]
 def advance(self):self.tick+=1;return self.tick
 def emit(self,typ,**kw):self.traces.append(dict(type=typ,frame=self.frame,**kw))
 def label(self):return ' > '.join(self.path)
 def begin(self):
  self.frame+=1
  if self.start>0:self.boundary=self.start
  self.start=self.tick
  self.emit('frame',tick=self.tick)
  for key,log in self.logs.items():
   boundary=min([self.boundary,*[self.cursor[n] for n in self.readers.get(key,[])]])
   self.logs[key]=[(t,v) for t,v in log if t>boundary]
  self.schedule+=1;self.path=[f'schedule#{self.schedule}'];self.emit('schedule.start',schedule=self.label())
 def end(self,result):self.emit('schedule.end',schedule=self.label(),ok=result['ok']);self.path=[];return result
 def register(self,name,key=None):
  if name not in self.cursor:self.cursor[name]=0;self.registered[name]=self.tick
  if key is not None and name not in self.readers.setdefault(key,[]):self.readers[key].append(name)
 def system_trace(self,name,tick,resources=None,events=None,nextstates=None,commands=None,error=None):
  kw=dict(tick=tick,schedule=self.label(),system=name,outcome='ok' if error is None else 'failed')
  if error is not None:kw['error']=error
  kw.update(writes=[],resources=resources or [],events=events or [],nextStates=nextstates or [],commands=commands or [],missed=[])
  self.emit('system',**kw)
 def append(self,key,value):self.logs.setdefault(key,[]).append((self.advance(),copy.deepcopy(value)))
 def defer(self,marker):
  self.advance();applied=[]
  for name,value in self.pending:
   if name=='seed':
    self.cells=[31,32];effects=[dict(kind='spawn',entity=1,components=dict(Cells=[31,32],Sibling=[41,42]))]
   else:
    before=self.cells;self.cells=[value,32]
    effects=[dict(kind='overwrite',entity=1,component='Cells',before=before,after=self.cells)]
   applied.append(dict(tag='spawn' if name=='seed' else 'insert',system=name,effects=effects))
  self.pending=[]
  if applied:self.emit('deferred',tick=self.tick,schedule=self.label(),marker=marker,commands=applied)
 def setup(self):
  self.begin();self.register('seed');t=self.advance();self.pending.append(('seed',None));self.system_trace('seed',t,commands=['spawn']);self.cursor['seed']=t
  self.defer('applyDeferred');self.register('initial-pending');t=self.advance();self.pending.append(('initial-pending',0));self.system_trace('initial-pending',t,commands=['insert']);self.cursor['initial-pending']=t;self.end({'ok':True})
 def queue(self):
  self.begin();self.register('queue');t=self.advance();self.machine['First']['pending']='Warm';self.machine['Second']['pending']=7
  self.system_trace('queue',t,nextstates=[dict(machine='First',value='Warm'),dict(machine='Second',value=7)]);self.cursor['queue']=t;return self.end({'ok':True})
 def hook(self,machine,phase):
  mi=0 if machine=='First' else 1;index=mi*3+phase-1;name=machine.lower()+'-'+['exit','transition','enter'][phase-1]
  state=self.machine[machine];old=state['previous'];to='Warm' if machine=='First' else 7
  slabel=[f'onExit({machine}={old})',f'onTransition({machine}: {old}->{to})',f'onEnter({machine}={to})'][phase-1]
  self.path.append(slabel);self.emit('schedule.start',schedule=self.label());self.register(name);t=self.advance()
  self.local[index]+=1;self.attempts.append(dict(machine=mi+1,phase=phase,attempt=self.local[index]))
  oldowned=self.owned[:];oldtrace=self.trace[:];amount=(mi+1)*10+phase;newowned=[oldowned[0]+amount,12];newtrace=oldtrace+[f'{mi+1}:{phase}']
  fail=index==1 and self.local[index]==1;err='transition-first-attempt' if fail else None
  nextstates=[]
  if index==2:self.machine['First']['pending']='Settled';nextstates=[dict(machine='First',value='Settled')]
  self.system_trace(name,t,resources=[dict(resource='Owned',before=oldowned,after=newowned),dict(resource='Trace',before=oldtrace,after=newtrace)],events=[dict(event='Pulse',values=[dict(machine=mi+1,phase=phase)])],nextstates=nextstates,commands=['insert'],error=err)
  if not fail:
   self.owned=newowned;self.trace=newtrace;self.append('Pulse',dict(machine=mi+1,phase=phase));self.pending.append((name,amount));self.cursor[name]=t
  self.emit('schedule.end',schedule=self.label(),ok=not fail);self.path.pop()
  return {'ok':False,'error':dict(kind='SystemFailure',system=name,error=err)} if fail else {'ok':True}
 def round(self):
  self.begin();self.defer('applyStateTransitions');scheduled=[(k,v['pending']) for k,v in self.machine.items() if 'pending' in v]
  for key,to in scheduled:
   st=self.machine[key];st.pop('pending',None);old=st['current'];st['previous']=old;snapshot=dict(from_=old,to=to);value={'from':old,'to':to}
   initial=(key=='First' and old=='Cold' and to=='Warm') or (key=='Second' and old==0 and to==7)
   if initial:
    for phase in [1,2]:
     result=self.hook(key,phase)
     if not result['ok']:
      st['pending']=to;self.emit('transition',tick=self.tick,schedule=self.label(),machine=key,**value,outcome='failed');return self.end(result)
   st['current']=to;self.append(key,value);self.emit('transition',tick=self.tick,schedule=self.label(),machine=key,**value,outcome='applied')
   if initial:
    result=self.hook(key,3)
    if not result['ok']:return self.end(result)
  return self.end({'ok':True})
 def read(self,index):
  self.begin();key=['First','Second'][index];name=key.lower()+'-reader';self.register(name,key);prior=self.cursor[name];t=self.advance()
  self.delivered[index].extend(copy.deepcopy(v) for stamp,v in self.logs.get(key,[]) if stamp>prior)
  self.system_trace(name,t);self.cursor[name]=t;return self.end({'ok':True})
 def barrier(self):self.begin();self.defer('applyDeferred');return self.end({'ok':True})
 def world(self):
  return dict(version=1,frame=self.frame,tick=self.tick,entityCount=1,entities=[dict(id=1,components=dict(Cells=self.cells,Sibling=[41,42]),relations={})],resources=dict(Owned=self.owned,SiblingOwner=[21,22],Trace=self.trace),machines={key:{field:state[field] for field in ['current','pending','previous'] if field in state} for key,state in self.machine.items()},pendingCommands=[dict(tag='insert',system=n) for n,v in self.pending])
 def streams(self):
  out=[]
  for key in ['Pulse','First','Second']:
   if key not in self.logs and key not in self.readers:continue
   log=self.logs.get(key,[]);names=self.readers.get(key,[]);row=dict(kind='event' if key=='Pulse' else 'transitionEvent',stream=key,size=len(log),capacity=65536,readers=[dict(system=n,unread=sum(t>self.cursor[n] for t,v in log),lagged=False) for n in names])
   if log and names:
    holder=min(names,key=lambda n:self.cursor[n])
    if log[0][0]<=self.boundary and self.cursor[holder]<log[0][0]:row['heldBy']=holder
   out.append(row)
  return out
 def point(self,label,result=None):self.records.append(copy.deepcopy(dict(label=label,result=result,world=self.world(),streams=self.streams(),local=self.local,attempts=self.attempts,firstDelivered=self.delivered[0],secondDelivered=self.delivered[1],traces=self.traces)))
 def run(self):
  self.setup();self.point('before');self.point('queued',self.queue());self.point('round-failure',self.round());self.point('first-reader-before-retry',self.read(0));self.point('round-retry',self.round());self.point('second-reader',self.read(1));self.point('first-reader',self.read(0));self.point('later-round',self.round());self.point('final-first-reader',self.read(0));self.point('final-second-reader',self.read(1));self.point('final-barrier',self.barrier())
  applied=sum(c['tag']=='insert' for e in self.traces if e['type']=='deferred' for c in e['commands'])
  pulse=[v for e in self.traces if e['type']=='system' and e['outcome']=='ok' for em in e['events'] if em['event']=='Pulse' for v in em['values']]
  ledger=dict(component=self.cells,siblingComponent=[41,42],owned=self.owned,siblingOwner=[21,22],locals=self.local,committedCallbacks=self.trace,appliedReplacements=applied,firstDelivered=self.delivered[0],secondDelivered=self.delivered[1],pulse=pulse,pendingCommands=len(self.pending))
  return dict(records=self.records,ledger=ledger)
def expected():return (json.dumps(Model().run(),separators=(',',':'),ensure_ascii=False)+'\n').encode()
