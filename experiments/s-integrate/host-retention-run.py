#!/usr/bin/env python3
"""Strict E11 public oracle preparation; actual Host binding is still pending.
--prepare refreshes ten public TS executions and oracle perturbations only.
Default deliberately returns INCOMPLETE until a real joined backend runner exists.
"""
import argparse, copy, hashlib, importlib.util, json
from pathlib import Path
HERE=Path(__file__).resolve().parent

def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
B=module('bounded_build',HERE.parent/'t05'/'run.py')
CMP=module('strict_trace',HERE/'trace-compare.py')
SCHEMAS=('Motion','Health')
LANES=('message','removed','despawned','unheld','marks')
PUBLIC=('schema','lane','capacity','invocations','rawReservationIds','dispatches','observations')

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def project(results):
    lanes={}
    for row in results:
        key=row['schema']+'/'+row['lane']
        if key in lanes:raise ValueError('duplicate lane '+key)
        if row.get('status')!='PASS' or row.get('firstDifference') is not None:
            raise ValueError('execution did not pass: '+key)
        if row['capacity']!=65536:raise ValueError('public capacity must remain 65536')
        lanes[key]={name:row[name] for name in PUBLIC}
    wanted={s+'/'+l for s in SCHEMAS for l in LANES}
    if lanes.keys()!=wanted:raise ValueError('requires all ten distinct public cases')
    return lanes

def word(value):
    if type(value) is not int or not 0 <= value <= 4294967295:
        raise ValueError('expected actual U32')
    return value

def exact(value,keys):
    if not isinstance(value,dict) or set(value)!=set(keys):
        raise ValueError('missing or unexpected compact field')

def interval(first,last,count):
    first,last,count=word(first),word(last),word(count)
    if count==0 or first+count-1!=last:
        raise ValueError('nonpositive, wrapped or inconsistent compact interval')
    return range(first,last+1)

def four(value):
    exact(value,('a','b','c','d'))
    return [word(value[k]) for k in ('a','b','c','d')]

def template_fields(schema,template):
    exact(template,('handle','main','aux','flag'))
    exact(template['handle'],('namespace','id'))
    word(template['handle']['namespace']);word(template['handle']['id'])
    main=template['main'];aux=template['aux'];flag=template['flag']
    if schema=='Motion':
        exact(main,('coordinates','frame'));cells=four(main['coordinates']);word(main['frame'])
        if aux is not None:
            exact(aux,('rates','moving'));four(aux['rates'])
            if type(aux['moving']) is not bool:raise ValueError('invalid actual moving Bool')
    elif schema=='Health':
        exact(main,('levels','reserve','class'));cells=four(main['levels']);word(main['reserve']);word(main['class'])
        if aux is not None:exact(aux,('layers','grade'));four(aux['layers']);word(aux['grade'])
    else:raise ValueError('unknown nominal schema')
    if flag is not None:exact(flag,('group',));word(flag['group'])
    return cells

def expand_rows(schema,value):
    if isinstance(value,list):
        for row in value:template_fields(schema,row)
        return value
    exact(value,('encoding','template','namespace','idFirst','idLast','xFirst','xLast','count','slot0'))
    if value['encoding']!='query-row-range':raise ValueError('nonrepresentable query rows')
    ids=interval(value['idFirst'],value['idLast'],value['count'])
    xs=interval(value['xFirst'],value['xLast'],value['count'])
    ns=word(value['namespace']);slot=value['slot0'];template=value['template']
    cells=template_fields(schema,template)
    if slot=={'mode':'x'}:constant=None
    else:exact(slot,('mode','value'));constant=word(slot['value'])
    if constant is not None and slot['mode']!='constant':raise ValueError('invalid slot0 rule')
    if value['xLast']>4294967292:raise ValueError('main cells would wrap')
    first0=value['xFirst'] if constant is None else constant
    if cells!=[first0,value['xFirst']+1,value['xFirst']+2,value['xFirst']+3]:
        raise ValueError('template is not actual first main value')
    if template['handle']!={'namespace':ns,'id':value['idFirst']}:
        raise ValueError('template is not actual first handle')
    field='coordinates' if schema=='Motion' else 'levels'
    result=[]
    for entity,x in zip(ids,xs):
        row=copy.deepcopy(template);row['handle']['id']=entity
        row['main'][field]=dict(zip(('a','b','c','d'),(x if constant is None else constant,x+1,x+2,x+3)))
        result.append(row)
    return result

