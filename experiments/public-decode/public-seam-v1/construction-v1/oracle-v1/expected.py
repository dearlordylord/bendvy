"""Independent source-derived complete construction DTO models; no runtime input."""
import copy,json
from pathlib import Path

def c(tag,**fields):return {'$':tag,**fields}
def number(n):return c('Number',value=n)
def text(s):return c('Text',value=s)
def obj(fields):return c('Object',fields=[c('Field',name=k,value=v) for k,v in fields])
def array(values):return c('Array',items=values)
UNIT=c('Unit');NONE=c('None')
def some(v):return c('Some',value=v)
CANON=obj([('items',array([number(7),c('Null')]))])
VALID=obj([('items',array([number(7),c('Null')])),('extra',text('discarded'))])
INVALID=obj([('items',array([number(7),text('wrong')]))])
def incoming(raw):return c('InputView',raw=copy.deepcopy(raw),words=[71,72],flags=[True,False])
def owner(raw,original=None,constructed=False):return c('View',raw=copy.deepcopy(raw),original=copy.deepcopy(raw if original is None else original),words=[71,72] if constructed else [81,82],flags=[True,False] if constructed else [False,True])
def invalid(raw,path='$',expected='integer'):return c('Invalid',path=path,expected=expected,actual=copy.deepcopy(raw))
NESTED_ERROR=invalid(text('wrong'),'$.items[1]','literal')
def meta(nextId=1,highWater=0,capacity=1,depth=0,clock=0,registrations=None,nextSystemId=1):return c('Meta',namespace=1,nextId=nextId,highWater=highWater,capacity=capacity,depth=depth,events=[],registrations=registrations or [],nextSystemId=nextSystemId,clock=clock)
def snapshot(resource=None,nextId=1,highWater=0,capacity=1,depth=0,live=None,clock=0,pending=0):return c('Snapshot',meta=meta(nextId,highWater,capacity,depth,clock),live=[False] if live is None else live,store=UNIT,resource=owner(number(100)) if resource is None else resource,pending=pending)
def construction(raw,canonical=None,error=None):
 if error is not None:return c('Rejected',input=incoming(raw),error=error)
 return c('Constructed',owner=owner(raw if canonical is None else canonical,raw,True),recovered=incoming(raw))
def resource(raw,refused=False,abort=False):
 before=snapshot();result=c('Refused',owner=owner(raw),error=NESTED_ERROR) if refused else c('Replaced',canonical=raw)
 return c('ResourceReport',before=before,after=snapshot(resource=owner(number(100)) if refused or abort else owner(raw)),result=result,outcome=c('Failure',error=UNIT) if abort else c('Success'),pending=0,undoCount=0 if refused else 1)
def initial():
 cases=c('Cases',constructed=construction(VALID,CANON),rejected=construction(INVALID,error=NESTED_ERROR),handle=construction(c('Handle',namespace=1,id=4)),foreign=construction(c('Handle',namespace=2,id=4),error=invalid(c('Handle',namespace=2,id=4),expected='same-world handle')),resource=resource(number(200)),invalidResource=resource(INVALID,True),abortedResource=resource(number(300),abort=True))
 return c('Candidate',first=copy.deepcopy(cases),second=copy.deepcopy(cases))
def custom():
 cases=c('Cases',constructorDenied=c('Refused',owner=incoming(number(7)),error=c('Constructor',error=c('Denied',code=403))),decoderRefused=c('Refused',owner=incoming(text('bad')),error=c('Validation',error=invalid(text('bad')))))
 return c('Candidate',first=copy.deepcopy(cases),second=copy.deepcopy(cases))
def request():
 spawn=c('Report',after=snapshot(nextId=2,highWater=1,capacity=2,depth=1,live=[False,False]),prepared=1,result=c('Accepted',namespace=1,id=1,spawned=True,canonical=CANON),recovered=[incoming(VALID)],completion=c('Failure',error=UNIT))
 foreign=c('Report',after=snapshot(),prepared=0,result=c('Refused',owner=some(incoming(number(11))),error=c('Entity',error=c('MissingEntity'))),recovered=[],completion=c('Failure',error=UNIT))
 bad=c('Report',after=snapshot(),prepared=0,result=c('Refused',owner=some(incoming(INVALID)),error=c('Validation',error=NESTED_ERROR)),recovered=[],completion=c('Failure',error=UNIT))
 cases=c('Cases',spawnAbort=spawn,foreignInsert=foreign,invalidSpawn=bad)
 return c('Candidate',first=copy.deepcopy(cases),second=copy.deepcopy(cases))
