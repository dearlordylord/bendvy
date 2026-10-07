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

HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
import importlib.util
spec=importlib.util.spec_from_file_location("relation_tool_pins",HERE/"tool-pins.py");tool_pins=importlib.util.module_from_spec(spec);spec.loader.exec_module(tool_pins)
from validate import validate as validate_reference
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
MUTANTS={
 'foreign-relate-accepted':('world-adapter.bend','Bool.and(U32.is_eq(namespace,sn),U32.is_eq(namespace,tn)),X.Tx{world,undo,commands,events}','True{},X.Tx{world,undo,commands,events}'),
 'foreign-reorder-accepted':('reorder-adapter.bend','same_world(~S,args,namespace),X.Tx{world,undo,commands,events}','True{},X.Tx{world,undo,commands,events}'),
 'foreign-cleanup-accepted':('cleanup-owned.bend','U32.is_eq(namespace,ns),X.Tx{world,undo,commands,events}','True{},X.Tx{world,undo,commands,events}'),
 'independent-root-collision':('foreign-owned.bend','~O.empty(~S),factory,88)','~O.empty(~S),W.factory(),88)'),
}
NEGATIVES={
 'negative-affine':'consumed more than once',
 'negative-cross-schema':'W.Handle<O.Other>',
 'negative-owner-inspect':'observed : H',
 'negative-undeclared':'observed : relation_write',
 'negative-write-through-read':'observed : P.ReadOnly',
 'negative-inverse-write':'observed : Cap.Request',
 'negative-reorder-ordinary':'observed : G.Descriptor<O.Workshop>',
 'negative-reorder-cross-schema':'observed : R.Args<O.Other>',
 'negative-reorder-write-through-read':'observed : P.ReadOnly',
}
NEGATIVE_SPANS={
 'negative-affine':'def bad(owner: O.Payload) -> O.Payload & O.Payload:',
 'negative-cross-schema':'P.relate_live(H,O.Workshop,caps,owner,P.Targets{foreign,target})',
 'negative-owner-inspect':'W.namespace(~O.Workshop,~A.Store<O.Workshop,O.Components<O.Workshop>>,~U32,~A.Notice<O.Workshop,U32>,owner)',
 'negative-undeclared':'P.relate_live(H,S,relation_write,owner,args)',
 'negative-write-through-read':'P.relate_live(H,S,caps,owner,args)',
 'negative-inverse-write':'case P.ReadOnly{inverse}: replace_inverse(H,S,inverse,owner)',
 'negative-reorder-ordinary':'R.invoke(~O.Workshop,~O.Components<O.Workshop>,~U32,~U32,~ordinary,~A.QueueStatus,~R.body(~O.Workshop),args,tx)',
 'negative-reorder-cross-schema':'R.body(~O.Workshop,H,caps,args,owner)',
 'negative-reorder-write-through-read':'R.body(~O.Workshop,H,caps,args,owner)',
}
def negative_span(entry,text,name):
 m=re.search(r'^\s*(\d+)>\|\s*(.*)$',text,re.M);assert m,(name,'missing diagnostic source span')
 line=int(m.group(1));body=m.group(2).strip();assert entry.read_text().splitlines()[line-1].strip()==body==NEGATIVE_SPANS[name],(name,line,body)
 return {'line':line,'source':body,'inputSHA256':sha(entry)}

def expected():
 owners='100,10,;200,20,21,;300,30,31,32,33,;400,40,41,42,43,44,45,46,47,;'
 lines=[]
 for root in ['Workshop','Other']:
  lines.append(root)
  lines.append('before|'+owners+'|:|events=|meta=1,5,4,8,3,77,1,0|pending=0')
  lines.append('second|'+owners+'|:|events=|meta=2,5,4,8,3,88,1,0|pending=0')
  for operation in ['relate-source','relate-target','unrelate','reorder-parent','reorder-child','cleanup']:lines.append(operation+'=MissingEntity')
  lines.append('queued|'+owners+'|:|events=|meta=1,5,4,8,3,77,1,0|pending=1')
  lines.append('second|'+owners+'|:|events=|meta=2,5,4,8,3,88,1,0|pending=0')
  lines.append('after|'+owners+'|3,:|events=|meta=1,5,4,8,3,77,1,0|pending=0')
  lines.append('second|'+owners+'|:|events=|meta=2,5,4,8,3,88,1,0|pending=0')
 return lines

