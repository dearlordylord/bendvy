"""Verify archived current-core Native mutant source/raw/full union; no children."""
import argparse
import hashlib
import io
import json
import tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
p=argparse.ArgumentParser();p.add_argument('variant',choices=['whole-marker-rollback','lost-retry','premature-publication']);v=p.parse_args().variant
OUT=H/('delivery-adoption-native-mutant-'+v+'-v1');m=json.loads((OUT/'manifest.json').read_text())
assert m['variant']==v and not any(m[k] for k in ['completeIssue49','proofCredit','productionAdopted','performanceQualified'])
for n,h in m['source'].items():assert sha((H/n).read_bytes())==h
assert sha((OUT/'REPORT.md').read_bytes())==m['reportSHA256']
def archive(blob,members):
    with tarfile.open(fileobj=io.BytesIO(blob),mode='r:gz') as t:
        assert set(t.getnames())==set(members);result={}
        for n,record in members.items():
            assert 'private-environment' not in n
            b=t.extractfile(n).read();assert sha(b)==record['sha256'] and len(b)==record['bytes'];result[n]=b
    return result
jmfile=H/'delivery-adoption-mutants-js-v1/manifest.json';assert sha(jmfile.read_bytes())==m['jsCapsuleManifestSHA256'];jm=json.loads(jmfile.read_text());ja=jm['archives']['js'];jblob=(jmfile.parent/ja['archive']).read_bytes();assert sha(jblob)==ja['sha256'];j=archive(jblob,ja['members'])
assert sha(j['receipt.json'])==m['jsReceiptSHA256']
a=m['archive'];blob=(OUT/a['name']).read_bytes();assert sha(blob)==a['sha256'];d=archive(blob,a['members']);plan=json.loads(d['plan.json']);r=json.loads(d['receipt.json'])
assert r['status']=='PROPOSED_HANDLER_EXTRACTION_ONE_MUTANT_NATIVE_FULL96_AND12_UNION_PASS' and r['planSHA256']==sha(d['plan.json']) and plan['variant']==v
assert len(r['commands'])==len(plan['commands'])==(20 if v=='premature-publication' else 8)
assert r['probeCommandsExecuted']==plan['expectedProbeCount']==(205 if v=='premature-publication' else 85)
assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
for n,h in plan['inventory'].items():assert sha(d['stage/'+n])==h
for path,h in r['probePins'].items():assert sha(d[str(Path(path).relative_to(a['historicalDirectory']))])==h
for path,h in r['generated'].items():
    name=str(Path(path).relative_to(a['historicalDirectory']))
    if name.endswith('.c'):assert sha(d[name])==h
    else:assert path.endswith('-native') and len(h)==64
for n,h in r['logs'].items():assert sha(d[n])==h
assert all(not d[c['label']+'.stderr'] for c in plan['commands'])
jsplan=json.loads(j['plan.json']);names=[f'schema{s}_{phase}{i}{suffix}' for s in ['A','B'] for phase in ['exit','transition','enter'] for i in [0,1] for suffix in ['','_missing']]
model=json.loads(j['stage/'+v+'/experiments/public-machine-handlers/candidate-v1/full-mutant-'+v+'-expected.json'])['bend'];assert set(model)==set(names)
assert sum(len(model[n]) for n in names if not n.endswith('_missing'))==96 and sum(n.endswith('_missing') for n in names)==12
union=b'';selectednames=[]
for label,root in plan['nominalRoots'].items():
    stage=Path(root['stage']);relative=str(stage.relative_to(plan['stage']));f='stage/'+relative+'/'
    for rel,h in root['inventory'].items():assert sha(d[f+rel])==h
    for rel,h in jsplan['inventory'].items():
        if rel.startswith(v+'/'):assert sha(d[f+rel[len(v)+1:]])==h
    wanted=''.join(n+'|['+', '.join(model[n])+']\n' for n in root['names']).encode()
    assert sha(wanted)==root['expectedSHA256'] and d[f+'expected.stdout']==wanted
    assert d[label+'-source.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
    assert d[label+'-run.stdout']==wanted;union+=d[label+'-run.stdout'];selectednames.extend(root['names'])
    entryrel=str(Path(root['entry']).relative_to(stage));assert sha(d[f+entryrel])==root['wrapperSHA256']
assert selectednames==names
wanted=''.join(n+'|['+', '.join(model[n])+']\n' for n in names).encode()
assert union==wanted==d[v+'-full96-and12-union.stdout'] and sha(union)==r['unions'][v]
print('FINITE_CURRENT_CORE_NATIVE_'+v.upper().replace('-','_')+'_FULL96_AND12_BYTE_JOINS_VERIFIED')
