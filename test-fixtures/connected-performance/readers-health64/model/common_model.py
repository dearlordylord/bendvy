"""Additive actual-state observer over the source-bound indexed Readers model."""
import json,copy
import operation_model as O
compact=lambda v:json.dumps(v,separators=(',',':'),ensure_ascii=False)
def tuple_records(records):
 def nat(n):return list(map(ord,str(n)))+[0]
 cells=nat(len(records))
 for r in records:
  s=compact(r);cells+=nat(len(s))+list(map(ord,s))
 return cells
def fold(cells):
 v=0
 for x in cells:v=(v*33+x)&0xffffffff
 return v
def ledger(v):return {'totals':list(v),'epoch':4}
def row(v,actor):
 h,m,a,f=v
 return {'actor':actor(h),'main':{'kind':'Found','value':{'levels':list(m),'reserve':m.reserve,'class':m.classification}},'aux':{'kind':'Absent'}if a is None else {'kind':'Found','value':{'layers':list(a),'grade':a.grade}},'flag':{'kind':'Absent'}if f is None else {'kind':'Found','value':{'group':f}}}
class Observer(O.Program):
 def __init__(self,*a,**kw):
  super().__init__(*a,**kw);self.method_records=[];self.actor_keys=[];self.method_reads=[];self.method_stages=[]
 def actor(self,h):
  assert h in self.actor_keys,('unknown actual reservation',h)
  return self.actor_keys.index(h)+1
 def mutation(self,index):
  super().mutation(index)
  if index==0:
   h=self.frame.transient;assert h not in self.actor_keys;self.actor_keys.append(h)
 def prime(self):
  self.actor_keys=list(self.world.main_handles());assert len(self.actor_keys)==self.frame.count
  self.method_records.append({'kind':'SeedActors','actors':[self.actor(h)for h in self.actor_keys]});super().prime()
 def read(self,provider):
  super().read(provider);a=self.audit[-1]
  def event(name):
   values,lagged=a['events'][name]
   result={'values':[{'code':v}if name=='ping'else {'actor':self.actor(v)}for kind,v in values]}
   if name=='ping':result['lagged']=lagged
   return result
  # Qualified finite model records successful ReadDone only after its complete
  # actual read/advance path. No fabricated private TS cursor is introduced.
  status=0
  r={'kind':'Read','who':a['who'],'phase':['Prime','Read','Drain'][a['phase']],'iteration':a['iteration']if a['phase']==1 else None,'rows':[row(v,self.actor)for v in a['rows']],'added':[row(v,self.actor)for v in a['added']],'changed':[row(v,self.actor)for v in a['changed']],'ping':event('ping'),'removed':event('removed'),'despawned':event('despawned'),'status':{'kind':['Success','Failed','Refused','Skipped'][status]}}
  self.method_records.append(r);self.method_reads.append(r)
 def schedule(self,name,ids,barrier=False):
  super().schedule(name,ids,barrier)
  # schedule reaches its Complete log only after each actual mutation/read and
  # authored barrier succeeds; all operation preconditions assert in the model.
  status=0
  r={'kind':'Stage','stage':name,'iteration':None if name in ['Prime','Drain']else self.frame.iteration,'outcome':{'kind':['Success','BodyFailed','Refused','Invalid'][status]}}
  self.method_records.append(r);self.method_stages.append(r)
 def completed(self):
  self.method_records.append({'kind':'Final','rows':[row(v,self.actor)for v in self.world.rows()],'ledger':ledger(self.world.ledger),'status':{'kind':'Complete'}})
  assert len(self.method_records)==280 and len(self.method_reads)==84 and len(self.method_stages)==194
  assert self.actor_keys==[h for _,h in self.actor_map]
  return self.method_records
 def actor_map_raw(self):return [{'actor':i+1,'namespace':h.namespace,'index':h.key.index,'generation':h.key.generation}for i,h in enumerate(self.actor_keys)]
