"""Complete predicted mutation witnesses, no actual backend outputs consulted."""
from pathlib import Path
import types,json,copy,hashlib,ast
H=Path(__file__).resolve().parent
P=H/'reached-mutations-v1/verify-witness.py';m=types.ModuleType('witness');exec(compile(P.read_bytes(),str(P),'exec'),m.__dict__)
rows=[]
for subject in json.loads((H/'reached-mutations-v1/subjects.json').read_bytes())['subjects']:
    b=json.loads((H/'bindings-v1'/f"{subject['role']}-binding.json").read_bytes());expected=json.loads(Path(b['oracle']['expected']['path']).read_bytes());kind=subject['kind'];predicted=m.witness(expected,kind)
    assert m.verify(expected,predicted,kind)=='REACHED_COMPLETE_MUTANT_KILLED'
    def reject(value):
        try:m.verify(expected,value,kind)
        except AssertionError:return
        raise AssertionError('unrelated/unchanged whole output accepted')
    reject(expected);bad=copy.deepcopy(predicted)
    if kind=='skip-input-validation':bad['first']['success']['before']['mail']['value']['words'][0]+=1
    else:bad['initial']['first']['constructed']['owner']['words'][0]+=1
    reject(bad)
    bad=copy.deepcopy(predicted)
    if kind=='skip-input-validation':bad['first']['success']['before']['mail']['value']['flags'][0]=0
    else:bad['initial']['first']['constructed']['owner']['flags'][0]=1
    reject(bad)
    rows.append({'kind':kind,'completePredictedWitness':True,'unchangedRefused':True,'unrelatedOwnerRefused':True,'boolIntegerRefused':True,'expectedSHA256':b['oracle']['expected']['sha256']})
# Exercise the actual collector's status-selection AST, including its new role.
W=Path('/workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam')
tree=ast.parse((W/'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/development-run.py').read_bytes())
node=next(n for n in tree.body if isinstance(n,ast.FunctionDef)and n.name=='main')
status=next(n.value for n in ast.walk(node)if isinstance(n,ast.Assign)and isinstance(n.value,ast.IfExp)and isinstance(n.value.body,ast.Constant)and n.value.body.value=='DEVELOPMENT_JS_MUTANT_KILLED')
for role in ('normal','construction-spine','custom-spine','completion-spine','input-codec-spine'):
    assert eval(compile(ast.Expression(status),'actual collector status','eval'),{'role':role})=='DEVELOPMENT_JS_PASS'
for role in ('skip-validation','partial-write','completion-omission'):
    assert eval(compile(ast.Expression(status),'actual collector status','eval'),{'role':role})=='DEVELOPMENT_JS_MUTANT_KILLED'
(H/'reached-mutations-v1/witness-controls.json').write_text(json.dumps({'scope':'synthetic source-derived complete witness controls only; no runtime kill claim','verifierSHA256':hashlib.sha256(P.read_bytes()).hexdigest(),'results':rows,'actualCollectorStatusBranches':True},indent=2)+'\n')
print('PASS three complete witness controls and unchanged collector status branches')
