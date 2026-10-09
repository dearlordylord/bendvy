"""Portable mock complete32 adapter controls; no compiler/runtime child or oracle."""
from pathlib import Path
import importlib.util
import copy
import json
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('aligned_adapter_test',HERE/'model-adapter.py')
module=importlib.util.module_from_spec(spec)
exec(compile(Path(spec.origin).read_bytes(),str(spec.origin),'exec'),module.__dict__)
types,_=module.inventory(HERE/'observation-main.bend')
def example(typ):
    if typ in ('U32','Nat'):return 0
    if typ=='Bool':return False
    if typ=='String':return ''
    if isinstance(typ,list):return []
    _,variants=typ if isinstance(typ,tuple) else types[typ]
    tag=next(iter(variants))
    return {'$':tag,**{key:example(child) for key,child in variants[tag]}}
full=[]
for schema,operation in (('Workshop','insert'),('Workshop','spawn'),('Workshop','resource'),('Garden','insert')):
    for name in module.OLD.CASES:
        full.append({'$':schema,'operation':operation,'name':name,'value':example('Whole')})
last=full[-1]['value'];owner=example('Owner');owner['words']=[111,222];owner['flags']=[True,False]
last['public']['barrier']['resource']=copy.deepcopy(owner)
last['public']['committed']['pending']=[{'$':'Pending','kind':'spawn','system':'application32','target':2,'payload':{'$':'ComponentPayload','owner':copy.deepcopy(owner)}}]
last['native']['committed']['store']['receipts']=[{'$':'Queued','kind':'spawn','system':'application32','namespace':1,'id':2,'payload':{'$':'ComponentPayload','owner':copy.deepcopy(owner)}}]
wire=module.render_native(full)
module.same(module.parse_native(wire),full)
for label,change in (
    ('field',lambda x:x[-1]['value']['native']['barrier']['store'].pop('receipts')),
    ('lastowner',lambda x:x[-1]['value']['public']['barrier']['resource']['words'].pop()),
    ('pendingpayload',lambda x:x[-1]['value']['public']['committed']['pending'][0]['payload']['owner']['flags'].reverse()),
    ('typedbool',lambda x:x[-1]['value']['public']['barrier']['resource']['flags'].__setitem__(0,1))):
    broken=copy.deepcopy(full);change(broken)
    try:module.same(broken,full)
    except AssertionError:pass
    else:raise AssertionError(label)
try:module.parse_native(wire+b'\n')
except (AssertionError,ValueError):pass
else:raise AssertionError('suffix')
common=[{**row,'value':row['value']['public']} for row in full]
text=json.dumps(common,separators=(',',':'))
module.same(module.parse_common((json.dumps(text)+'\n').encode(),'bend'),common)
module.same(module.parse_common((text+'\n').encode(),'ts'),common)
for suffix in ('\n\n','garbage'):
    try:module.parse_common((json.dumps(text)+suffix).encode(),'bend')
    except (AssertionError,ValueError):pass
    else:raise AssertionError('common suffix')
models={'common':common,'native-supplement':full,'ts-supplement':full}
assert module.oracle('common',models) is common
try:module.oracle('historic',models)
except AssertionError:pass
else:raise AssertionError('oracle fallback')
# Historical parser dispatch still rejects this new nested Whole inventory.
old_types,_=module.BASE.inventory(HERE.parent/'main.bend',True,'application32')
assert 'Whole' not in old_types and 'receipts' not in dict(old_types['Store'][1]['StoreView'])
print('PASS mock complete32 roundtrip/field/suffix/lastowner/pendingpayload/typedbool/role/default controls')