def expand_handles(value):
    if isinstance(value,list):
        for handle in value:exact(handle,('namespace','id'));word(handle['namespace']);word(handle['id'])
        return value
    exact(value,('encoding','namespace','first','last','count'))
    if value['encoding']!='handle-range':raise ValueError('nonrepresentable handles')
    ns=word(value['namespace'])
    return [{'namespace':ns,'id':i} for i in interval(value['first'],value['last'],value['count'])]

def expand_messages(value):
    if isinstance(value,list):
        for item in value:exact(item,('code',));word(item['code'])
        return value
    exact(value,('encoding','first','last','count'))
    if value['encoding']!='inclusive-contiguous-range':raise ValueError('nonrepresentable messages')
    return [{'code':i} for i in interval(value['first'],value['last'],value['count'])]

def expand_read(schema,event):
    if event['kind']!='Read':return event
    result=copy.deepcopy(event)
    for key in ('query','added','changed'):result[key]=expand_rows(schema,event[key])
    for key in ('removed','despawned'):result[key]=expand_handles(event[key])
    result['messages']=expand_messages(event['messages'])
    return result

def compact_controls():
    # Small parser canaries only; these constructed Data values are not runtime evidence.
    first={'handle':{'namespace':9,'id':7},'main':{'coordinates':{'a':10,'b':11,'c':12,'d':13},'frame':19},
           'aux':{'rates':{'a':2,'b':3,'c':4,'d':5},'moving':False},'flag':{'group':23}}
    encoded={'encoding':'query-row-range','template':first,'namespace':9,'idFirst':7,'idLast':8,'xFirst':10,'xLast':11,'count':2,'slot0':{'mode':'x'}}
    actual=expand_rows('Motion',encoded)
    expected=copy.deepcopy(first);expected['handle']['id']=8;expected['main']['coordinates']={'a':11,'b':12,'c':13,'d':14}
    assert actual==[first,expected]
    constant=copy.deepcopy(encoded);constant['slot0']={'mode':'constant','value':41};constant['template']['main']['coordinates']['a']=41
    assert [r['main']['coordinates']['a'] for r in expand_rows('Motion',constant)]==[41,41]
    assert expand_rows('Motion',[])==[]
    health=copy.deepcopy(encoded)
    health['template']={'handle':{'namespace':9,'id':7},'main':{'levels':{'a':10,'b':11,'c':12,'d':13},'reserve':37,'class':41},'aux':None,'flag':None}
    health_rows=expand_rows('Health',health)
    assert health_rows[1]=={'handle':{'namespace':9,'id':8},'main':{'levels':{'a':11,'b':12,'c':13,'d':14},'reserve':37,'class':41},'aux':None,'flag':None}
    assert expand_handles({'encoding':'handle-range','namespace':9,'first':7,'last':8,'count':2})==[{'namespace':9,'id':7},{'namespace':9,'id':8}]
    assert expand_messages({'encoding':'inclusive-contiguous-range','first':7,'last':8,'count':2})==[{'code':7},{'code':8}]
    invalid=[]
    for name,edit in [
        ('inconsistent-count',lambda x:x.__setitem__('count',3)),
        ('wrong-first-handle',lambda x:x['template']['handle'].__setitem__('id',6)),
        ('wrong-first-main',lambda x:x['template']['main']['coordinates'].__setitem__('c',99)),
        ('invalid-slot-rule',lambda x:x.__setitem__('slot0',{'mode':'guessed'})),
        ('unrepresentable',lambda x:x.__setitem__('encoding','unrepresentable'))]:
        value=copy.deepcopy(encoded);edit(value)
        try:expand_rows('Motion',value)
        except (ValueError,KeyError) as error:invalid.append({'name':name,'rejected':str(error)})
        else:raise AssertionError(name)
    return {'status':'PARSER_CANARIES_ONLY','validated':'all metadata retained from nonfixture template values, full fields and constant slot0 reconstructed','negativeControls':invalid}

