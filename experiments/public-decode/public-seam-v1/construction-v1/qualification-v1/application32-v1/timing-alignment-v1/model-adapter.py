"""Additive complete32 transport; caller verifies all source pins before import.
No child, runner, model fallback or historical collector mutation.
"""
from pathlib import Path
import importlib.util
import json
import os
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
def source_module(path,name):
    spec=importlib.util.spec_from_file_location(name,path)
    module=importlib.util.module_from_spec(spec)
    exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__)
    return module
BASE=source_module(ROOT/'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/transport.py','aligned_existing_transport')
OLD=source_module(HERE.parent/'transport-inventory.py','aligned_existing_inventory')

def inventory(entry):
    entry=Path(entry).resolve()
    types,_=OLD.inventory(HERE.parent/'main.bend',BASE.BASE,'application32')
    for key,definition in list(types.items()):
        if isinstance(definition,tuple):
            path,variants=definition
            if path==str(HERE.parent/'application.bend'):types[key]=(str(HERE/'application.bend'),variants)
            if path==str(HERE.parent/'owner.bend'):types[key]=(str(HERE/'owner.bend'),variants)
    fields=lambda **kw:list(kw.items())
    maybe=lambda typ:('Base',{'None':[],'Some':[('value',typ)]})
    def define(key,module,variants):types[key]=(str(HERE/module),variants)
    define('QueuedPayload','application.bend',{'ComponentPayload':fields(owner='Owner'),'MarkerPayload':fields(value='U32')})
    define('Queued','application.bend',{'Queued':fields(kind='String',system='String',namespace='U32',id='U32',payload='QueuedPayload')})
    types['Store'][1]['StoreView'].append(('receipts',['Queued']))
    define('PublicPending','public.bend',{'Pending':fields(kind='String',system='String',target='U32',payload='QueuedPayload')})
    define('PublicEntity','public.bend',{'Entity':fields(id='U32',value=maybe('Owner'),marker=maybe('U32'))})
    define('PublicState','public.bend',{'State':fields(entities=['PublicEntity'],resource='Owner',pending=['PublicPending'],logicalPendingCount='U32',receiptLoweringMatches='Bool'),'Unsupported':fields(snapshot='Snapshot')})
    define('PublicChecked','public.bend',{'Accepted':fields(target=maybe('U32'),spawned='Bool',canonical='Raw'),'Refused':fields(input=maybe('Input'),error='RequestError'),'SystemFailed':fields(error='Unit'),'InvocationRefused':fields(input='Input',operation='Mode',namespace='U32',target='U32')})
    define('PublicView','public.bend',{'View':fields(original='Input',before='PublicState',committed='PublicState',barrier='PublicState',checked='PublicChecked'),'SetupRefused':[]})
    define('Whole','public.bend',{'Whole':fields(public='PublicView',native='ApplicationReport')})
    types['Item']=(str(entry),{tag:fields(operation='String',name='String',value='Whole') for tag in ('Workshop','Garden')})
    types['Report']=['Item']
    def nominal(path,tag):return tag if path=='Base' or path==str(entry) else os.path.relpath(Path(path).with_suffix(''),entry.parent)+'.'+tag
    return types,nominal

def same(actual,expected):
    assert type(actual) is type(expected),'typed mismatch'
    if isinstance(actual,dict):
        assert set(actual)==set(expected),'field mismatch'
        for key in expected:same(actual[key],expected[key])
    elif isinstance(actual,list):
        assert len(actual)==len(expected),'count mismatch'
        for a,b in zip(actual,expected):same(a,b)
    else:assert actual==expected,'value mismatch'

def whole(value):return OLD.whole(value)
def render_native(value,entry=HERE/'observation-main.bend'):
    whole(value);types,name=inventory(entry)
    return (BASE.BASE.parser().render(BASE.BASE.codec(value,types['Report'],types,name,True))+'\n').encode()
def parse_native(raw,entry=HERE/'observation-main.bend'):
    assert type(raw)is bytes
    parser=BASE.BASE.parser();term=parser.parse(raw.decode())
    assert (parser.render(term)+'\n').encode()==raw,'noncanonical suffix/display'
    types,name=inventory(entry)
    result=BASE.BASE.codec(term,types['Report'],types,name,False)
    return whole(result)
def parse_common(raw,backend):
    assert type(raw)is bytes and backend in ('bend','ts')
    text=raw.decode('utf-8')
    if backend=='bend':
        assert text.endswith('\n') and not text.endswith('\n\n'),'external LF'
        text=json.loads(text[:-1]);assert type(text)is str and text!='SERIALIZATION_INCOMPLETE'
    elif text.endswith('\n'):text=text[:-1]
    return whole(json.loads(text))
def oracle(role,models):
    assert role in ('common','native-supplement','ts-supplement')
    assert set(models)=={'common','native-supplement','ts-supplement'}
    return whole(models[role])
def verify(raw,role,model,backend='bend'):
    if role=='native-supplement':value=parse_native(raw)
    elif role=='common':value=parse_common(raw,backend)
    elif role=='ts-supplement':value=whole(json.loads(raw.decode()))
    else:raise AssertionError('unknown explicit role')
    same(value,model)
    return value
