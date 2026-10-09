"""Independent source-only qualification model; never consumes backend output."""
import copy,importlib.util,json
from pathlib import Path
BASE=Path(__file__).resolve().parents[2]/'oracle-v1'
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
P=load('prior',BASE/'expected.py')
# Versioned foreign refusal contract restores original65 fields, same sentinel.
def baseline():
 v=P.expected();c=P.ref.expected()['struct64'];raw=P.converted(c['original']);canonical=P.converted(c['checked'])['value'];t=v['foreign']['result']['trace'];t['outcome']=P.tag('OperationRefused',original=raw,incoming=P.some(P.payload(copy.deepcopy(raw),[111,222])),error=P.tag('MissingEntity'));t['canonical']=P.some(canonical);return v
T=P.tag
N=P.none
S=P.some
def num(n):return T('Number',value=n)
def text(s):return T('Text',value=s)
def boolean(b):return T('Boolean',value=b)
def obj(name,value,extra=False):
 fs=[T('Field',name=name,value=value)]
 if extra:fs.append(T('Field',name='extra',value=num(99)))
 return T('Object',fields=fs)
def checked(raw,path=None,expected=None):return T('Accepted',value=copy.deepcopy(raw)) if path is None else T('Rejected',error=T('Invalid',path=path,expected=expected,actual=copy.deepcopy(raw)))
def empty():
 v=P.snapshot(seed=False);v['meta'].update(nextId=1,highWater=0,capacity=1,depth=0);v['live']=[False];return v
def resource(raw,result):
 before=empty();after=copy.deepcopy(before)
 if result['$']=='Rejected':out=T('ValidationRefused',incoming=P.payload(copy.deepcopy(raw),[111,222]),error=copy.deepcopy(result['error']));canonical=N()
 else:
  after['resource']=P.payload(copy.deepcopy(result['value']),[111,222]);out=T('Replaced',original=copy.deepcopy(raw),previous=S(copy.deepcopy(before['resource'])),handle=N());canonical=S(copy.deepcopy(result['value']))
 flushed=copy.deepcopy(after);flushed['pending']=0;flushed['meta']['events'].append(T('Unit'))
 return T('Observed',trace=T('Trace',before=before,after=after,flushed=flushed,outcome=out,canonical=canonical,seedPrevious=N()))
def extensions(skip=False):
 ready=obj('kind',text('ready'),True);canonical=obj('kind',text('ready'));busy=obj('kind',text('busy'))
 targets=[T('Handle',namespace=1,id=1),T('Handle',namespace=2,id=1),T('Handle',namespace=1,id=0),text('not-handle')]
 def admission(raw,result):return resource(raw,checked(raw) if skip else result)
 return T('Extension',plain=resource(text('plain-value'),checked(text('plain-value'))),transient=resource(boolean(False),checked(boolean(False))),resultRejectsDecodeAccepts=admission(boolean(True),checked(boolean(True),'$','integer')),resultAccepts=admission(num(7),checked(num(7))),decodeOverrides=T('Observation',originalRaw=boolean(True),sentinel=[111,222],checked=checked(boolean(True))),decodeFallsBack=T('Observation',originalRaw=boolean(True),sentinel=[111,222],checked=checked(boolean(True),'$','integer')),literalAccepts=admission(ready,checked(canonical)),literalRejects=admission(busy,checked(text('busy'),'$.kind','literal')),**{name:admission(obj('target',raw),checked(obj('target',raw)) if i==0 else checked(raw,'$.target','same-world handle')) for i,(name,raw) in enumerate(zip(['handleAccepts','handleForeign','handleZero','handleWrongType'],targets))})
def expected(variant='normal'):
 b=baseline()
 if variant=='skipped-validator':
  cases=P.ref.expected()
  for name,op in [('insert','insert'),('spawn','spawn'),('resource','resource'),('otherSchema','insert')]:
   b[name]=T('Cases',**{key:P.observed(op,P.converted(case['original']),checked(P.converted(case['original']))) for key,case in cases.items()})
  t=b['foreign']['result']['trace'];t['canonical']=S(copy.deepcopy(t['outcome']['original']))
 elif variant=='partial-write':
  for name in ['insert','spawn','resource','otherSchema']:
   for value in b[name].values():
    if isinstance(value,dict) and value.get('$')=='Observed':
     for phase in ['after','flushed']:value['trace'][phase]['meta']['events'].append(T('Unit'))
  for phase in ['after','flushed']:b['foreign']['result']['trace'][phase]['meta']['events'].append(T('Unit'))
 return T('Report',baseline=b,extension=extensions(variant=='skipped-validator'))
if __name__=='__main__':
 for variant in ['normal','skipped-validator','partial-write']:
  Path(__file__).with_name(variant+'-expected.json').write_text(json.dumps(expected(variant),indent=2)+'\n')
