#!/usr/bin/env python3
"""Proposed timer-aware paired-bootstrap decision; contract acceptance pending."""
import random,statistics

def score(candidates,references,seed=23):
    """Raw batch milliseconds, same B. Separate backend/schema guard, no pooling."""
    rng=random.Random(seed);cells={}
    for key,values in sorted(candidates.items()):
        reference=references[key]
        assert len(values)==len(reference)==14 and min(values)>2 and min(reference)>2
        ratios=[]
        for _ in range(10000):
            c=statistics.median(rng.choices(values,k=14));t=statistics.median(rng.choices(reference,k=14))
            ratios.append((c+2)/(t-2))
        upper=sorted(ratios)[9749];factor=2 if key.startswith('Native/') else 1
        cells[key]={'upper95TimerAwareRatio':upper,'weightedScore':factor*upper,'targetRatio':1/factor}
    assert set(cells)=={'Native/Health','JS/Health','Native/Motion','JS/Motion'}
    return {'metric':max(x['weightedScore'] for x in cells.values()),'cells':cells,'focusedGoalMet':all(x['weightedScore']<=1 for x in cells.values()),'productAcceptance':False}

def keep(current,best):
    # Reject uncertain score improvements or a known cell regression.
    return current['metric']<best['metric'] and all(current['cells'][k]['upper95TimerAwareRatio']<=best['cells'][k]['upper95TimerAwareRatio'] for k in best['cells'])
