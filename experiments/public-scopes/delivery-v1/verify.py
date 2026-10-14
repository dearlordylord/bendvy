"""Verify retained scopes bytes and guard progression; never run a backend."""
from pathlib import Path
import ast,gzip,hashlib,json,posixpath,zipfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()

def verify_role(role,read,resolvers,result):
    p=json.loads(read(role['plan'],role['planSHA256']))
    r=json.loads(read(role['receipt'],role['receiptSHA256']))
    assert r['planSHA256']==role['planSHA256']
    assert r['status']==role['expectedReceiptStatus']
    labels=['emit','build','consumer'] if any(c['label']=='build'for c in p['commands'])else['emit','consumer']
    caps=[30,120,5]if len(labels)==3 else([5,5]if role['counter']else[30,5])
    assert [c['label']for c in p['commands']]==[c['label']for c in r['commands']]==labels
    assert [c['capSeconds']for c in p['commands']]==caps
    out=str(Path(role['plan']).parent)
    assert p['artifactOutputRoot']==out and str(Path(p['generated']).parent)==out and str(Path(p['native']).parent)==out
    if role['counter']:
        assert p['commands'][0]['argv']==[p['tools']['taskset'],'-c','3',p['tools']['python'],out.rsplit('/js01',1)[0]+'/derive.py.source',out.rsplit('/reached-survivor-control-v1',1)[0]+'/frontend-v1/js01/scope.js',p['generated']]
    else:
        assert p['commands'][0]['argv']==[p['tools']['taskset'],'-c','3',p['tools']['bend'],p['entrypoint'],'-o',p['generated']]
    if len(labels)==3:
        assert p['commands'][1]['argv']==[p['tools']['taskset'],'-c','3',p['tools']['clangWrapper'],'-O3',p['generated'],'-pthread','-lm','-o',p['native']]
        assert p['commands'][-1]['argv']==[p['tools']['taskset'],'-c','3',p['native'],'--threads','1','--gpu','off']
    else:assert p['commands'][-1]['argv']==[p['tools']['taskset'],'-c','3',p['tools']['node'],p['generated']]
    for path,h in p['pins'].items():
        try:assert sha(read(path,h))==h
        except KeyError:assert resolvers[path][h]['sha256']==h
    assert p['sourceEntries']==[p['entrypoint']]and p['entrypoint']in p['sourceInventory']
    assert sorted(p['sourceInventory'])==p['importClosure']
    reached=set()
    def visit(path):
        if path in reached:return
        assert path in p['sourceInventory'];reached.add(path)
        import re
        source=read(path,p['sourceInventory'][path]).decode()
        assert p['pins'][path]==p['sourceInventory'][path]
        for target in re.findall(r'^import\s+(\S+)',source,re.M):
            if target!='Base':visit(posixpath.normpath(posixpath.join(posixpath.dirname(path),target)))
    for entry in p['sourceEntries']:visit(entry)
    assert reached==set(p['sourceInventory'])
    states=dict(p['pins']);states[role['plan']]=role['planSHA256'];guards=[]
    for c,w in zip(r['commands'],p['commands']):
        assert c['argv']==w['argv']and c['capSeconds']==w['capSeconds']and c['exit']==0 and c['failure']is None
        runner=[h for path,h in p['pins'].items()if path.endswith('/scripts/task_runner.py')];assert len(runner)==1 and c['runnerSHA256']==runner[0]
        for phase in ['pre','acquired']:guards.append((c['label']+'-'+phase,dict(states)))
        for stream in ['stdout','stderr']:
            path=out+'/'+c['label']+'.'+stream;raw=read(path,c[stream]['sha256'])
            assert c[stream]['path']==path and c[stream]['published']is True and c[stream]['bytes']==len(raw)
            if stream=='stderr':assert raw==b''
            states[path]=sha(raw)
        if c['label']in ['emit','build']:
            path=p['generated']if c['label']=='emit'else p['native'];raw=read(path,r[c['label']+'ArtifactSHA256']);states[path]=sha(raw)
        guards.append((c['label']+'-post',dict(states)))
    guards.append(('final',dict(states)));assert len(r['guards'])==len(guards)==(10 if len(labels)==3 else 7)
    for g,(label,state)in zip(r['guards'],guards):
        path=out+'/'+label+'.guard.json';assert g['path']==path
        raw=json.loads(read(path,g['sha256']));assert raw['label']==label and raw['unchanged']is True and raw['actualPins']==state
    expected=gzip.decompress(read(role['oracle'],role['oracleTransportSHA256']))
    assert read(out+'/consumer.stdout',r['commands'][-1]['stdout']['sha256'])==expected
    if role['freshRun']:
        assert sha(expected)==p['oracleSHA256']==r['wholeOracleSHA256']and len(expected)==p['oracleBytes']
    else:
        recovery=json.loads(read(result['frontendJSRecovery']))
        assert recovery['status']=='PASS_RETAINED_FRONTEND_JS_NOT_FRESH_RUN'and recovery['freshRun']is False
        assert recovery['originalReceiptSHA256']==role['receiptSHA256']and recovery['originalPlanSHA256']==role['planSHA256']
        assert recovery['oracleSHA256']==sha(expected)and recovery['bytes']==len(expected)
        assert p['oracleSHA256']!=sha(expected)and r['status']=='INCOMPLETE'
    return p,r,expected

