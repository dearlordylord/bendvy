"""Complete source-typed Candidate transport; no missing group/default repair."""
import importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('decode_complete_transport',HERE.parent/'transport.py')
BASE=importlib.util.module_from_spec(spec);exec(compile(Path(spec.origin).read_bytes(),str(spec.origin),"exec"),BASE.__dict__)

def spine_helper(entry):
 path=Path(entry).resolve().parent/'transport-inventory.py'
 spec=importlib.util.spec_from_file_location('complete_spine_inventory',path)
 module=importlib.util.module_from_spec(spec);exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__)
 return module

def inventory(entry,assembly=False,role="normal"):
 entry=Path(entry).resolve()
 if role in ('generic-spine','deferred-spine'):
  assert assembly and entry.name==role+'.bend','spine role requires exact complete source'
  return spine_helper(entry).inventory(entry,BASE,role)
 if role in ('generic-assembly','deferred-assembly'):
  assert assembly and entry.name==('complete.bend' if role=='generic-assembly' else 'fixture.bend'),'role requires explicit complete source'
  path=(entry.parent if role=='generic-assembly' else entry.parent.parent/'generic-assembly-v1')/'transport-inventory.py'
  spec=importlib.util.spec_from_file_location('generic_assembly_inventory',path)
  helper=importlib.util.module_from_spec(spec);exec(compile(path.read_bytes(),str(path),'exec'),helper.__dict__)
  return (helper.inventory if role=='generic-assembly' else helper.deferred_inventory)(entry,BASE)
 types,name=BASE.inventory(entry.parent.parent/'main.bend')
 if assembly:
  types=assembly_inventory(entry)
 maybe=lambda typ:('Base',{'None':[],'Some':[('value',typ)]})
 types['Report']=(str(entry),{'Candidate':[(k,maybe('Cases')) for k in ('insert','spawn','resource','otherSchema')]+[('foreign','Foreign'),('extension',maybe('Extension'))]})
 if role=='local-failure':
  assert assembly, 'failure role requires explicit assembly binding'
  types['Report']=(str(entry),{'Report':[(k,'Observation') for k in ('resourceAccepted','resourceRefused','spawnAccepted','spawnRefused')]})
 # BASE inventory is bound to original qualification main, so its Cases,
 # Extension and every nested nominal constructor remain canonical imports.
 def nominal(module,tag):
  import os
  return tag if module=='Base' or module==str(entry) else os.path.relpath(Path(module).with_suffix(''),entry.parent)+'.'+tag
 return types,nominal

