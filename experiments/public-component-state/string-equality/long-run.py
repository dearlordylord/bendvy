#!/usr/bin/env python3
import sys,pathlib,json,argparse
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'timing'));import run as timing
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output=a.output.resolve();a.stage=timing.ROOT/'.artifacts/state-timing-stage-v1';a.cpu=5;a.timing=False
h=timing.Harness(a)
try:
 h.refs()
 h.receipt['sourceScope']='Isolated20000-codepoint controls plus backend-specific surrogate printing canary; not full public application';h.save()
 for f in HERE.iterdir():
  if f.is_file():h.receipt['fixedInputs'][str(f)]=timing.digest(f)
 h.save()
 h.run('surrogate-checker',['bend',HERE/'negative-surrogate.bend','--check-only'],5)
 for suffix in ['js','c']:
  path=a.output/('surrogate.'+suffix);h.run('surrogate-emit-'+suffix,['bend',HERE/'negative-surrogate.bend','-o',path],30);h.pin(path)
 native=a.output/'surrogate.native';h.run('surrogate-build',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',a.output/'surrogate.c','-o',native,'-pthread','-lm'],120);h.pin(native)
 for backend,cmd in [('JS',['node',a.output/'surrogate.js']),('Native',[native,'--threads','1','--gpu','off'])]:
  rejected=h.run('surrogate-'+backend,cmd,5,backend=='Native')
  if backend=='JS':assert b'55296 is not a Unicode scalar value' in rejected.stderr+rejected.stdout
  else:assert rejected.stdout==bytes([237,160,128,10]) and not rejected.stderr
 h.receipt['surrogateObservation']='Checker/emit accept; JS runtime refuses55296; Native prints ED A0 80 LF. Existing backend discrepancy, not common scalar acceptance or candidate policy.'
 h.run('long-checker',['bend',HERE/'long.bend','--check-only'],5)
 for suffix in ['js','c']:
  path=a.output/('long.'+suffix);h.run('emit-'+suffix,['bend',HERE/'long.bend','-o',path],30);h.pin(path)
 native=a.output/'long.native';h.run('build',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',a.output/'long.c','-o',native,'-pthread','-lm'],120);h.pin(native)
 for backend,cmd in [('JS',['node',a.output/'long.js']),('Native',[native,'--threads','1','--gpu','off'])]:
  assert h.run(backend,cmd,5).stdout==b'false:false\ntrue\nfalse\nfalse\nfalse\n'
 js=(a.output/'long.js').read_text();start=js.index('function $equality$058equal_walk$');body=js[start:js.index('\nfunction ',start+1)];assert 'for (;;)' in body and 'continue;' in body and body.count('$equality$058equal_walk$')==1
 h.receipt['status']='PASS_LONG_CODEPOINT_CONTROLS_BOTH_BACKENDS';h.receipt['scope']='20000 supplementary-codepoint equal, early/late mismatch, prefix rejection;128-codepoint old/new comparison; no shortcircuit claim';h.guard();h.save();print(a.output)
except Exception as e:
 h.receipt['status']='FAILED';h.receipt['failure']=repr(e);h.save();raise