def run():
    m=json.loads((H/'MANIFEST.json').read_bytes());data={}
    with zipfile.ZipFile(H/'EVIDENCE.zip')as z:
        assert len(z.namelist())==len(set(z.namelist()))==len(m['members'])and set(z.namelist())==set(m['members'])
        for member,row in m['members'].items():
            raw=z.read(member);assert len(raw)==row['bytes']and sha(raw)==row['sha256'];assert m['pathHashToMember'][row['path']][row['sha256']]==member
            data[(row['path'],row['sha256'])]=raw
    def read(path,h=None):
        if h is None:
            variants=m['pathHashToMember'][path];assert len(variants)==1;h=next(iter(variants))
        return data[(path,h)]
    resultpath=next(path for path,h in data if path.endswith('/public-scopes/delivery-v1/RESULT.json'));result=json.loads(read(resultpath));base=str(Path(resultpath).parents[1]);root=str(Path(base).parents[1])
    assert result['status']=='BOUNDED_SCOPE_CAPABILITY_QUALIFIED_NOT_FEATURE_PERFORMANCE_OR_PRODUCTION_ADOPTION'and result['comparisonsRun']==0 and result['productionAdoption']is False
    assert {r['name']for r in result['roles']}=={'trusted-js','trusted-native','frontend-js-retained','frontend-native','authority-js','authority-native','deferred-js','deferred-native','survivor-counter-js'}and len(result['roles'])==9
    import difflib
    patch=''.join(''.join(difflib.unified_diff([],read(path,h).decode().splitlines(True),fromfile='/dev/null',tofile='b/'+str(Path(path).relative_to(root))))for path,h in result['sourceModules'].items())
    assert sha(patch.encode())==result['productionPatchSHA256']and read(str(Path(resultpath).parent/'PRODUCTION.patch'))==patch.encode()
    outputs={}
    for role in result['roles']:
        p,r,expected=verify_role(role,read,m['resolvers'],result);outputs[role['name']]=expected
        for entry in m['pathHashToMember']:
            if entry.endswith('/SOURCE-BASIS.json')and str(Path(role['oracle']).parent)==str(Path(entry).parent):
                basis=json.loads(read(entry))
                assert basis['runtimeOutputConsulted']is False
                sourcepins=basis['sourceClosure']['sha256ByPath']if 'sourceClosure'in basis else basis['sourcePins']
                assert sourcepins
                for rel,h in sourcepins.items():assert sha(read(root+'/'+rel,h))==h
    assert outputs['survivor-counter-js']!=outputs['frontend-js-retained']
    mutation=json.loads(read(base+'/reached-survivor-control-v1/MUTATION.json'));normal=read(mutation['normalJS'],mutation['normalJSSHA256'])
    counterrole=next(r for r in result['roles']if r['counter']);cp=json.loads(read(counterrole['plan'],counterrole['planSHA256']));counter=read(cp['generated'])
    before=mutation['generatedAnchor'].encode();after=mutation['generatedFault'].encode();assert normal.count(before)==1 and counter==normal.replace(before,after)and counter.replace(after,before)==normal
    controls=json.loads(read(result['typeControls']));assert controls['status']=='EXPECTED_REJECTIONS'and len(controls['controls'])==2
    for c in controls['controls']:
        assert c['exit']==c['expectedExit']==1 and c['capSeconds']==5
        assert sha(read(c['source'],c['sourceSHA256']))==c['sourceSHA256']
        stderr=read(c['stderr']['path'],c['stderr']['sha256']).decode();assert all(fragment in stderr for fragment in c['fragments'])and read(c['stdout']['path'],c['stdout']['sha256'])==b''
    print(json.dumps({'status':'PASS_RETAINED_SCOPE_CAPABILITY','members':len(data),'roles':9,'sourceModules':4,'comparisonsRun':0,'productionAdoption':False}))
    return result,read,m
if __name__=='__main__':run()
