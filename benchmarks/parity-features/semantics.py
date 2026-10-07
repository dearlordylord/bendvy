#!/usr/bin/env python3
"""Build and validate repeated complete feature lifecycles; no comparisons."""
import argparse,json,pathlib
from execute import Harness
import importlib.util
spec=importlib.util.spec_from_file_location("timer_preflight",pathlib.Path(__file__).with_name("timer-preflight.py"));timer_preflight=importlib.util.module_from_spec(spec);spec.loader.exec_module(timer_preflight)
fnv=timer_preflight.fnv
from validate import validate

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--features',nargs='+',choices=['nested','readers','fragments'],default=['nested','readers','fragments']);parser.add_argument('--stage',type=pathlib.Path,required=True);parser.add_argument('--output',type=pathlib.Path,required=True);args=parser.parse_args()
    harness=Harness(args.stage,args.output)
    harness.receipt['scope']='Full repeated feature observations; timer fields validate protocol only, no comparative timing or performance verdict'
    try:
        for feature in args.features:
            # Two successive lifecycles exercise fresh output/registration/cursor state.
            name=feature+'-2';commands=harness.build(name)
            for backend,command in commands.items():
                result=harness.run(name+'-semantic-'+backend,command,5)
                validate(feature,backend,result.stdout.decode('utf8'),2,harness.staged.get('nestedSpawn',False))
                timer=json.loads(result.stderr)
                assert timer['bytes']==len(result.stdout) and timer['digest']==fnv(result.stdout) and int(timer['elapsedNs'])>=0
        harness.guard();harness.receipt['status']='PASS';harness.receipt['repeatedLifecycles']=2;harness.receipt['features']=args.features
    finally:harness.save()
    print(json.dumps({'status':harness.receipt['status'],'output':str(args.output)}))

if __name__=='__main__':main()
