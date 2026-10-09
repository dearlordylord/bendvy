"""Full source-current roundtrips; source-nominal corruptions must be refused."""
from pathlib import Path
import types,json,hashlib,copy
H=Path(__file__).resolve().parent
W=Path('/workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam')
P=W/'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/transport.py'
t=types.ModuleType('transport');t.__file__=str(P);exec(compile(P.read_bytes(),str(P),'exec'),t.__dict__)
results=[]
for role in ('construction-spine','custom-spine','completion-spine','input-codec-spine'):
    b=json.loads((H/'bindings-v1'/f'{role}-binding.json').read_bytes());entry=Path(b['entry']['path']);expected=json.loads(Path(b['oracle']['expected']['path']).read_bytes())
    raw=t.render(expected,entry,True,role);assert t.parse(raw,entry,True,role)==expected
    helper=t.spine_helper(entry,role);items=helper.pack(expected,role);types_,name=t.inventory(entry,True,role);negatives=[]
    corrupt=copy.deepcopy(items);corrupt[0]['label']='wrong-label';negatives.append(('label',corrupt))
    corrupt=copy.deepcopy(items);corrupt[0],corrupt[1]=corrupt[1],corrupt[0];negatives.append(('order',corrupt))
    negatives.append(('extra-row',items+items[:1]));negatives.append(('missing-row',items[1:]))
    corrupt=copy.deepcopy(items)
    if role=='input-codec-spine':corrupt[0]['$']='Second'
    elif role=='completion-spine':corrupt[0]['$']='MaterialSecond'
    else:corrupt[0]['schema']='Second'
    negatives.append(('schema',corrupt))
    for kind,corrupt in negatives:
        bad=(t.BASE.parser().render(t.BASE.codec(corrupt,types_['Report'],types_,name,True))+'\n').encode()
        try:t.parse(bad,entry,True,role)
        except (AssertionError,KeyError,ValueError):pass
        else:raise AssertionError((role,kind,'accepted corruption'))
    # Every owner field and its declared scalar kind remains mandatory.
    owner=copy.deepcopy(items)
    first=owner[0]['value']
    if role=='construction-spine':view=first['owner']
    elif role=='custom-spine':view=first['after']['resource']
    else:view=first['before']['mail']['value']
    for field,value in [('words',[True,72]),('flags',[0,True]),('unexpected',0)]:
        bad=copy.deepcopy(owner)
        if role=='construction-spine':target=bad[0]['value']['owner']
        elif role=='custom-spine':target=bad[0]['value']['after']['resource']
        else:target=bad[0]['value']['before']['mail']['value']
        target[field]=value
        try:t.BASE.codec(bad,types_['Report'],types_,name,True)
        except (AssertionError,KeyError,ValueError):pass
        else:raise AssertionError((role,field,'accepted scalar/field drift'))
    try:t.parse(raw+b' ',entry,True,role)
    except (AssertionError,ValueError):pass
    else:raise AssertionError('noncanonical bytes accepted')
    results.append({'role':role,'count':len(items),'rawBytes':len(raw),'rawSHA256':hashlib.sha256(raw).hexdigest(),'completeRoundtrip':True,'corruptionCount':9})
# Historical normal subject/model remains unmodified and byte-identical.
old=W/'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/main.bend'
expected_path=W/'experiments/public-decode/public-seam-v1/list-spine-v1/prepared-v1/generic-binding.json'
# Historical default uses its independent original oracle, not the current role binding.
oracle=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-decode/adoption-v1/qualification-v1/oracle-v1/spine-report-v1/expected.json')
model=json.loads(oracle.read_bytes());raw=t.render(model,old,False,'normal');assert t.parse(raw,old,False,'normal')==model
assert hashlib.sha256(oracle.read_bytes()).hexdigest()=='26e965901c73e89804b69c1d3d13d10e512478955cb0541f6ccbe8e49693766d'
(H/'transport-controls.json').write_text(json.dumps({'scope':'synthetic source-current transport controls only; no backend/proof claim','results':results,'historicalDefaultRoundtrip':True},indent=2)+'\n')
print('PASS complete92 roundtrips, 36 corruption controls and historical default')
