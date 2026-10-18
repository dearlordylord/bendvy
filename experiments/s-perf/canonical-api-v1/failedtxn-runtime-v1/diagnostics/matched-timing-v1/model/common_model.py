"""Detached observer extension of the byte-identical independent operation model.
No production/subject module or output is loaded. JSON key order is wire order.
"""
import copy,json,types
import operation_model as M
compact=lambda x:json.dumps(x,separators=(',',':'),ensure_ascii=False)

def access(text):
 if text=='Missing':return {'kind':'Missing'}
 if text=='Absent':return {'kind':'Absent'}
 assert text.startswith('Found{')and text.endswith('}')
 return {'kind':'Found','value':json.loads(text[6:-1])}
def natural(n):
 assert isinstance(n,int)and n>=0
 return [*map(ord,str(n)),0]
def tuple_records(records):
 # Scalar counts, not UTF8 byte counts. JSON is deterministic and all scalars retained.
 out=natural(len(records))
 for record in records:
  text=compact(record);out+=natural(len(text))+list(map(ord,text))
 return out

class Observer(M.Model):
 def __init__(self,*args,**kwargs):
  super().__init__(*args,**kwargs)
  self.raw_actor_keys=list(self.world.allocator.order)
  assert len(set(self.raw_actor_keys))==len(self.raw_actor_keys)
  self.records=[{'kind':'SeedActors','actors':[self.actor(k)for k in self.raw_actor_keys]}]
  self.callback_records=[];self.publication_records=[];self.boundary_records=[];self.phase_records=[]
  old=self.meta.events_since
  def observed(meta,ident):
   values=old(ident)
   if ident==2:
    phase='Prime'if self.frame.phase==0 else 'AfterFailure'if self.frame.phase==2 else 'AfterRetry'
    r={'kind':'Publications','mode':phase,'iteration':None if phase=='Prime'else self.frame.iteration,'status':0,'messages':[{'code':n}for n in values],'lagged':False}
    self.records.append(r);self.publication_records.append(copy.deepcopy(r))
   return values
  self.meta.events_since=types.MethodType(observed,self.meta)
 def actor(self,key):
  assert key in self.raw_actor_keys,('unmapped',key)
  return self.raw_actor_keys.index(key)+1
 def reserve_tx(self,payload):
  result=super().reserve_tx(payload);key=result[0];assert key not in self.raw_actor_keys,('duplicate',key);self.raw_actor_keys.append(key);return result
 def callback_text(self,**kw):
  prime=kw.get('prime',False);key=kw['key'];who=kw['who'];success=kw['outcome_success']
  r={'kind':'Callback','who':who,'mode':'Prime'if prime else 'Fail'if not success else 'Commit'if who=='A'else 'Retry','iteration':None if prime else kw['iteration'],'capture':kw['capture'],'readerStatus':None if who=='A'else 0 if success else 1,'readerError':None if who=='A'or success else 7,'reading':None if who=='A'else {'messages':[{'code':n}for n in kw['reading']],'lagged':False},'outcome':{'kind':'Success'}if success else {'kind':'Failure','code':7},'reservation':None if key is None else {'kind':'Reserved','actor':self.actor(key)},'payload':None if kw['payload']is None else json.loads(M.json_pos(kw['payload'])),'writes':[access(x)for x in kw['writes']],'ledger':None if prime else json.loads(M.json_ledger(kw['ledger'])),'rejected':None,'error':None,'pendingLookup':None if prime else {'kind':'Missing'}}
  self.records.append(r);self.callback_records.append(copy.deepcopy(r))
  return super().callback_text(**kw)
 def rows(self):
  out=[]
  for key in self.world.allocator.visible():
   i=key[0]-1
   if i>=len(self.world.main.values)or self.world.main.values[i]is None:continue
   main=self.world.main.values[i];aux=self.world.aux.values[i]if i<len(self.world.aux.values)else None;flag=self.world.flag.values[i]if i<len(self.world.flag.values)else None
   out.append({'actor':self.actor(key),'main':access(M.access_json('main',main)),'aux':access(M.access_json('aux',aux)),'flag':access(M.access_json('flag',flag))})
  return out
 def lookup(self,key):return None if key is None else {'actor':self.actor(key),'result':access(M.get_position(self.world,key)[0])}
 def append_boundary(self,phase_name):
  f=self.frame;r={'kind':'Boundary','iteration':f.iteration,'phase':phase_name,'rows':self.rows(),'ledger':json.loads(M.json_ledger(self.world.ledger)),'pendingA':self.lookup(f.pending_a),'latestFailed':self.lookup(f.failed[-1])if f.failed else None,'retryB':self.lookup(f.retry_b),'allFailed':[self.lookup(k)for k in f.failed],'captures':{'A':self.a_capture,'B':self.b_capture}}
  self.records.append(r);self.boundary_records.append(copy.deepcopy(r));super().append_boundary(phase_name)
 def schedule(self,phase,steps,req,obs,failed=False):
  r={'kind':'Phase','phase':phase,'iteration':None if phase==0 else self.frame.iteration,'outcome':{'kind':'Failure'}if failed else {'kind':'Success'}}
  self.records.append(r);self.phase_records.append(copy.deepcopy(r));super().schedule(phase,steps,req,obs,failed)
 def completed(self):
  self.records.append({'kind':'Final','rows':self.rows(),'ledger':json.loads(M.json_ledger(self.world.ledger)),'captures':{'A':self.a_capture,'B':self.b_capture},'effects':list(reversed(self.world.audit)),'status':{'kind':'Complete'}})
  return self.records
 def raw_map(self):return [{'actor':i+1,'namespace':self.world.ns,'index':k[0],'generation':k[1]}for i,k in enumerate(self.raw_actor_keys)]
