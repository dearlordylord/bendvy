"""Existing gzip-object fulljoin verification adapted to selector subject; no replay."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import shutil
import sys
import tempfile
import types

OUT=Path(__file__).resolve().parent
sha=lambda body:hashlib.sha256(body).hexdigest()
m=json.loads((OUT/'manifest.json').read_text())
rows=m['members']
with tempfile.TemporaryDirectory() as directory:
    isolated=Path(directory)/'packet'
    shutil.copytree(OUT,isolated)
    data={}
    for row in rows:
        if 'object' in row:
            packed=(isolated/row['object']).read_bytes()
            assert sha(packed)==row['compressedSHA256']
            body=gzip.decompress(packed)
        else:
            body=Path(row['path']).read_bytes()
        assert len(body)==row['bytes'] and sha(body)==row['sha256'],row['path']
        data[row['path']]=body
    evolving=0
    raw_joins=0
    source_pin_joins=0
    model_results={}
    all_roles=m['roles']+m['history']
    for role in all_roles:
        plan=json.loads(data[role['plan']])
        receipt=json.loads(data[role['receipt']])
        assert receipt['planSHA256']==sha(data[role['plan']])
        for path,digest in plan['pins'].items():
            assert sha(data[path])==digest,path
        for root,entries in plan['resourceRoots'].items():
            for path,digest in entries.items():
                assert sha(data[str(Path(root)/path)])==digest
        for guard_row in receipt['guards']:
            guard=json.loads(data[guard_row['path']])
            assert sha(data[guard_row['path']])==guard_row['sha256']
            assert guard['unchanged']
            for path,digest in guard['actualPins'].items():
                assert sha(data[path])==digest,path
                evolving+=1
        seen=set()
        def visit(path):
            if path in seen:
                return
            seen.add(path)
            assert sha(data[path])==plan['sourceInventory'][path]
            for imported in re.findall(r'^import\s+(\S+)',data[path].decode(),re.M):
                if imported!='Base':
                    visit(str((Path(path).parent/imported).resolve()))
        visit(plan['entrypoint'])
        assert seen==set(plan['sourceInventory'])
        for command in receipt['commands']:
            for stream in ['stdout','stderr']:
                item=command[stream]
                assert sha(data[item['path']])==item['sha256']
                assert len(data[item['path']])==item['bytes']
                raw_joins+=1
            if role in m['roles']:
                assert command['exit']==0 and command['failure'] is None
                if command['label']=='consumer':
                    assert data[command['stdout']['path']]==gzip.decompress(data[plan['oracle']])
                    assert not data[command['stderr']['path']]
        if role in m['roles']:
            if role['role']=='native':
                assert any(row['path']==plan['native'] and 'object' in row for row in rows)
            assert receipt['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'
        else:
            assert receipt['status']=='INCOMPLETE'
            assert len(receipt['commands'])==1 and receipt['commands'][0]['label']=='emit'
            assert receipt['commands'][0]['exit']==1
            diagnostic=data[receipt['commands'][0]['stderr']['path']]
            assert b'label' in diagnostic and diagnostic
    # Verify every retained explicit hash mapping in source/oracle/check JSON,
    # including original and repaired freezes and historical pre/post source pins.
    def hash_maps(value):
        global source_pin_joins
        if isinstance(value,dict):
            for path,digest in value.items():
                if isinstance(path,str) and path.startswith('/') and isinstance(digest,str) and re.fullmatch('[0-9a-f]{64}',digest) and path in data:
                    assert sha(data[path])==digest,path
                    source_pin_joins+=1
                hash_maps(digest)
        elif isinstance(value,list):
            for item in value:
                hash_maps(item)
    for path,body in data.items():
        if path.endswith('.json') and ('SOURCE-' in Path(path).name or Path(path).name=='ORACLES.json'):
            hash_maps(json.loads(body))
    named_file_joins=0
    def file_pairs(value,origin):
        global named_file_joins
        if isinstance(value,dict):
            if isinstance(value.get('path'),str) and isinstance(value.get('sha256'),str) and value['path'] in data:
                assert sha(data[value['path']])==value['sha256']
                named_file_joins+=1
            for key,digest in value.items():
                if key.endswith('SHA256') and isinstance(digest,str) and key[:-6] in value and isinstance(value[key[:-6]],str):
                    target=value[key[:-6]]
                    candidates=[target] if target.startswith('/') else [str(parent/target) for parent in [Path(origin).parent,*Path(origin).parents]]
                    found=next((name for name in candidates if name in data),None)
                    if found is not None:
                        assert sha(data[found])==digest,found
                        named_file_joins+=1
                file_pairs(digest,origin)
        elif isinstance(value,list):
            for item in value:
                file_pairs(item,origin)
    for path,body in data.items():
        if path.endswith('.json') and ('SOURCE-' in Path(path).name or Path(path).name=='ORACLES.json'):
            file_pairs(json.loads(body),path)
    # Retained model is standalone (no model-parent imports). Execute its exact
    # archived source in-memory, with dataclass module registration restored.
    model_path=str(Path(m['modelBase'])/'model.py.source')
    name='retained_selector_model'
    previous=sys.modules.get(name)
    module=types.ModuleType(name)
    module.__file__=model_path
    sys.modules[name]=module
    try:
        exec(compile(data[model_path],model_path,'exec'),module.__dict__)
        module.self_test()
        for role in m['roles']:
            plan=json.loads(data[role['plan']])
            expected=gzip.decompress(data[plan['oracle']])
            rendered=module.render(role['schema'])
            assert rendered==expected
            model_results[role['schema']+'/'+role['role']]={'bytes':len(rendered),'sha256':sha(rendered)}
    finally:
        if previous is None:
            sys.modules.pop(name,None)
        else:
            sys.modules[name]=previous
    result={'status':'PASS','isolatedRelocation':True,'bindings':len(rows),'objects':len({row['object'] for row in rows if 'object' in row}),'externalELFs':sum('object' not in row for row in rows),'successfulCommands':sum(role['commands'] for role in m['roles']),'successfulGuards':sum(role['guards'] for role in m['roles']),'historyCommands':sum(role['commands'] for role in m['history']),'historyGuards':sum(role['guards'] for role in m['history']),'evolvingPinJoins':evolving,'sourceAndOracleHashJoins':source_pin_joins,'rawOutputJoins':raw_joins,'namedSourceFileJoins':named_file_joins,'importsPerSuccessfulRole':[len(json.loads(data[role['plan']])['sourceInventory']) for role in m['roles']],'retainedModels':model_results,'historyStatuses':{role['receipt']:json.loads(data[role['receipt']])['status'] for role in m['history']},'backendReplay':False,'scope':m['scope']}
    (OUT/'FULL-JOIN-VERIFICATION.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))
