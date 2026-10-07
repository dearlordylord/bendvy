#!/usr/bin/env python3
"""Preflight first; executable finite graph falsification is a separate opt-in.
No proof, World/Commands/cleanup or relation-system acceptance is reported.
"""
import argparse, hashlib, json, os, pathlib, re, shutil, sys, time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
import importlib.util
spec=importlib.util.spec_from_file_location("relation_tool_pins",HERE/"tool-pins.py");tool_pins=importlib.util.module_from_spec(spec);spec.loader.exec_module(tool_pins)
from validate import validate as validate_reference
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
MUTANTS={
 'empty-inverse':('match found:\n    case True{}: sources','match found:\n    case True{}: []'),
 'stale-inverse':('inverse_remove(~S,entries,descriptor,target,source)','entries'),
 'prepend-inverse':('List.append(&2,U32,sources,[source])','source <> sources'),
}
def expected():
 # Literal projections independently written from observed replacement/order rules.
 common=[
 'ok;none,none,1|3:[]|[]|[]',
 'ok;none,1,1|3:2:[]|[]|[]',
 'ok;none,1,1|3:2:[]|[]|[]',
 'ok;none,1,2|2:[]|3:[]|[]',
 'ok;none,1,none|2:[]|[]|[]',
 'ok;none,1,none|2:[]|[]|[]',
 'ok;none,1,none|2:[]|[]|[]',
 'ok;none,1,1|2:3:[]|[]|[]',
 'ok;none,1,2|2:[]|3:[]|[]',
 'ok;none,1,1|2:3:[]|[]|[]']
 ordinary=common+['ok;2,1,1|2:3:[]|1:[]|[]']*2+[
 'MissingEntity:999;2,1,1|2:3:[]|1:[]|[]',
 'MissingTarget:1:999:Link;2,1,1|2:3:[]|1:[]|[]',
 'Self:1:Link;2,1,1|2:3:[]|1:[]|[]']
 hierarchy=common+[
 'Cycle:1:2:Link;none,1,1|2:3:[]|[]|[]',
 'ok;none,1,1|2:3:[]|[]|[]',
 'MissingEntity:999;none,1,1|2:3:[]|[]|[]',
 'MissingTarget:1:999:Link;none,1,1|2:3:[]|[]|[]',
 'Self:1:Link;none,1,1|2:3:[]|[]|[]']
 ordinary+=['ok;none,1,1|2:3:[]|[]|[]','ok;none,none,1|3:[]|[]|[]','ok;none,none,none|[]|[]|[]','ok;2,none,none|[]|1:[]|[]','ok;2,3,none|[]|1:[]|2:[]','ok;2,3,1|3:[]|1:[]|2:[]','ok;2,3,1|3:[]|1:[]|2:[]','ok;2,3,1|3:[]|1:[]|2:[]']
 hierarchy+=['ok;none,1,1|2:3:[]|[]|[]','ok;none,none,1|3:[]|[]|[]','ok;none,none,none|[]|[]|[]','ok;2,none,none|[]|1:[]|[]','ok;2,3,none|[]|1:[]|2:[]','Cycle:3:1:Link;2,3,none|[]|1:[]|2:[]','ok;2,3,none|[]|1:[]|2:[]','ok;2,3,none|[]|1:[]|2:[]']
 empty='none,none,none|[]|[]|[]'
 return tuple([row+'#'+('none,none,2|[]|3:[]|[]' if i==21 else empty) for i,row in enumerate(group)] for group in [ordinary,hierarchy])

