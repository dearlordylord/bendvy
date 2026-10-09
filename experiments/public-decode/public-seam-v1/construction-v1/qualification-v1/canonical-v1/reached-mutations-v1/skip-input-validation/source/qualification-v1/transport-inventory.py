"""Closed source-nominal inventories; full constructor observations, no defaults."""
from pathlib import Path
import os
import re

INPUT_LABELS=("success","parseRefusal","wrongKind","downstreamRefusal","failure","skip")

def module_at(file,alias):
    match=re.search(r"^import (\S+) as "+re.escape(alias)+r"$",Path(file).read_text(),re.M)
    assert match, (file,alias)
    return (Path(file).parent/match[1]).resolve()

GROUPS = [('initial', ('constructed','rejected','handle','foreign','resource','invalidResource','abortedResource')),
          ('custom', ('constructorDenied','decoderRefused')),
          ('request', ('spawnAbort','foreignInsert','invalidSpawn')),
          ('materialization', ('spawn','insert','failure','failedInsert','invalid','lateMissing','skip')),
          ('raw-resource', ('success','refused','abort'))]

def record(value, tag, keys):
    assert type(value) is dict and set(value)=={'$',*keys} and value['$']==tag

def pack(models, role):
    if role=='input-codec-spine':
        record(models,'Candidate',('first','second'))
        items=[]
        for schema in ('First','Second'):
            cohort=models[schema.lower()];record(cohort,'Cases',INPUT_LABELS)
            items += [{'$':schema,'label':label,'value':cohort[label]} for label in INPUT_LABELS]
        assert len(items)==12
        return items
    if role=='completion-spine':
        assert set(models)=={'materialization','admission'}
        record(models['materialization'],'Candidate',('first','second'))
        record(models['admission'],'Candidate',('first','second'))
        items=[]
        for schema in ('First','Second'):
            cohort=models['materialization'][schema.lower()];record(cohort,'Cases',GROUPS[3][1])
            items += [{'$':'Material'+schema,'label':label,'value':cohort[label]} for label in GROUPS[3][1]]
        items += [{'$':'Admission'+schema,'value':models['admission'][schema.lower()]} for schema in ('First','Second')]
        assert len(items)==16
        return items
    if role=='construction-spine':
        assert set(models)=={group for group,_ in GROUPS}
        items=[]
        for group, labels in GROUPS:
            model=models[group];record(model,'Candidate',('first','second'))
            for schema in ('First','Second'):
                cohort=model[schema.lower()];record(cohort,'Cases',labels)
                for label in labels:
                    if group=='initial':tag='Constructed' if label in labels[:4] else 'ValidatedResource'
                    else:tag={'custom':'CustomError','request':'OwnedRequest','materialization':'Material'+schema,'raw-resource':'ConstructedResource'}[group]
                    item={'$':tag,'label':label,'value':cohort[label]}
                    if group!='materialization':item['schema']=schema
                    items.append(item)
        assert len(items)==44
        return items
    assert role=='custom-spine'
    assert set(models)=={'request','resource','refusal'}
    items=[]
    for group,labels,tag in [('request',('spawnAbort','constructorDenied','foreignInsert','invalidSpawn'),'OwnedRequest'),('resource',('success','denied','refused','abort'),'ResourceWrite')]:
        model=models[group];record(model,'Candidate',('first','second'))
        for schema in ('First','Second'):
            cohort=model[schema.lower()];record(cohort,'Cases',labels)
            items += [{'$':tag,'schema':schema,'label':label,'value':cohort[label]} for label in labels]
    model=models['refusal'];record(model,'Candidate',('foreignFirst','missingRegistrationFirst','foreignSecond','missingRegistrationSecond'))
    for schema in ('First','Second'):
        items += [{'$':'Refusal'+schema,'label':label,'value':model[key+schema]} for label,key in [('foreign','foreign'),('missingRegistration','missingRegistration')]]
    assert len(items)==20
    return items

