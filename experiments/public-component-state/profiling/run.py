#!/usr/bin/env python3
"""Guarded diagnostic profiles, no comparative timing or workload edits."""
import sys,pathlib,json,os,argparse
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'timing'))
import run as timing
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=11);a=p.parse_args()
a.stage=timing.ROOT/'.artifacts/state-timing-stage-v1';a.output=a.output.resolve();a.timing=False
h=timing.Harness(a)
try:
 h.refs()
 semantic=timing.ROOT/'.artifacts/state-timing-semantics-v1'
 receipt=json.loads((semantic/'receipt.json').read_text())
 assert receipt['status']=='PASS_COMPLETE_APPLICATION_EQUIVALENCE'
 h.receipt['fixedInputs'][str(semantic/'receipt.json')]=timing.digest(semantic/'receipt.json')
 for path in HERE.glob('*'):
  if path.is_file():h.receipt['fixedInputs'][str(path)]=timing.digest(path)
 for n in [1,4]:
  js=semantic/f'state-{n}.js';assert timing.digest(js)==receipt['artifactHashes'][js.name]
  h.receipt['fixedInputs'][str(js)]=timing.digest(js)
 h.receipt['profileScope']='One fresh complete application per process; scales1/4, CPU and collected-allocation diagnostics separately. Not comparable timings or physical allocation totals.'
 h.save()
 for n in [1,4]:
  for backend in ['JS','TS']:
   entry=semantic/f'state-{n}.js' if backend=='JS' else h.tree/f'experiments/public-component-state/timing/state-{n}.mjs'
   for mode in ['cpu','alloc']:
    label=f'{backend}-{n}-{mode}';profile=a.output/(label+'.json')
    result=h.run(label,['env',f'STATE_PROFILE_MODE={mode}',f'STATE_PROFILE_OUTPUT={profile}','node','--require',HERE/'region.cjs',entry],5)
    expected=(h.tree/'experiments/public-component-state/application-expected.txt').read_bytes()*n
    assert result.stdout==expected
    metadata=json.loads(result.stderr);assert metadata['bytes']==len(expected) and metadata['digest']==timing.fnv(expected)
    data=json.loads(profile.read_text());assert data['calls']==2 and data['mode']==mode
    assert data['profile']['nodes'] if mode=='cpu' else data['profile']['head']
    h.pin(profile)
 h.receipt['status']='PASS_FULL_OUTPUT_DIAGNOSTIC_PROFILES_NO_PERFORMANCE_VERDICT';h.guard();h.save();print(a.output)
except Exception as e:
 h.receipt['status']='FAILED';h.receipt['failure']=repr(e);h.save();raise
