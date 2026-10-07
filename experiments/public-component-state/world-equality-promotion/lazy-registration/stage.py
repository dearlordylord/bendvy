#!/usr/bin/env python3
"""Add staged lazy metadata/list predicates to the exact isolated equality stage."""
import pathlib,sys,json,argparse,importlib.util,shutil,difflib
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3];APP=HERE.parents[1]
spec=importlib.util.spec_from_file_location('previous_promotion_stage',HERE.parent/'stage.py');previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
sha=previous.sha;inventory=previous.inventory

def sources():
 result=previous.sources();result.update({str(p.relative_to(ROOT)):sha(p) for p in HERE.iterdir() if p.is_file()});return dict(sorted(result.items()))

def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();assert not out.exists();frozen=sources()
 oldargv=sys.argv;sys.argv=[str(HERE.parent/'stage.py'),'--output',str(out)]
 try:previous.main()
 finally:sys.argv=oldargv
 tree=out/'stage'
 for name,h in frozen.items():
  dst=tree/name
  # Preserve previous World patch/helper; original names are copied separately.
  if name=='src/ecs/world.bend':continue
  dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,dst);assert sha(dst)==h
 world=tree/'src/ecs/world.bend';before=world.read_text();start=before.index('def registration_meta_matches(');end=before.index('\ndef namespace(',start)
 candidate=(HERE/'candidate.bend').read_text();fragment=candidate[candidate.index('def matching_access('):].rstrip()+'\n'
 assert 'W.' not in fragment and 'C.' not in fragment
 after=before[:start]+fragment+'\n'+before[end:];world.write_text(after)
 patch=''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='equality-v2/src/ecs/world.bend',tofile='lazy/src/ecs/world.bend'))
 (out/'lazy-world.patch').write_text(patch)
 r=json.loads((out/'stage.json').read_text());r['equalityBasePromotion']=r.pop('promotion');r.update(sourceHashes=frozen,stageInventory=inventory(tree),lazyPromotion={'candidateSHA256':sha(HERE/'candidate.bend'),'fragmentSHA256':__import__('hashlib').sha256(fragment.encode()).hexdigest(),'lazyPatchSHA256':sha(out/'lazy-world.patch'),'worldSHA256':sha(world),'scope':'Existing exact ID/name/orderedaccess predicates gated lazily; stop only after exact match, duplicateID later match preserved; no live src change'},semanticPriorEvidence='Prior equality87+32+profiles+120pair subject preserved separately; lazy subject requires fresh full gate')
 assert frozen==sources();(out/'stage.json').write_text(json.dumps(r,indent=2)+'\n');print(out)
if __name__=='__main__':main()
