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
 'registered-relate-omission':('case Writable{_,Cap.Request{relate},_}: relate(owner,args)','case Writable{_,Cap.Request{relate},_}: (owner,A.Queued{})'),
 'inverse-snapshot-omission':('case Some{ids}: Some{handle_ids(~S,ids,namespace)}','case Some{ids}: Some{[]}'),
 'inverse-foreign-namespace':('W.Handle{namespace,id} <> handle_ids(~S,rest,namespace)','W.Handle{42,id} <> handle_ids(~S,rest,namespace)'),
}
NEGATIVES={
 'negative-affine':'consumed more than once',
 'negative-cross-schema':'W.Handle<O.Other>',
 'negative-owner-inspect':'observed : H',
 'negative-undeclared':'observed : relation_write',
 'negative-write-through-read':'observed : P.ReadOnly',
 'negative-inverse-write':'observed : Cap.Request',
}
def expected():
 owners='100,10,;200,20,21,;300,30,31,32,33,;400,40,41,42,43,44,45,46,47,;'
 m2='|meta=1,5,4,8,3,77,2,0|pending=0';m3='|meta=1,5,4,8,3,77,3,0|pending=0'
 return [owners+'|:|events='+m2,owners+'|3,:|events='+m2,owners+'|3,:|events='+m3,owners+'|3,:|events='+m3+'|snapshot=1:3,',owners+'|:3,|events='+m3+'|retained=1:3,']*2

def validate(out,mutant):
 rows=out.splitlines();literals=expected();assert len(rows)==len(literals),(len(rows),rows)
 witnesses=[{'checkpoint':i,'expected':a,'actual':b} for i,(a,b) in enumerate(zip(literals,rows)) if a!=b]
 owner=expected()[0].split('|')[0];assert all(row.startswith(owner) for row in rows),rows
 if mutant:assert witnesses,'undetected actual provider mutant'
 else:assert not witnesses,witnesses
 return witnesses

