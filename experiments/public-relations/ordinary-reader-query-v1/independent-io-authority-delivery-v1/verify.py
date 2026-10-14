"""Adapted from accepted scopes delivery guard verifier; never launch a backend."""
from pathlib import Path
import copy,gzip,hashlib,json,posixpath,sys,zipfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def verify_role(role,read,resolvers,result):
    p=json.loads(read(role['plan'],role['planSHA256']))
    r=json.loads(read(role['receipt'],role['receiptSHA256']))
    assert r['planSHA256']==role['planSHA256']
    assert r['status']==role['expectedReceiptStatus']
    labels=['emit','build','consumer'] if any(c['label']=='build'for c in p['commands'])else['emit','consumer']
    caps=[30,120,5]if len(labels)==3 else[30,5]
    assert [c['label']for c in p['commands']]==[c['label']for c in r['commands']]==labels
    assert [c['capSeconds']for c in p['commands']]==caps
    out=str(Path(role['plan']).parent)
    assert str(Path(p['generated']).parent)==out and str(Path(p['native']).parent)==out
    assert p['commands'][0]['argv']==[p['tools']['taskset'],'-c','3',p['tools']['bend'],p['entrypoint'],'-o',p['generated']]
    if len(labels)==3:
        assert p['commands'][1]['argv']==[p['tools']['taskset'],'-c','3',p['tools']['clangWrapper'],'-O3',p['generated'],'-o',p['native'],'-pthread','-lm']
        assert p['commands'][-1]['argv']==[p['tools']['taskset'],'-c','3',p['native'],'--threads','1','--gpu','off']
    else:assert p['commands'][-1]['argv']==[p['tools']['taskset'],'-c','3',p['tools']['node'],p['generated']]
    for path,h in p['pins'].items():
        try:assert sha(read(path,h))==h
        except KeyError:assert resolvers[path][h]['sha256']==h
    assert p['entrypoint']in p['sourceInventory']
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
    visit(p['entrypoint'])
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
        recovery=json.loads(read(result['jsRecovery']))
        assert recovery['status']=='PASS_RETAINED_IO_AUTHORITY_JS_NOT_FRESH_RUN'and recovery['freshRun']is False
        assert recovery['originalReceiptSHA256']==role['receiptSHA256']and recovery['originalPlanSHA256']==role['planSHA256']
        assert recovery['oracleSHA256']==sha(expected)and recovery['bytes']==len(expected)
        assert p['oracleSHA256']!=sha(expected)and r['status']=='INCOMPLETE'
        assert r['error']=='ValueError: Complete consumer byte output differs from whole independent oracle'and r.get('guardFailures')==[]
    return p,r,expected

def run(check_delivery=True):
    if check_delivery:
        delivery=json.loads((H/'DELIVERY.json').read_text())
        for name,digest in delivery['files'].items():assert sha((H/name).read_bytes())==digest
    manifest=json.loads((H/'MANIFEST.json').read_text());data={}
    with zipfile.ZipFile(H/'EVIDENCE.zip')as z:
        assert len(z.namelist())==len(set(z.namelist()))==len(manifest['members'])and set(z.namelist())==set(manifest['members'])
        for name,row in manifest['members'].items():
            raw=z.read(name);assert len(raw)==row['bytes']and sha(raw)==row['sha256'];data[name]=raw
    def read(path,digest=None):
        variants=manifest['pathHashToMember'][path]
        if digest is None:assert len(variants)==1;digest=next(iter(variants))
        raw=data[variants[digest]];assert sha(raw)==digest;return raw
    result=json.loads((H/'RESULT.json').read_text())
    assert result['status']=='BOUNDED_IO_RELATION_AUTHORITY_QUALIFIED_NOT_FULL_42_OR_PERFORMANCE'
    assert result['comparisons']==0 and result['sourceCoreChanges']==0 and result['productionAdoption']is False
    assert len(result['roles'])==2 and [r['name']for r in result['roles']]==['js-retained','native']
    outputs=[]
    for role in result['roles']:
        plan,receipt,output=verify_role(role,read,manifest['resolvers'],result);outputs.append(output)
        assert len(plan['sourceInventory'])==33
    assert outputs[0]==outputs[1]and len(outputs[0])==result['wholeOutputBytes']==18546 and sha(outputs[0])==result['wholeOutputSHA256']
    assert len(outputs[0].splitlines())==2
    basis=json.loads(read(result['oracleBasis']));assert basis['runtimeOutputConsulted']is False and len(basis['sourcePins'])==35
    for path,digest in basis['sourcePins'].items():assert sha(read(path,digest))==digest
    ts=json.loads(read(result['tsReuse']['path'],result['tsReuse']['sha256']))
    for row in ts['evidence']:assert sha(read(row['program'],row['programSHA256']))==row['programSHA256']
    ownership=json.loads((H/'OWNERSHIP.json').read_text());assert len(ownership['paths'])==len(set(ownership['paths']))and all(path.startswith('experiments/public-relations/ordinary-reader-query-v1/')for path in ownership['paths'])
    return result,read,manifest

def selftest():
    result,read,manifest=run(False);role=result['roles'][0];original=json.loads(read(role['receipt'],role['receiptSHA256']));passed=[]
    def rejects(name,mutate):
        altered=copy.deepcopy(original);mutate(altered)
        def counter(path,digest=None):
            if path==role['receipt']:return json.dumps(altered).encode()
            return read(path,digest)
        try:verify_role(role,counter,manifest['resolvers'],result)
        except (AssertionError,KeyError,IndexError,ValueError):passed.append(name);return
        raise AssertionError('Accepted corrupt receipt: '+name)
    rejects('missing-consumer',lambda r:r['commands'].pop())
    rejects('duplicate-command',lambda r:r['commands'].append(r['commands'][0]))
    rejects('reordered-commands',lambda r:r['commands'].reverse())
    rejects('wrong-argv',lambda r:r['commands'][0]['argv'].append('--wrong'))
    rejects('wrong-cap',lambda r:r['commands'][0].update(capSeconds=31))
    rejects('missing-guard',lambda r:r['guards'].pop())
    rejects('duplicate-guard',lambda r:r['guards'].__setitem__(1,r['guards'][0]))
    rejects('unpublished-stdout',lambda r:r['commands'][-1]['stdout'].update(published=False))
    print(json.dumps({'status':'PASS','controls':passed,'count':len(passed)}))

if __name__=='__main__':
    if sys.argv[1:]==['--selftest']:selftest()
    else:
        result,read,manifest=run();print(json.dumps({'status':'PASS_RETAINED_IO_RELATION_AUTHORITY','members':len(manifest['members']),'roles':2,'wholeBytes':18546,'freshNative':True,'jsFreshRun':False,'comparisons':0}))
