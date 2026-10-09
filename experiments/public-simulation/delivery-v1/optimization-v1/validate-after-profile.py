"""Whole unchanged JS application gate; profiles are whole-process diagnostics."""
import json,sys
from pathlib import Path
def validate(role,stdout,stderr):
    if role not in {'CPU','allocation'}or stderr or stdout!=Path('/tmp/bendvy63-named-loop-qualification-v1/JS-run.stdout').read_bytes():raise ValueError('full profiling semantic output required')
    comparator=sys.modules['simulation_delivery_compare'];comparator.validate_report(stdout,comparator.stage_joins(Path('/tmp/bendvy63-named-loop-stage-v1')))
    directory=Path('/tmp/bendvy63-named-loop-after-profile-v1')
    profile=json.loads((directory/('simulation.cpuprofile'if role=='CPU'else'simulation.heapprofile')).read_bytes())
    validate_shape(role,profile)
def validate_shape(role,profile):
    if role not in {'CPU','allocation'} or type(profile)is not dict:raise ValueError('declared complete profile object required')
    if role=='CPU':
        if not isinstance(profile.get('nodes'),list)or not profile['nodes']or len(profile.get('samples',[]))!=len(profile.get('timeDeltas',[])):raise ValueError('complete CPU profile shape required')
    elif not isinstance(profile.get('head'),dict)or not isinstance(profile.get('samples'),list):raise ValueError('complete sampling allocation profile shape required')
