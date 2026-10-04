#!/usr/bin/env python3
"""Malformed evidence and numerical boundary controls; never timing qualification."""
import copy
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('paired', HERE / 'paired-run.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)

cohorts = []
for role in ('reference', 'candidate', 'reference', 'candidate'):
    cohorts.append({'role': role, 'evidence': {
        'status': 'FINITE_FULL_FIELD_PASS', 'repetitions': 7,
        'resolutionLimited': False,
        'samples': [{'backend': b, 'repetition': i, 'milliseconds': 100.0,
                     'status': 'PASS'} for b in ('Native', 'TS', 'JS') for i in range(1, 8)]}})
receipts = []
answer = P.compare(cohorts)
assert answer['status'] == 'COMPLETE_COMPARISON'
assert all(v['percentile95High'] == 0 and v['percentile95Low'] == 0
           for c in answer['contrasts'] for v in c.values())
receipts.append({'control': 'identical constant cohorts', 'result': 'zero shift'})
assert P.bootstrap([100.0]*14, [80.0]*7)['percentile95High'] < -0.19
receipts.append({'control': 'known constant contrast', 'result': 'negative shift'})
assert not answer['proposedRuleReceipt']['experimentalKeepEligible']
improved = copy.deepcopy(cohorts)
for cohort in improved:
    if cohort['role'] == 'candidate':
        for sample in cohort['evidence']['samples']:
            if sample['backend'] == 'JS': sample['milliseconds'] = 80.0
assert P.compare(improved)['proposedRuleReceipt']['experimentalKeepEligible']
receipts.append({'control': 'constant improvement and unchanged Native/TS', 'result': 'proposed bounds pass; no keep authority'})
for backend, value, label in [('JS', 120.0, 'candidate JS cohort drift'), ('Native', 110.0, 'Native regression'), ('TS', 120.0, 'TS control drift')]:
    changed = copy.deepcopy(improved)
    subjects = [changed[1]] if label == 'candidate JS cohort drift' else [changed[1], changed[3]]
    for subject in subjects:
        for sample in subject['evidence']['samples']:
            if sample['backend'] == backend: sample['milliseconds'] = value
    assert not P.compare(changed)['proposedRuleReceipt']['experimentalKeepEligible']
    receipts.append({'control': label, 'result': 'not eligible'})
for name in ('duplicate repetition', 'missing sample', 'failed sample', 'NaN', 'infinity', 'zero', 'resolution limited', 'wrong repetitions'):
    changed = copy.deepcopy(cohorts)
    e = changed[1]['evidence']
    if name == 'duplicate repetition': e['samples'][0]['repetition'] = 2
    elif name == 'missing sample': e['samples'].pop()
    elif name == 'failed sample': e['samples'][0]['status'] = 'FAIL'
    elif name == 'NaN': e['samples'][0]['milliseconds'] = float('nan')
    elif name == 'infinity': e['samples'][0]['milliseconds'] = float('inf')
    elif name == 'zero': e['samples'][0]['milliseconds'] = 0
    elif name == 'resolution limited': e['resolutionLimited'] = True
    else: e['repetitions'] = 1
    assert P.compare(changed)['status'] == 'UNQUALIFIED', name
    receipts.append({'control': name, 'result': 'UNQUALIFIED'})
try:
    P.compare(cohorts[:3])
    raise AssertionError('incomplete roles accepted')
except ValueError:
    receipts.append({'control': 'missing cohort', 'result': 'rejected'})
for bad in ([], [0], [-1], [float('nan')], [float('inf')]):
    try:
        P.bootstrap([100], bad)
        raise AssertionError('invalid numerical input accepted')
    except ValueError:
        pass
receipts.append({'control': 'invalid bootstrap durations', 'result': 'rejected'})
print(json.dumps({'status': 'PASS', 'scope': 'Synthetic parser/comparison controls only; no performance evidence', 'controls': receipts}, indent=2))
