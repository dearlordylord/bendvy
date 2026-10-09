"""Whole output and clock protocol bound to the admitted plan."""
import hashlib,json,sys
from pathlib import Path
PLAN_BOUND = True

def expected_output(plan, role):
    path = Path(plan['validationInputs']['expectedOutputs'][role])
    if not path.is_absolute() or path.is_symlink() or not path.is_file():
        raise ValueError('regular absolute expected output required')
    raw = path.read_bytes()
    if plan['pins'].get(str(path)) != hashlib.sha256(raw).hexdigest():
        raise ValueError('expected output must match its admitted pin')
    return raw

def validate(role, stdout, stderr, *, plan):
    if role not in {'TS','JS','Native'}:raise ValueError('declared backend required')
    lines=stderr.decode().splitlines()
    if len(lines)!=1:raise ValueError('one full timer protocol required')
    metric=json.loads(lines[0]);keys={'simulationNs','transportNs'}if role=='Native'else{'simulationNs','transportNs','bytes'}
    if set(metric)!=keys:raise ValueError('complete clock fields required')
    for key in ['simulationNs','transportNs']:
        if type(metric[key])is not str or not metric[key].isdecimal():raise ValueError('nonnegative string clock required')
    if role!='Native' and (type(metric['bytes'])is not int or metric['bytes']!=len(stdout)):raise ValueError('full UTF8 output count required')
    if stdout!=expected_output(plan,role):raise ValueError('entire original semantic output mismatch')
    if role!='TS':
        comparator=sys.modules['simulation_delivery_compare']
        comparator.validate_report(stdout,comparator.stage_joins(Path(plan['stageRoot'])))
