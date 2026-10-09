"""Independent complete additive20 model; no actual runtime observations."""
import copy,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('construction_prior',HERE.parent/'expected.py');B=importlib.util.module_from_spec(s);s.loader.exec_module(B)
c,number,text,UNIT,none,some=B.c,B.number,B.text,B.UNIT,B.NONE,B.some

def request_cases():
 def refused(raw,error):return c('Report',after=B.snapshot(),prepared=0,result=c('Refused',owner=some(B.incoming(raw)),error=error),recovered=[],completion=c('Failure',error=UNIT))
 return c('Cases',spawnAbort=c('Report',after=B.snapshot(nextId=2,highWater=1,capacity=2,depth=1,live=[False,False]),prepared=1,result=c('Accepted',namespace=1,id=1,spawned=True,canonical=number(7)),recovered=[B.incoming(number(7))],completion=c('Failure',error=UNIT)),constructorDenied=refused(number(403),c('Construction',error=c('Constructor',error=c('Denied',code=403)))),foreignInsert=refused(number(11),c('Operation',error=c('Entity',error=c('MissingEntity')))),invalidSpawn=refused(text('wrong'),c('Construction',error=c('Validation',error=B.invalid(text('wrong'))))))
def resource_cases():
 def report(raw,error=None,abort=False):return c('Report',before=B.snapshot(),after=B.snapshot(resource=B.owner(number(100)) if error is not None or abort else B.owner(raw,raw,True)),result=c('Refused',owner=B.incoming(raw),error=error) if error is not None else c('Replaced',canonical=raw,undoAvailable=True),completion=c('Failure',error=UNIT) if abort else c('Success'))
 return c('Cases',success=report(number(7)),denied=report(number(403),c('Construction',error=c('Constructor',error=c('Denied',code=403)))),refused=report(text('wrong'),c('Construction',error=c('Validation',error=B.invalid(text('wrong'))))),abort=report(number(7),abort=True))
def refusal(foreign):
 access=['constructed-raw-owner','constructed-raw-resource']
 instance=c('InstanceView',namespace=1,id=1,name='constructed-materialization',access=access,recoveries=[])
 def snapshot(primary):
  meta=B.meta(registrations=[c('RegistrationMeta',id=1,name=instance['name'],access=access)] if primary else [],nextSystemId=2 if primary else 1)
  meta['namespace']=1 if primary or not foreign else 2
  return c('Snapshot',meta=meta,live=[False],column=c('ColumnView',supported=True,slots=[none],stamps=[]),mail=c('MailView',value=B.owner(number(100 if primary else 200)),retired=[],returned=[],errors=[]),pending=0)
 args=c('ArgsView',operation=c('Spawn'),input=B.incoming(B.VALID),fail=True)
 return c('Refused',primaryBefore=snapshot(True),primaryAfter=snapshot(True),suppliedBefore=snapshot(False),suppliedAfter=snapshot(False),instanceBefore=copy.deepcopy(instance),instanceAfter=copy.deepcopy(instance),incoming=copy.deepcopy(args),returned=copy.deepcopy(args))
def expected():
 req=request_cases();res=resource_cases()
 request=c('Candidate',first=copy.deepcopy(req),second=copy.deepcopy(req))
 resource=c('Candidate',first=copy.deepcopy(res),second=copy.deepcopy(res))
 local=c('Candidate',foreignFirst=refusal(True),missingRegistrationFirst=refusal(False),foreignSecond=refusal(True),missingRegistrationSecond=refusal(False))
 spine=[]
 for schema in ('First','Second'):
  for label in ('spawnAbort','constructorDenied','foreignInsert','invalidSpawn'):spine.append(c('OwnedRequest',schema=schema,label=label,value=copy.deepcopy(req[label])))
 for schema in ('First','Second'):
  for label in ('success','denied','refused','abort'):spine.append(c('ResourceWrite',schema=schema,label=label,value=copy.deepcopy(res[label])))
 for schema in ('First','Second'):
  for label in ('foreign','missingRegistration'):spine.append(c('Refusal'+schema,label=label,value=refusal(label=='foreign')))
 return {'request':request,'resource':resource,'local-refusal':local,'complete-spine':spine}
if __name__=='__main__':
 for name,value in expected().items():HERE.joinpath(name+'-expected.json').write_text(json.dumps(value,indent=2)+'\n')
