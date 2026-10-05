#!/usr/bin/env python3
"""Pure parity decision with approved targets and unapproved comparison rules; --synthetic writes only a synthetic receipt.

README / limitations: compare candidate Native/JS only with fresh actual TS in
that SAME cohort. Require two independently identified seven-sample cohorts.
The user approves Native speedup >=2 and JS/TS time <=1. Native factor defaults
to 2; a stricter factor may be requested, but the approved minimum cannot be lowered.
The 10% median/MAD noise guard and +/-2ms integer-timer endpoint allowance are
proposals, not approved rules. Bootstrap intervals describe sampling uncertainty,
not causal guarantees. A qualified success is a synthetic/proposed decision,
never product adoption, contract acceptance, or permission to run a session.
IDs are labels, not proof of independent freshness or source/tool provenance.
No benchmark execution, core edits, imports with side effects, or dependencies.
"""
import json
import math
from pathlib import Path
import random
import statistics


def bootstrap_ratios(reference, candidate):
    """Direct positive ratios: never subtract then re-add one."""
    ratios = [a/b for a in candidate for b in reference]
    if any(not math.isfinite(x) or x <= 0 for x in ratios):
        raise ValueError('nonfinite/nonpositive derived ratio')
    rng = random.Random(23)
    draws = sorted(statistics.median(rng.choices(candidate, k=len(candidate))) /
                   statistics.median(rng.choices(reference, k=len(reference)))
                   for _ in range(10000))
    result = {'medianRatio': statistics.median(candidate)/statistics.median(reference),
              'bootstrapUpperRatio': draws[9749], 'bootstrapLowerRatio': draws[250]}
    if any(not math.isfinite(x) or x <= 0 for x in result.values()):
        raise ValueError('nonfinite/nonpositive bootstrap bound')
    return result


def decide(cohorts, *, native_factor=2):
    """Return raw contrasts separately from uncertainty-qualified proposed success."""
    result = {'status': 'INCONCLUSIVE', 'qualifiedSuccess': False, 'rawTargetMet': None,
              'cohorts': [], 'nativeFactor': native_factor, 'rulesAccepted': False,
              'proposedTimerAllowanceMilliseconds': 2, 'proposedNoiseLimit': 0.10,
              'userApprovedNativeMinimumFactor': 2, 'userApprovedJsTimeRatioLimit': 1.0,
              'provenanceVerified': False, 'provenanceLimit': 'IDs are labels only; independent freshness and source/tool closure require external validation'}
    if isinstance(native_factor, bool) or not isinstance(native_factor, (int, float)) or not math.isfinite(native_factor) or native_factor < 2:
        return dict(result, reason='finite native_factor >= user-approved minimum 2 required')
    native_limit = 1/native_factor
    if not math.isfinite(native_limit) or native_limit <= 0:
        return dict(result, reason='Native inverse-factor underflow/nonfinite bound')
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
        if any((not math.isfinite(a/b) or a/b <= 0) for times in values.values() for a in times for b in values['TS']):
            reasons.append('nonfinite derived ratio');continue
        record = {'id': cohort.get('id'), 'raw': {}, 'conservative': {}, 'relativeMAD': {}}
        for backend, times in values.items():
            median = statistics.median(times);medians[backend].append(median)
            record['relativeMAD'][backend] = statistics.median([abs(t-median) for t in times])/median
            if record['relativeMAD'][backend] > 0.10:reasons.append('within-cohort noise')
        for backend in ('JS', 'Native'):
            record['raw'][backend] = bootstrap_ratios(values['TS'], values[backend])
            if any(t <= 2 for times in values.values() for t in times):
                reasons.append('integer timer uncertainty consumes a duration')
            else:
                try:
                    record['conservative'][backend] = bootstrap_ratios([t-2 for t in values['TS']], [t+2 for t in values[backend]])
                except ValueError as exc:
                    reasons.append(str(exc))
        result['cohorts'].append(record)
    if len(ids) != 2 or any(not isinstance(i, str) or not i for i in ids) or ids[0] == ids[1]:reasons.append('missing/distinct independent cohort identities required')
    if len(result['cohorts']) == 2:
        result['rawTargetMet'] = all(c['raw']['JS']['medianRatio'] <= 1 and c['raw']['Native']['medianRatio'] <= native_limit for c in result['cohorts'])
        drift = {b: max(v)/min(v)-1 for b,v in medians.items()}
        result['cohortMedianDrift'] = drift
        if any(d > 0.10 for d in drift.values()):reasons.append('fresh TS drift or backend cohort noise')
    if reasons:
        return dict(result, reasons=sorted(set(reasons)))
    qualified = all(c['conservative']['JS']['bootstrapUpperRatio'] <= 1 and c['conservative']['Native']['bootstrapUpperRatio'] <= native_limit for c in result['cohorts'])
    return dict(result, status='PROPOSED_TARGET_MET' if qualified else 'PROPOSED_TARGET_MISSED', qualifiedSuccess=qualified)


