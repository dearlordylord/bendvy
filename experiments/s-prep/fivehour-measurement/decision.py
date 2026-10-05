#!/usr/bin/env python3
"""Unaccepted conservative per-cohort decision proposal; synthetic checks only."""
import math, random, statistics
KEYS = {'Native/Health', 'JS/Health', 'Native/Motion', 'JS/Motion'}
NOISE_LIMIT = 0.10

def samples(value):
    if not isinstance(value, list) or len(value) != 14:
        raise ValueError('exactly fourteen raw samples required')
    if any(isinstance(x, bool) or not isinstance(x, (int, float)) or not math.isfinite(x) or x <= 2 for x in value):
        raise ValueError('finite numeric raw batch milliseconds >2 required')
    return [[float(x) for x in value[:7]], [float(x) for x in value[7:]]]

def finite(value):
    if not math.isfinite(value) or value <= 0:
        raise ValueError('nonfinite or underflowed derived statistic')
    return value

def describe(v):
    median = finite(statistics.median(v))
    mad = statistics.median([abs(x-median) for x in v])
    if not math.isfinite(mad): raise ValueError('nonfinite MAD')
    return {'median': median, 'MAD': mad, 'relativeMAD': mad/median}

def score(candidates, references, seed=23):
    try:
        if not isinstance(candidates, dict) or not isinstance(references, dict) or set(candidates) != KEYS or set(references) != KEYS:
            raise ValueError('exact backend/schema keys required')
        rng = random.Random(seed); cells = {}; reasons = []
        for key in sorted(KEYS):
            cs, ts = samples(candidates[key]), samples(references[key]); cohorts = []
            for i in range(2):
                c, t = cs[i], ts[i]; cd, td = describe(c), describe(t)
                ratios = []
                for _ in range(10000):
                    cm = statistics.median(rng.choices(c, k=7)); tm = statistics.median(rng.choices(t, k=7))
                    ratios.append(finite((cm+2)/(tm-2)))
                upper = sorted(ratios)[9749]; factor = 2 if key.startswith('Native/') else 1
                weighted = finite(factor*upper)
                cohorts.append({'candidate': cd, 'TS': td, 'upper95TimerAwareRatio': upper, 'weightedScore': weighted})
                if max(cd['relativeMAD'], td['relativeMAD']) > NOISE_LIMIT:
                    reasons.append(f'{key}/cohort{i+1}: relative MAD exceeds proposed 10% noise limit')
            drift = {}
            for label in ('candidate', 'TS'):
                medians = [x[label]['median'] for x in cohorts]
                drift[label] = finite(max(medians)/min(medians))-1
                if drift[label] > NOISE_LIMIT:
                    reasons.append(f'{key}: {label} cohort median drift exceeds proposed 10% limit')
            cells[key] = {'cohorts': cohorts, 'drift': drift}
        if reasons:
            return {'status': 'INCONCLUSIVE', 'reasons': reasons, 'cells': cells, 'metric': None, 'focusedGoalMet': False, 'productAcceptance': False}
        metric = max(x['weightedScore'] for cell in cells.values() for x in cell['cohorts'])
        return {'status': 'QUALIFIED_PROPOSAL', 'metric': metric, 'cells': cells, 'focusedGoalMet': metric <= 1, 'productAcceptance': False}
    except (ValueError, OverflowError, TypeError) as e:
        return {'status': 'INVALID', 'reason': str(e), 'metric': None, 'focusedGoalMet': False, 'productAcceptance': False}

def keep(current, best):
    if current.get('status') != 'QUALIFIED_PROPOSAL' or best.get('status') != 'QUALIFIED_PROPOSAL':
        return False
    return current['metric'] < best['metric'] and all(current['cells'][k]['cohorts'][i]['upper95TimerAwareRatio'] <= best['cells'][k]['cohorts'][i]['upper95TimerAwareRatio'] for k in KEYS for i in range(2))
