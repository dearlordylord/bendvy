#!/usr/bin/env python3
"""Pure source recipe: does not invoke Bend, compiler, benchmark, or loop."""
import argparse,hashlib,importlib.util,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def closure(root):
 seen={}
 def visit(p):
  assert not p.is_symlink();p=p.resolve();assert p.is_relative_to(root.resolve()),p
  if p in seen:return
  assert not p.is_symlink();seen[p]=sha(p)
  for name in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
   if name.startswith('.'):visit(p.parent/name)
 visit(root/'experiments/s-integrate/measurement-bend.bend')
 return {str(p.relative_to(root.resolve())):h for p,h in sorted(seen.items())}
def signature_api():
 spec=importlib.util.spec_from_file_location('sig',ROOT/'experiments/s-prep/segment-run.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m.signatures
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path);a=p.parse_args();plan=json.loads((HERE/'source-plan.json').read_text());sig=signature_api();observed={}
 if a.output:
  assert a.output.is_absolute() and not a.output.exists();assert not any(x.is_symlink() for x in [a.output,*a.output.parents]);a.output.mkdir()
 for backend,record in plan['backends'].items():
  base=pathlib.Path(record['initialRoot']); selected=pathlib.Path(record['selectedRoot']);assert closure(base)==record['initialClosure'];assert closure(selected)==record['selectedClosure']
  final=dict(record['selectedClosure']);final.update(record['overrides']);changes={};additions={}
  for name,h in final.items():
   source=HERE/'inputs'/backend/pathlib.Path(name).name if name in record['overrides'] else selected/name
   assert sha(source)==h;old=base/name;before=sig(old.read_text());after=sig(source.read_text());assert before['imports']==after['imports'] and before['types']==after['types'];assert all(x in after['definitions'] for x in before['definitions'])
   additions[name]=[x for x in after['definitions'] if x not in before['definitions']]
   assert additions[name]==record['newPrivateHeaders'][name]
   if sha(old)!=h:assert name in record['editable'];changes[name]=h
   if a.output:
    target=a.output/backend/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(source.read_bytes())
  assert len(final)==28
  # Entire authored callback module remains byte-identical, stronger than six definitions.
  assert final['experiments/s-integrate/measurement-bend.bend']==record['initialClosure']['experiments/s-integrate/measurement-bend.bend']
  observed[backend]={'finalClosure':final,'changedFromInitial':changes,'exactNewPrivateHeaders':additions,'closureDigest':hashlib.sha256(json.dumps(final,sort_keys=True,separators=(',',':')).encode()).hexdigest()}
 result={'status':'SOURCE_ONLY_RECIPE_VERIFIED','scope':'No gate/performance acceptance inferred','output':str(a.output) if a.output else None,'backends':observed}
 if a.output:(a.output/'source-receipt.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps(result,indent=2))
if __name__=='__main__':main()
