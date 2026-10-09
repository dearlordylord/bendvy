"""Whole output and generated profiles bound to the admitted plan."""
import hashlib,json,sys
from pathlib import Path
PLAN_BOUND = True

def validate(role, stdout, stderr, *, plan):
    if role not in {'CPU','allocation'} or stderr:raise ValueError('full profiling semantic output required')
    expected=Path(plan['validationInputs']['expectedOutputs']['JS'])
    if not expected.is_absolute() or expected.is_symlink() or not expected.is_file():raise ValueError('regular absolute expected output required')
    raw=expected.read_bytes()
    if plan['pins'].get(str(expected))!=hashlib.sha256(raw).hexdigest():raise ValueError('expected output must match its admitted pin')
    if stdout!=raw:raise ValueError('full profiling semantic output required')
    comparator=sys.modules['simulation_delivery_compare'];comparator.validate_report(stdout,comparator.stage_joins(Path(plan['stageRoot'])))
    commands=[command for command in plan['commands'] if command.get('control')==role]
    if len(commands)!=1:raise ValueError('one declared profile command required')
    name=commands[0].get('emits')
    if not isinstance(name,str) or Path(name).name!=name or name in {'','.','..'}:raise ValueError('declared profile filename required')
    directory=Path(plan['outputRoot'])
    if not directory.is_absolute() or directory.is_symlink():raise ValueError('absolute profile directory required')
    path=directory/name
    if path.is_symlink() or not path.is_file():raise ValueError('regular current profile required')
    validate_shape(role,json.loads(path.read_bytes()))

def validate_shape(role,profile):
    if role not in {'CPU','allocation'} or type(profile)is not dict:raise ValueError('declared complete profile object required')
    if role=='CPU':
        if not isinstance(profile.get('nodes'),list)or not profile['nodes']or len(profile.get('samples',[]))!=len(profile.get('timeDeltas',[])):raise ValueError('complete CPU profile shape required')
    elif not isinstance(profile.get('head'),dict)or not isinstance(profile.get('samples'),list):raise ValueError('complete sampling allocation profile shape required')