def unpack(items, role):
    if role=='input-codec-spine':
        assert type(items) is list and len(items)==12
        model={'$':'Candidate'};position=0
        for schema in ('First','Second'):
            model[schema.lower()]={'$':'Cases'}
            for label in INPUT_LABELS:
                model[schema.lower()][label]=items[position]['value'];position+=1
        assert pack(model,role)==items
        return model
    assert type(items) is list and len(items)=={'construction-spine':44,'custom-spine':20,'completion-spine':16}[role]
    if role=='completion-spine':
        models={'materialization':{'$':'Candidate'},'admission':{'$':'Candidate'}};position=0
        for schema in ('First','Second'):
            cohort={'$':'Cases'}
            for label in GROUPS[3][1]:cohort[label]=items[position]['value'];position+=1
            models['materialization'][schema.lower()]=cohort
        for schema in ('First','Second'):models['admission'][schema.lower()]=items[position]['value'];position+=1
        assert position==16 and pack(models,role)==items
        return models
    position=0; models={}
    groups=GROUPS if role=='construction-spine' else [('request',('spawnAbort','constructorDenied','foreignInsert','invalidSpawn')),('resource',('success','denied','refused','abort'))]
    for group, labels in groups:
        model={'$':'Candidate'}
        for schema in ('First','Second'):
            cohort={'$':'Cases'}
            for label in labels:
                cohort[label]=items[position]['value'];position+=1
            model[schema.lower()]=cohort
        models[group]=model
    if role=='custom-spine':
        models['refusal']={'$':'Candidate'}
        for schema in ('First','Second'):
            for key in ('foreign','missingRegistration'):
                models['refusal'][key+schema]=items[position]['value'];position+=1
    # Strict one-to-one ordering, labels, schema and exact fields; no projection.
    assert position==len(items) and pack(models,role)==items
    return models

