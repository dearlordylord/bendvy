"""Verify retained current-module JS source/raw/models and witnesses, without children."""
import hashlib
import io
import json
import tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
OUT=H/'delivery-handler-helper-mutants-js-v1'
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((OUT/'manifest.json').read_text())
assert not any(m[k] for k in ['completeIssue49','proofCredit','productionAdopted','nativeQualified','performanceQualified'])
for n,h in m['source'].items():assert sha((H/n).read_bytes())==h
for n,h in m['history'].items():assert sha((OUT/n).read_bytes())==h
assert sha((OUT/'REPORT.md').read_bytes())==m['reportSHA256']
assert sha((H/'delivery-handler-helper-native-v1/manifest.json').read_bytes())==m['baselineNativeManifestSHA256']
assert sha((H/'delivery-mutants-v1/manifest.json').read_bytes())==m['historicalMutationManifestSHA256']
old=json.loads((H/'delivery-mutants-v1/manifest.json').read_text())
cohorts={}
for label,a in m['archives'].items():
    blob=(OUT/a['archive']).read_bytes();assert sha(blob)==a['sha256']
    with tarfile.open(fileobj=io.BytesIO(blob),mode='r:gz') as t:
        assert set(t.getnames())==set(a['members']);d={}
        for n,entry in a['members'].items():
            assert 'private-environment' not in n
            b=t.extractfile(n).read();assert sha(b)==entry['sha256'] and len(b)==entry['bytes'];d[n]=b
    p=json.loads(d['plan.json']);r=json.loads(d['receipt.json']);assert r['planSHA256']==sha(d['plan.json'])
    assert len(r['commands'])==(3 if label=='source' else 6) and r['probeCommandsExecuted']==(35 if label=='source' else 65)
    assert r['status']==('STAGED_HANDLER_HELPERS_THREE_MUTANTS_SOURCE_TYPING_PASS' if label=='source' else 'STAGED_HANDLER_HELPERS_THREE_MUTANTS_FULL96_AND12_JS_PASS')
    assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
    for n,h in p['inventory'].items():assert sha(d['stage/'+n])==h
    for path,h in r['probePins'].items():assert sha(d[str(Path(path).relative_to(a['historicalDirectory']))])==h
    for path,h in r.get('generated',{}).items():assert sha(d[str(Path(path).relative_to(a['historicalDirectory']))])==h
    for n,h in r['logs'].items():assert sha(d[n])==h
    assert all(not d[c['label']+'.stderr'] for c in p['commands'])
    if label=='source':assert all(d[c['label']+'.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' for c in p['commands'])
    cohorts[label]=(p,r,d)
s,_,sd=cohorts['source'];p,r,d=cohorts['js']
for n,h in s['inventory'].items():assert p['inventory'][n]==h
for path,h in s['pins'].items():assert p['pins'][path]==h
assert p['pins'][p['sourceQualification']]==sha(sd['receipt.json'])
def between(row,start,end):
    text=row.split(start,1)[1]
    return text.split(end,1)[0] if end else text
names=[f'schema{s}_{phase}{i}{suffix}' for s in ['A','B'] for phase in ['exit','transition','enter'] for i in [0,1] for suffix in ['','_missing']]
for variant in ['lost-retry','premature-publication','whole-marker-rollback']:
    f='stage/'+variant+'/experiments/public-machine-handlers/candidate-v1/'
    model=json.loads(d[f+'full-mutant-'+variant+'-expected.json'])['bend'];normal=json.loads(d[f+'full-expected.json'])['bend']
    assert sha(d[f+'full-mutant-'+variant+'-expected.json'])==old['source']['full-mutant-'+variant+'-expected.json']
    assert sha(d[f+'full-mutant-complete-consumer.mjs'])==old['source']['full-mutant-complete-consumer.mjs']
    assert set(model)==set(names) and sum(len(model[n]) for n in names if not n.endswith('_missing'))==96
    missing=[n for n in names if n.endswith('_missing')];assert len(missing)==12 and all(len(model[n])==4 for n in missing)
    raw=json.loads(d[variant+'-consume.stdout']);assert raw['mutant']==variant and raw['status']=='REACHED_COMPLETE_TWO_SCHEMA_SEMANTIC_MUTANT_KILLED'
    assert raw['observations']==[n+'|['+', '.join(model[n])+']' for n in names]
    assert all(model[n]==normal[n] if n.endswith('_missing') else model[n][:2]==normal[n][:2] for n in names)
    witnesses=[]
    for schema in ['A','B']:
        n='schema'+schema+'_exit'+('1' if variant=='whole-marker-rollback' else '0');actual=model[n][2];before=normal[n][2];assert actual!=before
        if variant=='lost-retry':
            assert 'pending=none' in between(actual,';flow=',';level=') and 'pending=Play:false' in between(before,';flow=',';level=')
        elif variant=='premature-publication':
            assert 'Boot>Play' in between(actual,';flowStream=',';levelStream=') and between(before,';flowStream=',';levelStream=').startswith('batches=[]')
        else:
            for start,end in [(';cells=',';owned='),(';owned=',';flow='),(';pingStream=',';selector='),(';queue=',';registrations='),(';busEvents=',None)]:assert between(actual,start,end)!=between(before,start,end)
            for start,end in [(';locals=',';pingStream='),(';attempts=',';deliveries='),(';deliveries=',';queue=')]:assert between(actual,start,end)==between(before,start,end)
        witnesses.append({'name':n,'checkpoint':'handler-failure','normal':before,'actual':actual})
    assert raw['witnesses']==witnesses
print('FINITE_CURRENT_HANDLER_THREE_JS_FULL96_AND12_MUTANTS_BYTE_JOINS_VERIFIED')
