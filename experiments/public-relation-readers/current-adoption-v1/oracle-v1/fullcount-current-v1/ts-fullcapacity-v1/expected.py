"""Independent pinned TS public-observation model; no fixture execution/output."""
import copy,json,gzip,hashlib
from pathlib import Path
CAP=65536

def failure(relation,target):
 e={'_tag':'SelfRelationNotAllowed','entityId':1,'relation':relation} if target==1 else {'_tag':'MissingTargetEntity','entityId':1,'targetId':target,'relation':relation}
 return dict(operation='relate',relation=relation,source=1,target=target,error=e)

class Runtime:
 def __init__(self,resources):
  self.frame=self.tick=self.start=self.boundary=0;self.resources=resources;self.components={};self.pending=[];self.readers={};self.logs={};self.keys={};self.dropped={}
 def frame_begin(self):
  self.frame+=1
  if self.start>0:self.boundary=self.start
  self.start=self.tick
  for key,log in self.logs.items():
   cursors=[self.readers[n]['last'] for n in self.keys.get(key,[])];bound=min([self.boundary,*cursors]);gone=0
   while gone<len(log) and log[gone][0]<=bound:gone+=1
   if len(log)-gone>CAP:gone=len(log)-CAP
   if gone:self.dropped[key]=max(self.dropped.get(key,0),log[gone-1][0]);del log[:gone]
 def run(self,name,keys=(),enabled=True,failed=False):
  if not enabled:
   if name in self.readers:self.readers[name]['last']=self.tick
   return None
  if name not in self.readers:
   self.readers[name]={'last':0,'registered':self.tick}
   for key in keys:self.keys.setdefault(key,[]).append(name)
  old=self.readers[name]['last'];self.tick+=1
  views={key:dict(lagged=self.dropped.get(key,0)>max(old,self.readers[name]['registered']),values=[v for tick,v in self.logs.get(key,[]) if tick>old]) for key in keys}
  if not failed:self.readers[name]['last']=self.tick
  return views
 def flush(self):
  self.tick+=1
  for tag,origin,payload in self.pending:
   if tag=='spawn':self.components=payload
   elif tag=='insert':self.components.update(payload)
   elif tag=='remove':self.components.pop(payload,None)
   elif tag=='relate':key,target=payload;self.logs.setdefault(('relationFailure',key),[]).append((self.tick,failure(key,target)))
  self.pending=[]
 def world(self):return dict(version=1,frame=self.frame,tick=self.tick,entityCount=1,entities=[dict(id=1,components=copy.deepcopy(self.components),relations={})],resources=copy.deepcopy(self.resources),machines={},pendingCommands=[dict(tag=tag,system=origin) for tag,origin,_ in self.pending])
 def streams(self):
  out=[]
  for kind in ('event','transitionEvent','relationFailure'):
   keys=list(dict.fromkeys([k for k in self.logs if k[0]==kind]+[k for k in self.keys if k[0]==kind]))
   for key in keys:
    log=self.logs.get(key,[]);readers=[];holder=None
    for n in self.keys.get(key,[]):
     r=self.readers[n];readers.append(dict(system=n,unread=sum(t>r['last'] for t,_ in log),lagged=self.dropped.get(key,0)>max(r['last'],r['registered'])))
     if holder is None or r['last']<holder[1]:holder=(n,r['last'])
    row=dict(kind=kind,stream=key[1],size=len(log),capacity=CAP,readers=readers)
    if log and log[0][0]<=self.boundary and holder and holder[1]<log[0][0]:row['heldBy']=holder[0]
    out.append(row)
  return out
 def seed(self):self.frame_begin();self.run('seed');self.pending=[('spawn','seed',{'Left':[11,12],'Right':[21,22]})];self.flush()


def retry(root):
 r=Runtime({'Baseline':[301,302]});r.seed();deliveries=[];out=[];mail=[];owners={'fast':[101,102],'slow':[201,202]};key=('relationFailure','Parent')
 def read(name,label,failed=False):
  v=r.run(name,[key],failed=failed)[key];deliveries.append(dict(label=label,who=name,lagged=v['lagged'],failures=v['values']))
  if failed:mail.append(owners['slow'])
 def capture(label):out.append(dict(root=root,label=label,world=r.world(),streams=r.streams(),deliveries=list(deliveries),privateOwners=copy.deepcopy(owners),mailbox=copy.deepcopy(mail)))
 r.frame_begin();read('fast','register');read('slow','register');capture('register')
 r.frame_begin();r.run('queue');r.pending=[('relate','queue',('Parent',1)),('relate','queue',('Parent',99)),('relate','queue',('ParentB',1))]
 r.frame_begin();read('fast','before-barrier');read('slow','before-barrier');capture('before-barrier')
 r.frame_begin();r.flush();read('fast','published');capture('published')
 r.frame_begin();read('slow','failure',True);capture('failure')
 r.frame_begin();mail.pop();read('slow','retry');capture('retry')
 r.frame_begin();read('fast','fast-empty');capture('fast-empty')
 r.frame_begin();r.frame_begin();capture('aged');return out

