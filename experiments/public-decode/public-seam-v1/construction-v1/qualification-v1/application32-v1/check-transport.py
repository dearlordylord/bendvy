"""No compiler/runtime child: fictional DTO roundtrips and closed role guards."""
from pathlib import Path
import importlib.util
import copy
HERE=Path(__file__).resolve().parent
path=HERE.parents[3]/'adoption-v1/qualification-v1/spine-report-v1/transport.py'
# Source imports intentionally avoid cached pyc execution.
spec=importlib.util.spec_from_file_location('application32_test_transport',path)
module=importlib.util.module_from_spec(spec)
exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__)
types,_=module.inventory(HERE/'main.bend',True,'application32')

def example(typ):
    if typ in ('U32','Nat'):return 0
    if typ=='Bool':return False
    if typ=='String':return ''
    if isinstance(typ,list):return []
    definition=typ if isinstance(typ,tuple) else types[typ]
    _,variants=definition
    tag=next(iter(variants))
    return {'$':tag,**{name:example(field) for name,field in variants[tag]}}
model=[]
for schema,operation in (('Workshop','insert'),('Workshop','spawn'),('Workshop','resource'),('Garden','insert')):
    for name in ('array3','array128','array256','lateInvalid','struct64','nullableNull','nestedValid','nestedMissing'):
        model.append({'$':schema,'operation':operation,'name':name,'value':example('ApplicationReport')})
raw=module.render(model,HERE/'main.bend',True,'application32')
assert module.parse(raw,HERE/'main.bend',True,'application32')==model
for change in ('count','order','schema','omitted-field'):
    broken=copy.deepcopy(model)
    if change=='count':broken.pop()
    elif change=='order':broken[0],broken[1]=broken[1],broken[0]
    elif change=='schema':broken[0]['$']='Garden'
    else:del broken[0]['value']['before']['store']['marker']
    try:module.render(broken,HERE/'main.bend',True,'application32')
    except (AssertionError,KeyError):pass
    else:raise AssertionError(change+' must fail')
# Existing closed-role field guard remains unchanged, without rebuilding a subject.
original={'$':'Candidate','first':{},'second':{},'firstResource':{},'secondResource':{}}
assert module.whole(original,'native-consuming')==original
try:module.whole(model,'native-consuming')
except AssertionError:pass
else:raise AssertionError('new DTO cannot masquerade as old role')
print('PASS full32 fictional typed roundtrip/count/order/schema/field/default guards')