def raw_resource():
 def report(refused=False,abort=False):return c('Report',before=snapshot(),after=snapshot(resource=owner(number(100)) if refused or abort else owner(CANON,VALID,True)),result=c('Refused',owner=incoming(INVALID),error=NESTED_ERROR) if refused else c('Replaced',canonical=CANON,undoAvailable=True),completion=c('Failure',error=UNIT) if abort else c('Success'))
 cases=c('Cases',success=report(),refused=report(True),abort=report(abort=True))
 return c('Candidate',first=copy.deepcopy(cases),second=copy.deepcopy(cases))

def materialization():
 access=['constructed-raw-owner','constructed-raw-resource']
 registration=c('RegistrationMeta',id=1,name='constructed-materialization',access=access)
 seed=owner(CANON);packet=c('PacketView',owner=some(owner(CANON,VALID,True)),original=VALID,canonical=CANON)
 def snap(nextId=2,live=None,clock=1,slots=None,stamps=None,pending=0,retired=None,returned=None,errors=None):
  return c('Snapshot',meta=meta(nextId,nextId-1,2 if nextId==2 else 4,1 if nextId==2 else 2,clock,[registration],2),live=[False,True] if live is None else live,column=c('ColumnView',supported=True,slots=[some(seed)] if slots is None else slots,stamps=[c('Entry',id=1,stamp=c('Stamp',added=1,changed=1))] if stamps is None else stamps),mail=c('MailView',value=owner(number(100)),retired=retired or [],returned=returned or [],errors=errors or []),pending=pending)
 def report(mode):
  spawn=mode in ('spawn','failure');failed=mode in ('failure','failedInsert');late=mode=='lateMissing';bad=mode=='invalid';skip=mode=='skip'
  before=snap(pending=1 if late else 0)
  output=c('Refused',owner=some(incoming(INVALID)),error=c('Validation',error=NESTED_ERROR)) if bad else c('Accepted',target=c('Handle',namespace=1,id=2 if spawn else 1),spawned=spawn,canonical=CANON,undoAvailable=True)
  instance=c('InstanceView',namespace=1,id=1,name='constructed-materialization',access=access,recoveries=[c('RecoveryView',output=output,packets=[packet])] if failed else [])
  committed=snap(nextId=3 if spawn else 2,live=[False,True,False,False] if spawn else None,pending=(1 if late else 0)+(0 if bad or skip or failed else 2 if spawn else 1))
  barrier=copy.deepcopy(committed);barrier['pending']=0
  if not (bad or skip or failed):
   if late:
    barrier['live']=[False,False];barrier['mail']['returned']=[packet];barrier['mail']['errors']=[c('MissingEntity')]
   else:
    barrier['meta']['clock']=2
    if spawn:
     barrier['live']=[False,True,True,False];barrier['column']['slots']=[some(seed),some(owner(CANON,VALID,True))];barrier['column']['stamps']=[c('Entry',id=2,stamp=c('Stamp',added=2,changed=2)),c('Entry',id=1,stamp=c('Stamp',added=1,changed=1))]
    else:
     barrier['column']['slots']=[some(owner(CANON,VALID,True))];barrier['column']['stamps']=[c('Entry',id=1,stamp=c('Stamp',added=1,changed=2))];barrier['mail']['retired']=[seed]
  result=c('Failed',error=UNIT) if failed else c('Skipped',input=incoming(VALID)) if skip else c('Completed',output=output)
  return c('Report',before=before,committed=committed,barrier=barrier,instance=instance,result=result)
 cases=c('Cases',**{mode:report(mode) for mode in ('spawn','insert','failure','failedInsert','invalid','lateMissing','skip')})
 return c('Candidate',first=copy.deepcopy(cases),second=copy.deepcopy(cases))

if __name__=='__main__':
 for name,model in [('initial',initial()),('custom',custom()),('request',request()),('raw-resource',raw_resource()),('materialization',materialization())]:Path(__file__).with_name(name+'-expected.json').write_text(json.dumps(model,indent=2)+'\n')
