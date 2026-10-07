#!/usr/bin/env python3
import sys,pathlib,json,argparse
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'timing'));import run as timing
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output=a.output.resolve();a.stage=timing.ROOT/'.artifacts/state-timing-stage-v1';a.cpu=5;a.timing=False
h=timing.Harness(a)
try:
 h.refs()
 for f in HERE.iterdir():
  if f.is_file():h.receipt['fixedInputs'][str(f)]=timing.digest(f)
 h.save()
 h.receipt['sourceScope']='Native-only7 surrogate-representation old/new equality pairs. Not public application; not JS acceptance.';h.save()
 h.run('checker',['bend',HERE/'native-surrogate-compare.bend','--check-only'],5)
 path=a.output/'control.c';h.run('emit-c',['bend',HERE/'native-surrogate-compare.bend','-o',path],30);h.pin(path)
 native=a.output/'control.native';h.run('build',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',path,'-o',native,'-pthread','-lm'],120);h.pin(native)
 assert h.run('Native',[native,'--threads','1','--gpu','off'],5).stdout==b'true:true\nfalse:false\nfalse:false\nfalse:false\nfalse:false\ntrue:true\nfalse:false\n'
 h.receipt['status']='PASS_NATIVE_ONLY_SURROGATE_REPRESENTATION_EQUALITY';h.receipt['scope']='Seven actual native-representation pairs; no JS domain claim';h.guard();h.save();print(a.output)
except Exception as e:
 h.receipt['status']='FAILED';h.receipt['failure']=repr(e);h.save();raise
