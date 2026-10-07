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

RUNNER=pathlib.Path(__file__).resolve();HERE=RUNNER.parent.parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'scripts'));import task_runner
import importlib.util
spec=importlib.util.spec_from_file_location("relation_tool_pins",HERE/"tool-pins.py");tool_pins=importlib.util.module_from_spec(spec);spec.loader.exec_module(tool_pins)
sys.path.insert(0,str(HERE))
from validate import validate as validate_reference
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
MUTANTS={
 'empty-inverse-present':('case []: Missing{}','case []: Sources{[]}'),
 'inverse-order-reversed':('case []: List.reverse(&2,W.Handle<S>,acc)','case []: acc'),
 'optional-cell-omitted':('case True{}: Cell{key,end,value} <> cells','case True{}: cells'),
 'conjunction-omitted':('selected && Q.selection_aux','selected || Q.selection_aux'),
}
NEGATIVES={
 'negative-query-affine':'consumed more than once',
 'negative-query-owner-inspect':'observed : H',
 'negative-query-undeclared':'observed : relation_read',
 'negative-query-write-through-read':'observed : Cap.ValueRead',
 'negative-query-cross-schema':'G.Descriptor<O.Other>',
}
def literal():
 components={1:[100,10],2:[200,20,21],3:[300,30,31,32,33],4:[400,40,41,42,43,44,45,46,47]}
 selections={'optional':[1,2,3,4],'outgoing':[2,3],'incoming':[1],'with-out':[2,3],'without-out':[1,4],'with-in':[1],'without-in':[2,3,4],'multi':[3],'cross-filters':[1,4],'empty':[1,2,3,4]}
 result={}
 for name,ids in selections.items():
  rows=[]
  for id in ids:
   cells=[]
   if name in ['optional','outgoing','multi']:cells.append({'key':'target','value':1 if id in [2,3] else None})
   if name in ['optional','incoming','cross-filters']:cells.append({'key':'sources','value':[3,2,5] if id==1 else None})
   if name=='multi':cells.extend([{'key':'otherTarget','value':None},{'key':'otherSources','value':None}])
   rows.append({'id':id,'component':components[id],'cells':cells})
  result[name]=rows
 return [{'root':root,'rows':result} for root in ['Workshop','Other']]
def portable(text):
 output=[];current=None
 for line in text.splitlines():
  if line in ['Workshop','Other']:
   current={'root':line,'rows':{}};output.append(current);continue
  if not line or line.startswith('owners='):continue
  name,encoded=line.split('=',1);rows=[]
  for row in encoded.split('|'):
   if not row:continue
   m=re.fullmatch(r'1:(\d+)\[([0-9,]*)\]\{(.*)\}',row);assert m,row
   cells=[]
   for field in m[3].split(';'):
    if not field:continue
    key,value=field.split('=',1)
    if value=='none':value=None
    elif value.startswith('['):
     handles=[x for x in value[1:-1].split(',') if x];assert all(x.startswith('1:') for x in handles),'foreign inverse namespace'
     value=[int(x.split(':')[1]) for x in handles]
    else:assert value.startswith('1:'),value;value=int(value.split(':')[1])
    cells.append({'key':key,'value':value})
   rows.append({'id':int(m[1]),'component':[int(x) for x in m[2].split(',') if x],'cells':cells})
  current['rows'][name]=rows
 return output
