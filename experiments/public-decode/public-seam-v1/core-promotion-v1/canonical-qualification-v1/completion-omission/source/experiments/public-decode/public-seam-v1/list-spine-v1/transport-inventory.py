"""Strict complete tagged FIFO list mapping to unchanged independent Candidates."""
import importlib.util,os
from pathlib import Path
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent/'generic-assembly-v1/transport-inventory.py'
spec=importlib.util.spec_from_file_location('whole_generic_inventory',SOURCE)
BASE=importlib.util.module_from_spec(spec);exec(compile(SOURCE.read_bytes(),str(SOURCE),'exec'),BASE.__dict__)
PUBLIC=[('success','Success'),('failure','Failure'),('noMatch','NoMatch'),('skip','Skip')]
RECOVERY=[('interleaved','RInterleaved'),('equalPosition','REqualPosition'),('pending','RPending'),('success','RSuccess'),('reserveRefused','RReserveRefused'),('installRefused','RInstallRefused'),('activationRefused','RActivationRefused')]
DEFERRED=[('spawn','Spawn'),('insert','Insert'),('failure','Failure'),('foreign','Foreign'),('lateMissing','LateMissing'),('invalid','Invalid'),('failedInsert','FailedInsert'),('failedInvalid','FailedInvalid')]
def record(value,tag,keys):assert type(value) is dict and set(value)=={'$',*keys} and value['$']==tag

def pack(value,role):
 if role=='generic-spine':
  record(value,'Candidate',('second','first','recovery'))
  for group,names in [('second',PUBLIC),('first',PUBLIC),('recovery',RECOVERY)]:record(value[group],'Candidate',[k for k,_ in names])
  return [{'$':tag,'label':{'$':label},'value':value[group][key]} for group,tag,names in [('second','Second',PUBLIC),('first','First',PUBLIC),('recovery','Recovered',RECOVERY)] for key,label in names]
 assert role=='deferred-spine'
 record(value,'Candidate',[key for key,_ in DEFERRED])
 return [{'$':'Item','label':{'$':label},'value':value[key]} for key,label in DEFERRED]

def unpack(value,role):
 assert type(value) is list
 if role=='generic-spine':
  assert len(value)==15
  result={'$':'Candidate'};position=0
  for group,tag,names in [('second','Second',PUBLIC),('first','First',PUBLIC),('recovery','Recovered',RECOVERY)]:
   result[group]={'$':'Candidate'}
   for key,label in names:
    item=value[position];position+=1;record(item,tag,('label','value'));record(item['label'],label,())
    result[group][key]=item['value']
  return result
 assert role=='deferred-spine' and len(value)==8
 result={'$':'Candidate'}
 for item,(key,label) in zip(value,DEFERRED):
  record(item,'Item',('label','value'));record(item['label'],label,());result[key]=item['value']
 return result

def inventory(entry,base,role):
 entry=Path(entry).resolve();home=entry.parent
 if role=='generic-spine':
  types,_=BASE.inventory(home.parent/'generic-assembly-v1/complete.bend',base)
  types['Spine.Case']=(str(entry),{label:[] for _,label in PUBLIC})
  types['Spine.RecoveryCase']=(str(entry),{label:[] for _,label in RECOVERY})
  types['Spine.Item']=(str(entry),{'Second':[('label','Spine.Case'),('value','Second.Report')],'First':[('label','Spine.Case'),('value','First.Report')],'Recovered':[('label','Spine.RecoveryCase'),('value','Recovery.Report')]})
 else:
  assert role=='deferred-spine'
  types,_=BASE.deferred_inventory(home.parent/'deferred-assembly-v1/fixture.bend',base)
  types['Spine.Case']=(str(entry),{label:[] for _,label in DEFERRED})
  types['Spine.Item']=(str(entry),{'Item':[('label','Spine.Case'),('value','Deferred.Report')]})
 types['Report']=['Spine.Item']
 def name(module,tag):return tag if module=='Base' or module==str(entry) else os.path.relpath(Path(module).with_suffix(''),entry.parent)+'.'+tag
 return types,name
