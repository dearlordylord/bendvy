#!/usr/bin/env python3
"""Synthetic boundaries only: no measured runtime samples or acceptance."""
import decision, json
ref={k:[200]*14 for k in decision.KEYS}
values={k:[90 if k.startswith('Native') else 190]*14 for k in ref}
good=decision.score(values,ref); assert good['focusedGoalMet']
bad=dict(values);bad['JS/Motion']=[190]*7+[205]*7
assert not decision.score(bad,ref)['focusedGoalMet'] # Second cohort cannot be pooled away.
for invalid in (True, float('nan'), float('inf'), 0, 2, -1, '90'):
    bad=dict(values);bad['Native/Motion']=[invalid]*14
    assert decision.score(bad,ref)['status']=='INVALID'
for invalid in ({}, {**values,'extra':[90]*14}):
    assert decision.score(invalid,ref)['status']=='INVALID'
bad=dict(values);bad['Native/Motion']=[90]*7+[110]*7
assert decision.score(bad,ref)['status']=='INCONCLUSIVE'
bad=dict(values);bad['Native/Motion']=[90,90,90,110,120,130,140]*2
assert decision.score(bad,ref)['status']=='INCONCLUSIVE'
r=dict(values);r['Native/Motion']=[91]*14
assert not decision.keep(decision.score(r,ref),good)
assert not decision.keep(good,good)
print(json.dumps({'status':'PER_COHORT_INVALID_NOISE_DRIFT_REGRESSION_CONTROLS_PASS','proposalOnly':True,'noMeasuredSamples':True}))