def assembly_inventory(entry):
 # Explicit source-current DTO inventory. The binding pins its entire closure;
 # the independent whole oracle is mandatory and never taken from old ca88.
 entry=Path(entry).resolve();home=entry.parent
 types,_=BASE.inventory(HERE.parent/'main.bend')
 m=str(home/'main.bend');o=str(home/'observation.bend');r=str(home/'registered.bend');a=str(home/'application.bend');q=str(home/'extensions.bend');request=str(home/'request.bend')
 d=str(BASE.ROOT/'experiments/public-decode/typed.bend');tx=str(BASE.ROOT/'src/ecs/transaction.bend')
 fields=lambda **kw:list(kw.items())
 maybe=lambda typ:('Base',{'None':[],'Some':[('value',typ)]})
 record=lambda module,tag,fs:(module,{tag:fs})
 for key in ('Baseline','Cases','Foreign','Trace','Outcome','Observation'):types[key]=(m,types[key][1])
 for key in ('Snapshot','Meta','ColumnView','PayloadView'):types[key]=(o,types[key][1])
 types['Extension']=(q,types['Extension'][1])
 types['Observation']=(m,{'Observed':fields(trace='Trace'),'SetupRefused':fields(error='WorldError'),'CreateRefused':fields(resource='MailView'),'RegistrationRefused':[],'RegistrationRunRefused':fields(incoming='PayloadView'),'RegisteredObserved':fields(instance='InstanceView',result='Observation'),'SystemFailedObserved':fields(before='Snapshot',after='Snapshot',instance='InstanceView',error='Unit'),'AbortObserved':fields(before='Snapshot',after='Snapshot',output=maybe('OutputView'),packets=['PacketView'])})
 types['Outcome']=(m,{'ValidationRefused':fields(incoming=maybe('PayloadView'),error='Error'),'Replaced':fields(original='Raw',previous=maybe('PayloadView'),handle=maybe('U32')),'OperationRefused':fields(original='Raw',incoming=maybe('PayloadView'),error='WorldError')})
 types['Snapshot']=record(o,'Snapshot',fields(meta='Meta',live=['Bool'],column='ColumnView',resource='MailView',pending='U32'))
 types['PacketView']=record(o,'PacketView',fields(owner=maybe('PayloadView'),original='Raw',canonical='Raw'))
 types['MailView']=record(o,'MailView',fields(value='PayloadView',retired=['PayloadView'],returned=['PacketView'],errors=['WorldError']))
 types['OutputView']=(r,{'AcceptedView':fields(namespace='U32',id='U32',spawned='Bool',canonical='Raw'),'RefusedView':fields(owner=maybe('PayloadView'),error='AdmissionError')})
 types['AdmissionError']=(request,{'Validation':fields(error='Error'),'Entity':fields(error='WorldError')})
 types['RecoveryView']=record(r,'RecoveryView',fields(output='OutputView',packets=['PacketView']))
 types['InstanceView']=record(r,'InstanceView',fields(namespace='U32',id='U32',name='String',access=['String'],operation='Operation',codec='Codec',completion='Completion',recovery=['RecoveryView']))
 types['Operation']=(a,{'Insert':[],'Resource':[],'Spawn':[]})
 types['Completion']=(tx,{'Success':[],'Failure':fields(error='Unit')})
 types['Codec']=(d,{'FiniteNumber':[],'Integer':[],'StringValue':[],'BoolValue':[],'Literal':fields(value='Raw'),'LiteralValues':fields(values=['Raw']),'LiteralRendered':fields(values=['Raw'],expected='String'),'Nullable':fields(inner='Codec'),'ArrayValue':fields(inner='Codec'),'Struct':fields(fields=['NamedCodec']),'HandleValue':fields(namespace='U32')})
 types['NamedCodec']=record(d,'NamedCodec',fields(name='String',codec='Codec'))
 return types

def whole(value,role="normal"):
 if role in ("generic-assembly","generic-spine"):
  assert type(value) is dict and set(value)=={"$","second","first","recovery"} and value["$"]=="Candidate"
  return value
 if role in ("deferred-assembly","deferred-spine"):
  assert type(value) is dict and set(value)=={"$","spawn","insert","failure","foreign","lateMissing","invalid","failedInsert","failedInvalid"} and value["$"]=="Candidate"
  return value
 if role=="local-failure":
  assert type(value) is dict and set(value)=={"$","resourceAccepted","resourceRefused","spawnAccepted","spawnRefused"} and value["$"]=="Report"
  return value
 assert type(value) is dict and set(value)=={'$','insert','spawn','resource','otherSchema','foreign','extension'} and value['$']=='Candidate'
 def present(group):
  assert type(group) is dict and set(group)=={'$','value'} and group['$']=='Some','internally assembled group must be Some'
  return group['value']
 return {'$':'Report','baseline':{'$':'Report',**{k:present(value[k]) for k in ('insert','spawn','resource','otherSchema')},'foreign':value['foreign']},'extension':present(value['extension'])}

def render(expected,entry,assembly=False,role="normal"):
 whole(expected,role)
 types,name=inventory(entry,assembly,role)
 subject=spine_helper(entry).pack(expected,role) if role in ('generic-spine','deferred-spine') else expected
 return (BASE.parser().render(BASE.codec(subject,types['Report'] if role in ('generic-spine','deferred-spine') else 'Report',types,name,True))+'\n').encode()

def parse(raw,entry,assembly=False,role="normal"):
 assert type(raw) is bytes
 p=BASE.parser();term=p.parse(raw.decode())
 assert (p.render(term)+'\n').encode()==raw,'noncanonical complete output'
 types,name=inventory(entry,assembly,role)
 value=BASE.codec(term,types['Report'] if role in ('generic-spine','deferred-spine') else 'Report',types,name,False)
 if role in ('generic-spine','deferred-spine'):value=spine_helper(entry).unpack(value,role)
 whole(value,role)
 return value
