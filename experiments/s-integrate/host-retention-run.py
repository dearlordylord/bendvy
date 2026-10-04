#!/usr/bin/env python3
"""Actual E11 D.tick retention comparison against ten fresh public TS runs.
--prepare runs source/decoder preparation only; default builds both actual backends.
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

# Strict joined comparison: every decoded row and ordered element is checked.
DEC=module('e11_representation',HERE/'trace-decode.py')

def seq(value):
    if isinstance(value,list):return value
    exact(value,('encoding','first','last','count'))
    if value['encoding']!='inclusive-contiguous-range':raise ValueError('unknown source sequence')
    return list(interval(value['first'],value['last'],value['count']))

def same(actual,expected,label):
    if actual!=expected:
        raise AssertionError(label+': '+str(CMP.difference(expected,actual)[:1]))

def source_rows(schema,description):
    ids=seq(description['ids']);xs=seq(description['payloadParameterX'])
    same(len(ids),len(xs),'source row parameters')
    same(len(ids),description['allMainAndAuxFieldsCompared'],'source compared count')
    field='coordinates' if schema=='Motion' else 'levels'
    for entity,x in zip(ids,xs):
        main=copy.deepcopy(description['payload'])
        same(main[field],'[x,x+1,x+2,x+3]','source row formula')
        main[field]=[x if description['currentSlot0'] is None else description['currentSlot0'],x+1,x+2,x+3]
        yield {'id':entity,'main':main,'aux':description['aux'],'flag':description['flag']}

def compare_joined(text,reference):
    events=[json.loads(line) for line in text.splitlines()]
    schema=reference['schema'];lane=reference['lane']
    same(events[0],{'kind':'Lane','schema':schema,'lane':lane},'lane identity')
    reservation=events[1];exact(reservation,('kind','namespace','first','last','count'))
    same(reservation['kind'],'Reservations','actual reservation event')
    ns=word(reservation['namespace'])
    ids=[] if reservation['count']==0 else list(interval(reservation['first'],reservation['last'],reservation['count']))
    same(ids,seq(reference['rawReservationIds']),'actual factory reservation sequence')
    def local(h):
        exact(h,('namespace','id'));same(h['namespace'],ns,'local nominal handle namespace')
        value=word(h['id'])
        if not ids or not ids[0]<=value<=ids[-1]:raise ValueError('handle was not actually reserved')
        return value
    reads=[e for e in events[2:] if e['kind']=='Read'];done=[e for e in events[2:] if e['kind']=='ReadDone']
    dispatch=[e for e in events[2:] if e['kind']=='Dispatch']
    if any(e['kind'] not in ('Read','ReadDone','Dispatch') for e in events[2:]):raise ValueError('unexpected E11 event')
    same(len(reads),len(reference['observations']),'complete reader invocation count')
    same(len(done),len(reads),'complete reader result count')
    summaries=[];completed={}
    for read,end,expected in zip(reads,done,reference['observations']):
        key=(read['step'],read['system']);same(key,(expected['label'],expected['name']),'reader identity')
        same((end['step'],end['system']),key,'actual completion identity')
        same(read['count'],expected['invocation'],'persistent actual base capture')
        for actual_name,source_name in [('query','q'),('added','added'),('changed','changed')]:
            rows=expand_rows(schema,read[actual_name]);want=expected[source_name]
            same(len(rows),want['allMainAndAuxFieldsCompared'],key[0]+'/'+actual_name+' count')
            for index,(row,wanted) in enumerate(zip(rows,source_rows(schema,want))):
                actual=DEC.representation(row);actual['id']=local(actual.pop('handle'))
                same(actual,wanted,key[0]+'/'+actual_name+'/'+str(index))
        for field in ('removed','despawned'):
            same([local(h) for h in expand_handles(read[field])],seq(expected[field]),key[0]+'/'+field)
        same([p['code'] for p in expand_messages(read['messages'])],seq(expected['messages']),key[0]+'/messages')
        lag={key:read[value] for key,value in [('removed','removedLag'),('despawned','despawnedLag'),('messages','messageLag')]}
        same(lag,expected['lag'],'actual reader lag')
        same(lag,{key:end[value] for key,value in [('removed','removedLag'),('despawned','despawnedLag'),('messages','messageLag')]},'read completion lag')
        missed=[]
        if lag['messages']:missed.append({'kind':'event','stream':schema+'Ping'})
        if lag['removed']:missed.append({'kind':'removed','stream':'Position' if schema=='Motion' else 'Vitals'})
        if lag['despawned']:missed.append({'kind':'despawned','stream':'despawned'})
        failed=end['outcome']['kind']=='Failure'
        same(end['outcome'],{'kind':'Failure','code':7} if expected['attemptFails'] else {'kind':'Success'},'actual completion result')
        trace={'system':end['system'],'frame':end['frame'],'tick':end['tick'],'outcome':'failed' if failed else 'ok','missed':missed}
        same(trace,expected['publicDispatcherTrace'],'public dispatcher diagnostic')
        same(read['boundary'],{'since':completed.get(key[1],0),'streamSince':completed.get(key[1],0),'thisRun':end['tick']},'actual Run boundaries from prior successful source dispatch')
        if not failed:completed[key[1]]=end['tick']
        summaries.append({'step':key[0],'system':key[1],'count':read['count'],'boundary':read['boundary'],'trace':trace,'fullRowsCompared':{k:expected[v]['allMainAndAuxFieldsCompared'] for k,v in [('query','q'),('added','added'),('changed','changed')]},'lag':lag})
    same([{'name':d['step'],'result':DEC.outcome(d['outcome'])} for d in dispatch],reference['dispatches'],'all dispatch results')
    counts={entry['system']:four(entry['value'])[0] for entry in dispatch[-1]['counts'] if entry['system']!='Batch' and four(entry['value'])[0]!=0}
    same(counts,reference['invocations'],'final actual base captures')
    # Event sequence retains success/failure and the single emitted diagnostic before each dispatch.
    cursor=2
    for d in dispatch:
        expected_kinds=['Read','ReadDone','Dispatch'] if any(o['label']==d['step'] for o in reference['observations']) else ['Dispatch']
        same([e['kind'] for e in events[cursor:cursor+len(expected_kinds)]],expected_kinds,'ordered actual dispatch events')
        cursor+=len(expected_kinds)
    same(cursor,len(events),'no trailing events')
    return {'schema':schema,'lane':lane,'status':'PASS','rawBytes':len(text.encode()),'rawSha256':hashlib.sha256(text.encode()).hexdigest(),'reservations':reservation,'observations':summaries,'dispatches':dispatch}

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

COMPARISON_FUNCTIONS=('word','exact','interval','four','template_fields','expand_rows','expand_handles','expand_messages','expand_read','seq','same','source_rows','compare_joined')
def comparison_fingerprint(source=None,helpers=None):
    import ast
    source=(HERE/'host-retention-run.py').read_text() if source is None else source
    functions={node.name:ast.get_source_segment(source,node) for node in ast.parse(source).body if isinstance(node,ast.FunctionDef)}
    selected={name:functions[name] for name in COMPARISON_FUNCTIONS}
    selected['helpers']=helpers if helpers is not None else {name:sha(HERE/name) for name in ('trace-compare.py','trace-decode.py')}
    return hashlib.sha256(json.dumps(selected,sort_keys=True).encode()).hexdigest()

def source_closure():
    import re
    seen={}
    def visit(path):
        path=path.resolve()
        if path in seen:return
        text=path.read_text();seen[path]=sha(path)
        for dependency in re.findall(r'^import (\.[^\s]+)',text,re.M):visit(path.parent/dependency)
    visit(HERE/'host-retention-controls.bend')
    return {str(p.relative_to(HERE.parent.parent)):value for p,value in seen.items()}

def joined():
    import tempfile,time,os
    source=HERE.parent/'s-integrate-trace'/'reference-retention.mjs'
    frozen=source_closure();runner_sha=sha(HERE/'host-retention-run.py');comparison_sha=comparison_fingerprint()
    evidence={'status':'INCOMPLETE','actualJoinedBendExecuted':False,'productionAcceptance':False,
      'limits':{'checkerSeconds':5,'runtimeSeconds':5,'referenceSeconds':5,'codegenSeconds':30,'nativeCompilationSeconds':120},
      'cpuAffinity':sorted(os.sched_getaffinity(0)) if hasattr(os,'sched_getaffinity') else None,
      'versions':{'bend':B.command(['bend','version']),'node':B.command(['node','--version'])},
      'sourceClosure':frozen,'referenceSha256':sha(source),'runnerSha256':runner_sha,'comparisonSha256':comparison_sha,
      'publicReference':[],'actual':[],'failures':[],
      'compactDecoderControls':compact_controls(),
      'semanticMutants':{'status':'PENDING','reason':'Full original ten-case gate must pass first'}}
    def save():
        (HERE/'host-retention-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    save()
    with tempfile.TemporaryDirectory(prefix='e11-joined-') as temporary:
        try:programs=B.build(HERE/'host-retention-controls.bend',Path(temporary))
        except Exception as error:
            evidence['failures'].append({'backend':'Build','error':str(error)[:2000]});save();raise
        for schema_index,schema in enumerate(SCHEMAS):
            for lane_index,lane in enumerate(LANES):
                try:
                    reference=json.loads(B.command(['node',source,schema,lane]))
                    assert reference['status']=='PASS',reference
                except Exception as error:
                    evidence['failures'].append({'schema':schema,'lane':lane,'backend':'TypeScript','error':str(error)[:2000]})
                    save();print(schema+'/'+lane+' TypeScript: FAIL '+str(error)[:200],flush=True);continue
                evidence['publicReference'].append(reference);save()
                outputs=[]
                for backend,program in zip(('Native','JavaScript'),programs):
                    started=time.monotonic()
                    try:
                        text=B.execute(program,[str(schema_index),str(lane_index)])
                        seconds=time.monotonic()-started
                        result=compare_joined(text,reference)
                        result.update(backend=backend,executionSeconds=seconds)
                        evidence['actual'].append(result);outputs.append(text)
                        evidence['actualJoinedBendExecuted']=True
                        print(schema+'/'+lane+' '+backend+': PASS',flush=True)
                    except Exception as error:
                        evidence['failures'].append({'schema':schema,'lane':lane,'backend':backend,'error':str(error)[:2000]})
                        print(schema+'/'+lane+' '+backend+': FAIL '+str(error)[:200],flush=True)
                    save()
                if len(outputs)==2:same(outputs[0],outputs[1],'exact Native/JS output')
    same(source_closure(),frozen,'unchanged executed source closure')
    same(comparison_fingerprint(),comparison_sha,'unchanged executed comparator helpers')
    same(sha(HERE/'host-retention-run.py'),runner_sha,'unchanged running comparator')
    if len(evidence['publicReference'])==10:
        project(evidence['publicReference'])
        evidence['oraclePerturbations']=perturbations(evidence['publicReference'])
    if not evidence['failures'] and len(evidence['actual'])==20:
        evidence['status']='JOINED_EXECUTION_PASS_MUTANTS_PENDING'
    save();print(evidence['status'],flush=True)
    return 0 if evidence['status']=='JOINED_EXECUTION_PASS_MUTANTS_PENDING' else 2

def wrapper_types(root):
    prefix='import Base\nimport '+str(HERE/'host-batch-invoker.bend')+' as B\nimport '+str(HERE/'host.bend')+' as H\nimport '+str(HERE/'dispatcher.bend')+' as D\n'
    cases=[
      ('positive','def probe(owner:B.Batch<H.MotionHost()>) -> B.Batch<H.MotionHost()> & D.Presence:\n  B.motion_presence(owner)\n',0),
      ('schema-negative','def probe(owner:B.Batch<H.HealthHost()>) -> B.Batch<H.MotionHost()> & D.Presence:\n  B.motion_presence(owner)\n',1),
      ('affine-negative','def probe(owner:B.Batch<H.MotionHost()>) -> (B.Batch<H.MotionHost()> & D.Presence) & (B.Batch<H.MotionHost()> & D.Presence):\n  (B.motion_presence(owner),B.motion_presence(owner))\n',1)]
    results=[]
    for name,body,expected in cases:
        path=root/(name+'.bend');path.write_text(prefix+body)
        out=B.command([B.CHECK,path,'--check-only'],expected=expected)
        assert ('ALL PROOFS CHECK' if expected==0 else 'SOME PROOFS FAIL') in out,out
        if name=='schema-negative':assert 'HealthSchema' in out and 'MotionSchema' in out,out
        if name=='affine-negative':assert 'consumed more than once' in out,out
        results.append({'name':name,'body':body,'exit':expected,'diagnostic':out})
    return results

def mutation_cases():
    return [
      ('failure-advances-same-reader','readers.bend','case T.Failure{_}: readers','case T.Failure{_}: completed(readers,run)',1,'message'),
      ('completion-overwrites-other-readers','readers.bend','replace_case(U32.is_eq(key,id)','replace_case(True{}',1,'message'),
      ('registration-ignored','streams.bend','maximum(since,registered)','since',2,'message'),
      ('holders-ignored','streams.bend','minimum(window,head)','window',1,'message'),
      ('whole-tick-lifecycle-drop','streams.bend','Bool.or(U32.is_le(tick,window),U32.is_gt(size,capacity))','Bool.or(U32.is_le(tick,window),Bool.or(U32.is_gt(size,capacity),U32.is_eq(tick,dropped)))',1,'removed'),
      ('old-live-marks-erased','host.bend','U32.is_le(tick,thisRun)','U32.is_eq(tick,thisRun)',1,'marks'),
      ('full-payload-cell-corrupted','host-batch-invoker.bend','T.Position{F.vector(x),7}','T.Position{F.vector(U32.add(x,1)),7}',1,'marks'),
      ('reader-dispatch-dropped','host-retention-controls.bend','case B.RetRead{who,fails} _: K.Call{actor(who,actors),read_mode(fails)}','case B.RetRead{who,fails} _: K.Nested{[]}',1,'marks'),
      ('publication-batch-split','streams.bend',None,None,None,'message'),
      ('main-slot3-only-corrupted','host-batch-invoker.bend','T.Position{F.vector(x),7}','T.Position{Array.set(U32,F.vector(x),3,99),7}',1,'marks')]

def mutants():
    import tempfile,time
    evidence=json.loads((HERE/'host-retention-evidence.json').read_text())
    if evidence['status'] not in ('JOINED_EXECUTION_PASS_MUTANTS_PENDING','BOUNDED_JOINED_PASS') or len(evidence['actual'])!=20:
        raise ValueError('all ten unchanged cases must pass both actual backends first')
    same(comparison_fingerprint(),evidence['comparisonSha256'],'unchanged comparator and decoder for resumed evidence')
    same(sha(HERE.parent/'s-integrate-trace/reference-retention.mjs'),evidence['referenceSha256'],'unchanged independent source adapter')
    repository=HERE.parent.parent
    for name,value in evidence['sourceClosure'].items():same(sha(repository/name),value,'unchanged original closure '+name)
    prior={r['name']:r for r in evidence.get('semanticMutants',{}).get('results',[])}
    prior_runner=evidence.get('mutantRunnerSha256',evidence.get('runnerSha256'))
    results=[]
    evidence['status']='JOINED_EXECUTION_PASS_MUTANTS_PENDING'
    (HERE/'host-retention-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    with tempfile.TemporaryDirectory(prefix='e11-mutants-') as temporary:
        evidence['typeControls']=wrapper_types(Path(temporary))
        for name,file,old,new,count,lane in mutation_cases():
            root=Path(temporary)/name
            for source in evidence['sourceClosure']:
                target=root/source;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes((repository/source).read_bytes())
            subject=root/'experiments/s-integrate'/file
            content=subject.read_text()
            if old is not None:
                same(content.count(old),count,name+' mutation occurrence count')
                changed=content.replace(old,new)
            else:
                start=content.index('def append(-P:');end=content.index('def append_units(',start)
                append=content[start:end].replace('append_buffer(P,buffer,tick,values)','append_units(P,values,tick,buffer)')
                changed=content[:start]+content[end:];index=changed.index('def append_lifecycle(')
                changed=changed[:index]+append+changed[index:]
            subject.write_text(changed)
            if name in prior:
                saved=prior[name]
                same(saved['originalSha256'],hashlib.sha256(content.encode()).hexdigest(),name+' original subject')
                same(saved['mutantSha256'],sha(subject),name+' exact resumed mutation')
                same(saved['input'],{'schema':'Motion','lane':lane},name+' exact resumed input')
                same(saved['checkerAndBothBuilds'],'PASS',name+' resumed build gate')
                same([r['backend'] for r in saved['runs']],['Native','JavaScript'],name+' resumed backends')
                saved.setdefault('runnerSha256',prior_runner);results.append(saved)
                print('retained verified unchanged mutant: '+name,flush=True);continue
            programs=B.build(root/'experiments/s-integrate/host-retention-controls.bend',root)
            expected=next(r for r in evidence['publicReference'] if r['schema']=='Motion' and r['lane']==lane)
            runs=[];outputs=[]
            for backend,program in zip(('Native','JavaScript'),programs):
                started=time.monotonic();text=B.execute(program,['0',str(LANES.index(lane))]);elapsed=time.monotonic()-started
                try:compare_joined(text,expected)
                except (AssertionError,ValueError,KeyError) as error:
                    runs.append({'backend':backend,'executionSeconds':elapsed,'difference':str(error)[:1200],
                      'rawSha256':hashlib.sha256(text.encode()).hexdigest(),'rawBytes':len(text.encode())})
                else:raise AssertionError('compiling semantic mutant survived: '+name+'/'+backend)
                outputs.append(text)
            same(outputs[0],outputs[1],name+' Native/JS mutant output')
            result={'name':name,'subject':file,'originalSha256':hashlib.sha256(content.encode()).hexdigest(),
              'mutantSha256':sha(subject),'old':old,'new':new,'changedOccurrences':count,
              'operation':'split actual publication into single-value batches' if old is None else 'exact string replacement',
              'input':{'schema':'Motion','lane':lane},'checkerAndBothBuilds':'PASS','runs':runs,'runnerSha256':sha(HERE/'host-retention-run.py')}
            if name=='main-slot3-only-corrupted':
                result['actualRejection']=[{'step':event['step'],'query':event['query']} for event in map(json.loads,outputs[0].splitlines()) if event['kind']=='Read' and isinstance(event['query'],dict) and event['query'].get('encoding')=='unrepresentable']
            results.append(result)
            print('compiling actual joined mutant detected: '+name,flush=True)
            evidence['semanticMutants']={'status':'RUNNING','results':results}
            (HERE/'host-retention-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    evidence['semanticMutants']={'status':'PASS','results':results}
    evidence['status']='BOUNDED_JOINED_PASS';evidence['mutantRunnerSha256']=sha(HERE/'host-retention-run.py')
    (HERE/'host-retention-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
    return 0

def main():
    import os
    if os.environ.get('BENDVY_CPU') and hasattr(os,'sched_setaffinity'):
        os.sched_setaffinity(0,{int(os.environ['BENDVY_CPU'])})
    parser=argparse.ArgumentParser(description=__doc__)
    options=parser.add_mutually_exclusive_group()
    options.add_argument('--prepare',action='store_true')
    options.add_argument('--joined-only',action='store_true',help='diagnostic original cases; leaves semantic mutation gate pending')
    options.add_argument('--mutants',action='store_true',help='resume semantic mutants only against an unchanged passing original closure')
    args=parser.parse_args()
    if args.prepare:prepare();return 0
    if args.mutants:return mutants()
    result=joined()
    if result or args.joined_only:return result
    return mutants()
if __name__=='__main__':raise SystemExit(main())
