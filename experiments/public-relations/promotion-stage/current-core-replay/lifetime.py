#!/usr/bin/env python3
"""Prospective bounded lifetime adapter; preflight precedes Native admission."""
import argparse,hashlib,importlib.util,json,os,pathlib,shutil,sys,time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

RUNNER=pathlib.Path(__file__).resolve();HERE=RUNNER.parent.parent/'query-lifetime';PARENT=HERE.parent;ROOT=HERE.parents[3]
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
sys.path.insert(0,str(HERE));from model import literal,portable,validate
load=lambda name,path: importlib.util.spec_from_file_location(name,path)
def module(name,path):
 spec=load(name,path);result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
raw=task_runner;logs_module=module('receipt_logs',ROOT/'scripts/receipt-logs.py');tools_module=module('lifetime_tools',HERE/'tool-pins.py')
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
MUTANTS={
 'inverse-order-reversed':('src/ecs/relation-query.bend','case []: List.reverse(&2,W.Handle<S>,acc)','case []: acc'),
 'conjunction-omitted':('src/ecs/relation-query.bend','selected && Q.selection_aux','selected || Q.selection_aux'),
 'retained-snapshot-dropped':('experiments/public-relations/promotion-stage/query-lifetime/query-owned.bend','"retained=" ++ show_rows(~S,retained)','"retained=" ++ ""'),
}
# Eager application is deliberately planted at the actual relation queue seam.
EAGER='''def eager_relate(~S: Data,~C: Type,~R: Type,~E: Data,tx: X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>,descriptor: G.Descriptor<S>,source: W.Handle<S>,target: W.Handle<S>) -> X.Tx<W.World<S,Store<S,C>,R,Notice<S,E>>,Notice<S,E>>:
  match tx:
    case X.Tx{world,undo,commands,events}: X.Tx{apply_relate(~S,~C,~R,~E,world,descriptor,source,target),undo,commands,events}
'''
NEGATIVES={
 'negative-query-affine':('consumed more than once','- expected : owner','def bad(-H:Type,owner:H)'),
 'negative-query-cross-schema':('G.Descriptor<O.Other>','- expected : G.Descriptor<O.Workshop>','RQ.read_relation(~O.Workshop,"foreign",descriptor)'),
 'negative-query-owner-inspect':('observed : H','- expected : a datatype','case W.World{ns,_,_,_,_,_,_,_,_,_,_,_,_}: ns'),
 'negative-query-undeclared':('observed : relation_read','- expected : a defined name','Cap.value_read(~H,~RQ.Row<S,List<&2,U32>>,~relation_read,owner)'),
 'negative-query-write-through-read':('observed : Cap.ValueRead','- expected : Cap.ValueWrite','Cap.value_set(~H,~RQ.Row<S,List<&2,U32>>,~RQ.Row<S,List<&2,U32>>,~caps,owner,row)'),
}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');args=ap.parse_args();out=RUNNER.parent/'evidence'/('lifetime-'+str(time.time_ns()));out.mkdir(parents=True)
 subjects=['normal',*MUTANTS,'eager-queue-application'];labels=['version','guide',*[f'reference-{name}' for name in ['bevy-ts','bevy','bend2']],'ts',*[f'negative-{name}' for name in NEGATIVES],*[f'{name}-{phase}' for name in subjects for phase in ['check','emit-js','run-js','emit-c','clang','run-native']]]
 logs=logs_module.CommandLogs(out,labels);tools=tools_module.snapshot();files={RUNNER}|set(HERE.glob('*.bend'))|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|{HERE/'fixture-inputs.json',ROOT/'scripts/receipt-logs.py',pathlib.Path(task_runner.__file__),ROOT/'docs/parity/source-review.json'}
 files|=set((PARENT/'modules').glob('*.bend'))|set((ROOT/'src/ecs').glob('*'));files={p for p in files if p.is_file()}
 files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))|set((ROOT/'.references/bend2/bend2').rglob('*.ts'))|{pathlib.Path('/home/node/.bend/check.json')}
 files|={pathlib.Path(p) for p in tools['pins']};pins={str(p.resolve()):sha(p) for p in sorted(files)};stages={};generated={}
 receipt={'status':'INCOMPLETE','scope':'fresh registered relation Query lifetime/pre-barrier/affine owners; finite only','pins':pins,'tools':tools,'plannedLabels':labels,'commands':[],'stages':stages,'generatedPins':generated,'limits':{'checker':5,'emission':30,'clang':120,'runtime':5},'capture':'raw merged stdout/stderr stored as stdout; stderr explicitly empty','CPU':8}
 def save():(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(p for p in stage.rglob('*') if p.is_file() and (p.suffix=='.bend' or (str(p.relative_to(stage)).startswith('src/ecs/') and p.suffix in ['.c','.js'])))}
 def guard():
  logs.guard();tools_module.verify(tools);assert all(sha(p)==h for p,h in pins.items()),'input drift';assert all(inventory(pathlib.Path(d['path']))==d['derivedInventory'] for d in stages.values()),'stage drift';assert all(sha(p)==h for p,h in generated.items()),'generated drift'
 def run(label,argv,cap,expected=0):
  guard();argv=['taskset','-c','8',*map(str,argv)];r=task_runner.execute_result(argv,cap,env={**os.environ,'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root','BEND_NO_TELEMETRY':'1'});guard();logpins=logs.record(label,r['stdout'],r['stderr']);receipt['commandLogPins']=logpins;receipt['commands'].append({'label':label,'argv':argv,'capSeconds':cap,'exit':r['exit'],'failure':r['failure']});save();assert r['failure'] is None and r['exit']==expected,(label,r);return r['stdout'].decode('utf-8')
 try:
  sources={str(p.relative_to(ROOT)):p for p in list(HERE.glob('*.bend'))+[p for p in (ROOT/'src/ecs').glob('*') if p.is_file() and p.suffix in ['.bend','.c','.js']]}
  for p in (PARENT/'modules').glob('*.bend'):key='src/ecs/'+p.name;assert key not in sources;sources[key]=p
  normal={key:sha(p) for key,p in sources.items()}
  for name in subjects:
   stage=out/name
   for key,h in normal.items():dst=stage/key;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(sources[key],dst);assert sha(dst)==h
   assert inventory(stage)==normal
   if name in MUTANTS:
    file,old,new=MUTANTS[name];file=stage/file;text=file.read_text();assert text.count(old)==1;file.write_text(text.replace(old,new))
   if name=='eager-queue-application':
    file=stage/'src/ecs/relation-commands.bend';text=file.read_text();anchor='def queue_checked(';assert text.count(anchor)==1;text=text.replace(anchor,EAGER+anchor)
    old='X.stage(~W.World<S,Store<S,C>,R,Notice<S,E>>,~Notice<S,E>,tx,world => apply_relate(~S,~C,~R,~E,world,descriptor,source,target))';new='eager_relate(~S,~C,~R,~E,tx,descriptor,source,target)';assert text.count(old)==1;file.write_text(text.replace(old,new))
   derived=inventory(stage);changes={k:{'original':normal[k],'intentional':h} for k,h in derived.items() if normal[k]!=h};assert len(changes)==(0 if name=='normal' else 1);stages[name]={'path':str(stage),'normalInventory':normal,'derivedInventory':derived,'intentionalChanges':changes}
  guard();save()
  if not args.execute:receipt['status']='GUARDED_QUERY_LIFETIME_PREFLIGHT_ONLY';save();print(out,receipt['status']);return 0
  run('version',['bend','version'],5);run('guide',['bend','guide'],5)
  for name,h in json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'].items():assert run('reference-'+name,['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).strip()==h
  ts=run('ts',['node',HERE/'query-reference.mjs'],5);actualTS=[json.loads(line) for line in ts.splitlines()];assert actualTS==literal(),(actualTS,literal());receipt['actualTS']=actualTS;receipt['actualTSSHA256']=hashlib.sha256(ts.encode()).hexdigest()
  receipt['negativeResults']=[]
  import re
  for name,(diagnostic,expected,expression) in NEGATIVES.items():
   entry=pathlib.Path(stages['normal']['path'])/str(HERE.relative_to(ROOT))/(name+'.bend');text=run('negative-'+name,['bend',entry,'--check-only'],5,1);line=next(i+1 for i,l in enumerate(entry.read_text().splitlines()) if expression in l);assert diagnostic in text and expected in text and 'Location: bad' in text and '^' in text and expression in text and re.search(r'(?m)^\s*'+str(line)+r'>\|',text);receipt['negativeResults'].append({'case':name,'expression':expression,'line':line,'expected':expected,'observed':diagnostic,'completeDiagnosticSHA256':hashlib.sha256(text.encode()).hexdigest()})
  receipt['results']=[]
  for name,d in stages.items():
   stage=pathlib.Path(d['path']);entry=stage/str(HERE.relative_to(ROOT))/'query-owned.bend';run(name+'-check',['bend',entry,'--check-only'],5)
   for backend in ['js','native']:
    code=stage/('query.js' if backend=='js' else 'query.c');assert not code.exists();run(name+('-emit-js' if backend=='js' else '-emit-c'),['bend',entry,'-o',code],30);generated[str(code)]=sha(code)
    if backend=='native':
     binary=stage/'query-native';assert not binary.exists();run(name+'-clang',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',code,'-pthread','-lm','-o',binary],120);generated[str(binary)]=sha(binary);argv=[binary,'--threads','1','--gpu','off']
    else:argv=['node',code]
    text=run(name+('-run-js' if backend=='js' else '-run-native'),argv,5);actual,witnesses=validate(text,name!='normal')
    if name=='normal':
     assert actual==actualTS
     owners='owners=100,10,;200,20,21,;300,30,31,32,33,;400,40,41,42,43,44,45,46,47,;|2,5,:3,|events=|meta=1,6,5,8,3,77,4,0|pending=0';assert text.splitlines().count(owners)==2,text
    receipt['results'].append({'case':name,'backend':backend,'queryShapeCount':66,'retainedSnapshotCount':2,'witnesses':witnesses,'fullOutputSHA256':hashlib.sha256(text.encode()).hexdigest()})
  guard();receipt['status']='FINITE_REGISTERED_QUERY_LIFETIME_PASS'
 except Exception as error:receipt['status']='FAIL';receipt['error']=repr(error)
 finally:save()
 print(out,receipt['status']);return 0 if receipt['status']=='FINITE_REGISTERED_QUERY_LIFETIME_PASS' else 1
if __name__=='__main__':sys.exit(main())
