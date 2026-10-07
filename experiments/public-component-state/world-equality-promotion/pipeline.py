#!/usr/bin/env python3
"""Existing reviewed complete-workload timing pipeline plus exact region profiler."""
import sys,pathlib,json,argparse
HERE=pathlib.Path(__file__).resolve().parent
import stage as promotion
sys.path.insert(0,str(HERE.parent/'timing'));import run as timing
timing.stage.sources=promotion.sources
p=argparse.ArgumentParser();p.add_argument('--stage',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,required=True);p.add_argument('--profiles',action='store_true');p.add_argument('--timing',action='store_true');p.add_argument('--semantic-receipt',type=pathlib.Path);p.add_argument('--quiet-window');a=p.parse_args();a.stage=a.stage.resolve();a.output=a.output.resolve()
assert not(a.profiles and a.timing)
if not a.profiles:
 sys.argv=[str(HERE.parent/'timing/run.py'),'--stage',str(a.stage),'--output',str(a.output),'--cpu',str(a.cpu)]
 if a.timing:
  assert a.semantic_receipt and a.quiet_window
  sys.argv+=['--timing','--semantic-receipt',str(a.semantic_receipt),'--quiet-window',a.quiet_window]
 timing.main();raise SystemExit(0)
assert a.semantic_receipt
h=timing.Harness(a)
try:
 h.refs();semantic=json.loads(a.semantic_receipt.read_text());assert semantic['status']=='PASS_COMPLETE_APPLICATION_EQUIVALENCE' and semantic['stageReceiptSHA256']==h.receipt['stageReceiptSHA256']
 assert semantic['installedTools']['pins']==h.receipt['installedTools']['pins']
 h.receipt['fixedInputs'][str(a.semantic_receipt.resolve())]=timing.digest(a.semantic_receipt)
 preload=HERE.parent/'profiling/region.cjs';h.receipt['fixedInputs'][str(preload)]=timing.digest(preload)
 h.receipt['sourceScope']='Patched actual full62-row lifecycle in two schemas; identical original diagnostic CPU/allocation parameters, separate process modes, scales1/4; no comparative timing claim'
 for n in [1,4]:
  path=a.semantic_receipt.parent/f'state-{n}.js';assert timing.digest(path)==semantic['artifactHashes'][path.name]
  h.receipt['fixedInputs'][str(path.resolve())]=timing.digest(path)
 h.save()
 for n in [1,4]:
  for backend in ['JS','TS']:
   entry=a.semantic_receipt.parent/f'state-{n}.js' if backend=='JS' else h.tree/f'experiments/public-component-state/timing/state-{n}.mjs'
   for mode in ['cpu','alloc']:
    label=f'{backend}-{n}-{mode}';profile=a.output/(label+'.json')
    result=h.run(label,['env',f'STATE_PROFILE_MODE={mode}',f'STATE_PROFILE_OUTPUT={profile}','node','--require',preload,entry],5)
    expected=(h.tree/'experiments/public-component-state/application-expected.txt').read_bytes()*n;assert result.stdout==expected
    metadata=json.loads(result.stderr);assert metadata['bytes']==len(expected) and metadata['digest']==timing.fnv(expected)
    data=json.loads(profile.read_text());assert data['calls']==2 and data['mode']==mode
    assert data['profile']['nodes'] if mode=='cpu' else data['profile']['head'];h.pin(profile)
 h.receipt['status']='PASS_PATCHED_FULL_OUTPUT_DIAGNOSTIC_PROFILES_NO_PERFORMANCE_VERDICT';h.guard();h.save();print(a.output)
except Exception as e:
 h.receipt['status']='FAILED';h.receipt['failure']=repr(e);h.save();raise
