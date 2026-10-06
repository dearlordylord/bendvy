#!/usr/bin/env python3
"""Run unchanged protected source controls with explicit approved Clang19."""
import argparse, hashlib, importlib.machinery, importlib.util, json, os, pathlib, sys
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--kind',choices=['tx','factory','access'],required=True);p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
os.environ['BENDVY_CHECKER_SECONDS']='15'
os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
os.sched_setaffinity(0,{8})
original=importlib.machinery.SourceFileLoader.exec_module
commands=[]
def intercepted(loader,module):
 original(loader,module)
 if pathlib.Path(loader.path).resolve()==(ROOT/'experiments/t05/run.py').resolve():
  command=module.command
  def explicit(args,expected=0,timeout=5):
   args=list(args)
   if str(args[0])=='clang':args[0]='/tmp/bendvy-clang19-diagnostic/clang19'
   commands.append({'argv':list(map(str,args)),'expectedExit':expected,'limitSeconds':15 if '--check-only' in list(map(str,args)) else timeout})
   return command(args,expected=expected,timeout=timeout)
  module.command=explicit
importlib.machinery.SourceFileLoader.exec_module=intercepted
folder=ROOT/'experiments/s-prep/fivehour-connected-gates'
name={'tx':'tx-controls-run.py','factory':'static-world-run.py','access':'access-run.py'}[a.kind]
runner=folder/name;sys.path.insert(0,str(folder))
sys.argv=[str(runner),*( [str(a.overlay),'--evidence',str(a.output)] if a.kind=='access' else ['--overlay',str(a.overlay),'--output',str(a.output)]),'--cpu','8',*(['--split-schemas'] if a.kind=='tx' else [])]
try:
 spec=importlib.util.spec_from_file_location('protected_source_control',runner);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 if a.kind!='access':m.main()
finally:
 target=a.output.parent/(a.output.name+'.adapter.json')
 target.write_text(json.dumps({'protectedRunner':str(runner),'protectedRunnerSHA256':hashlib.sha256(runner.read_bytes()).hexdigest(),'adapterSHA256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'changes':'Only explicit approved Clang19 executable and process-local checker diagnostic limit; fixtures/oracles unchanged','commands':commands},indent=2)+'\n')