def validate(text,mutant):
 actual=portable(text);expected=literal();witnesses=[]
 assert [r['root'] for r in actual]==['Workshop','Other'],actual
 for got,want in zip(actual,expected):
  for key,rows in want['rows'].items():
   if got['rows'][key]!=rows:witnesses.append({'root':got['root'],'query':key,'expected':rows,'actual':got['rows'][key]})
 if mutant:assert witnesses,'undetected reached relation Query mutant'
 else:assert not witnesses,witnesses
 owners='owners=100,10,;200,20,21,;300,30,31,32,33,;400,40,41,42,43,44,45,46,47,;|3,2,5,:|events=|meta=1,6,5,8,3,77,2,0|pending=0'
 assert text.splitlines().count(owners)==2,'complete owner/meta/queue witness differs'
 return witnesses

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');args=ap.parse_args()
 out=RUNNER.parent/'evidence'/('query-'+str(time.time_ns()));out.mkdir(parents=True)
 files={RUNNER}|set((HERE/'modules').glob('*.bend'))|{HERE/'derivation.json',HERE/'additive-modules.patch',HERE/'promotion-source.json'}|set(HERE.glob('*.bend'))|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|{pathlib.Path(task_runner.__file__).resolve(),ROOT/'docs/parity/source-review.json'}
 files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))
 files|=set((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 files|={pathlib.Path('/home/node/.bend/check.json')}
 tools=tool_pins.snapshot();files|={pathlib.Path(p) for p in tools['pins']}
 for p in ROOT.joinpath('src/ecs').glob('*'):
  if p.is_file():files.add(p)
 pins={str(p):sha(p) for p in sorted(files)};stages={};generated={}
 receipt={'status':'INCOMPLETE','scope':'finite actual registered relation Query: arbitrary-Type component views plus ten conjunction/outgoing/incoming specs/two nominal schemas; retention/phase coverage separate OPEN','pins':pins,'tools':tools,'stages':stages,'commands':[],'limits':{'checker':5,'emission':30,'clang':120,'runtime':5}}
 def save():(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(p for p in stage.rglob('*') if p.is_file() and (p.suffix=='.bend' or (str(p.relative_to(stage)).startswith('src/ecs/') and p.suffix in ['.c','.js'])))}
 def guard():
  tool_pins.verify(tools)
  assert all(sha(p)==h for p,h in pins.items()),'input source drift'
  assert all(inventory(pathlib.Path(d['path']))==d['derivedInventory'] for d in stages.values()),'stage drift'
  assert all(sha(p)==h for p,h in generated.items()),'generated drift'
  logs={c['log']:c['sha256'] for c in receipt['commands'] if 'log' in c}
  assert {str(p) for p in out.glob('command-*.txt')}==set(logs),'command log membership drift'
  assert all(sha(p)==h for p,h in logs.items()),'recorded command log drift'
 def run(argv,cap,expected=0):
  guard();argv=['taskset','-c','8',*map(str,argv)]
  try:code,text=task_runner.execute(argv,cap,env={**os.environ,'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root','BEND_NO_TELEMETRY':'1'})
  except Exception as e:receipt['commands'].append({'argv':argv,'capSeconds':cap,'error':repr(e)});save();raise
  guard();log=out/('command-'+str(len(receipt['commands']))+'.txt');log.write_text(text)
  receipt['commands'].append({'argv':argv,'capSeconds':cap,'exit':code,'log':str(log),'sha256':sha(log)});save();assert code==expected,(code,text);return text
 try:
  sources={str(p.relative_to(ROOT)):p for p in list(HERE.glob('*.bend'))+[p for p in (ROOT/'src/ecs').glob('*') if p.is_file() and p.suffix in ['.bend','.c','.js']]}
  for p in (HERE/'modules').glob('*.bend'):
   key='src/ecs/'+p.name;assert key not in sources,'already present live module';sources[key]=p
  normal={key:sha(p) for key,p in sources.items()}
  for name in ['normal',*MUTANTS]:
   stage=out/name
   for path,h in normal.items():dst=stage/path;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(sources[path],dst);assert sha(dst)==h
   assert inventory(stage)==normal
   if name in MUTANTS:
    file=stage/'src/ecs/relation-query.bend';text=file.read_text();old,new=MUTANTS[name];assert text.count(old)==1,(name,text.count(old));file.write_text(text.replace(old,new))
   derived=inventory(stage);changes={k:{'original':normal[k],'intentional':v} for k,v in derived.items() if normal[k]!=v};assert len(changes)==(0 if name=='normal' else 1)
   stages[name]={'path':str(stage),'normalInventory':normal,'derivedInventory':derived,'intentionalChanges':changes}
  guard();save()
  # Preflight records deliberate mutant bytes, source closure, imported supervisor;
  # all operations below recheck both normal and every mutant stage.
  if not args.execute:receipt['status']='GUARDED_RELATION_QUERY_PREFLIGHT_ONLY';save();print(out,receipt['status']);return 0
  run(['bend','version'],5);run(['bend','guide'],5)
  for name,h in json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'].items():assert run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).strip()==h
  reference=run(['node',HERE/'query-reference.mjs'],5);tsExpected=[json.loads(line) for line in reference.splitlines()];assert tsExpected==literal(),(tsExpected,literal());receipt['actualQueryTS']=tsExpected;receipt['actualQueryTSSHA256']=hashlib.sha256(reference.encode()).hexdigest()
  receipt['negativeResults']=[]
  for name,diagnostic in NEGATIVES.items():
   entry=pathlib.Path(stages['normal']['path'])/'experiments/public-relations/promotion-stage'/(name+'.bend');text=run(['bend',entry,'--check-only'],5,1);assert diagnostic in text
   expressions={'negative-query-affine':'def bad(-H:Type,owner:H)', 'negative-query-cross-schema':'RQ.read_relation(~O.Workshop,"foreign",descriptor)', 'negative-query-owner-inspect':'case W.World{ns,_,_,_,_,_,_,_,_,_,_,_,_}: ns', 'negative-query-undeclared':'Cap.value_read(~H,~RQ.Row<S,List<&2,U32>>,~relation_read,owner)', 'negative-query-write-through-read':'Cap.value_set(~H,~RQ.Row<S,List<&2,U32>>,~RQ.Row<S,List<&2,U32>>,~caps,owner,row)'}
   expected={'negative-query-affine':'- expected : owner','negative-query-cross-schema':'- expected : G.Descriptor<O.Workshop>','negative-query-owner-inspect':'- expected : a datatype','negative-query-undeclared':'- expected : a defined name','negative-query-write-through-read':'- expected : Cap.ValueWrite'}
   expression=expressions[name];assert expected[name] in text and 'Location: bad' in text and '^' in text
   lines=entry.read_text().splitlines();line=next(i+1 for i,l in enumerate(lines) if expression in l);assert re.search(r'(?m)^\s*'+str(line)+r'>\|',text),text
   assert expression in text,text
   receipt['negativeResults'].append({'case':name,'intendedDiagnostic':diagnostic,'expectedType':expected[name],'expression':expression,'line':line,'completeDiagnosticSHA256':hashlib.sha256(text.encode()).hexdigest()})
  receipt['results']=[]
  for name,d in stages.items():
   stage=pathlib.Path(d['path']);entry=stage/'experiments/public-relations/promotion-stage/query-owned.bend';run(['bend',entry,'--check-only'],5)
   for backend in ['js','native']:
    code=stage/('world.js' if backend=='js' else 'world.c');assert not code.exists();run(['bend',entry,'-o',code],30);generated[str(code)]=sha(code)
    if backend=='native':
     binary=stage/'world-native';assert not binary.exists();run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',code,'-pthread','-lm','-o',binary],120);generated[str(binary)]=sha(binary);argv=[binary,'--threads','1','--gpu','off']
    else:argv=['node',code]
    text=run(argv,5);witnesses=validate(text,name!='normal');
    if name=='normal':assert portable(text)==tsExpected
    receipt['results'].append({'case':name,'backend':backend,'witnesses':witnesses,'queryCount':20})
  guard();receipt['generatedPins']=generated;receipt['status']='FINITE_REGISTERED_RELATION_QUERY_PASS'
 except Exception as e:receipt['status']='FAIL';receipt['error']=repr(e)
 finally:save()
 print(out,receipt['status']);return 0 if receipt['status']=='FINITE_REGISTERED_RELATION_QUERY_PASS' else 1
if __name__=='__main__':sys.exit(main())