def portable(out):
 result=[]
 for i,row in enumerate(out.splitlines()):
  fields=row.split('|');owners=[[int(x) for x in owner.split(',') if x] for owner in fields[0].split(';') if owner]
  left,right=fields[1].split(':');inverse1=[int(x) for x in left.split(',') if x];inverse2=[int(x) for x in right.split(',') if x]
  retained=[]
  for field in fields[2:]:
   if field.startswith(('snapshot=','retained=')):
    retained=[int(x.split(':')[1]) for x in field.split('=',1)[1].split(',') if x]
  result.append({'root':['Workshop','Other'][i//5],'phase':['registered-writer','written','registered-reader','read','replaced'][i%5],'owners':owners,'inverse1':inverse1,'inverse2':inverse2,'retained':retained})
 return result

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');args=ap.parse_args()
 out=HERE/'evidence'/('provider-'+str(time.time_ns()));out.mkdir(parents=True)
 files=set(HERE.glob('*.bend'))|set(HERE.glob('*.py'))|set(HERE.glob('*.mjs'))|{pathlib.Path(supervisor.__file__).resolve(),ROOT/'docs/parity/source-review.json'}
 files|=set((ROOT/'.references/bevy-ts/packages/core/src').rglob('*.ts'))
 files|=set((ROOT/'.references/bend2/bend2').rglob('*.ts'))
 files|={pathlib.Path('/home/node/.bend/check.json')}
 tools=tool_pins.snapshot();files|={pathlib.Path(p) for p in tools['pins']}
 for p in ROOT.joinpath('src/ecs').glob('*.bend'):files.add(p)
 pins={str(p):sha(p) for p in sorted(files)};stages={};generated={}
 receipt={'status':'INCOMPLETE','scope':'finite actual registered relation providers/retained inverse/Type owners; cleanup/reorder/retention OPEN','pins':pins,'tools':tools,'stages':stages,'commands':[],'limits':{'checker':5,'emission':30,'clang':120,'runtime':5}}
 def save():(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def inventory(stage):return {str(p.relative_to(stage)):sha(p) for p in sorted(stage.rglob('*.bend'))}
 def guard():
  tool_pins.verify(tools)
  assert all(sha(p)==h for p,h in pins.items()),'input source drift'
  assert all(inventory(pathlib.Path(d['path']))==d['derivedInventory'] for d in stages.values()),'stage drift'
  assert all(sha(p)==h for p,h in generated.items()),'generated drift'
 def run(argv,cap,expected=0):
  guard();argv=['taskset','-c','10',*map(str,argv)]
  try:code,text=supervisor.execute(argv,cap,env={**os.environ,'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root'})
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
    file=stage/'experiments/public-relations/providers.bend';text=file.read_text();old,new=MUTANTS[name];assert text.count(old)==1,(name,text.count(old));file.write_text(text.replace(old,new))
   derived=inventory(stage);changes={k:{'original':normal[k],'intentional':v} for k,v in derived.items() if normal[k]!=v};assert len(changes)==(0 if name=='normal' else 1)
   stages[name]={'path':str(stage),'normalInventory':normal,'derivedInventory':derived,'intentionalChanges':changes}
  guard();save()
  # Preflight records deliberate mutant bytes, source closure, imported supervisor;
  # all operations below recheck both normal and every mutant stage.
  if not args.execute:receipt['status']='GUARDED_PROVIDER_PREFLIGHT_ONLY';save();print(out,receipt['status']);return 0
  run(['bend','version'],5);run(['bend','guide'],5)
  for name,h in json.loads((ROOT/'docs/parity/source-review.json').read_text())['references'].items():assert run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).strip()==h
  reference=run(['node',HERE/'reference.mjs'],5);validate_reference([json.loads(line) for line in reference.splitlines()]);receipt['freshTSReferenceSHA256']=hashlib.sha256(reference.encode()).hexdigest()
  foreign=run(['node',HERE/'foreign-reference.mjs'],5);receipt['freshTSForeignSHA256']=hashlib.sha256(foreign.encode()).hexdigest()
  providerTS=run(['node',HERE/'provider-reference.mjs'],5);providerRecords=[json.loads(line) for line in providerTS.splitlines()];assert [r['root'] for r in providerRecords]==['Workshop','Other'];tsExpected=[o for r in providerRecords for o in r['observations']];assert portable('\n'.join(expected()))==tsExpected;receipt['actualProviderTS']=providerRecords
  receipt['negativeResults']=[]
  for name,diagnostic in NEGATIVES.items():
   entry=pathlib.Path(stages['normal']['path'])/'experiments/public-relations'/(name+'.bend');text=run(['bend',entry,'--check-only'],5,1);assert diagnostic in text;receipt['negativeResults'].append({'case':name,'intendedDiagnostic':diagnostic})
  receipt['results']=[]
  for name,d in stages.items():
   stage=pathlib.Path(d['path']);entry=stage/'experiments/public-relations/registered-world.bend';run(['bend',entry,'--check-only'],5)
   for backend in ['js','native']:
    code=stage/('world.js' if backend=='js' else 'world.c');assert not code.exists();run(['bend',entry,'-o',code],30);generated[str(code)]=sha(code)
    if backend=='native':
     binary=stage/'world-native';assert not binary.exists();run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',code,'-pthread','-lm','-o',binary],120);generated[str(binary)]=sha(binary);argv=[binary,'--threads','1','--gpu','off']
    else:argv=['node',code]
    text=run(argv,5);witnesses=validate(text,name!='normal');
    if name=='normal':assert portable(text)==tsExpected
    receipt['results'].append({'case':name,'backend':backend,'witnesses':witnesses,'checkpointCount':10})
  guard();receipt['generatedPins']=generated;receipt['status']='FINITE_REGISTERED_RELATION_PROVIDER_PASS'
 except Exception as e:receipt['status']='FAIL';receipt['error']=repr(e)
 finally:save()
 print(out,receipt['status']);return 0 if receipt['status']=='FINITE_REGISTERED_RELATION_PROVIDER_PASS' else 1
if __name__=='__main__':sys.exit(main())
