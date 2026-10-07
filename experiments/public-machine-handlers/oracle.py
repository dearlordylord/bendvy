"""Prospective exact public world/stream oracle authored before executing TS fixture."""
import copy
PHASES=['exit','transition','enter']
class Model:
 def __init__(self,phase,position):
  self.phase=phase;self.position=position;self.frame=0;self.tick=0;self.start=0;self.boundary=0;self.entities={};self.nextid=1;self.owned=[3,13];self.machines={'Flow':{'current':'Boot'},'Level':{'current':0}};self.pending=[];self.local={};self.attempts=[];self.deliveries=[];self.records=[];self.cursor={};self.registered={k:[] for k in ['Ping','Flow','Level']};self.logs={k:[] for k in self.registered}
 def advance(self):self.tick+=1;return self.tick
 def frame_start(self):
  self.frame+=1
  if self.start>0:self.boundary=self.start
  self.start=self.tick
  for key,log in self.logs.items():
   boundary=min([self.boundary,*[self.cursor[n] for n in self.registered[key]]]);self.logs[key]=[(t,v) for t,v in log if t>boundary]
 def register(self,name):
  if name not in self.cursor:
   self.cursor[name]=0
   for names in self.registered.values():names.append(name)
 def delivered(self,name):
  self.register(name);values={k:[copy.deepcopy(v) for t,v in log if t>self.cursor[name]] for k,log in self.logs.items()}
  return {'name':name,'ping':values['Ping'],'flow':values['Flow'],'level':values['Level'],'lagged':[False,False,False]}
 def reserve(self,payload,name):
  ident=self.nextid;self.nextid+=1;return {'id':ident,'payload':payload,'system':name}
 def deferred(self):
  self.advance()
  for cmd in self.pending:self.entities[cmd['id']]=list(cmd['payload'])
  self.pending=[]
 def read(self,name,fails=False):
  row=self.delivered(name);this=self.advance();self.deliveries.append(row)
  if not fails:self.cursor[name]=this
  return {'ok':False,'error':{'kind':'SystemFailure','system':name,'error':'reader-failed'}} if fails else {'ok':True}
 def hook(self,name,index,machine,fails=False):
  row=self.delivered(name);this=self.advance();self.local[name]=self.local.get(name,0)+1;row.update(local=self.local[name],current=[self.machines['Flow']['current'],self.machines['Level']['current']],active=copy.deepcopy(self.active));self.attempts.append(row)
  cmd=self.reserve([100+index,1000+index,0],name)
  if fails:return {'ok':False,'error':{'kind':'SystemFailure','system':name,'error':'hook-failed:'+name}}
  for cell in self.entities.values():cell[2]+=1
  self.owned=[self.owned[0]+1,self.owned[1]+10];self.logs['Ping'].append((self.advance(),{'handler':name,'attempt':self.local[name]}));self.pending.append(cmd)
  if name=='enter0':self.machines['Flow']['pending']='Pause'
  self.cursor[name]=this;return {'ok':True}
 def marker(self,failing):
  self.deferred();scheduled=[(name,v['pending']) for name,v in self.machines.items() if 'pending' in v]
  for machine,to in scheduled:
   values=self.machines[machine];values.pop('pending',None);old=values['current'];values['previous']=old;self.active={'from':old,'to':to}
   if machine=='Flow' and old=='Boot' and to=='Play':
    for phase in ['exit','transition']:
     for pos in [0,1]:
      outcome=self.hook(phase+str(pos),PHASES.index(phase)*2+pos,machine,failing and self.phase==phase and self.position==pos)
      if not outcome['ok']:values['pending']=to;return outcome
   values['current']=to;self.logs[machine].append((self.advance(),copy.deepcopy(self.active)))
   names=[('enter'+str(i),4+i) for i in [0,1]] if machine=='Flow' and to=='Play' else [('level0',6)] if machine=='Level' and to==1 else []
   for name,index in names:
    outcome=self.hook(name,index,machine,failing and name==self.phase+str(self.position))
    if not outcome['ok']:return outcome
  return {'ok':True}
 def streams(self):
  result=[]
  for key in ['Ping','Flow','Level']:
   if not self.logs[key] and not self.registered[key]:continue
   readers=[{'system':n,'unread':sum(t>self.cursor[n] for t,_ in self.logs[key]),'lagged':False} for n in self.registered[key]];row={'kind':'event' if key=='Ping' else 'transitionEvent','stream':key,'size':len(self.logs[key]),'capacity':65536,'readers':readers}
   if self.logs[key]:
    holder=min(self.registered[key],key=lambda n:self.cursor[n]) if self.registered[key] else None
    if self.logs[key][0][0]<=self.boundary and holder is not None and self.cursor[holder]<self.logs[key][0][0]:row['heldBy']=holder
   result.append(row)
  return result
 def world(self,missing=False):
  return {'version':1,'frame':self.frame,'tick':self.tick,'entityCount':len(self.entities),'entities':[{'id':i,'components':{'Cells':copy.deepcopy(c)},'relations':{}} for i,c in self.entities.items()],'resources':{'Owned':self.owned[:]},'machines':copy.deepcopy(self.machines),'pendingCommands':[{'tag':'spawn','system':c['system']} for c in self.pending]}
 def point(self,label,result):self.records.append(copy.deepcopy({'label':label,'result':result,'world':self.world(),'streams':self.streams(),'hostLocal':self.local,'attempts':self.attempts,'deliveries':self.deliveries}))
 def run(self,schema):
  self.frame_start();self.advance();self.pending.append(self.reserve([1,10,0],'seed'));self.deferred();self.read('fast');self.read('slow');self.point('initial',{'ok':True})
  self.frame_start();self.advance();self.machines['Level']['pending']=1;self.machines['Flow']['pending']='Play';self.pending.append(self.reserve([90,900,0],'queue'));self.point('queued',{'ok':True})
  self.frame_start();self.point('handler-failure',self.marker(True))
  self.frame_start();self.point('reader-failure',self.read('flaky',True))
  self.frame_start();self.point('handler-retry',self.marker(False))
  self.frame_start();self.point('reader-retry',self.read('flaky'))
  self.frame_start();result=self.marker(False);self.read('fast');self.read('slow');self.point('later-marker',result)
  self.frame_start();self.read('fast');self.read('slow');self.point('repeat-readers',{'ok':True})
  empty={'version':1,'frame':0,'tick':0,'entityCount':0,'entities':[],'resources':{},'machines':{'Flow':{'current':'Boot'}},'pendingCommands':[]}
  return {'schema':schema,'phase':self.phase,'position':self.position,'requirements':[{'kind':'resource','name':'Owned'},{'kind':'stateMachine','name':'Flow'},{'kind':'stateMachine','name':'Level'}],'records':self.records,'missingRequirements':{'result':{'ok':False,'error':{'kind':'MissingRuntimeRequirements','requirements':[{'kind':'stateMachine','name':'Level'},{'kind':'resource','name':'Owned'}]}},'before':empty,'after':copy.deepcopy(empty)}}
def expected():return {'applications':[Model(phase,pos).run(schema) for schema in ['HandlersAlpha','HandlersBeta'] for phase in PHASES for pos in [0,1]]}
def compare(actual):
 want=expected();assert actual==want,{'expected':want,'actual':actual}
 return {'status':'COMPLETE_TWO_SCHEMA_SIX_FAILURE_POSITIONS_AND_RETRY_PASS','applications':12,'checkpoints':96,'missingRequirementRefusals':12,'scope':'Finite actual pinned TS public world/streams/host-local observations; not Bend affine/Local/API/proof/performance acceptance.'}
if __name__=='__main__':
 import json;print(json.dumps(expected(),indent=2))
