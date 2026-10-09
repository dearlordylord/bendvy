"""Whole source-derived deferred assembly observations, frozen 6c23d2df."""
import copy,json,types
from pathlib import Path
MODEL=Path(__file__).resolve().parent.parent/'generic-assembly-v1/expected.py'
G=types.ModuleType('independent_owned_model');G.__file__=str(MODEL)
exec(compile(MODEL.read_bytes(),str(MODEL),'exec'),G.__dict__)
t,some,none,raw,payload,packet=G.t,G.some,G.none,G.raw,G.payload,G.packet
def snapshot(world,namespace=1,pending=1,events=1,value=100,retired=None,returned=None,errors=None):
 v=world.snap();v['meta']['namespace']=namespace;v['meta']['events']=[t('Unit')for _ in range(events)]
 v.pop('resource');v['mail']=t('MailView',value=payload(value,True),retired=copy.deepcopy(retired or []),returned=copy.deepcopy(returned or []),errors=copy.deepcopy(errors or []));v['pending']=pending;return v
def incoming(n,invalid):
 v=payload(n)
 if invalid:v['raw']=t('Text',value='invalid-integer')
 return v
def refused(n,validation=False):
 error=t('Validation',error=t('Invalid',path='$',expected='integer',actual=t('Text',value='invalid-integer')))if validation else t('Entity',error=t('MissingEntity'))
 return t('RefusedView',owner=some(incoming(n,validation)),error=error)
def report(mode):
 w=G.World(False,'declared-deferred-owned');w.spawn(10);ns=2 if mode=='foreign'else 1;late=mode=='lateMissing';invalid=mode in ('invalid','failedInvalid');failed=mode in ('failure','failedInsert','failedInvalid');spawn=mode in ('spawn','failure')
 before=snapshot(w,ns,pending=2 if late else 1)
 outputs=[];recovered=[]
 if invalid:outputs=[refused(n,True)for n in (11,22)]
 elif mode=='foreign':outputs=[refused(n)for n in (11,22)]
 else:
  ids=[2,3]if spawn else [1,1]
  for n,i in zip((11,22),ids):outputs.append(t('AcceptedView',target=t('Handle',namespace=ns,id=i),spawned=spawn,canonical=raw(n)))
  if spawn:
   # Reserve now; activation and insertion are retained deferred commands.
   for _ in (11,22):i=w.reserve();w.live[i]=False
  if failed:recovered=[packet(n)for n in (11,22)]
 recoveries=[t('RecoveryView',outputs=outputs,packets=recovered)]if failed else []
 committed=snapshot(w,ns,pending=(2 if late else 1)+(0 if failed or invalid or mode=='foreign'else 4 if spawn else 2),value=100 if failed else 300)
 retired=[];returned=[];errors=[]
 if not failed and not invalid and mode!='foreign':
  if late:
   w.live[1]=False;returned=[packet(22),packet(11)];errors=[t('MissingEntity'),t('MissingEntity')]
  elif spawn:
   for i,n in ((2,11),(3,22)):w.live[i]=True;w.set(i,payload(n))
  else:
   for n in (11,22):old,_=w.set(1,payload(n));retired.insert(0,old['value'])
 barrier=snapshot(w,ns,pending=0,events=2,value=100 if failed else 300,retired=retired,returned=returned,errors=errors)
 instance=t('InstanceView',namespace=ns,id=1,name=w.name,access=w.access,codec=t('Integer'),recoveries=recoveries)
 return t('Report',before=before,committed=committed,barrier=barrier,instance=some(instance),result=t('Failed')if failed else t('Completed',outputs=outputs))
def expected():return t('Candidate',**{m:report(m)for m in ('spawn','insert','failure','foreign','lateMissing','invalid','failedInsert','failedInvalid')})
if __name__=='__main__':Path(__file__).with_name('expected.json').write_text(json.dumps(expected(),separators=(',',':'))+'\n')
