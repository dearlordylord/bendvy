"""Independent frozen-source model; no runtime output inputs."""
import copy,json
N=lambda x:{'nat':x}
def packet(key,base):return {'key':key,'payload':{'cells':list(range(base,base+4)),'sentinel':[base+100,base+101]}}
def trace(capacity,steps):
 tick=0;frameStart=0;boundary=0;dropped=0;batches=[];positions=[];seen=[];rows=[];retired=[];refused=[];errors=[];reads=[];ok=True;foreign=False;snapshots=[]
 def snapshot(label):
  status=[dict(p,unread=N(sum(len(b['values']) for b in batches if b['tick']>p['cursor'])),lagged=max(p['cursor'],p['registeredAt'])<dropped) for p in positions]
  positionsN=[{k:(N(v) if k!='id' else v) for k,v in p.items()} for p in positions]
  for p in status:p['cursor']=N(p['cursor']);p['registeredAt']=N(p['registeredAt'])
  world={'namespace':1,'nextId':1,'highWater':0,'capacity':1,'depth':N(0),'events':[k for b in batches for k in b['values']],'registrations':[{'id':2,'name':'slow','access':['event:read']},{'id':1,'name':'fast','access':['event:read']}],'nextSystemId':3,'clock':0}
  def reader(i):return {'namespace':999 if i==1 and foreign else 1,'id':i,'registryId':i,'registryNamespace':1,'actualRegistryId':i,'name':'fast' if i==1 else 'slow','access':['event:read'],'cursor':0}
  snapshots.append(copy.deepcopy({'label':label,'runtime':{'namespace':1,'statuses':status,'world':world,'batches':[{'tick':N(b['tick']),'values':b['values']} for b in batches],'positions':positionsN,'nextReader':3,'tick':N(tick),'frameStart':N(frameStart),'boundary':N(boundary),'capacity':N(capacity),'droppedThrough':N(dropped),'log':{'seen':seen,'rows':rows}},'fast':reader(1),'slow':reader(2),'reads':reads,'retired':retired,'refused':refused,'errors':errors,'ok':ok}))
 def read(i,fail=False):
  nonlocal tick,ok
  name='fast' if i==1 else 'slow'
  if foreign and i==1:reads.append({'ReadRejected':{'request':{'name':name,'fail':fail}}});ok=False;return
  p=next((p for p in positions if p['id']==i),None);cursor=0 if p is None else p['cursor'];registered=tick if p is None else p['registeredAt']
  keys=[k for b in batches if b['tick']>cursor for k in b['values']];lagged=max(cursor,registered)<dropped
  view={'name':name,'keys':keys,'packets':[{'key':k,'cells':next(r['payload']['cells'] for r in rows if r['key']==k)} for k in keys],'lagged':lagged,'errors':[]}
  tick+=1
  if p is None:p={'id':i,'cursor':0,'registeredAt':tick-1};positions.insert(0,p)
  if fail:reads.append({'ReadBodyFailed':{'error':{'ReadFailed':{'view':view}}}});ok=False
  else:p['cursor']=tick;reads.append({'ReadSucceeded':{'view':view}});ok=True
 def publish(items):
  nonlocal tick,ok
  tick+=1;accepted=[];errs=[]
  for k,base in items:
   r=packet(k,base)
   if k in seen:refused.append(r);errs.append({'DuplicateKey':{'key':k}})
   else:seen.append(k);rows.append(r);accepted.append(k)
  if accepted:batches.append({'tick':tick,'values':accepted})
  errors.extend(errs);ok=not errs
 snapshot('registered')
 for label,action in steps:
  if action=='activate':read(1);read(2)
  elif action=='first':publish([(1,11),(2,21)])
  elif action=='next':publish([(3,31)])
  elif action=='fast':read(1)
  elif action=='slowfail':read(2,True)
  elif action=='slow':read(2)
  elif action=='skip':
   for p in positions:
    if p['id']==1:p['cursor']=tick
  elif action=='duplicate':publish([(1,91)])
  elif action=='foreign':foreign=True;read(1)
  elif action=='frame':
   boundary,frameStart=frameStart,tick;hold=min([boundary]+[p['cursor'] for p in positions])
   while batches and batches[0]['tick']<=hold:dropped=max(dropped,batches.pop(0)['tick'])
   while batches and sum(len(b['values']) for b in batches)>capacity:dropped=max(dropped,batches.pop(0)['tick'])
   retainedKeys=[k for b in batches for k in b['values']];retired.extend([r for r in rows if r['key'] not in retainedKeys]);rows[:]=[r for r in rows if r['key'] in retainedKeys]
  else:raise ValueError(action)
  snapshot(label)
 return {'Trace':{'snapshots':snapshots}}
STANDARD=[('skip-inactive','skip'),('activate','activate'),('publish-first','first'),('fast','fast'),('slow-failed','slowfail'),('slow-retry','slow'),('fast-repeat','fast'),('publish-next','next'),('skip-fast','skip'),('fast-after-skip','fast'),('slow-next','slow'),('duplicate-publication','duplicate'),('window-first','frame'),('window-second','frame'),('foreign-reader','foreign')]
CAPACITY=[('activate','activate'),('publish-first','first'),('publish-next','next'),('whole-batch-capacity','frame'),('fast-lagged','fast'),('slow-lagged-failure','slowfail'),('slow-lagged-retry','slow')]
def direct(rows,seen,value,error=None,refused=None):return {'log':{'seen':seen,'rows':rows},'value':{'None':{}} if value is None else {'Some':value},'errors':[] if error is None else [error],'refused':refused or []}
def expected():
 normal=[packet(1,11),packet(2,21)]
 return {'standard':trace(8,STANDARD),'capacity':trace(2,CAPACITY),'missing':direct(copy.deepcopy(normal),[1,2],None,{'MissingKey':{'key':99}}),'duplicateRows':direct([packet(1,11),packet(1,21)],[1],None,{'DuplicateKey':{'key':1}}),'duplicatePublication':direct(copy.deepcopy(normal),[1,2],None,{'DuplicateKey':{'key':1}},[packet(1,91)]),'ownedOutput':direct(copy.deepcopy(normal),[1,2],[13])}
if __name__=='__main__':print(json.dumps(expected(),indent=2))
