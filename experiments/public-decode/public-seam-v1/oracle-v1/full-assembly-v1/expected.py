"""Complete source-only registered/deferred assembly model; no backend outputs."""
import copy,json,importlib.util
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy')
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
Q=load('prior_qualification',ROOT/'experiments/public-decode/adoption-v1/qualification-v1/oracle-v1/expected.py')
P=Q.P;T=P.tag;S=P.some;N=P.none

def mail(snapshot):
 snapshot=copy.deepcopy(snapshot);snapshot['resource']=T('MailView',value=snapshot['resource'],retired=[],returned=[],errors=[]);return snapshot

def registered(snapshot,operation='Insert',typed=False):
 snapshot=mail(snapshot);key='decoded-resource' if typed or operation=='Resource' else 'decoded-value'
 snapshot['meta']['registrations']=[T('RegistrationMeta',id=1,name='decode-typed-resource' if typed else 'decode-owned',access=[key])];snapshot['meta']['nextSystemId']=2;return snapshot

def codec(name):
 if name.startswith('array') or name=='lateInvalid':return T('ArrayValue',inner=T('Integer'))
 if name=='struct64':return T('Struct',fields=[T('NamedCodec',name='f'+str(i),codec=T('Integer')) for i in range(64)])
 return T('Struct',fields=[T('NamedCodec',name='items',codec=T('Nullable',inner=T('ArrayValue',inner=T('Struct',fields=[T('NamedCodec',name='value',codec=T('Integer'))]))))])

def observation(op,raw,checked,code,namespace=1,resource_name='initial-resource',foreign=False):
 before=registered(P.snapshot(namespace,resource_name),op);after=copy.deepcopy(before);canonical=N()
 if checked['$']=='Rejected':out=T('ValidationRefused',incoming=S(P.payload(copy.deepcopy(raw),[111,222])),error=copy.deepcopy(checked['error']))
 elif foreign:out=T('OperationRefused',original=copy.deepcopy(raw),incoming=S(P.payload(copy.deepcopy(raw),[111,222])),error=T('MissingEntity'))
 else:
  value=copy.deepcopy(checked['value']);canonical=S(value);out=T('Replaced',original=copy.deepcopy(raw),previous=N(),handle=N() if op=='Resource' else S(2 if op=='Spawn' else 1))
  if op=='Resource':after['resource']['value']=P.payload(copy.deepcopy(value),[111,222])
  elif op=='Spawn':after['meta'].update(nextId=3,highWater=2,capacity=4,depth=2);after['live']=[False,True,False,False];after['pending']=3
  else:after['pending']=2
 flushed=copy.deepcopy(after);flushed['pending']=0;flushed['meta']['events'].append(T('Unit'))
 if checked['$']=='Accepted' and not foreign and op!='Resource':
  value=copy.deepcopy(checked['value']);flushed['meta']['clock']=2
  if op=='Spawn':flushed['live'][2]=True;flushed['column']['slots'].append(S(P.payload(value,[111,222])));flushed['column']['stamps']=[P.entry(2,2,2),P.entry(1,1,1)]
  else:flushed['resource']['retired']=[copy.deepcopy(before['column']['slots'][0]['value'])];flushed['column']['slots'][0]=S(P.payload(value,[111,222]));flushed['column']['stamps']=[P.entry(1,1,2)]
 instance=T('InstanceView',namespace=namespace,id=1,name='decode-owned',access=['decoded-resource' if op=='Resource' else 'decoded-value'],operation=T(op),codec=code,completion=T('Success'),recovery=[])
 trace=T('Trace',before=before,after=after,flushed=flushed,outcome=out,canonical=canonical,seedPrevious=N())
 return T('RegisteredObserved',instance=instance,result=T('Observed',trace=trace))

def expected():
 cases=P.ref.expected()
 def suite(op):return T('Cases',**{name:observation(op,P.converted(v['original']),P.converted(v['checked']),codec(name)) for name,v in cases.items()})
 foreigncase=cases['struct64'];raw=P.converted(foreigncase['original']);check=P.converted(foreigncase['checked'])
 foreign=T('Foreign',first=mail(P.snapshot(1,'first-resource',[777,888],seed=False,events=False)),result=observation('Insert',raw,check,codec('struct64'),2,'second-resource',True))
 extensions=Q.extensions()
 for name,value in extensions.items():
  if name=='$' or name in ('decodeOverrides','decodeFallsBack'):continue
  trace=value['trace']
  for phase in ('before','after','flushed'):trace[phase]=registered(trace[phase],'Resource',True)
  out=trace['outcome']
  if out['$']=='ValidationRefused':out['incoming']=S(out['incoming'])
  elif out['$']=='Replaced':out['previous']=N()
 return T('Candidate',insert=S(suite('Insert')),spawn=S(suite('Spawn')),resource=S(suite('Resource')),otherSchema=S(suite('Insert')),foreign=foreign,extension=S(extensions))
if __name__=='__main__':Path(__file__).with_name('expected.json').write_text(json.dumps(expected(),indent=2)+'\n')

def failure_expected():
 def case(op,raw,accepted):
  before=registered(P.snapshot(seed=False,events=False),op);before['live']=[False,False];after=copy.deepcopy(before)
  packets=[]
  if accepted:
   target=2 if op=='Spawn' else 1
   output=T('AcceptedView',namespace=1,id=target,spawned=op=='Spawn',canonical=copy.deepcopy(raw))
   if op=='Spawn':
    after['meta'].update(nextId=3,highWater=2,capacity=4,depth=2);after['live']=[False,False,False,False]
    packets=[T('PacketView',owner=S(P.payload(copy.deepcopy(raw),[111,222])),original=copy.deepcopy(raw),canonical=copy.deepcopy(raw))]
  else:output=T('RefusedView',owner=S(P.payload(copy.deepcopy(raw),[111,222])),error=T('Validation',error=T('Invalid',path='$',expected='integer',actual=copy.deepcopy(raw))))
  recovery=T('RecoveryView',output=output,packets=packets)
  instance=T('InstanceView',namespace=1,id=1,name='decode-owned',access=['decoded-resource' if op=='Resource' else 'decoded-value'],operation=T(op),codec=T('Integer'),completion=T('Failure',error=T('Unit')),recovery=[recovery])
  return T('SystemFailedObserved',before=before,after=after,instance=instance,error=T('Unit'))
 return T('Report',resourceAccepted=case('Resource',T('Number',value=7),True),resourceRefused=case('Resource',T('Boolean',value=False),False),spawnAccepted=case('Spawn',T('Number',value=7),True),spawnRefused=case('Spawn',T('Boolean',value=False),False))
