#!/usr/bin/env python3
"""Preflight first; executable finite graph falsification is a separate opt-in.
No proof, World/Commands/cleanup or relation-system acceptance is reported.
"""
import argparse, hashlib, json, os, pathlib, re, shutil, sys, time
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
import importlib.util
spec=importlib.util.spec_from_file_location("relation_tool_pins",HERE/"tool-pins.py");tool_pins=importlib.util.module_from_spec(spec);spec.loader.exec_module(tool_pins)
from validate import validate as validate_reference
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
MUTANTS={
 'inverse-order-omission':('reorder-core.bend','case True{} T.Inverse{d,parent,_}: T.Inverse{d,parent,sources} <> rest','case True{} T.Inverse{d,parent,old}: T.Inverse{d,parent,old} <> rest'),
 'child-before-parent':('reorder-core.bend','case False{}: Some{T.MissingEntity{parent}}','case False{}: children_checked(~S,children,graph,d,parent,[])'),
 'wrong-failure-target':('reorder-adapter.bend','parent,error_target(error,parent),error','parent,parent,error'),
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

model_spec=importlib.util.spec_from_file_location('independent_reorder_model',HERE/'reorder-model.py');model=importlib.util.module_from_spec(model_spec);model_spec.loader.exec_module(model)
def error_text(e):
 tag=e['_tag'];parent=str(e['entityId'])
 if tag=='MissingEntity':return tag+':'+parent
 if 'childId' in e:return tag+':'+parent+':'+str(e['childId'])+':'+e['relation']
 return tag+':'+parent+':'+e['relation']
def expected():
 lines=[]
 for root in ['Workshop','Other']:
  lines.append(root)
  for r in model.records(root):
   owners=''.join(''.join(str(x)+',' for x in owner)+';' for owner in model.OWNERS)
   inverse=lambda xs:''.join(str(x)+',' for x in xs)
   targets=''.join('none,' if x is None else str(x)+',' for x in r['targets'])
   inverses=''.join(inverse(xs)+';' for xs in r['inverses'])
   failures=''.join('1:Parent:Children:'+f['operation']+':'+str(f['source'])+':'+str(f['target'])+':'+error_text(f['error'])+';' for f in r['failures'])
   pending=5 if r['phase']=='fifo-queued' else 1 if r['phase'].endswith('-queued') else 0
   lines.append(r['phase']+'|'+owners+'|'+inverse(r['inverses'][0])+':'+inverse(r['inverses'][1])+'|targets='+targets+'|inverses='+inverses+'|failures='+failures+'|meta=1,5,4,8,3,77,2,0|pending='+str(pending))
  lines.append('done')
 return lines

def validate(out,mutant):
 rows=out.splitlines();literals=expected();assert len(rows)==len(literals),(len(rows),rows)
 witnesses=[{'checkpoint':i,'expected':a,'actual':b} for i,(a,b) in enumerate(zip(literals,rows)) if a!=b]
 if mutant:assert witnesses,'undetected actual reorder mutant'
 else:assert not witnesses,witnesses
 return witnesses

def parse_error(fields):
 tag,parent,*tail=fields;e={'_tag':tag,'entityId':int(parent)}
 if tag=='MissingEntity':assert not tail
 elif tag in ['MissingChildEntity','DuplicateChild','ChildNotRelatedToParent']:e.update(childId=int(tail[0]),relation=tail[1])
 else:e['relation']=tail[0]
 return e

def portable(out):
 result=[];root=None
 for row in out.splitlines():
  if row in ['Workshop','Other']:root=row;continue
  if row=='done':continue
  fields=row.split('|');extra=dict(x.split('=',1) for x in fields[3:]);owners=[[i+1,[int(x) for x in owner.split(',') if x]]for i,owner in enumerate(fields[1].split(';')[:-1])]
  targets=[None if x=='none' else int(x) for x in extra['targets'].split(',')[:-1]]
  inverses=[[int(x)for x in xs.split(',')if x]for xs in extra['inverses'].split(';')[:-1]]
  failures=[]
  for event in extra['failures'].split(';'):
   if not event:continue
   key,relation,inverse,op,source,target,*error=event.split(':');assert key=='1' and inverse=='Children'
   failures.append({'operation':op,'relation':relation,'source':int(source),'target':int(target),'error':parse_error(error)})
  result.append({'root':root,'phase':fields[0],'owners':owners,'targets':targets,'inverses':inverses,'failures':failures})
 return result

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');args=ap.parse_args()
 out=HERE/'evidence'/('reorder-'+str(time.time_ns()));out.mkdir(parents=True)
 files=set(HERE.glob('*.bend'))|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|{pathlib.Path(supervisor.__file__).resolve(),ROOT/'docs/parity/source-review.json'}
 files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))
 files|=set((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 files|={pathlib.Path('/home/node/.bend/check.json')}
 tools=tool_pins.snapshot();files|={pathlib.Path(p) for p in tools['pins']}
 for p in ROOT.joinpath('src/ecs').glob('*.bend'):files.add(p)
 pins={str(p):sha(p) for p in sorted(files)};stages={};generated={}
 receipt={'status':'INCOMPLETE','scope':'finite registered hierarchy reorder/Type owners; keyed retention OPEN','pins':pins,'tools':tools,'stages':stages,'commands':[],'limits':{'checker':5,'emission':30,'clang':120,'runtime':5},'childEnvironment':{'BEND_NO_TELEMETRY':'1','BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root'},'retainedFailedAttempt':'evidence/reorder-1791359681028526401/receipt.json'}
 def save():(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(stage.rglob('*.bend'))}
 def guard():
  tool_pins.verify(tools)
  assert all(sha(p)==h for p,h in pins.items()),'input source drift'
  assert all(inventory(pathlib.Path(d['path']))==d['derivedInventory'] for d in stages.values()),'stage drift'
  assert all(sha(p)==h for p,h in generated.items()),'generated drift'
 def run(argv,cap,expected=0):
  guard();argv=['taskset','-c','10',*map(str,argv)]
  try:code,text=supervisor.execute(argv,cap,env={**os.environ,'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root','BEND_NO_TELEMETRY':'1'})
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
  if not args.execute:receipt['status']='GUARDED_REORDER_PREFLIGHT_ONLY';save();print(out,receipt['status']);return 0
  run(['bend','version'],5);run(['bend','guide'],5)
  for name,h in json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'].items():assert run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).strip()==h
  reference=run(['node',HERE/'reference.mjs'],5);validate_reference([json.loads(line) for line in reference.splitlines()]);receipt['freshTSReferenceSHA256']=hashlib.sha256(reference.encode()).hexdigest()
  foreign=run(['node',HERE/'foreign-reference.mjs'],5);receipt['freshTSForeignSHA256']=hashlib.sha256(foreign.encode()).hexdigest()
  reorderTS=run(['node',HERE/'reorder-reference.mjs'],5);tsExpected=[json.loads(line) for line in reorderTS.splitlines()];assert tsExpected==model.records('Workshop')+model.records('Other');assert portable('\n'.join(expected()))==tsExpected;receipt['actualReorderTS']=tsExpected
  receipt['negativeResults']=[]
  for name,diagnostic in NEGATIVES.items():
   entry=pathlib.Path(stages['normal']['path'])/'experiments/public-relations'/(name+'.bend');text=run(['bend',entry,'--check-only'],5,1);assert diagnostic in text;span=negative_span(entry,text,name);receipt['negativeResults'].append({'case':name,'intendedDiagnostic':diagnostic,'intendedSourceSpan':span})
  receipt['results']=[]
  for name,d in stages.items():
   stage=pathlib.Path(d['path']);entry=stage/'experiments/public-relations/reorder-owned.bend';run(['bend',entry,'--check-only'],5)
   for backend in ['js','native']:
    code=stage/('world.js' if backend=='js' else 'world.c');assert not code.exists();run(['bend',entry,'-o',code],30);generated[str(code)]=sha(code)
    if backend=='native':
     binary=stage/'world-native';assert not binary.exists();run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',code,'-pthread','-lm','-o',binary],120);generated[str(binary)]=sha(binary);argv=[binary,'--threads','1','--gpu','off']
    else:argv=['node',code]
    text=run(argv,5);witnesses=validate(text,name!='normal');
    if name=='normal':assert portable(text)==tsExpected
    receipt['results'].append({'case':name,'backend':backend,'witnesses':witnesses,'checkpointCount':52})
  guard();receipt['generatedPins']=generated;receipt['status']='FINITE_REGISTERED_HIERARCHY_REORDER_PASS'
 except Exception as e:receipt['status']='FAIL';receipt['error']=repr(e)
 finally:save()
 print(out,receipt['status']);return 0 if receipt['status']=='FINITE_REGISTERED_HIERARCHY_REORDER_PASS' else 1
if __name__=='__main__':sys.exit(main())
