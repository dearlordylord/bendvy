#!/usr/bin/env python3
"""Pure, unapproved parity proposal; --synthetic writes only a synthetic receipt.

README / limitations: compare candidate Native/JS only with fresh actual TS in
that SAME cohort. Require two independently identified seven-sample cohorts.
Native factor must be supplied (>1); no numerical product minimum is inferred.
The 10% median/MAD noise guard and +/-2ms integer-timer endpoint allowance are
proposals, not approved rules. Bootstrap intervals describe sampling uncertainty,
not causal guarantees. A qualified success is a synthetic/proposed decision,
never product adoption, contract acceptance, or permission to run a session.
No benchmark execution, core edits, imports with side effects, or dependencies.
"""
import importlib.util
import json
import math
from pathlib import Path
import statistics

_spec = importlib.util.spec_from_file_location('paired_proposal', Path(__file__).with_name('paired-run.py'))
_paired = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_paired)


def decide(cohorts, *, native_factor):
    """Return raw contrasts separately from uncertainty-qualified proposed success."""
    result = {'status': 'INCONCLUSIVE', 'qualifiedSuccess': False, 'rawTargetMet': None,
              'cohorts': [], 'nativeFactor': native_factor, 'rulesAccepted': False,
              'proposedTimerAllowanceMilliseconds': 2, 'proposedNoiseLimit': 0.10}
    if isinstance(native_factor, bool) or not isinstance(native_factor, (int, float)) or not math.isfinite(native_factor) or native_factor <= 1:
        return dict(result, reason='explicit finite native_factor > 1 required')
    if not isinstance(cohorts, list) or len(cohorts) != 2:
        return dict(result, reason='exactly two independent cohorts required')
    reasons = []
    medians = {b: [] for b in ('TS', 'JS', 'Native')}
    ids = []
    for cohort in cohorts:
        if not isinstance(cohort, dict):
            reasons.append('missing cohort');continue
        ids.append(cohort.get('id'))
        d = cohort.get('evidence', {})
        if not isinstance(d, dict):
            reasons.append('missing evidence');continue
        if d.get('status') != 'FINITE_FULL_FIELD_PASS' or d.get('repetitions') != 7 or d.get('resolutionLimited') is not False:
            reasons.append('failed/incomplete/resolution-limited cohort')
        samples = d.get('samples', [])
        if not isinstance(samples, list):
            reasons.append('missing samples');continue
        values = {}
        for backend in medians:
            items = [s for s in samples if isinstance(s, dict) and s.get('backend') == backend]
            if len(items) != 7 or any(type(s.get('repetition')) is not int for s in items) or {s.get('repetition') for s in items} != set(range(1, 8)) or any(s.get('status') != 'PASS' or isinstance(s.get('milliseconds'), bool) or not isinstance(s.get('milliseconds'), (int, float)) or not math.isfinite(s['milliseconds']) or s['milliseconds'] <= 0 for s in items):
                reasons.append('missing/nonfinite/nonpositive/full-field-failed sample');break
            values[backend] = [s['milliseconds'] for s in items]
        if len(values) != 3:continue
        if any(not math.isfinite(a/b) for times in values.values() for a in times for b in values['TS']):
            reasons.append('nonfinite derived ratio');continue
        record = {'id': cohort.get('id'), 'raw': {}, 'conservative': {}, 'relativeMAD': {}}
        for backend, times in values.items():
            median = statistics.median(times);medians[backend].append(median)
            record['relativeMAD'][backend] = statistics.median([abs(t-median) for t in times])/median
            if record['relativeMAD'][backend] > 0.10:reasons.append('within-cohort noise')
        for backend in ('JS', 'Native'):
            raw = _paired.bootstrap(values['TS'], values[backend])
            record['raw'][backend] = {'medianRatio': raw['medianRelativeShift']+1, 'bootstrapUpperRatio': raw['percentile95High']+1, 'bootstrapLowerRatio': raw['percentile95Low']+1}
            if any(t <= 2 for times in values.values() for t in times):
                reasons.append('integer timer uncertainty consumes a duration')
            else:
                bound = _paired.bootstrap([t-2 for t in values['TS']], [t+2 for t in values[backend]])
                record['conservative'][backend] = {'bootstrapUpperRatio': bound['percentile95High']+1}
        result['cohorts'].append(record)
    if len(ids) != 2 or any(not isinstance(i, str) or not i for i in ids) or ids[0] == ids[1]:reasons.append('missing/distinct independent cohort identities required')
    if len(result['cohorts']) == 2:
        result['rawTargetMet'] = all(c['raw']['JS']['medianRatio'] <= 1 and c['raw']['Native']['medianRatio'] <= 1/native_factor for c in result['cohorts'])
        drift = {b: max(v)/min(v)-1 for b,v in medians.items()}
        result['cohortMedianDrift'] = drift
        if any(d > 0.10 for d in drift.values()):reasons.append('fresh TS drift or backend cohort noise')
    if reasons:
        return dict(result, reasons=sorted(set(reasons)))
    qualified = all(c['conservative']['JS']['bootstrapUpperRatio'] <= 1 and c['conservative']['Native']['bootstrapUpperRatio'] <= 1/native_factor for c in result['cohorts'])
    return dict(result, status='PROPOSED_TARGET_MET' if qualified else 'PROPOSED_TARGET_MISSED', qualifiedSuccess=qualified)


def synthetic():
    def cohorts(js=80, native=30, ts=100):
        return [{'id': f'independent-{i}', 'evidence': {'status': 'FINITE_FULL_FIELD_PASS', 'repetitions': 7, 'resolutionLimited': False, 'samples': [{'backend': b, 'repetition': r, 'status': 'PASS', 'milliseconds': t} for b,t in [('TS',ts),('JS',js),('Native',native)] for r in range(1,8)]}} for i in range(2)]
    cases = {'success': cohorts(), 'parity-fail': cohorts(js=110), 'native-fail': cohorts(native=60), 'timer-resolution': cohorts(js=2,native=1,ts=2), 'raw-only-parity': cohorts(js=100)}
    cases['noise'] = cohorts();cases['noise'][1]['evidence']['samples'] = [{**s, 'milliseconds': s['milliseconds']*1.5} for s in cases['noise'][1]['evidence']['samples']]
    cases['invalid'] = cohorts();cases['invalid'][0]['evidence']['samples'][0]['milliseconds'] = float('nan')
    cases['missing'] = cohorts();cases['missing'][0]['evidence']['samples'].pop()
    results = {name: decide(c, native_factor=2) for name,c in cases.items()}
    assert results['success']['qualifiedSuccess']
    assert all(results[n]['status']=='PROPOSED_TARGET_MISSED' for n in ('parity-fail','native-fail','raw-only-parity'))
    assert results['raw-only-parity']['rawTargetMet'] and not results['raw-only-parity']['qualifiedSuccess']
    assert all(results[n]['status']=='INCONCLUSIVE' for n in ('noise','invalid','missing','timer-resolution'))
    assert decide(cohorts(),native_factor=None)['status']=='INCONCLUSIVE'
    return {'syntheticOnly': True, 'benchmarkExecuted': False, 'contractAccepted': False, 'factor2SyntheticFixtureOnly': True, 'controls': results, 'limitations': __doc__}


if __name__ == '__main__':
    import sys
    if sys.argv[1:] != ['--synthetic']:raise SystemExit('Only --synthetic is supported; no benchmark/session execution')
    Path(__file__).with_name('parity-synthetic-receipt.json').write_text(json.dumps(synthetic(),indent=2,allow_nan=False)+'\n')
    print('PASS synthetic parity controls; rules unapproved')
