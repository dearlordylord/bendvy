"""Synthetic full independent-model roundtrips; no ECS/reference child."""
from pathlib import Path
import ast, copy, hashlib, json, types

HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
HOME=HERE.parent
TRANSPORT=HOME.parents[1]/'adoption-v1/qualification-v1/spine-report-v1/transport.py'

def load(path):
    module=types.ModuleType('transport');module.__file__=str(path)
    exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__)
    return module

def refused(action):
    try: action()
    except (AssertionError,ValueError,KeyError,TypeError):return
    raise AssertionError('corruption accepted')

def main():
    transport=load(TRANSPORT); result=[]
    for role,entry,model in [('construction-spine',HERE/'complete-spine.bend',HERE/'complete44-model-join.json'),
                             ('custom-spine',HOME/'fallible-composition-v1/complete-spine.bend',HERE/'complete20-model-join.json'),
                             ('completion-spine',HOME/'completion-addon-v1/complete-spine.bend',HERE/'complete16-model-join.json')]:
        expected=json.loads(model.read_bytes()); helper=transport.spine_helper(entry,role)
        items=helper.pack(expected,role)
        assert helper.unpack(items,role)==expected
        raw=transport.render(expected,entry,True,role)
        assert transport.parse(raw,entry,True,role)==expected
        assert transport.render(transport.parse(raw,entry,True,role),entry,True,role)==raw
        wrong=copy.deepcopy(items);wrong[0]['label']='wrong';refused(lambda:helper.unpack(wrong,role))
        wrong=copy.deepcopy(items);wrong[0]['schema']='Other';refused(lambda:helper.unpack(wrong,role))
        refused(lambda:helper.unpack(items[:-1],role));refused(lambda:helper.unpack(items+items[:1],role))
        wrong=copy.deepcopy(items);wrong[0]['extra']=0;refused(lambda:helper.unpack(wrong,role))
        wrong=copy.deepcopy(expected);group=wrong[{'construction-spine':'initial','custom-spine':'request','completion-spine':'materialization'}[role]]
        del group['first'];refused(lambda:transport.render(wrong,entry,True,role))
        refused(lambda:transport.parse(raw+b' ',entry,True,role))
        wrong=copy.deepcopy(expected)
        if role in ('construction-spine','completion-spine'):wrong['materialization']['first']['spawn']['before']['mail']['value']['words'][0]=True
        else:wrong['refusal']['foreignFirst']['returned']['input']['words'][0]=True
        refused(lambda:transport.render(wrong,entry,True,role))
        wrong=copy.deepcopy(expected)
        if role in ('construction-spine','completion-spine'):wrong['materialization']['first']['spawn']['before']['mail']['value']['flags'][0]=1
        else:wrong['refusal']['foreignFirst']['returned']['input']['flags'][0]=1
        refused(lambda:transport.render(wrong,entry,True,role))
        result.append({'role':role,'reports':len(items),'rawBytes':len(raw),'rawSHA256':hashlib.sha256(raw).hexdigest(),'fullRoundtrip':True,'corruptions':9})
    old=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-decode/adoption-v1/qualification-v1/oracle-v1/spine-report-v1/expected.json')
    assert hashlib.sha256(old.read_bytes()).hexdigest()=='26e965901c73e89804b69c1d3d13d10e512478955cb0541f6ccbe8e49693766d'
    original=load(TRANSPORT.parent/'development-run.py')
    assert original.assembly_binding(None,None) is None
    assert original.ORACLE_FILES['normal']['sha256']=='26e965901c73e89804b69c1d3d13d10e512478955cb0541f6ccbe8e49693766d'
    expected=json.loads(old.read_bytes());entry=TRANSPORT.parent/'main.bend'
    raw=transport.render(expected,entry,False,'normal')
    assert transport.parse(raw,entry,False,'normal')==expected
    result.append({'role':'historical-default-normal','oracleSHA256':hashlib.sha256(old.read_bytes()).hexdigest(),'rawBytes':len(raw),'rawSHA256':hashlib.sha256(raw).hexdigest(),'fullRoundtrip':True,'defaultBinding':None})
    tree=ast.parse((TRANSPORT.parent/'development-run.py').read_bytes())
    main_node=next(node for node in tree.body if isinstance(node,ast.FunctionDef) and node.name=='main')
    status=next(node.value for node in ast.walk(main_node) if isinstance(node,ast.Assign) and isinstance(node.value,ast.IfExp) and isinstance(node.value.body,ast.Constant) and node.value.body.value=='DEVELOPMENT_JS_MUTANT_KILLED')
    reached=next(node.test for node in ast.walk(main_node) if isinstance(node,ast.If) and any(isinstance(child,ast.Call) and isinstance(child.func,ast.Name) and child.func.id=='mutant_witness' for child in ast.walk(ast.Module(body=node.body,type_ignores=[]))))
    for role in ('construction-spine','custom-spine','completion-spine','normal'):
        assert eval(compile(ast.Expression(status),'<actual collector status>','eval'),{'role':role})=='DEVELOPMENT_JS_PASS'
        assert not eval(compile(ast.Expression(reached),'<actual collector branch>','eval'),{'role':role})
    for role in ('skip-validation','partial-write','completion-omission'):
        assert eval(compile(ast.Expression(status),'<actual collector status>','eval'),{'role':role})=='DEVELOPMENT_JS_MUTANT_KILLED'
        assert eval(compile(ast.Expression(reached),'<actual collector branch>','eval'),{'role':role})
    print(json.dumps({'scope':'full model synthetic transport only; no application execution','checks':result}))

if __name__=='__main__':main()
