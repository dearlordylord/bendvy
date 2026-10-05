#!/usr/bin/env python3
"""Finite physical equal-depth capacity/owner probe, not a measurement."""
import gzip,hashlib,importlib.util,json,pathlib,shutil,tempfile
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sp=importlib.util.spec_from_file_location('R',ROOT/'experiments/s-perf/occupancy-run.py');R=importlib.util.module_from_spec(sp);sp.loader.exec_module(R)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
import argparse
cli=argparse.ArgumentParser();cli.add_argument('--prepared',type=pathlib.Path,required=True);args=cli.parse_args();assert args.prepared.is_absolute() and args.prepared.resolve()==args.prepared
base=args.prepared/'experiments/s-integrate'
pins=json.loads((HERE/'source-bindings.json').read_text())['variant'];assert all(sha(base/n)==v for n,v in pins.items())
ids=[2**i for i in range(17)]+[65537]
expected=''.join(f'{n}:{1<<(n-1).bit_length()}:{1<<(n-1).bit_length()}:{1<<(n-1).bit_length()}:{1<<(n-1).bit_length()}:E:E:37\n' for n in ids)
e={'scope':'finite physical Main/Aux/metadata equal capacities and guarded actual Type-owner opening/reinsertion; no universal law','cases':{},'mutants':{},'limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':8,'expected':expected}
with tempfile.TemporaryDirectory(prefix='fivehour-native-columns-capacity-') as td:
 root=pathlib.Path(td);core=root/'core';shutil.copytree(base,core);shutil.copy2(HERE/'capacity-fixture.bend',core/'fixture.bend');original=(core/'storage.bend').read_text()
 def save(): (HERE/'capacity-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 def run(name):
  entry=core/'fixture.bend';assert 'ALL PROOFS CHECK' in ''.join(R.run(['taskset','-c','8','bend',entry,'--check-only']));c=root/(name+'.c');R.run(['taskset','-c','8','bend',entry,'-o',c],30);binary=root/name;R.run(['taskset','-c','8','clang','-O3',c,'-o',binary,'-pthread','-lm'],120);out=R.run(['taskset','-c','8',binary,'--threads','1','--gpu','off'])[0];(HERE/(name+'.txt')).write_text(out)
  code=c.read_text();lines=code.splitlines();excerpts=[]
  for i,line in enumerate(lines):
   if ('native_column' in line.lower() or 'native_take' in line.lower()) and len(excerpts)<24:excerpts.append('\n'.join(lines[max(0,i-1):i+12]))
  (HERE/(name+'-codegen.json')).write_text(json.dumps({'generatedSha256':sha(c),'excerpts':excerpts},indent=2)+'\n')
  return out,{'generatedSha256':sha(c),'artifactSha256':sha(binary),'outputSha256':hashlib.sha256(out.encode()).hexdigest(),'closure':R.closure(entry)}
 try:
  out,r=run('capacity');assert out==expected;e['cases']['Native']=dict(r,status='PHYSICAL_CAPACITY_OWNER_BOUNDS_PASS18');save()
  for name,old,new in [('growth','U32.add(c,c),1n+d,h','c,1n+d,h'),('bounds','Bool.and((0 < id : U32),Bool.and((id <= capacity : U32),(id <= high : U32)))','True{}')]:
   assert old in original;(core/'storage.bend').write_text(original.replace(old,new));out,r=run(name);assert out!=expected;e['mutants'][name]=dict(r,status='COMPILED_ACTUAL_COUNTER_ORACLE_DETECTED');save()
  e['status']='FINITE_NATIVE_COLUMNS_PHYSICAL_PASS'
 except Exception as exc:e.update(status='BOUNDED_FAILURE',error=str(exc));save();raise
 save();print(e['status'])
