"""Full22 native Candidate transport reusing the reviewed complete field inventory."""
from pathlib import Path
import importlib.util
import os


def inventory(entry, base, role):
    assert role == 'native-consuming'
    entry = Path(entry).resolve()
    helper = entry.parent.parent / 'transport-inventory.py'
    spec = importlib.util.spec_from_file_location('native_existing_inventory', helper)
    module = importlib.util.module_from_spec(spec)
    exec(compile(helper.read_bytes(), str(helper), 'exec'), module.__dict__)
    canonical = entry.parent.parent / 'canonical-v1/source'
    types, _ = module.inventory(canonical / 'qualification-v1/complete-spine.bend', base, 'construction-spine')
    original = str(canonical / 'materialization-v1/fixture.bend')
    actual = str(entry.parent / ('mutant-handle-fixture.bend' if entry.name.startswith('mutant-') else 'handle-fixture.bend'))
    for key, value in list(types.items()):
        if isinstance(value, tuple) and value[0] == original:
            types[key] = (actual, value[1])
    fields = lambda **kw: list(kw.items())
    types['HandleCases'] = (actual, {'Cases': fields(**{k:'MaterialReport' for k in ('spawn','insert','failure','failedInsert','invalid','invalidSpawn','lateMissing','skip')})})
    types['Resources'] = (str(entry), {'Resources': fields(valid='ResourceReport',invalid='ResourceReport',rollback='ResourceReport')})
    types['Report'] = (str(entry), {'Candidate': fields(first='HandleCases',second='HandleCases',firstResource='Resources',secondResource='Resources')})
    if entry.name in ('complete-spine.bend','mutant-spine.bend','sequential-spine.bend','mutant-sequential-spine.bend'):
        types['Item'] = (str(entry), {**{tag:fields(label='String',value='MaterialReport') for tag in ('ComponentFirst','ComponentSecond')}, **{tag:fields(label='String',value='ResourceReport') for tag in ('ResourceFirst','ResourceSecond')}})
        types['Report'] = ['Item']
    def nominal(module, tag):
        return tag if module == 'Base' or module == str(entry) else os.path.relpath(Path(module).with_suffix(''), entry.parent) + '.' + tag
    return types, nominal

COMPONENTS = ('spawn','insert','failure','failedInsert','invalid','invalidSpawn','lateMissing','skip')
RESOURCES = ('valid','invalid','rollback')

def pack(value):
    assert type(value) is dict and set(value)=={'$','first','second','firstResource','secondResource'} and value['$']=='Candidate'
    result=[]
    for schema in ('First','Second'):
        cases=value[schema.lower()]
        assert type(cases) is dict and set(cases)=={'$',*COMPONENTS} and cases['$']=='Cases'
        result += [{'$':'Component'+schema,'label':label,'value':cases[label]} for label in COMPONENTS]
    for schema in ('First','Second'):
        cases=value[schema.lower()+'Resource']
        assert type(cases) is dict and set(cases)=={'$',*RESOURCES} and cases['$']=='Resources'
        result += [{'$':'Resource'+schema,'label':label,'value':cases[label]} for label in RESOURCES]
    assert len(result)==22
    return result

def unpack(items):
    assert type(items) is list and len(items)==22
    result={'$':'Candidate'}; position=0
    for schema in ('First','Second'):
        cases={'$':'Cases'}
        for label in COMPONENTS:
            item=items[position];position+=1
            assert type(item) is dict and set(item)=={'$','label','value'} and item['$']=='Component'+schema and item['label']==label
            cases[label]=item['value']
        result[schema.lower()]=cases
    for schema in ('First','Second'):
        cases={'$':'Resources'}
        for label in RESOURCES:
            item=items[position];position+=1
            assert type(item) is dict and set(item)=={'$','label','value'} and item['$']=='Resource'+schema and item['label']==label
            cases[label]=item['value']
        result[schema.lower()+'Resource']=cases
    assert pack(result)==items
    return result