def validate(out,mutant):
 blocks=out.strip().split('\ndone');assert len(blocks)==5 and not blocks[-1].strip()
 groups=[b.strip().splitlines() for b in blocks[:4]];normal=expected()*2
 witnesses=[]
 for index,(rows,literals) in enumerate(zip(groups,normal)):
  assert len(rows)==23
  for step,(row,literal) in enumerate(zip(rows,literals)):
   spec,core=row.split('=');assert spec==literal,('independent spec vs literal',index,step,spec,literal)
   if core!=literal:witnesses.append({'group':index,'step':step,'expected':literal,'actual':core})
 if mutant:assert witnesses,'undetected mutant'
 else:assert not witnesses,witnesses
 return witnesses

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');args=ap.parse_args()
 out=HERE/'evidence'/('graph-'+str(time.time_ns()));out.mkdir(parents=True)
 files=set((HERE/'modules').glob('*.bend'))|{HERE/'derivation.json',HERE/'additive-modules.patch'}|set(HERE.glob('*.bend'))|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|{pathlib.Path(task_runner.__file__).resolve(),ROOT/'docs/parity/source-review.json'}
 files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))
 files|=set((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 files|={pathlib.Path('/home/node/.bend/check.json')}
 tools=tool_pins.snapshot();files|={pathlib.Path(p) for p in tools['pins']}
 for p in ROOT.joinpath('src/ecs').glob('*.bend'):files.add(p)
 pins={str(p):sha(p) for p in sorted(files)};stages={};generated={}
 receipt={'status':'INCOMPLETE','scope':'finite pure Data graph only; World transport/cleanup/reorder/authority OPEN','pins':pins,'tools':tools,'stages':stages,'commands':[],'limits':{'checker':5,'emission':30,'clang':120,'runtime':5}}
 def save():(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(stage.rglob('*.bend'))}
 def guard():
  tool_pins.verify(tools)
  assert all(sha(p)==h for p,h in pins.items()),'input source drift'
  assert all(inventory(pathlib.Path(d['path']))==d['derivedInventory'] for d in stages.values()),'stage drift'
  assert all(sha(p)==h for p,h in generated.items()),'generated drift'
 def run(argv,cap):
  guard();argv=['taskset','-c','10',*map(str,argv)]
  try:code,text=task_runner.execute(argv,cap,env={**os.environ,'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root','BEND_NO_TELEMETRY':'1'})
  except Exception as e:receipt['commands'].append({'argv':argv,'capSeconds':cap,'error':repr(e)});save();raise
  guard();log=out/('command-'+str(len(receipt['commands']))+'.txt');log.write_text(text)
  receipt['commands'].append({'argv':argv,'capSeconds':cap,'exit':code,'log':str(log),'sha256':sha(log)});save();assert code==0,(code,text);return text
 try:
  sources={str(p.relative_to(ROOT)):p for p in list(HERE.glob('*.bend'))+list((ROOT/'src/ecs').glob('*.bend'))}
  for p in (HERE/'modules').glob('*.bend'):
   key='src/ecs/'+p.name;assert key not in sources,'already present live module';sources[key]=p
  normal={key:sha(p) for key,p in sources.items()}
  for name in ['normal',*MUTANTS]:
   stage=out/name
   for path,h in normal.items():dst=stage/path;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(sources[path],dst);assert sha(dst)==h
   assert inventory(stage)==normal
   if name in MUTANTS:
    file=stage/'src/ecs/relation-graph.bend';text=file.read_text();old,new=MUTANTS[name];assert text.count(old)==1,(name,text.count(old));file.write_text(text.replace(old,new))
   derived=inventory(stage);changes={k:{'original':normal[k],'intentional':v} for k,v in derived.items() if normal[k]!=v};assert len(changes)==(0 if name=='normal' else 1)
   stages[name]={'path':str(stage),'normalInventory':normal,'derivedInventory':derived,'intentionalChanges':changes}
  guard();save()
  # Preflight records deliberate mutant bytes, source closure, imported supervisor;
  # all operations below recheck both normal and every mutant stage.
  if not args.execute:receipt['status']='GUARDED_GRAPH_PREFLIGHT_ONLY';save();print(out,receipt['status']);return 0
  run(['bend','version'],5);run(['bend','guide'],5)
  for name,h in json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'].items():assert run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).strip()==h
  reference=run(['node',HERE/'reference.mjs'],5);validate_reference([json.loads(line) for line in reference.splitlines()]);receipt['freshTSReferenceSHA256']=hashlib.sha256(reference.encode()).hexdigest()
  foreign=run(['node',HERE/'foreign-reference.mjs'],5);receipt['freshTSForeignSHA256']=hashlib.sha256(foreign.encode()).hexdigest()
  receipt['results']=[]
  for name,d in stages.items():
   stage=pathlib.Path(d['path']);entry=stage/'experiments/public-relations/promotion-stage/graph-trace.bend';run(['bend',entry,'--check-only'],5)
   for backend in ['js','native']:
    code=stage/('graph.js' if backend=='js' else 'graph.c');assert not code.exists();run(['bend',entry,'-o',code],30);generated[str(code)]=sha(code)
    if backend=='native':
     binary=stage/'graph-native';assert not binary.exists();run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',code,'-pthread','-lm','-o',binary],120);generated[str(binary)]=sha(binary);argv=[binary,'--threads','1','--gpu','off']
    else:argv=['node',code]
    text=run(argv,5);witnesses=validate(text,name!='normal');receipt['results'].append({'case':name,'backend':backend,'witnesses':witnesses,'checkpointCount':92})
  guard();receipt['generatedPins']=generated;receipt['status']='FINITE_PURE_GRAPH_FALSIFICATION_PASS'
 except Exception as e:receipt['status']='FAIL';receipt['error']=repr(e)
 finally:save()
 print(out,receipt['status']);return 0 if receipt['status']=='FINITE_PURE_GRAPH_FALSIFICATION_PASS' else 1
if __name__=='__main__':sys.exit(main())
