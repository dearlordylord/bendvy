#!/usr/bin/env python3
"""Create an isolated candidate stage; no execution or live-core mutation."""
import argparse,json,pathlib,shutil,sys
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
import preflight
from stage import inventory

def main():
 p=argparse.ArgumentParser();p.add_argument('--original',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
 assert not a.output.exists();m=json.loads((a.original/'stage.json').read_text());assert inventory(a.original/'stage')==m['stageInventory'];assert preflight.snapshot()==m['sources']
 shutil.copytree(a.original,a.output)
 file=a.output/'stage/src/ecs/event-runtime.bend';old=file.read_text()
 seam='def size(~E: Data,batches: List<&2,Batch<E>>) -> Nat:\n  count(~E,values(~E,batches))'
 assert old.count(seam)==1
 replacement='''def size_loop(~E: Data,batches: List<&2,Batch<E>>,+acc: Nat) -> Nat:
  match batches:
    case []: acc
    case Batch{_,items} <> rest: size_loop(~E,rest,count_loop(~E,items,acc))

def size(~E: Data,batches: List<&2,Batch<E>>) -> Nat:
  size_loop(~E,batches,0n)'''
 file.write_text(old.replace(seam,replacement))
 m.setdefault('intentionalAdaptations',{})['src/ecs/event-runtime.bend']={'before':__import__('hashlib').sha256(old.encode()).hexdigest(),'after':preflight.digest(file),'purpose':'Isolated exact-Nat cardinality candidate; no event payload materialization solely to count'}
 m['candidateSourcePins']={str(x):preflight.digest(x) for x in HERE.glob('*') if x.is_file()};m['stageInventory']=inventory(a.output/'stage');m['status']='CANDIDATE_STAGED_REVIEW_REQUIRED_NO_EXECUTION'
 (a.output/'stage.json').write_text(json.dumps(m,indent=2)+'\n');print(a.output/'stage.json')
if __name__=='__main__':main()
