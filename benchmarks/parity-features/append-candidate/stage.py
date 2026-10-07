#!/usr/bin/env python3
"""Isolated count+append stage; no builds or live-core edits."""
import argparse,json,pathlib,shutil,sys
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
import preflight
from stage import inventory

def main():
 p=argparse.ArgumentParser();p.add_argument('--original',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args()
 assert not a.output.exists();m=json.loads((a.original/'stage.json').read_text());assert inventory(a.original/'stage')==m['stageInventory'];assert preflight.snapshot()==m['sources']
 shutil.copytree(a.original,a.output);file=a.output/'stage/src/ecs/event-runtime.bend';old=file.read_text()
 size='def size(~E: Data,batches: List<&2,Batch<E>>) -> Nat:\n  count(~E,values(~E,batches))'
 assert old.count(size)==1
 text=old.replace(size,'''def size_loop(~E: Data,batches: List<&2,Batch<E>>,+acc: Nat) -> Nat:
  match batches:
    case []: acc
    case Batch{_,items} <> rest: size_loop(~E,rest,count_loop(~E,items,acc))

def size(~E: Data,batches: List<&2,Batch<E>>) -> Nat:
  size_loop(~E,batches,0n)''')
 append='def append(~E: Data,+left: List<&2,E>,+right: List<&2,E>) -> List<&2,E>:\n  append_loop(~E,List.reverse(&2,E,left),right)'
 assert text.count(append)==1
 text=text.replace(append,'''def append(~E: Data,+left: List<&2,E>,+right: List<&2,E>) -> List<&2,E>:
  match left right:
    case Nil{} right: right
    case left Nil{}: left
    case left right: append_loop(~E,List.reverse(&2,E,left),right)''')
 file.write_text(text)
 m.setdefault('intentionalAdaptations',{})['src/ecs/event-runtime.bend']={'before':__import__('hashlib').sha256(old.encode()).hexdigest(),'after':preflight.digest(file),'purpose':'Exact Nat cardinality plus append Nil fast paths; original both-nonempty reverse+append_loop retained'}
 m['candidateSourcePins']={str(x):preflight.digest(x) for x in HERE.glob('*') if x.is_file()};m['stageInventory']=inventory(a.output/'stage');m['status']='CANDIDATE_STAGED_REVIEW_REQUIRED_NO_EXECUTION'
 (a.output/'stage.json').write_text(json.dumps(m,indent=2)+'\n');print(a.output/'stage.json')
if __name__=='__main__':main()
