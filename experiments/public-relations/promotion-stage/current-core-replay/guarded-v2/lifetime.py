#!/usr/bin/env python3
"""Prospective bounded lifetime adapter; preflight precedes Native admission."""
import argparse,hashlib,importlib.util,json,os,pathlib,shutil,sys,time
RUNNER=pathlib.Path(__file__).resolve();HERE=RUNNER.parent.parent.parent/'query-lifetime';PARENT=HERE.parent;ROOT=HERE.parents[3]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
sys.path.insert(0,str(RUNNER.parent));sys.path.insert(0,str(HERE));from model import literal,portable,validate
load=lambda name,path: importlib.util.spec_from_file_location(name,path)
def module(name,path):
 spec=load(name,path);result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
raw=module('raw_supervisor',RUNNER.parent/'raw_supervisor.py');logs_module=module('receipt_logs',ROOT/'scripts/receipt-logs.py');tools_module=module('lifetime_tools',RUNNER.parent/'tool-pins.py')
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
def exact_caret(name,entry,text):
 tokens={'negative-query-affine':('owner',16,5),'negative-query-cross-schema':('descriptor',41,10),'negative-query-owner-inspect':('W.World{ns,_,_,_,_,_,_,_,_,_,_,_,_}',9,35),'negative-query-undeclared':('relation_read',45,13),'negative-query-write-through-read':('caps',68,4)}
 token,column,length=tokens[name];lines=entry.read_text().splitlines();matches=[(i+1,l) for i,l in enumerate(lines) if l[column:column+length]==token];assert len(matches)==1,(name,matches)
 number,line=matches[0];caret=' '*len(str(number+1))+' | '+' '*column+'^'*length
 assert str(number)+'>| '+line in text and caret in text,(name,caret,text);return True
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');args=ap.parse_args();out=RUNNER.parent/'evidence'/('lifetime-'+str(time.time_ns()));out.mkdir(parents=True)
 subjects=['normal',*MUTANTS,'eager-queue-application'];labels=['version','guide',*[f'reference-{name}' for name in ['bevy-ts','bevy','bend2']],'ts',*[f'negative-{name}' for name in NEGATIVES],*[f'{name}-{phase}' for name in subjects for phase in ['check','emit-js','run-js','emit-c','clang','run-native']]]
 logs=logs_module.CommandLogs(out,labels);tools=tools_module.snapshot();files={RUNNER, RUNNER.parent/'tool-pins.py',RUNNER.parent/'raw_supervisor.py',ROOT/'scripts/receipt-logs.py'}|set(HERE.glob('*.bend'))|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|{HERE/'fixture-inputs.json',ROOT/'scripts/receipt-logs.py',pathlib.Path(supervisor.__file__),ROOT/'docs/parity/source-review.json'}
 files|=set((PARENT/'modules').glob('*.bend'))|set((ROOT/'src/ecs').glob('*'));files={p for p in files if p.is_file()}
 files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))|set((ROOT/'.references/bend2/bend2').rglob('*.ts'))|{pathlib.Path('/home/node/.bend/check.json')}
 files|={pathlib.Path(p) for p in tools['pins']};pins={str(p.resolve()):sha(p) for p in sorted(files)};stages={};generated={}
 receipt={'status':'INCOMPLETE','scope':'fresh registered relation Query lifetime/pre-barrier/affine owners; finite only','pins':pins,'tools':tools,'plannedLabels':labels,'commands':[],'stages':stages,'generatedPins':generated,'limits':{'checker':5,'emission':30,'clang':120,'runtime':5},'capture':'raw merged stdout/stderr stored as stdout; stderr explicitly empty','CPU':8}
 def save():(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(stage.rglob('*')) if p.is_file()}
 configPaths=set()
 for folder in [ROOT,pathlib.Path.cwd(),out,*[out/n for n in subjects]]:
  for ancestor in [folder,*folder.parents]:
   for cfg in ['check.json','bend.json','bender.json']:configPaths.add(ancestor/cfg)
 configs={str(p):sha(p) if p.is_file() else None for p in sorted(configPaths)};receipt['configurationStates']=configs
 def stage_guard():
  assert {str(p):sha(p) if p.is_file() else None for p in sorted(configPaths)}==configs,'configuration state changed'
  for d in stages.values():
   stage=pathlib.Path(d['path']);expected=dict(d['derivedInventory'])
   expected.update({str(pathlib.Path(p).relative_to(stage)):h for p,h in generated.items() if pathlib.Path(p).is_relative_to(stage)})
   assert inventory(stage)==expected,'exact stage membership/bytes changed'
 def guard():
  logs.guard();tools_module.verify(tools);assert all(sha(p)==h for p,h in pins.items()),'input drift';stage_guard();assert all(sha(p)==h for p,h in generated.items()),'generated drift'
 def run(label,argv,cap,expected=0):
  guard();argv=['taskset','-c','8',*map(str,argv)];r=raw.execute(argv,cap,env={**os.environ,'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root','BEND_NO_TELEMETRY':'1'})
  if '-o' in argv:
   product=pathlib.Path(argv[argv.index('-o')+1]);
   assert str(product) in receipt['plannedGeneratedOutputs'],'unplanned output'
   if product.exists():generated[str(product)]=sha(product)
  guard();logpins=logs.record(label,r['stdout'],r['stderr']);receipt['commandLogPins']=logpins;receipt['commands'].append({'label':label,'argv':argv,'capSeconds':cap,'exit':r['exit'],'failure':r['failure']});save();assert r['failure'] is None and r['exit']==expected,(label,r);return r['stdout'].decode('utf-8')
 try:
  sources={str(p.relative_to(ROOT)):p for p in list(HERE.glob('*.bend'))+[p for p in (ROOT/'src/ecs').glob('*') if p.is_file() and p.suffix in ['.bend','.c','.js']]}
  for p in (PARENT/'modules').glob('*.bend'):key='src/ecs/'+p.name;assert key not in sources;sources[key]=p
  normal={key:sha(p) for key,p in sources.items()}
  prospective={}
  for name in subjects:
   contents={key:p.read_bytes() for key,p in sources.items()}
   if name in MUTANTS:
    key,old,new=MUTANTS[name];text=contents[key].decode();assert text.count(old)==1;contents[key]=text.replace(old,new).encode()
   if name=='eager-queue-application':
    key='src/ecs/relation-commands.bend';text=contents[key].decode();anchor='def queue_checked(';assert text.count(anchor)==1;text=text.replace(anchor,EAGER+anchor)
    old='X.stage(~W.World<S,Store<S,C>,R,Notice<S,E>>,~Notice<S,E>,tx,world => apply_relate(~S,~C,~R,~E,world,descriptor,source,target))';new='eager_relate(~S,~C,~R,~E,tx,descriptor,source,target)';assert text.count(old)==1;contents[key]=text.replace(old,new).encode()
   planned={key:hashlib.sha256(value).hexdigest() for key,value in contents.items()};changes={k:{'original':normal[k],'intentional':h} for k,h in planned.items() if normal[k]!=h};assert len(changes)==(0 if name=='normal' else 1)
   prospective[name]={'contents':contents,'inventory':planned,'changes':changes}
  receipt['plannedGeneratedOutputs']=[str(out/n/product) for n in subjects for product in ['query.js', 'query.c', 'query-native']]
  receipt['prospectiveStagePlans']={n:{'inventory':d['inventory'],'intentionalChanges':d['changes']} for n,d in prospective.items()};save()
  for name,plan in prospective.items():
   stage=out/name;assert not stage.exists()
   for key,value in plan['contents'].items():
    dst=stage/key;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(value)
   assert inventory(stage)==plan['inventory']
   stages[name]={'path':str(stage),'normalInventory':normal,'derivedInventory':plan['inventory'],'intentionalChanges':plan['changes']}
  guard();save()
  if not args.execute:receipt['status']='GUARDED_QUERY_LIFETIME_PREFLIGHT_ONLY';save();print(out,receipt['status']);return 0
  run('version',['bend','version'],5);run('guide',['bend','guide'],5)
  for name,h in json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'].items():assert run('reference-'+name,['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).strip()==h
  ts=run('ts',['node',HERE/'query-reference.mjs'],5);actualTS=[json.loads(line) for line in ts.splitlines()];assert actualTS==literal(),(actualTS,literal());receipt['actualTS']=actualTS;receipt['actualTSSHA256']=hashlib.sha256(ts.encode()).hexdigest()
  receipt['negativeResults']=[]
  import re
  for name,(diagnostic,expected,expression) in NEGATIVES.items():
   entry=pathlib.Path(stages['normal']['path'])/str(HERE.relative_to(ROOT))/(name+'.bend');text=run('negative-'+name,['bend',entry,'--check-only'],5,1);line=next(i+1 for i,l in enumerate(entry.read_text().splitlines()) if expression in l);assert diagnostic in text and expected in text and 'Location: bad' in text and exact_caret(name,entry,text) and expression in text and re.search(r'(?m)^\s*'+str(line)+r'>\|',text);receipt['negativeResults'].append({'case':name,'expression':expression,'line':line,'expected':expected,'observed':diagnostic,'completeDiagnosticSHA256':hashlib.sha256(text.encode()).hexdigest()})
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
