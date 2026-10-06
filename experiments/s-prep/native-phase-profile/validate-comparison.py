#!/usr/bin/env python3
"""Validate retained adjacent raw executions; never restart or qualify timing."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('--input',type=Path,required=True)
a=p.parse_args()
root=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('V',root/'experiments/s-integrate/measurement-bend-run.py')
v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
r=json.loads((a.input/'evidence.json').read_text())
roles=['TS','combined','batched','boxed']
assert [c['role'] for c in r['commands']]==roles
outputs={}
for command in r['commands']:
    assert command['exit']==0 and command['limitSeconds']==5
    data=(a.input/(command['role']+'.txt')).read_bytes()
    assert hashlib.sha256(data).hexdigest()==command['outputSHA256']
    outputs[command['role']]=data.decode()
ts=json.loads(outputs['TS'])
assert ts['batch']==64 and ts['count']==256 and ts['iterations']==64
assert len(ts['samples'])==64
result={'status':'ONE_ADJACENT_ALL_FULL65_WORLDS_PASS','scope':'Single CPU11 adjacent raw diagnostic; no canonical cohort, noise qualification or adoption',
        'cpu':r['cpu'],'phaseMS':{'TS':ts['batchMilliseconds']},'allFullFieldsEqual':True,
        'executionReceiptSHA256':hashlib.sha256((a.input/'evidence.json').read_bytes()).hexdigest()}
for role in roles[1:]:
    lines=outputs[role].splitlines()
    records=[x for x in lines if x.startswith('{')]
    assert len(records)==65
    for line,w in zip(records,[ts['warmup'],*ts['samples']]):
        v.validate(line,'Motion',False,256,w)
        assert v.normalized(json.loads(line),'Motion')==w['final']
    clocks=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')]
    assert len(clocks)==1
    result['phaseMS'][role]=float(clocks[0].split(':',1)[1])
(a.input/'validation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
