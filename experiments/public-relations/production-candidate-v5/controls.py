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

 'component-clear-omission':('cleanup-owned.bend','case O.Components{column} W.Handle{_,+id}: removed(~S,Col.clear(~S,~O.Payload,column,id),id)','case O.Components{column} W.Handle{_,+id}: (O.Components{column},[])'),
 'linked-order-reversal':('relation-cleanup.bend','(world,G.CleanupChildren{id,descriptor,remaining,children} <> frames)','(world,G.CleanupChildren{id,descriptor,remaining,List.reverse(&2,U32,children)} <> frames)'),
 'entered-despawn-omission':('relation-cleanup.bend','List.append(&2,A.Notice<S,E>,notices,[record(handle)])','List.append(&2,A.Notice<S,E>,notices,[])'),
 'fixed128-completion':('relation-cleanup.bend','owner_blocks(~S,~C,~R,~E,~clear,~record,nodes,drive(~S,~C,~R,~E,~clear,~record,1n,[G.CleanupEnter{id}],world,namespace,descriptors),nodes,edges,namespace,descriptors)','drive(~S,~C,~R,~E,~clear,~record,128n,[G.CleanupEnter{id}],world,namespace,descriptors)'),
}
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
CASES=[('ordinary',[(1,False)],[(1,3,1),(1,2,1)],1),('ordinary-source',[(1,False)],[(1,3,1),(1,2,1)],3),('hierarchy',[(1,True)],[(1,3,1),(1,2,1),(1,4,2)],1),('cycle-one',[(1,True),(2,True)],[(1,1,2),(2,2,1)],1),('cycle-two',[(1,True),(2,True)],[(1,1,2),(2,2,1)],2),('bound219',[(1,True),(2,True),(3,True)],[(1,2,1),(1,3,2),(1,4,3),(2,1,4),(2,3,2),(2,4,3),(3,1,4),(3,2,1),(3,4,3)],1)]
model_spec=importlib.util.spec_from_file_location('independent_cleanup_model',HERE/'cleanup-model.py');model=importlib.util.module_from_spec(model_spec);model_spec.loader.exec_module(model)
def expected():
 lines=[]
 for root in ['Workshop','Other']:
  lines.append(root)
  for name,descriptors,edges,destroy in CASES:
   lines.append(name);end=model.cleanup(descriptors,edges,OWNERS,destroy)
   # Independent literals falsify model conventions before model-driven comparison.
   assert end['despawned']=={'ordinary':[1],'ordinary-source':[3],'hierarchy':[3,4,2,1],'cycle-one':[2,1],'cycle-two':[2,1,2],'bound219':[2,1,4,3,2,1,4,3,2,1,4,3,2,1,4,3,2,1,4,3,2,1]}[name]
   assert [x[0] for x in end['removed']]=={'ordinary':[1],'ordinary-source':[3],'hierarchy':[3,4,2,1],'cycle-one':[2,1],'cycle-two':[2,1],'bound219':[2,1,4,3]}[name]
   for phase in ['before','queued','after']:
    current=dict(end['owners']) if phase=='after' else OWNERS;currentEdges=end['edges'] if phase=='after' else edges
    owners=''.join((''.join(str(x)+',' for x in current[id]) if id in current else 'absent')+';' for id in range(1,5))
    inverse=lambda parent: ''.join(str(source)+',' for key,source,target in currentEdges if key==1 and target==parent)
    events=''
    if phase=='after':
     for id,cells in end['removed']:events+='Removed:'+str(id)+';'+''.join('Original:'+str(100000+x)+';' for x in cells)
     # Actual TS interleaves each frame removal with its despawn, including duplicates.
     events='';removed=dict(end['removed']);emitted=set()
     for id in end['despawned']:
      if id not in emitted and id in removed:events+='Removed:'+str(id)+';'+''.join('Original:'+str(100000+x)+';' for x in removed[id]);emitted.add(id)
      events+='Original:'+str(1000+id)+';'
    edgeText=''.join(':'.join(map(str,e))+';' for e in currentEdges)
    live=''.join(('1,' if id in current else '0,') for id in range(1,5))
    lines.append(phase+'|'+owners+'|'+inverse(1)+':'+inverse(2)+'|events='+events+'|meta=1,5,4,8,3,77,2,0|pending='+('1' if phase=='queued' else '0')+'|edges='+edgeText+'|live='+live)
 return lines

def validate(out,mutant):
 rows=out.splitlines();literals=expected();assert len(rows)==len(literals),(len(rows),rows)
 witnesses=[{'checkpoint':i,'expected':a,'actual':b} for i,(a,b) in enumerate(zip(literals,rows)) if a!=b]
 if mutant:assert witnesses,'undetected actual cleanup mutant'
 else:assert not witnesses,witnesses
 return witnesses

