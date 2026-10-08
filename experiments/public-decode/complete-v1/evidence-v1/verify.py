#!/usr/bin/env python3
"""Verify exact retained development source/raw joins without child processes."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tarfile
import tempfile

HERE = Path(__file__).resolve().parent


def sha(value):
    return hashlib.sha256(value).hexdigest()


def verify():
    index = json.loads((HERE/'index.json').read_text())
    with tarfile.open(HERE/'evidence.tar.gz') as archive:
        members = archive.getmembers()
        assert len(members) == len(index) == len({m.name for m in members})
        assert {m.name for m in members} == set(index)
        assert all(m.isfile() and not Path(m.name).is_absolute() and '..' not in Path(m.name).parts for m in members)
        data = {m.name:archive.extractfile(m).read() for m in members}
    assert all(sha(value) == index[name] for name,value in data.items())
    origins = json.loads(data['source-origins.json'])
    expected_labels = {'paired-js-v1':['complete-emit','complete-run','bounded-emit','bounded-run'],
                       'native-v1':['complete-emit','complete-build','complete-run'],
                       'mutant-budget128-v1':['complete-emit','complete-run']}
    expected_caps = {'paired-js-v1':[30,5,30,5],'native-v1':[30,120,5],'mutant-budget128-v1':[30,5]}
    expected_status = {'paired-js-v1':'INCOMPLETE','native-v1':'DEVELOPMENT_PASS','mutant-budget128-v1':'MUTANT_DETECTED'}
    plans = {}
    for cohort, labels in expected_labels.items():
        prefix = 'development/'+cohort+'/'
        plan = json.loads(data[prefix+'plan.json'])
        receipt = json.loads(data[prefix+'receipt.json'])
        plans[cohort] = plan
        assert receipt['status'] == expected_status[cohort] and not receipt.get('guardFailures')
        assert [c['label'] for c in plan['commands']] == labels
        assert [c['capSeconds'] for c in plan['commands']] == expected_caps[cohort]
        assert len(receipt['commands']) == len(labels)
        for expected, actual in zip(plan['commands'],receipt['commands']):
            assert actual['argv'] == expected['argv'] and actual['capSeconds'] == expected['capSeconds']
            assert actual['exit'] == 0 and actual['failure'] is None
        assert set(receipt['logs']) == {label+suffix for label in labels for suffix in ('.stdout','.stderr')}
        for name,digest in receipt['logs'].items():
            assert sha(data[prefix+'raw/'+name]) == digest
        for name,row in origins[cohort].items():
            assert plan['inputs'][name] == row['sha256'] == sha(data[row['member']])
        assert set(origins[cohort]) == {p for p,h in plan['inputs'].items() if not isinstance(h,dict) and p.endswith(('.py','.bend'))}
    failed = json.loads(data['development/paired-js-v1/receipt.json'])
    assert failed['error'] == "AssertionError: ('controls.Observation', 'Observation')"
    native = data['development/native-v1/raw/complete-run.stdout']
    assert native == data['development/paired-js-v1/raw/complete-run.stdout']
    assert sha(native) == '917231359d590da45bf7de1bb02fab2b2dcdc42bbac801c7ec6fb15315e407cd'
    delta = json.loads(data['mutants/budget128-v1/delta.json'])
    assert [r['file'] for r in delta['files'] if r['changed']] == ['size.bend']
    original = next(data[r['member']] for p,r in origins['native-v1'].items() if p.endswith('/complete-v1/size.bend'))
    mutant = data['mutants/budget128-v1/stage/size.bend']
    expression = b'Nat.mul(4n,Nat.mul(codec_size(codec),Nat.add(raw_size(raw),1n)))'
    assert original.count(expression) == 1 and original.replace(expression,b'128n') == mutant
    for row in delta['files']:
        p = row['file']
        candidate = next(data[r['member']] for name,r in origins['native-v1'].items() if name.endswith('/complete-v1/'+p))
        mutated = data['mutants/budget128-v1/stage/'+p]
        assert sha(candidate) == row['originalSha256'] and sha(mutated) == row['mutantSha256']
        if p != 'size.bend':assert candidate == mutated
    negative = data['source-history/negative-owner-v1.stderr']
    assert b'owner (consumed more than once)' in negative and negative.count(b'Error:') == 1
    assert data['source-history/negative-owner-v1.stdout'] == b''
    oracle_complete = HERE.parent/'oracle-v1/expected-complete.json'
    oracle_bounded = HERE.parent/'oracle-v1/expected-bounded-v2.json'
    assert sha(oracle_complete.read_bytes()) == '13607718be581d8b76de1db1cc0e6439e0c60a7f5641a9dfd1eb4f7578cc83c2'
    assert sha(oracle_bounded.read_bytes()) == '09983234541bba0c32b230bfca75f63a4ff2131068d97fdd21f3cb8be6f77be0'
    with tempfile.TemporaryDirectory(prefix='bendvy-decode46-verify-') as folder:
        scratch = Path(folder)
        parser = scratch/'parse-report.py'
        helper = scratch/'check-observation.py'
        parser.write_bytes(data['verification/parse-report.py'])
        helper.write_bytes(data['verification/check-observation.py'])
        spec = importlib.util.spec_from_file_location('decode46_capsule_compare',helper)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        module.PARSER = parser
        for cohort, kind, oracle in [('paired-js-v1','complete',oracle_complete),('native-v1','complete',oracle_complete),
                                     ('paired-js-v1','bounded',oracle_bounded),('mutant-budget128-v1','complete',oracle_bounded)]:
            plan = plans[cohort]
            entry = Path(next(c['argv'][-3] for c in plan['commands'] if c['label'] == kind+'-emit'))
            raw = scratch/'observation.stdout'
            raw.write_bytes(data['development/'+cohort+'/raw/'+kind+'-run.stdout'])
            module.compare(raw,oracle,entry)
            if cohort == 'mutant-budget128-v1':
                try:module.compare(raw,oracle_complete,entry)
                except AssertionError as error:assert 'array128.checked' in str(error)
                else:raise AssertionError('Reached source mutant escaped complete oracle')
    return {'status':'DEVELOPMENT_EVIDENCE_PASS','members':len(data),'fullJsNativeSame':True,
            'reachedMutantRejected':True,'scope':__doc__,
            'limitations':'No external installed tool/environment/artifact portability or universal proof/performance/public adoption claim.'}


if __name__ == '__main__':
    print(json.dumps(verify()))
