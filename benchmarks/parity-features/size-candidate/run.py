#!/usr/bin/env python3
"""Finite old/count-loop comparison and reached wrong-count mutant; no proof/timing."""
import argparse,gzip,hashlib,json,pathlib,shutil,sys
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
from execute import Harness
from stage import inventory
import preflight

def main():
 p=argparse.ArgumentParser();p.add_argument('--stage',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
 h=Harness(a.stage,a.output.resolve())
 extra={str(x):preflight.digest(x) for x in HERE.glob('*') if x.is_file()}
 h.receipt['candidateSources']=extra
 def guard():
  h.guard();assert all(preflight.digest(pathlib.Path(n))==v for n,v in extra.items())
 for variant in ['candidate','wrong-count']:
  directory=h.output/variant;directory.mkdir()
  # Keep exact relative import roots by staging a standalone mirrored closure.
  base=directory/'tree';shutil.copytree(h.stage,base)
  dest=base/'benchmarks/parity-features/size-candidate';dest.mkdir(parents=True,exist_ok=True)
  for name in ['count.bend','fixture.bend']:shutil.copy2(HERE/name,dest/name)
  if variant=='wrong-count':
   file=dest/'count.bend';text=file.read_text();assert text.count('  size_loop(~E,batches,0n)')==1;file.write_text(text.replace('  size_loop(~E,batches,0n)','  1n+size_loop(~E,batches,0n)'))
  frozen=inventory(base);h.receipt.setdefault('variantSources',{})[variant]=frozen
  entry=dest/'fixture.bend';js=directory/'fixture.js';c=directory/'fixture.c';exe=directory/'fixture'
  guard();h.run(variant+'-check',[h.tools['bend'],entry,'--check-only'],5)
  for label,target in [('JS',js),('Native',c)]:
   assert not target.exists();h.run(variant+'-emit-'+label,[h.tools['bend'],entry,'-o',target],30);h.pin(target)
  assert not exe.exists();h.run(variant+'-compile',[h.tools['clang'],'-O3',c,'-o',exe,'-pthread','-lm'],120);h.pin(exe)
  for label,command in [('JS',[h.tools['node'],js]),('Native',[exe,'--threads','1','--gpu','off'])]:
   result=h.run(variant+'-run-'+label,[h.tools['taskset'],'-c','11',*command],5)
   rows=[tuple(map(int,line.split(':'))) for line in result.stdout.decode().splitlines()];assert len(rows)==18
   assert all(x==y for x,y in rows)==(variant=='candidate'),(variant,label,rows)
  assert inventory(base)==frozen;guard()
 h.receipt['status']='FINITE_EQUIVALENCE_AND_REACHED_MUTANT_PASS';h.receipt['limits']='18 finite cases; unapproved subject, no universal refinement/proof/performance claim';h.save();print(h.output/'receipt.json')
if __name__=='__main__':main()