def perturbations(reference):
    tests=[]
    def expect(name,edit):
        candidate=copy.deepcopy(reference);edit(candidate)
        differences=CMP.difference(project(reference),project(candidate))
        assert differences,name
        tests.append({'name':name,'firstDifference':differences[0]})
    message=0;removed=1;marks=4
    expect('dropped-last-message',lambda r:r[message]['observations'][2]['messages'].__setitem__('last',65534))
    expect('wrong-full-payload-field',lambda r:r[removed]['observations'][2]['q']['payload'].__setitem__('frame',999))
    expect('wrong-last-row',lambda r:r[removed]['observations'][2]['q']['ids'].__setitem__('last',65536))
    expect('wrong-compared-row-count',lambda r:r[removed]['observations'][2]['q'].__setitem__('allMainAndAuxFieldsCompared',65536))
    expect('lost-old-surviving-marks',lambda r:r[marks]['observations'][-1].__setitem__('changed',{}))
    expect('incorrect-lag',lambda r:r[message]['observations'][-1]['lag'].__setitem__('messages',True))
    expect('wrong-base-invocation-count',lambda r:r[message]['invocations'].__setitem__('B',3))
    expect('dropped-reader-dispatch',lambda r:r[message]['observations'].pop())
    expect('wrong-failure-code',lambda r:r[message]['dispatches'][7]['result']['error']['error'].__setitem__('code',999))
    for name,rows in [('missing-lane',reference[:-1]),('duplicate-lane',reference+[reference[0]])]:
        try:project(rows)
        except ValueError as error:tests.append({'name':name,'rejected':str(error)})
        else:raise AssertionError(name)
    return tests

def prepare():
    source=HERE.parent/'s-integrate-trace'/'reference-retention.mjs'
    checked=B.command([B.CHECK,HERE/'host-retention-controls.bend','--check-only'])
    assert 'ALL PROOFS CHECK' in checked
    results=[]
    for schema in SCHEMAS:
        for lane in LANES:
            result=json.loads(B.command(['node',source,schema,lane]))
            assert result['status']=='PASS',result
            results.append(result);print('fresh public reference '+schema+'/'+lane+': PASS',flush=True)
    project(results)
    controls=perturbations(results)
    evidence={'status':'PREPARATION_ONLY','actualJoinedBendExecuted':False,
      'pending':'Actual parameterized Host invocation and D.tick binding; no E11 runtime gate claimed',
      'limits':{'checkerSeconds':5,'referenceExecutionSeconds':5},
      'versions':{'bend':B.command(['bend','version']),'node':B.command(['node','--version'])},
      'sha256':{p.name:sha(p) for p in [source,HERE/'host-retention-controls.bend',HERE/'host-retention-run.py',HERE/'HOST-RETENTION-LAWS-DRAFT.md',HERE/'trace-compare.py']},
      'inputCheck':checked,'publicReference':results,'oraclePerturbations':controls,'compactDecoderControls':compact_controls()}
    (HERE/'host-retention-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    print('PREPARATION_ONLY: ten source runs and eleven comparator controls; actual joined backend binding pending')

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--prepare',action='store_true')
    args=parser.parse_args()
    if args.prepare:prepare();return 0
    print(json.dumps({'status':'INCOMPLETE','reason':'Real parameterized Host + D.tick binding not delivered; --prepare is oracle preparation only'}));return 2
if __name__=='__main__':raise SystemExit(main())
