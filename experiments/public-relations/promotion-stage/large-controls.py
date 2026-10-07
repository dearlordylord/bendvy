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
 'graph-remove-wrong-order':('relation-graph.bend','case []: List.reverse(&2,T.Edge<S>,acc)','case []: acc'),
 'graph-remove-drop-survivors':('relation-graph.bend','case False{}: edge <> rest','case False{}: rest'),
"overflowing-old-bound":("relation-cleanup.bend",'def automatic_start(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+nodes:Nat,+edges:List<&2,G.Edge<S>>,+namespace:U32,id:U32,+descriptors:List<&2,G.Descriptor<S>>) -> CleanupResult<S,C,R,E>:\n  owner_blocks(~S,~C,~R,~E,~clear,~record,nodes,drive(~S,~C,~R,~E,~clear,~record,1n,[G.CleanupEnter{id}],world,namespace,descriptors),nodes,edges,namespace,descriptors)\n','# MUTANT-ONLY tail cardinality adapter: avoids unrelated Base List.length stack failure.\ndef mutant_length(~T:Data,values:List<&2,T>,count:Nat) -> Nat:\n  match values:\n    case []: count\n    case value <> rest: mutant_length(~T,rest,Nat.add(count,1n))\ndef automatic_start(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,+nodes:Nat,+edges:List<&2,G.Edge<S>>,+namespace:U32,id:U32,+descriptors:List<&2,G.Descriptor<S>>) -> CleanupResult<S,C,R,E>:\n  drive(~S,~C,~R,~E,~clear,~record,Nat.add(1n,Nat.mul(nodes,Nat.mul(Nat.add(mutant_length(~G.Edge<S>,edges,0n),Nat.add(nodes,1n)),Nat.add(3n,Nat.add(Nat.mul(2n,mutant_length(~G.Descriptor<S>,descriptors,0n)),Nat.mul(2n,mutant_length(~G.Edge<S>,edges,0n))))))),[G.CleanupEnter{id}],world,namespace,descriptors)\n')}
NEGATIVES={
 'negative-affine':'consumed more than once',
 'negative-cross-schema':'W.Handle<O.Other>',
 'negative-owner-inspect':'observed : H',
 'negative-undeclared':'observed : relation_write',
 'negative-write-through-read':'observed : P.ReadOnly',
 'negative-inverse-write':'observed : Cap.Request',
 'negative-cleanup-cross-schema':'observed : W.Handle<O.Other>',
 'negative-cleanup-write-through-read':'observed : P.ReadOnly',
 'negative-clear-graph':'observed : O.Components',
 'negative-clear-world':'observed : O.Components',
}
NEGATIVE_SPANS={'negative-affine': 'def bad(owner: O.Payload) -> O.Payload & O.Payload:', 'negative-cross-schema': 'P.relate_live(H,O.Workshop,caps,owner,P.Targets{foreign,target})', 'negative-owner-inspect': 'W.namespace(~O.Workshop,~A.Store<O.Workshop,O.Components<O.Workshop>>,~U32,~A.Notice<O.Workshop,U32>,owner)', 'negative-undeclared': 'P.relate_live(H,S,relation_write,owner,args)', 'negative-write-through-read': 'P.relate_live(H,S,caps,owner,args)', 'negative-inverse-write': 'case P.ReadOnly{inverse}: replace_inverse(H,S,inverse,owner)', 'negative-cleanup-cross-schema': 'C.body(~O.Workshop,H,caps,handle,owner)', 'negative-cleanup-write-through-read': 'C.body(~O.Workshop,H,caps,handle,owner)', 'negative-clear-graph': 'A.graph_read(~S,~O.Components<S>,components)', 'negative-clear-world': 'W.namespace(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,components)'}
OWNERS={1:[100,10],2:[200,20,21],3:[300,30,31,32,33],4:[400,40,41,42,43,44,45,46,47]}
def expected():
 result=[]
 for root in ['Workshop','Other']:
  result.append(root)
  for phase in ['before','queued','after']:
   owners=''.join(('absent' if phase=='after' and id==1 else ''.join(str(x)+',' for x in OWNERS[id]))+';' for id in range(1,5))
   inverse=':' if phase=='after' else ':1,'
   events='Removed:1;Original:100100;Original:100010;Original:1001;' if phase=='after' else ''
   result.append(phase+'|'+owners+'|'+inverse+'|events='+events+'|meta=1,131073,131072,262144,18,77,2,0|pending='+('1' if phase=='queued' else '0')+'|all-live-shape=true|all-graph-fields=true')
 return result

