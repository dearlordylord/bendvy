#!/usr/bin/env python3
"""Freeze standalone #47 complete application timing inputs; no execution."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];APP=HERE.parent

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory(p):return {str(q.relative_to(p)):sha(q) for q in sorted(p.rglob('*')) if q.is_file()}
def sources():
 closure={ROOT/'scripts/task_runner.py'}
 def visit(p):
  p=p.resolve()
  if p in closure:return
  assert p.is_relative_to(ROOT) and p.is_file(),p
  closure.add(p)
  if p.suffix=='.bend':
   for imp in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
    imp=imp.strip('"')
    if imp!='Base':visit(p.parent/imp)
 visit(APP/'driver.bend');visit(HERE/'timing.bend')
 closure.update(p for p in HERE.iterdir() if p.is_file() and p.suffix in {'.py','.md','.mjs','.c','.js','.bend','.json'})
 closure.update([APP/'application-reference.mjs',APP/'application-expected.txt',ROOT/'benchmarks/contract.json',ROOT/'docs/SPEC.md',ROOT/'docs/parity/component-state.md',ROOT/'docs/parity/remaining-core-spec.md'])
 return {str(p.relative_to(ROOT)):sha(p) for p in sorted(closure)}

def bend_entry(n):return f'''import Base
import ../driver.bend as D
import timing.bend as Bench

def captured(lines: List<&2,String>) -> IO(Unit):
  match lines:
    case []: IO.pure(Unit,Unit{{}})
    case line <> rest: IO.bind(Unit,Unit,Bench.capture(line),unit => captured(rest))
def repeat(remaining: Nat) -> IO(Unit):
  match remaining:
    case 0n: IO.pure(Unit,Unit{{}})
    case 1n+rest: IO.bind(Unit,Unit,captured(D.main()),unit => repeat(rest))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,Bench.begin(),unit => IO.bind(Unit,Unit,repeat({n}n),unit => Bench.end()))
'''

def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();assert not out.exists(),'stage must be fresh'
 frozen=sources();out.mkdir(parents=True);stage=out/'stage';stage.mkdir()
 for n,h in frozen.items():
  dst=stage/n;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,dst);assert sha(dst)==h
 (stage/'.references').symlink_to(ROOT/'.references',target_is_directory=True)
 source=stage/'experiments/public-component-state/application-reference.mjs';text=source.read_text();lines=text.splitlines();imports=[s for s in lines if s.startswith('import ')];body=[s for s in lines if not s.startswith('import ')];assert len(imports)==1
 callable=source.with_name('application-callable.mjs');callable.write_text('\n'.join(imports)+'\nexport function run(){\n'+'\n'.join(body)+'\n}\n')
 harness=stage/HERE.relative_to(ROOT);adaptations={str(callable.relative_to(stage)):{'source':str(source.relative_to(stage)),'sourceSHA256':sha(source),'outputSHA256':sha(callable),'purpose':'Only static imports hoisted; every unchanged authored application statement runs inside a fresh callable lifecycle'}}
 for n in [1,2,4]:
  (harness/f'state-{n}.bend').write_text(bend_entry(n))
  (harness/f'state-{n}.mjs').write_text("import {timed} from './capture.mjs';\nimport {run} from '../application-callable.mjs';\n"+f"await timed(async()=>{{for(let batch=0;batch<{n};batch++)run();}});\n")
 receipt={'status':'STAGED_REVIEW_REQUIRED_NO_EXECUTION','sourceHashes':frozen,'stageInventory':inventory(stage),'adaptations':adaptations,'scales':[1,2,4],'referenceSourceHashes':inventory(ROOT/'.references/bevy-ts/packages/core/src'),'manifestHash':sha(ROOT/'.references/sources.json'),'expectedRowsPerLifecycle':62,'schemasPerLifecycle':2,'timerScope':'Complete fresh public lifecycle, materialized full UTF8 output/capture/hash in-region; imports/startup/compiler/output flush excluded','semanticPriorEvidence':'81-command normal receipt and isolated wrong-target separately source-bound; current integrated core needs fresh replay','numericalAcceptance':'No new per-feature threshold or statistical criterion'}
 assert frozen==sources(),'live source drift while staging';(out/'stage.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
if __name__=='__main__':main()
