"""Exact nominal DTO inventory for frozen 72f02c22 complete consumer; no defaults."""
from pathlib import Path

def inventory(entry,base):
 entry=Path(entry).resolve();home=entry.parent;root=base.ROOT
 t={};f=lambda **kw:list(kw.items());maybe=lambda typ:('Base',{'None':[],'Some':[('value',typ)]})
 def define(key,module,variants):t[key]=(str(module),variants)
 def record(key,module,tag,fields):define(key,module,{tag:fields})
 w=root/'src/ecs/world.bend';l=root/'src/ecs/lifecycle.bend';d=root/'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend';old=root/'experiments/public-decode/typed.bend'
 define('Unit','Base',{'Unit':[]});record('Handle',w,'Handle',f(namespace='U32',id='U32'))
 define('WorldError',w,{name:[] for name in ('MissingEntity','CapacityExceeded','NamespaceExhausted','SystemIdExhausted')})
 record('RegistrationMeta',w,'RegistrationMeta',f(id='U32',name='String',access=['String']))
 record('Stamp',l,'Stamp',f(added='U32',changed='U32'));record('Entry',l,'Entry',f(id='U32',stamp='Stamp'))
 define('Result','Base',{'Fail':f(error='Unit'),'Done':f(value='Unit')})
 for prefix,module in [('D',d),('Old',old)]:
  raw=prefix+'.Raw';field=prefix+'.Field';codec=prefix+'.Codec';error=prefix+'.Error'
  define(raw,module,{'Missing':[],'Null':[],'Number':f(value='U32'),'SignedInteger':f(negative='Bool',magnitude='Nat'),'Float':f(value='F32'),'Binary64':f(high='U32',low='U32'),'Text':f(value='String'),'Utf16Text':f(units=['U32']),'Boolean':f(value='Bool'),'Handle':f(namespace='U32',id='U32'),'Array':f(items=[raw]),'Object':f(fields=[field])})
  record(field,module,'Field',f(name='String',value=raw))
  define(codec,module,{'FiniteNumber':[],'Integer':[],'StringValue':[],'BoolValue':[],'Literal':f(value=raw),'LiteralValues':f(values=[raw]),'LiteralRendered':f(values=[raw],expected='String'),'Nullable':f(inner=codec),'ArrayValue':f(inner=codec),'Struct':f(fields=[prefix+'.NamedCodec']),'HandleValue':f(namespace='U32')})
  record(prefix+'.NamedCodec',module,'NamedCodec',f(name='String',codec=codec))
  define(error,module,{'Invalid':f(path='String',expected='String',actual=raw),'FuelExhausted':f(path='String')})
 define('RequestError',home/'request.bend',{'Validation':f(error='D.Error'),'Entity':f(error='WorldError')})
 define('QueryError',root/'src/ecs/compose.bend',{'UserError':f(error='Unit'),'AccessError':f(error='WorldError')})
 define('Access',root/'src/ecs/component.bend',{'Found':f(value='D.Raw'),'ComponentAbsent':[],'MissingEntity':[]})
 # Historical resource Data projection has a different nominal Raw and DTO.
 ro=root/'experiments/public-decode/adoption-v1/observation.bend'
 record('Resource',ro,'PayloadView',f(raw='Old.Raw',sentinel=['U32']))
 for prefix,obs,payload,resource in [('Second',home/'observation.bend',f(raw='D.Raw',words=['U32'],flags=['Bool']),'Resource'),('First',home/'first-observation.bend',f(raw='Old.Raw',sentinel=['U32']),'Second.Payload')]:
  record(prefix+'.Payload',obs,'PayloadView',payload)
  record(prefix+'.Column',obs,'ColumnView',f(supported='Bool',slots=[maybe(prefix+'.Payload')],stamps=['Entry']))
  record(prefix+'.Meta',obs,'Meta',f(namespace='U32',nextId='U32',highWater='U32',capacity='U32',depth='Nat',events=['Unit'],registrations=['RegistrationMeta'],nextSystemId='U32',clock='U32'))
  record(prefix+'.Snapshot',obs,'Snapshot',f(meta=prefix+'.Meta',live=['Bool'],column=prefix+'.Column',resource=resource,pending='U32'))
 recovery=home/'recovery-fixture.bend'
 def owner_views(prefix,module,payload):
  record(prefix+'.Packet',module,'PacketView',f(owner=maybe(payload),original='D.Raw',canonical='D.Raw'))
  record(prefix+'.Pending',module,'PendingView',f(target='Handle',owner=maybe(payload),stamp='Stamp',error='WorldError'))
 owner_views('Recovery',recovery,'Second.Payload');owner_views('FirstOwner',home/'first-public-fixture.bend','First.Payload')
 record('Recovery.State',recovery,'StateView',f(owners=['Recovery.Packet'],pending=['Recovery.Pending'],during=maybe('Second.Snapshot'),errors=['WorldError']))
 define('Recovery.Report',recovery,{'CreationRejected':[],'Report':f(before='Second.Snapshot',after='Second.Snapshot',local='Recovery.State',result='Result')})
 record('Recovery.Candidate',recovery,'Candidate',[(k,'Recovery.Report') for k in ('interleaved','equalPosition','pending','success','reserveRefused','installRefused','activationRefused')])
 for prefix,module,packet,pending in [('Second',home/'public-fixture.bend','Recovery.Packet','Recovery.Pending'),('First',home/'first-public-fixture.bend','FirstOwner.Packet','FirstOwner.Pending')]:
  payload=prefix+'.Payload';snapshot=prefix+'.Snapshot'
  record(prefix+'.Incoming',module,'IncomingView',f(first=payload,second=payload))
  define(prefix+'.Operation',module,{'AcceptedView':f(target='Handle',spawned='Bool',canonical='D.Raw'),'RefusedView':f(owner=maybe(payload),error='RequestError')})
  define(prefix+'.Write',module,{'WrittenView':[],'WriteRefusedView':f(owner=maybe(payload),error='WorldError')})
  record(prefix+'.Args',module,'ArgsView',f(incoming=maybe(prefix+'.Incoming'),operations=[prefix+'.Operation'],writes=[prefix+'.Write'],fail='Bool'))
  record(prefix+'.Recovery',module,'RecoveryView',f(args=prefix+'.Args',owners=[packet],pending=[pending]))
  record(prefix+'.State',module,'StateView',f(codec='D.Codec',recovery=[prefix+'.Recovery']))
  record(prefix+'.Instance',module,'InstanceView',f(namespace='U32',id='U32',name='String',access=['String'],state=prefix+'.State'))
  define(prefix+'.Result',module,{'CompletedView':f(args=prefix+'.Args',rows=['Access']),'FailedView':f(error='QueryError'),'RegistrationRefusedView':[],'FactoryRefusedView':[],'InvocationRefusedView':f(args=prefix+'.Args'),'SkippedView':f(args=prefix+'.Args')})
  define(prefix+'.Report',module,{'Report':f(before=snapshot,after=snapshot,instance=prefix+'.Instance',result=prefix+'.Result'),'Unavailable':f(result=prefix+'.Result')})
  record(prefix+'.Candidate',module,'Candidate',[(k,prefix+'.Report') for k in ('success','failure','noMatch','skip')])
 record('Report',entry,'Candidate',f(second='Second.Candidate',first='First.Candidate',recovery='Recovery.Candidate'))
 def name(module,tag):
  import os
  return tag if module=='Base' or module==str(entry) else os.path.relpath(Path(module).with_suffix(''),entry.parent)+'.'+tag
 return t,name