def validate(out,mutant):
 rows=out.splitlines();literals=expected();assert len(rows)==len(literals),(len(rows),rows)
 witnesses=[{'checkpoint':i,'expected':a,'actual':b} for i,(a,b) in enumerate(zip(literals,rows)) if a!=b]
 if mutant:assert witnesses,'undetected actual graph mutant'
 else:assert not witnesses,witnesses
 return witnesses
def portable(out):
 records=[];root=None
 for line in out.splitlines():
  if line in ['Workshop','Other']:root=line;continue
  fields=line.split('|');phase=fields[0]
  owners=[[id,[int(x) for x in owner.split(',') if x]] for id,owner in enumerate(fields[1].split(';')[:-1],1) if owner!='absent']
  records.append({'root':root,'phase':phase,'count':131072,'liveCount':131071 if phase=='after' else 131072,'owners':owners,'allLiveShape':fields[-2]=='all-live-shape=true','allGraphFields':fields[-1]=='all-graph-fields=true','removed':[1] if phase=='after' else [],'despawned':[1] if phase=='after' else []})
 return records

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');ap.add_argument('--only-overflow-mutant',action='store_true');args=ap.parse_args()
 out=HERE/'evidence'/('large-'+str(time.time_ns()));out.mkdir(parents=True)
 files=set((HERE/'modules').glob('*.bend'))|{HERE/'derivation.json',HERE/'additive-modules.patch'}|set(HERE.glob('*.bend'))|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|{pathlib.Path(task_runner.__file__).resolve(),ROOT/'docs/parity/source-review.json'}
 files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))
 files|=set((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 files|={pathlib.Path('/home/node/.bend/check.json')}
 tools=tool_pins.snapshot();files|={pathlib.Path(p) for p in tools['pins']}
 for p in ROOT.joinpath('src/ecs').glob('*.bend'):files.add(p)
 pins={str(p):sha(p) for p in sorted(files)};stages={};generated={}
 receipt={'status':'INCOMPLETE','scope':'derivedNat candidate automatic cleanup, actual registered arbitrary-Type owner/adaptor; complete219-step subject, no production delivery/proofs/keyed retention acceptance','pins':pins,'tools':tools,'stages':stages,'commands':[],'selection':'overflowing-old-bound only' if args.only_overflow_mutant else 'all', 'limits':{'checker':5,'emission':30,'clang':120,'runtime':5}}
 def save():(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(stage.rglob('*.bend'))}
 def guard():
  tool_pins.verify(tools)
  assert all(sha(p)==h for p,h in pins.items()),'input source drift'
  assert all(inventory(pathlib.Path(d['path']))==d['derivedInventory'] for d in stages.values()),'stage drift'
  assert all(sha(p)==h for p,h in generated.items()),'generated drift'
 def run(argv,cap,expected=0):
  guard();argv=['taskset','-c','10',*map(str,argv)]
  try:code,text=task_runner.execute(argv,cap,env={**os.environ,'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root','BEND_NO_TELEMETRY':'1','BEND_NO_TELEMETRY':'1'})
  except Exception as e:receipt['commands'].append({'argv':argv,'capSeconds':cap,'error':repr(e)});save();raise
  guard();log=out/('command-'+str(len(receipt['commands']))+'.txt');log.write_text(text)
  receipt['commands'].append({'argv':argv,'capSeconds':cap,'exit':code,'log':str(log),'sha256':sha(log)});save();assert code==expected,(code,text);return text
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
    filename,old,new=MUTANTS[name];file=stage/'src/ecs'/filename if filename.startswith('relation-') else stage/'experiments/public-relations/promotion-stage'/filename;text=file.read_text();assert text.count(old)==1,(name,text.count(old));file.write_text(text.replace(old,new))
   derived=inventory(stage);changes={k:{'original':normal[k],'intentional':v} for k,v in derived.items() if normal[k]!=v};assert len(changes)==(0 if name=='normal' else 1)
   stages[name]={'path':str(stage),'normalInventory':normal,'derivedInventory':derived,'intentionalChanges':changes}
  guard();save()
  # Preflight records deliberate mutant bytes, source closure, imported supervisor;
  # all operations below recheck both normal and every mutant stage.
  if not args.execute:receipt['status']='GUARDED_LARGE_STRUCTURAL_BUDGET_PREFLIGHT_ONLY';save();print(out,receipt['status']);return 0
  run(['bend','version'],5);run(['bend','guide'],5)
  for name,h in json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'].items():assert run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).strip()==h
  if not args.only_overflow_mutant:
   reference=run(['node',HERE/'reference.mjs'],5);validate_reference([json.loads(line) for line in reference.splitlines()]);receipt['freshTSReferenceSHA256']=hashlib.sha256(reference.encode()).hexdigest()
   foreign=run(['node',HERE/'foreign-reference.mjs'],5);receipt['freshTSForeignSHA256']=hashlib.sha256(foreign.encode()).hexdigest()
  cleanupTS=run(['node',HERE/'large-reference.mjs'],5);tsExpected=[json.loads(line) for line in cleanupTS.splitlines()];assert portable('\n'.join(expected()))==tsExpected;receipt['actualCleanupTS']=tsExpected
  receipt['negativeResults']=[]
  for name,diagnostic in ([] if args.only_overflow_mutant else NEGATIVES.items()):
   entry=pathlib.Path(stages['normal']['path'])/'experiments/public-relations/promotion-stage'/(name+'.bend');text=run(['bend',entry,'--check-only'],5,1);assert diagnostic in text;span=re.search(r'^\s*(\d+)>\|\s*(.*)$',text,re.M);assert span,(name,'missing diagnostic span');line=int(span.group(1));body=span.group(2).strip();assert entry.read_text().splitlines()[line-1].strip()==body==NEGATIVE_SPANS[name],(name,line,body);receipt['negativeResults'].append({'case':name,'intendedDiagnostic':diagnostic,'sourceSpan':{'line':line,'source':body,'inputSHA256':sha(entry)}})
  receipt['results']=[]
  for name,d in stages.items():
   if args.only_overflow_mutant and name!='overflowing-old-bound':continue
   stage=pathlib.Path(d['path']);entry=stage/'experiments/public-relations/promotion-stage/large-owned.bend';run(['bend',entry,'--check-only'],5)
   for backend in ['js','native']:
    code=stage/('world.js' if backend=='js' else 'world.c');assert not code.exists();run(['bend',entry,'-o',code],30);generated[str(code)]=sha(code)
    if backend=='native':
     binary=stage/'world-native';assert not binary.exists();run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',code,'-pthread','-lm','-o',binary],120);generated[str(binary)]=sha(binary);argv=[binary,'--threads','1','--gpu','off']
    else:argv=['node',code]
    if name=='overflowing-old-bound':
     text=run(argv,5,1);assert 'a Nat past the largest immediate 2^48-1' in text,text
     receipt['results'].append({'case':name,'backend':backend,'observedFailStop':'Nat past 2^48-1','notSemanticCompletion':True});continue
    text=run(argv,5);witnesses=validate(text,name!='normal');
    if name=='normal':assert portable(text)==tsExpected
    receipt['results'].append({'case':name,'backend':backend,'witnesses':witnesses,'checkpointCount':6})
  guard();receipt['generatedPins']=generated;receipt['status']='FINITE_OLD_OVERFLOW_MUTANT_ISOLATED_PASS' if args.only_overflow_mutant else 'FINITE_LARGE_STRUCTURAL_BUDGET_AND_OLD_OVERFLOW_FAILSTOP_PASS'
 except Exception as e:receipt['status']='FAIL';receipt['error']=repr(e)
 finally:save()
 print(out,receipt['status']);return 0 if receipt['status'] in ['FINITE_LARGE_STRUCTURAL_BUDGET_AND_OLD_OVERFLOW_FAILSTOP_PASS','FINITE_OLD_OVERFLOW_MUTANT_ISOLATED_PASS'] else 1
if __name__=='__main__':sys.exit(main())