def validate(out,mutant):
 rows=out.splitlines();literals=expected();assert len(rows)==len(literals),(len(rows),rows)
 witnesses=[{'checkpoint':i,'expected':a,'actual':b} for i,(a,b) in enumerate(zip(literals,rows)) if a!=b]
 if mutant:assert witnesses,'undetected actual namespace/independent-root subject'
 else:assert not witnesses,witnesses
 return witnesses

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');args=ap.parse_args()
 out=HERE/'evidence'/('foreign-'+str(time.time_ns()));out.mkdir(parents=True)
 files=set(HERE.glob('*.bend'))|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|{pathlib.Path(task_runner.__file__).resolve(),ROOT/'docs/parity/source-review.json'}
 files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))
 files|=set((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 files|={pathlib.Path('/home/node/.bend/check.json')}
 tools=tool_pins.snapshot();files|={pathlib.Path(p) for p in tools['pins']}
 for p in ROOT.joinpath('src/ecs').glob('*.bend'):files.add(p)
 pins={str(p):sha(p) for p in sorted(files)};stages={};generated={}
 receipt={'status':'INCOMPLETE','scope':'two actual same-schema worlds from threaded affine Factory; independent roots failed authority discovery; no global factory policy acceptance','pins':pins,'tools':tools,'stages':stages,'commands':[],'limits':{'checker':5,'emission':30,'clang':120,'runtime':5},'childEnvironment':{'BEND_NO_TELEMETRY':'1','BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root'},'cachePolicySource':'pinned Bend main.ts182 BEND_NO_TELEMETRY=1 skips daily update cache, not compiler/checker'}
 def save():(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(stage.rglob('*.bend'))}
 def guard():
  tool_pins.verify(tools)
  assert all(sha(p)==h for p,h in pins.items()),'input source drift'
  assert all(inventory(pathlib.Path(d['path']))==d['derivedInventory'] for d in stages.values()),'stage drift'
  assert all(sha(p)==h for p,h in generated.items()),'generated drift'
 def run(argv,cap,expected=0):
  guard();argv=['taskset','-c','10',*map(str,argv)]
  try:code,text=task_runner.execute(argv,cap,env={**os.environ,'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root','BEND_NO_TELEMETRY':'1'})
  except Exception as e:receipt['commands'].append({'argv':argv,'capSeconds':cap,'error':repr(e)});save();raise
  guard();log=out/('command-'+str(len(receipt['commands']))+'.txt');log.write_text(text)
  receipt['commands'].append({'argv':argv,'capSeconds':cap,'exit':code,'log':str(log),'sha256':sha(log)});save();assert code==expected,(code,text);return text
 try:
  normal={str(p.relative_to(ROOT)):sha(p) for p in list(HERE.glob('*.bend'))+list((ROOT/'src/ecs').glob('*.bend'))}
  for name in ['normal',*MUTANTS]:
   stage=out/name
   for path,h in normal.items():dst=stage/path;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/path,dst);assert sha(dst)==h
   assert inventory(stage)==normal
   if name in MUTANTS:
    filename,old,new=MUTANTS[name];file=stage/'experiments/public-relations'/filename;text=file.read_text();assert text.count(old)==1,(name,text.count(old));file.write_text(text.replace(old,new))
   derived=inventory(stage);changes={k:{'original':normal[k],'intentional':v} for k,v in derived.items() if normal[k]!=v};assert len(changes)==(0 if name=='normal' else 1)
   stages[name]={'path':str(stage),'normalInventory':normal,'derivedInventory':derived,'intentionalChanges':changes}
  guard();save()
  # Preflight records deliberate mutant bytes, source closure, imported supervisor;
  # all operations below recheck both normal and every mutant stage.
  if not args.execute:receipt['status']='GUARDED_FOREIGN_PREFLIGHT_ONLY';save();print(out,receipt['status']);return 0
  run(['bend','version'],5);run(['bend','guide'],5)
  for name,h in json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'].items():assert run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).strip()==h
  reference=run(['node',HERE/'reference.mjs'],5);validate_reference([json.loads(line) for line in reference.splitlines()]);receipt['freshTSReferenceSHA256']=hashlib.sha256(reference.encode()).hexdigest()
  foreign=run(['node',HERE/'foreign-reference.mjs'],5);receipt['freshTSForeignSHA256']=hashlib.sha256(foreign.encode()).hexdigest()
  receipt['actualTSForeignRaw']=foreign
  receipt['negativeResults']=[]
  for name,diagnostic in NEGATIVES.items():
   entry=pathlib.Path(stages['normal']['path'])/'experiments/public-relations'/(name+'.bend');text=run(['bend',entry,'--check-only'],5,1);assert diagnostic in text;span=negative_span(entry,text,name);receipt['negativeResults'].append({'case':name,'intendedDiagnostic':diagnostic,'intendedSourceSpan':span})
  receipt['results']=[]
  for name,d in stages.items():
   stage=pathlib.Path(d['path']);entry=stage/'experiments/public-relations/foreign-owned.bend';run(['bend',entry,'--check-only'],5)
   for backend in ['js','native']:
    code=stage/('world.js' if backend=='js' else 'world.c');assert not code.exists();run(['bend',entry,'-o',code],30);generated[str(code)]=sha(code)
    if backend=='native':
     binary=stage/'world-native';assert not binary.exists();run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',code,'-pthread','-lm','-o',binary],120);generated[str(binary)]=sha(binary);argv=[binary,'--threads','1','--gpu','off']
    else:argv=['node',code]
    text=run(argv,5);witnesses=validate(text,name!='normal');
    receipt['results'].append({'case':name,'backend':backend,'witnesses':witnesses,'checkpointCount':12,'queueRefusalCount':12})
  guard();receipt['generatedPins']=generated;receipt['status']='FINITE_THREADED_FACTORY_RELATION_FOREIGN_PASS'
 except Exception as e:receipt['status']='FAIL';receipt['error']=repr(e)
 finally:save()
 print(out,receipt['status']);return 0 if receipt['status']=='FINITE_THREADED_FACTORY_RELATION_FOREIGN_PASS' else 1
if __name__=='__main__':sys.exit(main())
