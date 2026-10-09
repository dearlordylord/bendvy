"""Source-only complete ordinary constructed admission consumer expectation."""
import copy,json,importlib.util
from pathlib import Path
REFERENCE=Path('/workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/oracle-v1/expected-complete.py')
spec=importlib.util.spec_from_file_location('complete_input_contract',REFERENCE);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
def tag(ctor,**fields):return {'$':ctor,**fields}
def none():return tag('None')
def some(value):return tag('Some',value=value)
def converted(value):
 if isinstance(value,list):return [converted(x) for x in value]
 if not isinstance(value,dict):return value
 if len(value)==1:
  k,v=next(iter(value.items()))
  field={'Number':'value','Text':'value','Array':'items','Object':'fields','Accepted':'value','Rejected':'error'}
  if k in field:return tag(k,**{field[k]:converted(v)})
  if k in ['Null','Missing']:return tag(k)
  if k in ['Field','Invalid']:return tag(k,**{a:converted(b) for a,b in v.items()})
 return {k:converted(v) for k,v in value.items()}
def payload(raw,sentinel):return tag('PayloadView',raw=raw,sentinel=sentinel)
def entry(id,added,changed):return tag('Entry',id=id,stamp=tag('Stamp',added=added,changed=changed))
def snapshot(namespace=1,resource_name='initial-resource',resource_sentinel=None,seed=True,events=True):
 return tag('Snapshot',meta=tag('Meta',namespace=namespace,nextId=2,highWater=1,capacity=2,depth=1,events=[tag('Unit')] if events else [],registrations=[],nextSystemId=1,clock=1 if seed else 0),live=[False,True],column=tag('ColumnView',supported=True,slots=[some(payload(tag('Number',value=9),[333,444]))] if seed else [none()],stamps=[entry(1,1,1)] if seed else []),resource=payload(tag('Text',value=resource_name),[555,666] if resource_sentinel is None else resource_sentinel),pending=1 if events else 0)
def observed(op,raw,checked,namespace=1,resource_name='initial-resource',foreign=False):
 before=snapshot(namespace,resource_name);after=copy.deepcopy(before);canonical=none()
 if checked['$']=='Rejected':
  outcome=tag('ValidationRefused',incoming=payload(copy.deepcopy(raw),[111,222]),error=checked['error'])
 else:
  value=copy.deepcopy(checked['value']);canonical=some(copy.deepcopy(value))
  if foreign:
   outcome=tag('OperationRefused',original=copy.deepcopy(raw),incoming=some(payload(value,[111,222])),error=tag('MissingEntity'))
  elif op=='resource':
   outcome=tag('Replaced',original=copy.deepcopy(raw),previous=some(copy.deepcopy(before['resource'])),handle=none());after['resource']=payload(value,[111,222])
  elif op=='spawn':
   outcome=tag('Replaced',original=copy.deepcopy(raw),previous=none(),handle=some(2));after['meta'].update(nextId=3,highWater=2,capacity=4,depth=2,clock=2);after['live']=[False,True,True,False];after['column']['slots'].append(some(payload(value,[111,222])));after['column']['stamps']=[entry(2,2,2),entry(1,1,1)]
  else:
   outcome=tag('Replaced',original=copy.deepcopy(raw),previous=copy.deepcopy(before['column']['slots'][0]),handle=some(1));after['meta']['clock']=2;after['column']['slots'][0]=some(payload(value,[111,222]));after['column']['stamps']=[entry(1,1,2)]
 flushed=copy.deepcopy(after);flushed['pending']=0;flushed['meta']['events'].append(tag('Unit'))
 return tag('Observed',trace=tag('Trace',before=before,after=after,flushed=flushed,outcome=outcome,canonical=canonical,seedPrevious=none()))
def expected():
 cases=ref.expected()
 def suite(op):return tag('Cases',**{name:observed(op,converted(v['original']),converted(v['checked'])) for name,v in cases.items()})
 raw=tag('Array',items=[tag('Number',value=1) for _ in range(3)])
 foreign=tag('Foreign',first=snapshot(1,'first-resource',[777,888],seed=False,events=False),result=observed('insert',raw,tag('Accepted',value=raw),2,'second-resource',foreign=True))
 return tag('Report',insert=suite('insert'),spawn=suite('spawn'),resource=suite('resource'),otherSchema=suite('insert'),foreign=foreign)
if __name__=='__main__':Path(__file__).with_name('expected.json').write_text(json.dumps(expected(),indent=2)+'\n')
