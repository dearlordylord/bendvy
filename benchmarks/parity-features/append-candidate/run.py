#!/usr/bin/env python3
"""Finite old/append-Nil comparison and reached wrong-count mutant; no proof/timing."""
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
 for variant in ['candidate','wrong-empty-order']:
  directory=h.output/variant;directory.mkdir()
  # Keep exact relative import roots by staging a standalone mirrored closure.
  base=directory/'tree';shutil.copytree(h.stage,base)
  dest=base/'benchmarks/parity-features/append-candidate';dest.mkdir(parents=True,exist_ok=True)
  for name in ['append.bend','fixture.bend']:shutil.copy2(HERE/name,dest/name)
  if variant=='wrong-empty-order':
   file=dest/'append.bend';text=file.read_text();assert text.count('    case left Nil{}: left')==1;file.write_text(text.replace('    case left Nil{}: left','    case left Nil{}: List.reverse(&2,E,left)'))
  frozen=inventory(base);h.receipt.setdefault('variantSources',{})[variant]=frozen
  entry=dest/'fixture.bend';js=directory/'fixture.js';c=directory/'fixture.c';exe=directory/'fixture'
  guard();h.run(variant+'-check',[h.tools['bend'],entry,'--check-only'],5)
  for label,target in [('JS',js),('Native',c)]:
   assert not target.exists();h.run(variant+'-emit-'+label,[h.tools['bend'],entry,'-o',target],30);h.pin(target)
  assert not exe.exists();h.run(variant+'-compile',[h.tools['clang'],'-O3',c,'-o',exe,'-pthread','-lm'],120);h.pin(exe)
  for label,command in [('JS',[h.tools['node'],js]),('Native',[exe,'--threads','1','--gpu','off'])]:
   result=h.run(variant+'-run-'+label,[h.tools['taskset'],'-c','11',*command],5)
   rows=[tuple(json.loads(value) for value in line.split('|')) for line in result.stdout.decode().splitlines()];assert len(rows)==25
   assert all(x==y for x,y in rows)==(variant=='candidate'),(variant,label,rows)
  assert inventory(base)==frozen;guard()
 h.receipt['status']='FINITE_EQUIVALENCE_AND_REACHED_MUTANT_PASS';h.receipt['limits']='25 finite cases; unapproved subject, no universal refinement/proof/performance claim';h.save();print(h.output/'receipt.json')
if __name__=='__main__':main()