def inventory(entry, base, role):
    entry=Path(entry).resolve(); home=entry.parent.parent
    if role=='input-codec-spine':return input_codec_inventory(entry,base)
    assert role in ('construction-spine','custom-spine','completion-spine')
    root=base.ROOT; src=root/'src/ecs'; t={}; fields=lambda **kw:list(kw.items())
    maybe=lambda value:('Base',{'None':[],'Some':[('value',value)]})
    def define(key,module,variants):t[key]=(str(module),variants)
    def one(key,module,tag,**kw):define(key,module,{tag:fields(**kw)})
    define('Unit','Base',{'Unit':[]})
    d=src/'decode-data.bend'; w=src/'world.bend'; c=module_at(home/'fixture.bend','Constructor'); i=home/'fixture.bend'; m=home/('completion-addon-v1/materialization-fixture.bend' if role=='completion-spine' else 'materialization-v1/fixture.bend')
    one('Handle',w,'Handle',namespace='U32',id='U32')
    define('WorldError',w,{tag:[] for tag in ('MissingEntity','CapacityExceeded','NamespaceExhausted','SystemIdExhausted')})
    one('Registration',w,'RegistrationMeta',id='U32',name='String',access=['String'])
    one('Stamp',src/'lifecycle.bend','Stamp',added='U32',changed='U32');one('Entry',src/'lifecycle.bend','Entry',id='U32',stamp='Stamp')
    define('Raw',d,{'Missing':[],'Null':[],'Number':fields(value='U32'),'SignedInteger':fields(negative='Bool',magnitude='Nat'),'Float':fields(value='F32'),'Binary64':fields(high='U32',low='U32'),'Text':fields(value='String'),'Utf16Text':fields(units=['U32']),'Boolean':fields(value='Bool'),'Handle':fields(namespace='U32',id='U32'),'Array':fields(items=['Raw']),'Object':fields(fields=['Field'])})
    one('Field',d,'Field',name='String',value='Raw')
    define('DecodeError',d,{'Invalid':fields(path='String',expected='String',actual='Raw'),'FuelExhausted':fields(path='String')})
    define('RequestError',src/'decode-requests.bend',{'Validation':fields(error='DecodeError'),'Entity':fields(error='WorldError')})
    define('Outcome',src/'transaction.bend',{'Success':[],'Failure':fields(error='Unit')})
    define('Operation',src/'bundle-requests.bend',{'Spawn':[],'Insert':fields(target='Handle')})
    one('Input',i,'InputView',raw='Raw',words=['U32'],flags=['Bool'])
    one('Owner',i,'View',raw='Raw',original='Raw',words=['U32'],flags=['Bool'])
    one('Meta',i,'Meta',namespace='U32',nextId='U32',highWater='U32',capacity='U32',depth='Nat',events=['Unit'],registrations=['Registration'],nextSystemId='U32',clock='U32')
    one('Snapshot',i,'Snapshot',meta='Meta',live=['Bool'],store='Unit',resource='Owner',pending='U32')
    define('Constructed',i,{'Constructed':fields(owner='Owner',recovered='Input'),'Rejected':fields(input='Input',error='DecodeError')})
    define('ResourceResult',i,{'Replaced':fields(canonical='Raw'),'Refused':fields(owner='Owner',error='DecodeError')})
    define('ResourceReport',i,{'ResourceReport':fields(before='Snapshot',after='Snapshot',result='ResourceResult',outcome='Outcome',pending='U32',undoCount='Nat'),'CreateRefused':[]})
    one('Packet',m,'PacketView',owner=maybe('Owner'),original='Raw',canonical='Raw')
    one('Mail',m,'MailView',value='Owner',retired=['Owner'],returned=['Packet'],errors=['WorldError'])
    one('Column',m,'ColumnView',supported='Bool',slots=[maybe('Owner')],stamps=['Entry'])
    one('MaterialSnapshot',m,'Snapshot',meta='Meta',live=['Bool'],column='Column',mail='Mail',pending='U32')
    material_error='RequestError'
    if role=='completion-spine':
        one('BusinessCustom',home/'fallible-composition-v1/business.bend','Denied',code='U32')
        define('BusinessConstructorError',c,{'Validation':fields(error='DecodeError'),'Constructor':fields(error='BusinessCustom')})
        define('BusinessRequestError',module_at(home/'fallible-composition-v1/request-fixture.bend','Constructed'),{'Construction':fields(error='BusinessConstructorError'),'Operation':fields(error='RequestError')})
        material_error='BusinessRequestError'
    define('MaterialOperation',m,{'Accepted':fields(target='Handle',spawned='Bool',canonical='Raw',undoAvailable='Bool'),'Refused':fields(owner=maybe('Input'),error=material_error)})
    one('Recovery',m,'RecoveryView',output='MaterialOperation',packets=['Packet'])
    one('Instance',m,'InstanceView',namespace='U32',id='U32',name='String',access=['String'],recoveries=['Recovery'])
    define('MaterialResult',m,{'Completed':fields(output='MaterialOperation'),'Failed':fields(error='Unit'),'Skipped':fields(input='Input'),'RefusedInvocation':[],'Unavailable':[]})
    define('MaterialReport',m,{'Report':fields(before='MaterialSnapshot',committed='MaterialSnapshot',barrier='MaterialSnapshot',instance='Instance',result='MaterialResult'),'SetupRefused':[]})
    custom=home/'custom-fixture.bend' if role=='construction-spine' else home/'fallible-composition-v1/business.bend'
    one('Custom',custom,'Denied',code='U32')
    define('ConstructorError',c,{'Validation':fields(error='DecodeError'),'Constructor':fields(error='Custom')})
    one('CustomReport',home/'custom-fixture.bend','Refused',owner='Input',error='ConstructorError');t['CustomReport'][1]['UnexpectedConstructed']=[]
    q=home/'request-fixture.bend' if role=='construction-spine' else home/'fallible-composition-v1/request-fixture.bend'
    r=home/'raw-resource-fixture.bend' if role=='construction-spine' else home/'fallible-composition-v1/resource-fixture.bend'
    qe='RequestError'; re='DecodeError'
    if role=='custom-spine':
        define('ComposedRequestError',module_at(home/'fallible-composition-v1/request-fixture.bend','Constructed'),{'Construction':fields(error='ConstructorError'),'Operation':fields(error='RequestError')});qe='ComposedRequestError'
        define('ComposedResourceError',module_at(home/'fallible-composition-v1/resource-fixture.bend','Constructed'),{'Construction':fields(error='ConstructorError'),'Admission':fields(error='DecodeError')});re='ComposedResourceError'
    define('RequestResult',q,{'Accepted':fields(namespace='U32',id='U32',spawned='Bool',canonical='Raw'),'Refused':fields(owner=maybe('Input'),error=qe)})
    define('RequestReport',q,{'Report':fields(after='Snapshot',prepared='Nat',result='RequestResult',recovered=['Input'],completion='Outcome'),'CreateRejected':[]})
    define('RawResourceResult',r,{'Replaced':fields(canonical='Raw',undoAvailable='Bool'),'Refused':fields(owner='Input',error=re)})
    define('RawResourceReport',r,{'Report':fields(before='Snapshot',after='Snapshot',result='RawResourceResult',completion='Outcome'),'CreateRefused':[]})
    if role=='completion-spine':
        a=home/'completion-addon-v1/resource-admission-fixture.bend'
        one('BadCustom',home/'completion-addon-v1/bad-business.bend','Denied',code='U32')
        define('BadConstructorError',c,{'Validation':fields(error='DecodeError'),'Constructor':fields(error='BadCustom')})
        define('BadResourceError',module_at(home/'fallible-composition-v1/resource-fixture.bend','Constructed'),{'Construction':fields(error='BadConstructorError'),'Admission':fields(error='DecodeError')})
        define('AdmissionResult',a,{'Replaced':fields(canonical='Raw',undoAvailable='Bool'),'Refused':fields(owner='Input',error='BadResourceError')})
        define('Codec',d,{'FiniteNumber':[],'Integer':[],'StringValue':[],'BoolValue':[],'Literal':fields(value='Raw'),'LiteralValues':fields(values=['Raw']),'LiteralRendered':fields(values=['Raw'],expected='String'),'Nullable':fields(inner='Codec'),'ArrayValue':fields(inner='Codec'),'Struct':fields(fields=['NamedCodec']),'HandleValue':fields(namespace='U32')})
        one('NamedCodec',d,'NamedCodec',name='String',codec='Codec')
        define('Frame',a,{'EmptyFrame':fields(world='Snapshot',codec='Codec',handle='Handle',error=maybe('WorldError'),cursor='U32'),'NonemptyFrame':[]})
        define('AdmissionReport',a,{'Report':fields(before='Snapshot',after='Snapshot',frameBefore='Frame',frameAfter='Frame',result='AdmissionResult',completion='Outcome'),'CreateRefused':[]})
        variants={tag:fields(label='String',value='MaterialReport') for tag in ('MaterialFirst','MaterialSecond')}
        variants.update({tag:fields(value='AdmissionReport') for tag in ('AdmissionFirst','AdmissionSecond')})
    elif role=='construction-spine':
        variants={tag:fields(schema='String',label='String',value=typ) for tag,typ in [('Constructed','Constructed'),('ValidatedResource','ResourceReport'),('CustomError','CustomReport'),('OwnedRequest','RequestReport'),('ConstructedResource','RawResourceReport')]}
        variants.update({tag:fields(label='String',value='MaterialReport') for tag in ('MaterialFirst','MaterialSecond')})
    else:
        rf=home/'fallible-composition-v1/local-refusal-fixture.bend'
        one('Args',rf,'ArgsView',operation='Operation',input='Input',fail='Bool')
        define('RefusalReport',rf,{'Refused':fields(primaryBefore='MaterialSnapshot',primaryAfter='MaterialSnapshot',suppliedBefore='MaterialSnapshot',suppliedAfter='MaterialSnapshot',instanceBefore='Instance',instanceAfter='Instance',incoming='Args',returned='Args'),'UnexpectedCompleted':[],'SetupRefused':[]})
        variants={tag:fields(schema='String',label='String',value=typ) for tag,typ in [('OwnedRequest','RequestReport'),('ResourceWrite','RawResourceReport')]}
        variants.update({tag:fields(label='String',value='RefusalReport') for tag in ('RefusalFirst','RefusalSecond')})
    define('Item',entry,variants);t['Report']=['Item']
    def name(module,tag):return tag if module=='Base' or module==str(entry) else os.path.relpath(Path(module).with_suffix(''),entry.parent)+'.'+tag
    return t,name


