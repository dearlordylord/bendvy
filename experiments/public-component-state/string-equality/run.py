#!/usr/bin/env python3
"""Bounded old/new exact equality controls, no live core mutation or timing."""
import sys,pathlib,argparse,json
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'timing'));import run as timing
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output=a.output.resolve();a.stage=timing.ROOT/'.artifacts/state-timing-stage-v1';a.cpu=5;a.timing=False
h=timing.Harness(a)
try:
 h.refs()
 h.receipt['sourceScope']='Isolated324 Unicode old/new pairs +9 registration/access rows and reached mutants; not full public application';h.save()
 for f in HERE.iterdir():
  if f.is_file():h.receipt['fixedInputs'][str(f)]=timing.digest(f)
 h.receipt['scope']='Isolated 324 old/new Unicode string pairs and9 exact registration/access rows; no World adoption or law approval';h.save()
 expected=(HERE/'expected.txt').read_bytes()
 original=(HERE/'equality.bend').read_text()
 for name,source in [('normal',original),('always-true',original.replace('Bool.and(same,Char.is_eq(a,b))','True{}')),('equal-prefix',original.replace('case SNil{} SCon{_,_}: False{}','case SNil{} SCon{_,_}: True{}'))]:
  assert source!=original if name!='normal' else True
  directory=a.output/name;directory.mkdir()
  for file,text in [('equality.bend',source),('controls.bend',(HERE/'controls.bend').read_text())]:
   path=directory/file;path.write_text(text);h.pin(path)
  checked=h.run(name+'-checker',['bend',directory/'controls.bend','--check-only'],5);assert b'ALL PROOFS CHECK' in checked.stdout+checked.stderr
  for suffix in ['js','c']:
   path=directory/('controls.'+suffix);h.run(name+'-emit-'+suffix,['bend',directory/'controls.bend','-o',path],30);h.pin(path)
  native=directory/'controls.native';h.run(name+'-build',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',directory/'controls.c','-o',native,'-pthread','-lm'],120);h.pin(native)
  for backend,command in [('JS',['node',directory/'controls.js']),('Native',[native,'--threads','1','--gpu','off'])]:
   out=h.run(name+'-'+backend,command,5).stdout
   if name=='normal':assert out==expected
   else:
    assert len(out.splitlines())==333 and out!=expected
    row=1 if name=='equal-prefix' else 18+5 # empty/a prefix; a/b unequal same length
    assert out.splitlines()[row]==b'true:false',(name,row,out.splitlines()[row])
 h.receipt['status']='PASS_FINITE_EQUALITY_AND_REACHED_MUTANTS_BOTH_BACKENDS';h.guard();h.save();print(a.output)
except Exception as e:
 h.receipt['status']='FAILED';h.receipt['failure']=repr(e);h.save();raise
