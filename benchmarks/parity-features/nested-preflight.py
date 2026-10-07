#!/usr/bin/env python3
"""Guarded fresh TS observations and staged Bend type diagnostic; no backend timing."""
import argparse,json,pathlib
from execute import Harness
from validate import validate
import importlib.util
spec=importlib.util.spec_from_file_location('timer_preflight',pathlib.Path(__file__).with_name('timer-preflight.py'))
timer=importlib.util.module_from_spec(spec);spec.loader.exec_module(timer)

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--stage',type=pathlib.Path,required=True);parser.add_argument('--output',type=pathlib.Path,required=True);args=parser.parse_args()
    h=Harness(args.stage,args.output)
    assert h.staged.get('nestedSpawn') is True
    try:
        result=h.run('nested-2-TS',[h.tools['node'],h.stage/'feature-harness/nested-2.mjs'],5)
        validate('nested','TS',result.stdout.decode('utf8'),2,True)
        region=json.loads(result.stderr)
        assert region['bytes']==len(result.stdout) and region['digest']==timer.fnv(result.stdout)
        result=h.run('nested-2-check',[h.tools['bend'],h.stage/'feature-harness/nested-2.bend','--check-only'],5,False)
        assert b'defs rely on unsafe or foreign code' in result.stderr and b'timing.capture' in result.stderr,result.stderr
        h.guard();h.receipt.update(status='NESTED_TS_AND_FOREIGN_BOUNDARY_PREFLIGHT_PASS',scope='Two fresh complete TS lifecycles plus staged Bend type diagnostics. No generated Bend execution, comparable timing, safe-core proof or performance acceptance.')
    finally:h.save()
    print(json.dumps({'status':h.receipt['status'],'output':str(args.output)}))
if __name__=='__main__':main()