def portable(out):
 result=[];root=None;case=None
 for line in out.splitlines():
  if line in ['Workshop','Other']:root=line;continue
  if line in [x[0] for x in CASES]:case=line;continue
  fields=line.split('|');phase=fields[0];owners=[]
  for id,owner in enumerate(fields[1].split(';')[:-1],1):
   if owner!='absent':owners.append([id,[int(x) for x in owner.split(',') if x]])
  extra=dict(x.split('=',1) for x in fields[3:] if '=' in x);edges=sorted([[int(x) for x in e.split(':')] for e in extra['edges'].split(';') if e]);removed=[];despawned=[]
  for event in extra['events'].split(';'):
   if event.startswith('Removed:'):removed.append(int(event.split(':')[1]))
   elif event.startswith('Original:'):
    value=int(event.split(':')[1])
    if 1000<value<2000:despawned.append(value-1000)
  result.append({'root':root,'case':case,'phase':phase,'owners':owners,'edges':edges,'removed':removed,'despawned':despawned})
 return result

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');args=ap.parse_args()
 out=HERE/'evidence'/('cleanup-'+str(time.time_ns()));out.mkdir(parents=True)
 files=set(HERE.glob('*.bend'))|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|{pathlib.Path(task_runner.__file__).resolve(),ROOT/'docs/parity/source-review.json'}
 files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))
 files|=set((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 files|={pathlib.Path('/home/node/.bend/check.json')}
 tools=tool_pins.snapshot();files|={pathlib.Path(p) for p in tools['pins']}
 for p in ROOT.joinpath('src/ecs').glob('*.bend'):files.add(p)
 pins={str(p):sha(p) for p in sorted(files)};stages={};generated={}
 receipt={'status':'INCOMPLETE','scope':'derivedNat candidate automatic cleanup, actual registered arbitrary-Type owner/adaptor; complete219-step subject, no production delivery/proofs/keyed retention acceptance','pins':pins,'tools':tools,'stages':stages,'commands':[],'limits':{'checker':5,'emission':30,'clang':120,'runtime':5}}
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
    filename,old,new=MUTANTS[name];file=stage/'experiments/public-relations/production-candidate-v5'/filename;text=file.read_text();assert text.count(old)==1,(name,text.count(old));file.write_text(text.replace(old,new))
   derived=inventory(stage);changes={k:{'original':normal[k],'intentional':v} for k,v in derived.items() if normal[k]!=v};assert len(changes)==(0 if name=='normal' else 1)
   stages[name]={'path':str(stage),'normalInventory':normal,'derivedInventory':derived,'intentionalChanges':changes}
  guard();save()
  # Preflight records deliberate mutant bytes, source closure, imported supervisor;
  # all operations below recheck both normal and every mutant stage.
  if not args.execute:receipt['status']='GUARDED_DERIVED_NAT_CLEANUP_PREFLIGHT_ONLY';save();print(out,receipt['status']);return 0
  run(['bend','version'],5);run(['bend','guide'],5)
  for name,h in json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'].items():assert run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).strip()==h
  reference=run(['node',HERE/'reference.mjs'],5);validate_reference([json.loads(line) for line in reference.splitlines()]);receipt['freshTSReferenceSHA256']=hashlib.sha256(reference.encode()).hexdigest()
  foreign=run(['node',HERE/'foreign-reference.mjs'],5);receipt['freshTSForeignSHA256']=hashlib.sha256(foreign.encode()).hexdigest()
  cleanupTS=run(['node',HERE/'cleanup-reference.mjs'],5);tsExpected=[json.loads(line) for line in cleanupTS.splitlines()];assert portable('\n'.join(expected()))==tsExpected;receipt['actualCleanupTS']=tsExpected
  receipt['negativeResults']=[]
  for name,diagnostic in NEGATIVES.items():
   entry=pathlib.Path(stages['normal']['path'])/'experiments/public-relations/production-candidate-v5'/(name+'.bend');text=run(['bend',entry,'--check-only'],5,1);assert diagnostic in text;span=re.search(r'^\s*(\d+)>\|\s*(.*)$',text,re.M);assert span,(name,'missing diagnostic span');line=int(span.group(1));body=span.group(2).strip();assert entry.read_text().splitlines()[line-1].strip()==body==NEGATIVE_SPANS[name],(name,line,body);receipt['negativeResults'].append({'case':name,'intendedDiagnostic':diagnostic,'sourceSpan':{'line':line,'source':body,'inputSHA256':sha(entry)}})
  receipt['results']=[]
  for name,d in stages.items():
   stage=pathlib.Path(d['path']);entry=stage/'experiments/public-relations/production-candidate-v5/cleanup-owned.bend';run(['bend',entry,'--check-only'],5)
   for backend in ['js','native']:
    code=stage/('world.js' if backend=='js' else 'world.c');assert not code.exists();run(['bend',entry,'-o',code],30);generated[str(code)]=sha(code)
    if backend=='native':
     binary=stage/'world-native';assert not binary.exists();run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',code,'-pthread','-lm','-o',binary],120);generated[str(binary)]=sha(binary);argv=[binary,'--threads','1','--gpu','off']
    else:argv=['node',code]
    text=run(argv,5);witnesses=validate(text,name!='normal');
    if name=='normal':assert portable(text)==tsExpected
    receipt['results'].append({'case':name,'backend':backend,'witnesses':witnesses,'checkpointCount':36})
  guard();receipt['generatedPins']=generated;receipt['status']='FINITE_DERIVED_NAT_REGISTERED_AFFINE_CLEANUP_PASS'
 except Exception as e:receipt['status']='FAIL';receipt['error']=repr(e)
 finally:save()
 print(out,receipt['status']);return 0 if receipt['status']=='FINITE_DERIVED_NAT_REGISTERED_AFFINE_CLEANUP_PASS' else 1
if __name__=='__main__':sys.exit(main())
