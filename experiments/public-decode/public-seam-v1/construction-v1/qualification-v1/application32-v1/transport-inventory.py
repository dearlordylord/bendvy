"""Closed application32 whole DTO inventory; no observation projection/defaults."""
from pathlib import Path
import importlib.util
import os

CASES=('array3','array128','array256','lateInvalid','struct64','nullableNull','nestedValid','nestedMissing')
def whole(value):
    assert type(value) is list and len(value)==32
    index=0
    for schema,operation in (('Workshop','insert'),('Workshop','spawn'),('Workshop','resource'),('Garden','insert')):
        for name in CASES:
            item=value[index]; index+=1
            assert type(item) is dict and set(item)=={'$','operation','name','value'}
            assert item['$']==schema and item['operation']==operation and item['name']==name
    return value

def inventory(entry,base,role):
    assert role=='application32'
    entry=Path(entry).resolve();home=entry.parent
    helper=home.parent/'transport-inventory.py'
    spec=importlib.util.spec_from_file_location('application32_existing_inventory',helper)
    module=importlib.util.module_from_spec(spec)
    exec(compile(helper.read_bytes(),str(helper),'exec'),module.__dict__)
    types,_=module.inventory(home.parent/'canonical-v1/source/qualification-v1/complete-spine.bend',base,'construction-spine')
    application=str(home/'application.bend');owner=str(home/'owner.bend')
    fields=lambda **kw:list(kw.items())
    maybe=lambda typ:('Base',{'None':[],'Some':[('value',typ)]})
    def define(key,path,variants):types[key]=(path,variants)
    def one(key,path,tag,**kw):define(key,path,{tag:fields(**kw)})
    one('Input',owner,'InputView',raw='Raw',words=['U32'],flags=['Bool'])
    one('Owner',owner,'View',raw='Raw',original='Raw',words=['U32'],flags=['Bool'])
    one('Meta',application,'Meta',namespace='U32',nextId='U32',highWater='U32',capacity='U32',depth='Nat',events=['Unit'],registrations=['Registration'],nextSystemId='U32',clock='U32')
    define('Marker',application,{'MarkerView':fields(slots=[maybe('U32')],stamps=['Entry']),'UnsupportedMarker':[]})
    one('Packet',application,'PacketView',owner=maybe('Owner'),original='Raw',canonical='Raw')
    one('Column',application,'ColumnView',supported='Bool',slots=[maybe('Owner')],stamps=['Entry'])
    one('Store',application,'StoreView',values='Column',marker='Marker',returned=['Packet'],errors=['WorldError'])
    one('Snapshot',application,'Snapshot',meta='Meta',live=['Bool'],store='Store',resource='Owner',pending='U32')
    define('OperationView',application,{'Accepted':fields(target='Handle',spawned='Bool',canonical='Raw',undoAvailable='Bool'),'Refused':fields(owner=maybe('Input'),error='RequestError')})
    define('ResourceView',application,{'ResourceReplaced':fields(canonical='Raw',undoAvailable='Bool'),'ResourceRefused':fields(owner='Input',error='DecodeError')})
    define('Output',application,{'ComponentView':fields(value='OperationView'),'ResourceOutputView':fields(value='ResourceView')})
    one('Recovery',application,'RecoveryView',output='Output',packets=['Packet'])
    one('Pending',application,'PendingView',owner='Unit',error='WorldError')
    one('Instance',application,'InstanceView',namespace='U32',id='U32',name='String',access=['String'],recoveries=['Recovery'],pending=['Pending'])
    define('Mode',application,{tag:[] for tag in ('Spawn','Insert','ResourceWrite')})
    define('Result',application,{'Completed':fields(output='Output'),'Failed':fields(error='Unit'),'InvocationRefused':fields(input='Input',operation='Mode',target='Handle')})
    define('ApplicationReport',application,{'Report':fields(original='Input',before='Snapshot',committed='Snapshot',barrier='Snapshot',instance='Instance',result='Result'),'SetupRefused':[]})
    define('Item',str(entry),{tag:fields(operation='String',name='String',value='ApplicationReport') for tag in ('Workshop','Garden')})
    types['Report']=['Item']
    def nominal(path,tag):
        return tag if path=='Base' or path==str(entry) else os.path.relpath(Path(path).with_suffix(''),entry.parent)+'.'+tag
    return types,nominal
