#!/usr/bin/env python3
"""Synthetic boundary checks, no runtime samples or performance claim."""
import decision,json
from pathlib import Path
ref={k:[200]*14 for k in ['Native/Health','JS/Health','Native/Motion','JS/Motion']}
passvalues={k:[90 if k.startswith('Native') else 190]*14 for k in ref};good=decision.score(passvalues,ref);assert good['focusedGoalMet']
badvalues=dict(passvalues);badvalues['JS/Motion']=[201]*14;bad=decision.score(badvalues,ref);assert not bad['focusedGoalMet']
regressed=dict(passvalues);regressed['Native/Motion']=[91]*14;r=decision.score(regressed,ref);assert not decision.keep(r,good)
assert not decision.keep(good,good)
print(json.dumps({'status':'SYNTHETIC_GOAL_REGRESSION_AND_NO_CHANGE_CONTROLS_PASS','proposalOnly':True,'noMeasuredSamples':True}))
