#!/usr/bin/env python3
"""Perturb actual captured timed TS reader outputs; do not replace runtime gates."""
import copy,hashlib,importlib.util,json,os,pathlib
HERE=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('samples',HERE/'measurement-samples-readers-run.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
def main():
 os.sched_setaffinity(0,{6})
 ref=json.loads(R.B.command(['node',HERE/'measurement-reference.mjs','Motion','readers','64']))
 actual=json.loads(R.B.command(['node',HERE/'measurement-samples-readers-reference.mjs','Motion','64']))
 R.checked('TS',json.dumps(actual),'Motion',64,ref)
 result={'scope':'finite comparator controls on fresh actual timed TS output; not runtime mutants or law proofs','positive':'PASS','cpuAffinity':sorted(os.sched_getaffinity(0)),'controls':[],'sources':{name:hashlib.sha256((HERE/name).read_bytes()).hexdigest() for name in ['measurement-samples-readers-reference.mjs','measurement-samples-readers-run.py','measurement-samples-validation-controls.py']}}
 def check(name,edit):
  value=copy.deepcopy(actual);edit(value['sample']);caught=False
  try:R.checked('TS',json.dumps(value),'Motion',64,ref)
  except AssertionError:caught=True
  assert caught,name
  result['controls'].append({'name':name,'rejected':True})
 check('Main-slot3',lambda s:s['audit'][2]['rows'][0]['main']['coordinates'].__setitem__(3,999))
 check('Aux-slot3',lambda s:s['audit'][2]['rows'][0]['aux']['rates'].__setitem__(3,999))
 check('Flag-group',lambda s:s['audit'][2]['rows'][1]['flag'].__setitem__('group',999))
 check('lifecycle-identity',lambda s:next(a for a in s['audit'] if a['removed'])['removed'].__setitem__(0,999))
 check('message-payload',lambda s:next(a for a in s['audit'] if a['messages'])['messages'][0].__setitem__('code',999))
 check('lag',lambda s:s['audit'][2].__setitem__('lagged',True))
 check('actual-diagnostic-clock',lambda s:s['diagnostics'][2].__setitem__('tick',999))
 (HERE/'measurement-samples-validation-evidence.json').write_text(json.dumps(result,indent=2)+'\n')
 print('PASS: original and seven field/delivery/diagnostic perturbations')
if __name__=='__main__':main()