def input_codec_inventory(entry,base):
    """Exact twelve registered reports, including typed affine owner views."""
    entry=Path(entry).resolve();home=entry.parent.parent;src=base.ROOT/'src/ecs'
    m=home/'input-codec-v1/materialization-fixture.bend';i=home/'fixture.bend'
    b=home/'input-codec-v1/business.bend';c=module_at(m,'Constructor');q=module_at(m,'Constructed')
    t={};fields=lambda **kw:list(kw.items());maybe=lambda value:('Base',{'None':[],'Some':[('value',value)]})
    def define(key,module,variants):t[key]=(str(module),variants)
    def one(key,module,tag,**kw):define(key,module,{tag:fields(**kw)})
    define('Unit','Base',{'Unit':[]});d=src/'decode-data.bend';w=src/'world.bend'
    one('Handle',w,'Handle',namespace='U32',id='U32')
    define('WorldError',w,{tag:[]for tag in ('MissingEntity','CapacityExceeded','NamespaceExhausted','SystemIdExhausted')})
    one('Registration',w,'RegistrationMeta',id='U32',name='String',access=['String'])
    one('Stamp',src/'lifecycle.bend','Stamp',added='U32',changed='U32');one('Entry',src/'lifecycle.bend','Entry',id='U32',stamp='Stamp')
    define('Raw',d,{'Missing':[],'Null':[],'Number':fields(value='U32'),'SignedInteger':fields(negative='Bool',magnitude='Nat'),'Float':fields(value='F32'),'Binary64':fields(high='U32',low='U32'),'Text':fields(value='String'),'Utf16Text':fields(units=['U32']),'Boolean':fields(value='Bool'),'Handle':fields(namespace='U32',id='U32'),'Array':fields(items=['Raw']),'Object':fields(fields=['Field'])})
    one('Field',d,'Field',name='String',value='Raw')
    define('DecodeError',d,{'Invalid':fields(path='String',expected='String',actual='Raw'),'FuelExhausted':fields(path='String')})
    define('RequestError',src/'decode-requests.bend',{'Validation':fields(error='DecodeError'),'Entity':fields(error='WorldError')})
    one('ParseError',b,'ParseError',raw='Raw')
    define('ConstructorError',c,{'Validation':fields(error='DecodeError'),'Constructor':fields(error='ParseError')})
    define('ComposedError',q,{'Construction':fields(error='ConstructorError'),'Operation':fields(error='RequestError')})
    one('Input',i,'InputView',raw='Raw',words=['U32'],flags=['Bool'])
    one('Owner',b,'View',x='U32',y='U32',raw='Raw',original='Raw',words=['U32'],flags=['Bool'])
    one('Meta',i,'Meta',namespace='U32',nextId='U32',highWater='U32',capacity='U32',depth='Nat',events=['Unit'],registrations=['Registration'],nextSystemId='U32',clock='U32')
    one('Packet',m,'PacketView',owner=maybe('Owner'),original='Raw',canonical='Raw')
    one('Mail',m,'MailView',value='Owner',retired=['Owner'],returned=['Packet'],errors=['WorldError'])
    one('Column',m,'ColumnView',supported='Bool',slots=[maybe('Owner')],stamps=['Entry'])
    one('Snapshot',m,'Snapshot',meta='Meta',live=['Bool'],column='Column',mail='Mail',pending='U32')
    define('Output',m,{'Accepted':fields(target='Handle',spawned='Bool',canonical='Raw',undoAvailable='Bool'),'Refused':fields(owner=maybe('Input'),error='ComposedError')})
    one('Recovery',m,'RecoveryView',output='Output',packets=['Packet'])
    one('Instance',m,'InstanceView',namespace='U32',id='U32',name='String',access=['String'],recoveries=['Recovery'])
    define('Result',m,{'Completed':fields(output='Output'),'Failed':fields(error='Unit'),'Skipped':fields(input='Input'),'RefusedInvocation':[],'Unavailable':[]})
    define('Observation',m,{'Report':fields(before='Snapshot',committed='Snapshot',barrier='Snapshot',instance='Instance',result='Result'),'SetupRefused':[]})
    define('Item',entry,{tag:fields(label='String',value='Observation')for tag in ('First','Second')});t['Report']=['Item']
    def name(module,tag):return tag if module=='Base'or module==str(entry)else os.path.relpath(Path(module).with_suffix(''),entry.parent)+'.'+tag
    return t,name
