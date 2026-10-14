"""Finite enforcement controls against retained verifier; no backend."""
from pathlib import Path
import copy,importlib.util,contextlib,io,json
H=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('scope_verify',H/'verify.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
with contextlib.redirect_stdout(io.StringIO()):result,read,manifest=V.run()
role=next(r for r in result['roles']if r['name']=='frontend-native');receipt=json.loads(read(role['receipt'],role['receiptSHA256']))
tests=[]
def reject(name,change,guard=False):
    value=copy.deepcopy(receipt);overrides={}
    if guard:
        path=value['guards'][0]['path'];raw=json.loads(read(path,value['guards'][0]['sha256']));change(raw);overrides[path]=json.dumps(raw).encode()
    else:change(value);overrides[role['receipt']]=json.dumps(value).encode()
    def injected(path,h=None):return overrides[path]if path in overrides else read(path,h)
    try:V.verify_role(role,injected,manifest['resolvers'],result)
    except (AssertionError,KeyError,ValueError):tests.append(name)
    else:raise AssertionError('Verifier accepted '+name)
reject('missing-consumer',lambda r:r['commands'].pop())
reject('empty-commands',lambda r:r.update(commands=[]))
reject('duplicate-command',lambda r:r['commands'].append(copy.deepcopy(r['commands'][-1])))
reject('reordered-command',lambda r:r['commands'].reverse())
reject('changed-argv',lambda r:r['commands'][-1]['argv'].append('--invalid'))
reject('changed-cap',lambda r:r['commands'][-1].update(capSeconds=6))
reject('unpublished-stream',lambda r:r['commands'][-1]['stdout'].update(published=False))
reject('missing-guard',lambda r:r['guards'].pop())
reject('duplicate-guard',lambda r:r['guards'].append(copy.deepcopy(r['guards'][-1])))
reject('reordered-guard',lambda r:r['guards'].reverse())
reject('wrong-pin-state',lambda g:g.update(actualPins={}),True)
reject('changed-guard',lambda g:g.update(unchanged=False),True)
print(json.dumps({'status':'PASS_SCOPE_VERIFIER_CONTROLS','negativeCases':len(tests),'rejected':tests,'backendExecutions':0}))
