"""Full unchanged output and internal-clock protocol; no performance decision."""
import json,sys
from pathlib import Path
def validate(role,stdout,stderr):
    if role not in {'TS','JS','Native'}:raise ValueError('declared backend required')
    lines=stderr.decode().splitlines()
    if len(lines)!=1:raise ValueError('one full timer protocol required')
    metric=json.loads(lines[0]);keys={'simulationNs','transportNs'}if role=='Native'else{'simulationNs','transportNs','bytes'}
    if set(metric)!=keys:raise ValueError('complete clock fields required')
    for key in ['simulationNs','transportNs']:
        if type(metric[key])is not str or not metric[key].isdecimal():raise ValueError('nonnegative string clock required')
    if role!='Native' and (type(metric['bytes'])is not int or metric['bytes']!=len(stdout)):raise ValueError('full UTF8 output count required')
    root=Path('/tmp/bendvy63-ordinary-delivery-v6')
    expected=root/('TS.stdout'if role=='TS'else'JS-run.stdout')
    if stdout!=expected.read_bytes():raise ValueError('entire original semantic output mismatch')
    if role!='TS':
        comparator=sys.modules['simulation_delivery_compare']
        comparator.validate_report(stdout,comparator.stage_joins(Path('/tmp/bendvy63-ordinary-delivery-stage-v1')))