def synthetic():
    def cohorts(js=80, native=30, ts=100):
        return [{'id': f'independent-{i}', 'evidence': {'status': 'FINITE_FULL_FIELD_PASS', 'repetitions': 7, 'resolutionLimited': False, 'samples': [{'backend': b, 'repetition': r, 'status': 'PASS', 'milliseconds': t} for b,t in [('TS',ts),('JS',js),('Native',native)] for r in range(1,8)]}} for i in range(2)]
    cases = {'success': cohorts(), 'parity-fail': cohorts(js=110), 'native-fail': cohorts(native=60), 'timer-resolution': cohorts(js=2,native=1,ts=2), 'raw-only-parity': cohorts(js=100)}
    cases['noise'] = cohorts();cases['noise'][1]['evidence']['samples'] = [{**s, 'milliseconds': s['milliseconds']*1.5} for s in cases['noise'][1]['evidence']['samples']]
    cases['invalid'] = cohorts();cases['invalid'][0]['evidence']['samples'][0]['milliseconds'] = float('nan')
    cases['missing'] = cohorts();cases['missing'][0]['evidence']['samples'].pop()
    results = {name: decide(c, native_factor=2) for name,c in cases.items()}
    results['tiny-positive-reproducer'] = decide(cohorts(js=3,native=3,ts=1e308), native_factor=1e308)
    tiny = results['tiny-positive-reproducer']
    assert tiny['status'] == 'PROPOSED_TARGET_MISSED' and not tiny['qualifiedSuccess']
    assert 0 < tiny['cohorts'][0]['raw']['Native']['medianRatio'] < 1e-307
    assert tiny['cohorts'][0]['conservative']['Native']['bootstrapUpperRatio'] > 1e-308
    results['weakened-native-target'] = decide(cohorts(native=60), native_factor=1.5)
    assert results['weakened-native-target']['status'] == 'INCONCLUSIVE'
    assert not results['weakened-native-target']['qualifiedSuccess']
    assert decide(cohorts())['nativeFactor'] == 2
    results['derived-underflow'] = decide(cohorts(js=1e-308,native=1e-308,ts=1e308), native_factor=2)
    assert results['derived-underflow']['status'] == 'INCONCLUSIVE'
    assert results['success']['qualifiedSuccess']
    assert all(results[n]['status']=='PROPOSED_TARGET_MISSED' for n in ('parity-fail','native-fail','raw-only-parity'))
    assert results['raw-only-parity']['rawTargetMet'] and not results['raw-only-parity']['qualifiedSuccess']
    assert all(results[n]['status']=='INCONCLUSIVE' for n in ('noise','invalid','missing','timer-resolution'))
    assert decide(cohorts(),native_factor=None)['status']=='INCONCLUSIVE'
    return {'syntheticOnly': True, 'benchmarkExecuted': False, 'contractAccepted': False, 'userApprovedTargets': {'JS/TS': 1.0, 'Native/TS': 0.5}, 'controls': results, 'limitations': __doc__}


if __name__ == '__main__':
    import sys
    if sys.argv[1:] != ['--synthetic']:raise SystemExit('Only --synthetic is supported; no benchmark/session execution')
    Path(__file__).with_name('parity-synthetic-receipt.json').write_text(json.dumps(synthetic(),indent=2,allow_nan=False)+'\n')
    print('PASS synthetic parity controls; rules unapproved')
