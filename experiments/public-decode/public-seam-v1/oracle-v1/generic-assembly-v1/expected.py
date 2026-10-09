"""Independent complete model from frozen 72f02c22; no runtime observations."""
import copy,json
from pathlib import Path
def t(kind,**fields):return {'$':kind,**fields}
def some(v):return t('Some',value=copy.deepcopy(v))
def none():return t('None')
def raw(n):return t('Number',value=n)
def payload(n,first=False):
 return t('PayloadView',raw=raw(n),**({'sentinel':[n,n+1]} if first else {'words':[n,n+10],'flags':[True,False]}))
def entry(i,a,c):return t('Entry',id=i,stamp=t('Stamp',added=a,changed=c))
def packet(n,first=False):return t('PacketView',owner=some(payload(n,first)),original=raw(n),canonical=raw(n))
class World:
 def __init__(self,first=False,name='declared-owned-system'):
  self.first=first;self.next=1;self.high=0;self.cap=1;self.clock=0;self.live=[False];self.slots=[none()];self.stamps=[];self.resource=payload(100,not first)
  self.access=['first-owner' if first else 'second-owner','decoded-resource'];self.name=name
 def snap(self):
  return t('Snapshot',meta=t('Meta',namespace=1,nextId=self.next,highWater=self.high,capacity=self.cap,depth=self.cap.bit_length()-1,events=[],registrations=[t('RegistrationMeta',id=1,name=self.name,access=self.access)],nextSystemId=2,clock=self.clock),live=copy.deepcopy(self.live),column=t('ColumnView',supported=True,slots=copy.deepcopy(self.slots),stamps=copy.deepcopy(self.stamps)),resource=copy.deepcopy(self.resource),pending=0)
 def reserve(self):
  i=self.next
  if i>=self.cap:self.cap*=2;self.live.extend([False]*(self.cap-len(self.live)))
  self.next+=1;self.high=i;self.live[i]=True;return i
 def stamp(self,i):return copy.deepcopy(next((x['stamp']for x in self.stamps if x['id']==i),t('Stamp',added=0,changed=0)))
 def mark(self,i,stamp):self.stamps=[t('Entry',id=i,stamp=stamp)]+[x for x in self.stamps if x['id']!=i]
 def set(self,i,value,advance=True):
  while len(self.slots)<i:self.slots.extend(none()for _ in range(len(self.slots)))
  old=copy.deepcopy(self.slots[i-1]);stamp=self.stamp(i)
  if advance:self.clock+=1
  tick=self.clock if advance else 0
  self.slots[i-1]=some(value) if value is not None else none()
  self.mark(i,t('Stamp',added=(stamp['added']if old['$']=='Some' else tick)if value is not None else 0,changed=tick if value is not None else 0))
  return old,stamp
 def undo(self,i,old,stamp):
  self.set(i,old.get('value'),False);self.mark(i,stamp)
 def spawn(self,n):
  i=self.reserve();old,stamp=self.set(i,payload(n,self.first));return i,old,stamp

def args(first=False,incoming=False,fail=False,operations=None,writes=None):
 return t('ArgsView',incoming=some(t('IncomingView',first=payload(11,first),second=payload(22,first)))if incoming else none(),operations=copy.deepcopy(operations or []),writes=copy.deepcopy(writes or []),fail=fail)
def instance(w,recovery):return t('InstanceView',namespace=1,id=1,name=w.name,access=w.access,state=t('StateView',codec=t('Integer'),recovery=copy.deepcopy(recovery)))
def public(first,mode):
 w=World(first);seed=mode in ('success','failure')
 if seed:w.spawn(10)
 before=w.snap();recovery=[]
 if mode=='skip':result=t('SkippedView',args=args(first,True))
 elif mode=='noMatch':result=t('CompletedView',args=args(first,True),rows=[])
 else:
  original=copy.deepcopy(w.resource);w.resource=payload(200,not first)
  i,old,stamp=w.spawn(11);writeold,writestamp=w.set(i,payload(99,first));j,jold,jstamp=w.spawn(22);w.resource=payload(300,not first)
  operations=[t('AcceptedView',target=t('Handle',namespace=1,id=j),spawned=True,canonical=raw(22)),t('AcceptedView',target=t('Handle',namespace=1,id=i),spawned=True,canonical=raw(11))]
  av=args(first,False,mode=='failure',operations,[t('WrittenView')])
  if mode=='success':result=t('CompletedView',args=av,rows=[t('Found',value=raw(10))])
  else:
   w.undo(j,jold,jstamp);w.live[j]=False;w.undo(i,writeold,writestamp);w.undo(i,old,stamp);w.live[i]=False;w.resource=original
   recovery=[t('RecoveryView',args=av,owners=[packet(22,first),packet(11,first)],pending=[])]
   result=t('FailedView',error=t('UserError',error=t('Unit')))
 return t('Report',before=before,after=w.snap(),instance=instance(w,recovery),result=result)

def recovery(mode):
 w=World(False,'immediate-recovery');before=w.snap();owners=[];pending=[];errors=[];w.resource=payload(200,True)
 if mode=='reserveRefused':
  w.next=131073;before=w.snap();before['resource']=payload(100,True);errors=[t('CapacityExceeded')];owners=[packet(11)]
 elif mode=='activationRefused':errors=[t('MissingEntity')];owners=[packet(11)]
 elif mode=='installRefused':i=w.reserve();w.live[i]=False;errors=[t('MissingEntity')];owners=[packet(11)]
 else:
  i,old,stamp=w.spawn(11)
  if mode!='equalPosition':writeold,writestamp=w.set(i,payload(99))
  j,jold,jstamp=w.spawn(22);w.resource=payload(300,True)
  if mode=='pending':w.live[j]=False
 during=w.snap()
 if mode!='success':
  if mode not in ('reserveRefused','activationRefused','installRefused'):
   if mode=='pending':pending=[t('PendingView',target=t('Handle',namespace=1,id=j),owner=jold,stamp=jstamp,error=t('MissingEntity'))]
   else:w.undo(j,jold,jstamp);w.live[j]=False;owners.append(packet(22))
   if mode!='equalPosition':w.undo(i,writeold,writestamp)
   w.undo(i,old,stamp);w.live[i]=False;owners.append(packet(11))
  w.resource=payload(100,True)
 return t('Report',before=before,after=w.snap(),local=t('StateView',owners=owners,pending=pending,during=some(during),errors=errors),result=t('Done',value=t('Unit'))if mode=='success'else t('Fail',error=t('Unit')))
def expected():
 return t('Candidate',second=t('Candidate',**{m:public(False,m)for m in ('success','failure','noMatch','skip')}),first=t('Candidate',**{m:public(True,m)for m in ('success','failure','noMatch','skip')}),recovery=t('Candidate',**{m:recovery(m)for m in ('interleaved','equalPosition','pending','success','reserveRefused','installRefused','activationRefused')}))
if __name__=='__main__':
 Path(__file__).with_name('expected.json').write_text(json.dumps(expected(),separators=(',',':'))+'\n')
