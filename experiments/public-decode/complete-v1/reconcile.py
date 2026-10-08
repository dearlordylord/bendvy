#!/usr/bin/env python3
"""Join retained backend results to corrected helpers/oracles without replay."""
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE/'development/paired-js-v1'


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    plan = json.loads((OUT/'plan.json').read_text())
    receipt = json.loads((OUT/'receipt.json').read_text())
    assert receipt['status'] == 'INCOMPLETE' and receipt['guardFailures'] == []
    assert receipt['error'] == "AssertionError: ('controls.Observation', 'Observation')"
    aliases = {str(HERE/'check-observation.py'): OUT/'failed-comparator/check-observation.py',
               str(HERE/'development-run.py'): OUT/'failed-comparator/development-run.py'}
    for name, expected in plan['inputs'].items():
        if isinstance(expected,dict):
            root = Path(name)
            actual = {str(p.relative_to(root)):sha(p) for p in sorted(root.rglob('*')) if p.is_file()}
            assert actual == expected, ('Recorded directory drift',name)
        else:
            path = aliases.get(name,Path(name))
            assert sha(path) == expected, ('Recorded input drift',name)
    old = aliases[str(HERE/'check-observation.py')].read_text()
    new = (HERE/'check-observation.py').read_text()
    corrected = old.replace("constructor(value,'Observation',3,entry.stem)","constructor(value,'Observation',3)")
    corrected = corrected.replace("    equal(actual,json.loads(expected.read_text()))", "    try:\n        equal(actual,json.loads(expected.read_text()))\n    except AssertionError as error:\n        error.actual = actual\n        raise")
    assert corrected == new
    assert [c['label'] for c in plan['commands']] == ['complete-emit','complete-run','bounded-emit','bounded-run']
    assert [c['capSeconds'] for c in plan['commands']] == [30,5,30,5]
    assert len(receipt['commands']) == 4
    for expected, actual in zip(plan['commands'],receipt['commands']):
        assert actual['argv'] == expected['argv'] and actual['capSeconds'] == expected['capSeconds']
        assert actual['exit'] == 0 and actual['failure'] is None
    assert set(receipt['logs']) == {label+suffix for label in ('complete-emit','complete-run','bounded-emit','bounded-run') for suffix in ('.stdout','.stderr')}
    for name, expected in receipt['logs'].items():
        assert sha(OUT/'raw'/name) == expected
    for name, expected in receipt['generated'].items():
        assert sha(name) == expected
    spec = importlib.util.spec_from_file_location('complete_decode_compare',HERE/'check-observation.py')
    comparison = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(comparison)
    oracle_paths = [HERE/'oracle-v1/expected-complete.json',HERE/'oracle-v1/expected-bounded-v2.json']
    assert [sha(p) for p in oracle_paths] == ['13607718be581d8b76de1db1cc0e6439e0c60a7f5641a9dfd1eb4f7578cc83c2','09983234541bba0c32b230bfca75f63a4ff2131068d97fdd21f3cb8be6f77be0']
    for kind, oracle in zip(('complete','bounded'),oracle_paths):
        result = comparison.compare(OUT/'raw'/(kind+'-run.stdout'),oracle,HERE/('controls.bend' if kind=='complete' else 'bounded-controls.bend'))
        (OUT/(kind+'-reconciled.json')).write_text(json.dumps(result,indent=2)+'\n')
    record = {'status':'DEVELOPMENT_RECONCILIATION_PASS','scope':__doc__,
              'originalPlanSha256':sha(OUT/'plan.json'),'originalReceiptSha256':sha(OUT/'receipt.json'),
              'comparisonSha256':sha(HERE/'check-observation.py'),'oracleSha256':[sha(p) for p in oracle_paths],
              'actualStdoutSha256':{kind:sha(OUT/'raw'/(kind+'-run.stdout')) for kind in ('complete','bounded')},
              'limitations':'Historical original INCOMPLETE receipt preserved; no backend replay, Native/tool/delivery/performance acceptance from this reconciliation.'}
    (OUT/'reconciliation.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(record))


if __name__ == '__main__':
    main()