def lifecycle(root):
 r=Runtime({'Baseline':[301,302]});r.seed();out=[];A=('relationFailure','Alpha');B=('relationFailure','Beta');deliveries=[]
 def read(name,enabled=True):
  ks=[A] if name=='only-alpha' else [B] if name=='only-beta' else [A,B];v=r.run(name,ks,enabled=enabled)
  if v is not None:deliveries.append({'reader':name,**{('alpha' if k==A else 'beta'):v[k] for k in ks}})
 def capture(label):
  nonlocal deliveries
  out.append(dict(root=root,label=label,world=r.world(),streams=r.streams(),deliveries=deliveries));deliveries=[]
 r.frame_begin();read('only-alpha');read('only-beta',False);capture('never-activated-beta')
 r.frame_begin();r.run('publish-two');r.pending=[('relate','publish-two',('Alpha',1)),('relate','publish-two',('Beta',1))];r.flush()
 r.frame_begin();read('only-beta',False);r.frame_begin();read('only-beta',False);capture('age-unheld-beta')
 for label,n in [('alpha-held','only-alpha'),('beta-first','only-beta'),('register-both','both')]:r.frame_begin();read(n);capture(label)
 r.frame_begin();r.run('publish-capacity');r.pending=[('relate','publish-capacity',('Alpha',1))]+[('relate','publish-capacity',('Beta',1000+i)) for i in range(65537)];capture('publication-queued')
 r.frame_begin();r.flush();capture('after-publication');r.frame_begin();capture('capacity-trim')
 for label,n in [('alpha-not-lagged','only-alpha'),('beta-exact-ordered','only-beta'),('shared-independent-lag','both')]:r.frame_begin();read(n);capture(label)
 r.frame_begin();r.run('publish-after-read');r.pending=[('relate','publish-after-read',('Beta',70000))];r.flush();read('only-beta',False);capture('activated-beta-skip')
 for label,n in [('beta-resume-empty','only-beta'),('shared-retains-skipped-beta','both')]:r.frame_begin();read(n);capture(label)
 r.frame_begin();read('only-alpha');read('only-beta');read('both');capture('consumed');return out

def mixed(root):
 r=Runtime({});r.frame_begin();r.run('seed');r.pending=[('spawn','seed',{})];r.flush();out=[];name='mixed-reader';stock=root+'/MixedStock';P=('relationFailure',root+'/MixedParent');E=('event',root+'/MixedPing')
 def read(label,rows,added,changed,events,removed,failures):
  r.frame_begin();r.run(name,[E,P]);snapshot=dict(rows=rows,added=added,changed=changed,events=events,eventLag=False,removed=removed,failures=failures,relationLag=False);out.append(dict(root=root,label=label,snapshots=[snapshot],world=r.world(),streams=r.streams()))
 read('activated',[],[],[],[],[],[])
 r.frame_begin();r.run('insert');r.pending=[('insert','insert',{stock:{'cells':[11,12,13,14]}})];r.flush()
 row=[{'id':1,'cells':[11,12,13,14]}];read('inserted',row,[1],[1],[],[],[]);read('repeat',row,[],[],[],[],[])
 r.frame_begin();r.run('publish');r.tick+=1;r.logs[E]=[(r.tick,31),(r.tick,32)];r.pending=[('relate','publish',(P[1],999)),('remove','publish',stock)];r.flush();read('published',[],[],[],[31,32],[1],[failure(P[1],999)]);return out

def expected():
 roots=('ReadersAlpha','ReadersBeta')
 return dict(scope='Source-current TS shared scenarios, not Bend physical-owner equality',retry=dict(developmentOnly=True,observations=sum([retry(x) for x in roots],[])),lifecycle=dict(developmentOnly=True,capacity=CAP,publications=65537,defaultCapacityOverflow=True,output=sum([lifecycle(x) for x in roots],[])),mixed=dict(developmentOnly=True,acceptance=False,completeIssue43=False,application='ActualMixedRegisteredReader',observations=sum([mixed(x) for x in roots],[])))
if __name__=='__main__':
 p=Path(__file__).with_name('expected.json.gz');value=expected()
 with gzip.open(p,'wt') as f:json.dump(value,f,separators=(',',':'));f.write('\n')
 print('whole TS expected generated',p)
