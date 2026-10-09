"""Independent source delta model for full custom materialization and admission."""
import copy,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('prior',HERE.parent/'expected.py');B=importlib.util.module_from_spec(s);s.loader.exec_module(B)
c=B.c

def materialization():
 def rewrite(value):
  if value in (B.VALID,B.CANON):return B.number(7)
  if value==B.INVALID:return B.text('wrong')
  if value==B.NESTED_ERROR:return c('Invalid',path='$',expected='integer',actual=B.text('wrong'))
  if isinstance(value,list):return [rewrite(x)for x in value]
  if isinstance(value,dict):
   if value.get('$')=='View' and value.get('words')==[81,82] and value['raw']==B.CANON:return B.owner(B.number(99))
   result={k:rewrite(v)for k,v in value.items()}
   if value.get('$')=='Refused' and value.get('error',{}).get('$')=='Validation':result['error']=c('Construction',error=result['error'])
   return result
  return value
 return rewrite(B.materialization())
def admission():
 world=B.snapshot()
 frame=c('EmptyFrame',world=copy.deepcopy(world),codec=c('Integer'),handle=c('Handle',namespace=0,id=0),error=B.NONE,cursor=0)
 return c('Report',before=copy.deepcopy(world),after=copy.deepcopy(world),frameBefore=copy.deepcopy(frame),frameAfter=copy.deepcopy(frame),result=c('Refused',owner=B.incoming(B.number(7)),error=c('Admission',error=B.invalid(B.text('bad-resource')))),completion=c('Success'))
def expected():
 material=materialization();a=admission();adm=c('Candidate',first=copy.deepcopy(a),second=copy.deepcopy(a));spine=[]
 for schema in ('First','Second'):
  for mode in ('spawn','insert','failure','failedInsert','invalid','lateMissing','skip'):spine.append(c('Material'+schema,label=mode,value=copy.deepcopy(material[schema.lower()][mode])))
 spine.extend([c('AdmissionFirst',value=copy.deepcopy(a)),c('AdmissionSecond',value=copy.deepcopy(a))])
 return {'materialization':material,'resource-admission':adm,'complete-spine':spine}
if __name__=='__main__':
 for name,value in expected().items():HERE.joinpath(name+'-expected.json').write_text(json.dumps(value,indent=2)+'\n')
