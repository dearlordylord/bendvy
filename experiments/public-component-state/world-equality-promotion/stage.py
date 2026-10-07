#!/usr/bin/env python3
"""Isolated exact two-call World patch, reusing frozen state timing staging."""
import pathlib,sys,importlib.util,json,argparse,re,shutil,difflib
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];APP=HERE.parent
spec=importlib.util.spec_from_file_location('original_state_stage',APP/'timing/stage.py');original=importlib.util.module_from_spec(spec);spec.loader.exec_module(original)
sha=original.sha;inventory=original.inventory

def sources():
 result=original.sources();closure=set()
 def visit(p):
  p=p.resolve()
  if p in closure:return
  assert p.is_relative_to(ROOT) and p.is_file();closure.add(p)
  if p.suffix=='.bend':
   for imp in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
    if imp!='Base':visit(p.parent/imp)
 for p in APP.glob('*.bend'):visit(p)
 closure.update(p for p in APP.iterdir() if p.is_file() and p.suffix in {'.py','.mjs','.md','.txt','.jsonl'})
 closure.update(p for p in HERE.iterdir() if p.is_file())
 closure.add(APP/'string-equality/equality.bend')
 closure.add(APP/'profiling/region.cjs')
 result.update({str(p.relative_to(ROOT)):sha(p) for p in sorted(closure)});return dict(sorted(result.items()))

def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();assert not out.exists();frozen=sources()
 # Original reviewed stage generator creates exact full-workload wrappers unchanged.
 oldargv=sys.argv;sys.argv=[str(APP/'timing/stage.py'),'--output',str(out)]
 try:original.main()
 finally:sys.argv=oldargv
 tree=out/'stage'
 for n,h in frozen.items():
  dst=tree/n;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,dst);assert sha(dst)==h
 world=tree/'src/ecs/world.bend';text=world.read_text();new=text.replace('import Base\n','import Base\nimport string-equality.bend as SE\n',1)
 assert text.count('String.eq(')==2
 new=new.replace('String.eq(x,y)','SE.equal(x,y)').replace('String.eq(mname,name)','SE.equal(mname,name)')
 patch=''.join(difflib.unified_diff(text.splitlines(True),new.splitlines(True),fromfile='a/src/ecs/world.bend',tofile='b/src/ecs/world.bend'))
 assert patch==(HERE/'world.patch').read_text(),'patch subject drift';world.write_text(new)
 helper=tree/'src/ecs/string-equality.bend';shutil.copyfile(APP/'string-equality/equality.bend',helper)
 receipt=json.loads((out/'stage.json').read_text());receipt.update(sourceHashes=frozen,stageInventory=inventory(tree),promotion={'patchSHA256':sha(HERE/'world.patch'),'worldSHA256':sha(world),'helperSHA256':sha(helper),'scope':'Exact helper addition and two World equality calls only; full actual state fixtures/timers unchanged; no live adoption'},semanticPriorEvidence='Current integrated87-command normal subject; patched executable requires fresh full gate')
 assert frozen==sources();(out/'stage.json').write_text(json.dumps(receipt,indent=2)+'\n')
if __name__=='__main__':main()
