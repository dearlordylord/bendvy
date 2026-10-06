#!/usr/bin/env python3
"""Fresh compiling corruption at reached Slot/cursor setters and unpacked rollback."""
import argparse, hashlib, importlib.util, json, os, re, shutil, signal, subprocess, sys, time
from pathlib import Path
H=Path(__file__).resolve().parent; ROOT=H.parents[2]
p=argparse.ArgumentParser();p.add_argument('--baseline',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{5})
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
b=json.loads((a.baseline/'evidence.json').read_text());assert b['status']=='FRESH_ACTUAL_TYPED_CURSOR_TX_AND_SUPPRESSED_576_PER_BACKEND_PASS' and b['sourceClosure']=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c'
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
sp=importlib.util.spec_from_file_location('protected_oracle',ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py');I=importlib.util.module_from_spec(sp);sp.loader.exec_module(I)
r={'status':'INCOMPLETE','scope':'Finite reached Slot/cursor cached/raw Tx corruption controls; unpacked rollback route, not universal refinement or full22','baselineReceiptSHA256':sha(a.baseline/'evidence.json'),'sourceClosure':b['sourceClosure'],'commands':[],'cases':[],'variants':[],'oracleSHA256':sha(ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py'),'defaultProofSeconds':5,'CPU':5}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,cap,label):
 env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';start=time.monotonic();q=subprocess.Popen(list(map(str,argv)),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=q.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(q.pid,signal.SIGKILL);out=q.communicate()[0]
 f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'limitSeconds':cap,'elapsedSeconds':time.monotonic()-start,'exit':q.returncode,'timeout':timed,'outputSHA256':sha(f)});save();assert q.returncode==0 and not timed,out[-2000:];return out

def mutate(core,variant,schema):
 file='transaction.bend' if variant=='inverse-order' else 'held-adapter.bend';f=core/file;s=f.read_text()
 if variant=='inverse-order':
  before='Reverted{unwind(W,H,restore_main,restore_ledger,undo,world)}';after='Reverted{unwind(W,H,restore_main,restore_ledger,List.reverse(&2,Inverse<H>,undo),world)}';assert s.count(before)==1;s=s.replace(before,after,1)
 else:
  name='prototype_packed_row_set_done' if schema=='motion' else 'prototype_packed_prototype_journalledger_health_set_fused_done';m=re.search(r'^def '+name+r'\(.*?(?=\ndef |\Z)',s,re.M|re.S);assert m;before=m[0];after=before
  if variant=='stale-head':
   old='rawframe,value,b,c,d,cachedframe' if schema=='motion' else 'rawreserve,rawclass,value,b,c,d,cachedreserve';new=old.replace(',value,',',old,');assert after.count(old)==1;after=after.replace(old,new).replace('Tuple{coordinates,old}','Tuple{coordinates,+old}').replace('Tuple{levels,old}','Tuple{levels,+old}')
  elif variant=='torn-tail':
   old='rawframe,value,b,c,d,cachedframe' if schema=='motion' else 'rawreserve,rawclass,value,b,c,d,cachedreserve';new=old.replace(',b,',',U32.add(b,1),');assert after.count(old)==1;after=after.replace(old,new)
  elif variant=='lost-mark':
   old='X.PrototypeFlatMark{space,id,marks}';assert after.count(old)==1;after=after.replace(old,'marks')
  else:raise AssertionError(variant)
  assert before!=after;s=s[:m.start()]+after+s[m.end():]
 f.write_text(s);return {'file':file,'beforeSHA256':hashlib.sha256(before.encode()).hexdigest(),'afterSHA256':hashlib.sha256(after.encode()).hexdigest(),'before':before,'after':after}
try:
 for variant in ['stale-head','torn-tail','lost-mark','inverse-order']:
  outputs={};originals={}
  for rec in b['programs']:
   if rec['suppressed']:continue
   name=variant+'-'+rec['label'];folder=a.output/name;folder.mkdir();core=folder/'core';oldcore=Path(rec['sourceRoot']);assert all(sha(oldcore/Path(n).name)==h for n,h in rec['source29Pins'].items());assert all(sha(oldcore/n)==h for n,h in rec['extraPins'].items());assert sha(rec['fixturePath'])==rec['fixtureSHA256'];shutil.copytree(oldcore,core);change=mutate(core,variant,rec['schema']);fixture=core/Path(rec['fixturePath']).name
   item={'variant':variant,'schema':rec['schema'],'getter':rec['getter'],'change':change,'fixtureSHA256':sha(fixture),'actualSourcePins':{str(n.relative_to(core)):sha(n) for n in core.glob('*.bend')},'originalProgramSHA256':rec['generatedPins']['subject.js'],'status':'INCOMPLETE'};r['cases'].append(item);save()
   run(['bend',fixture,'--check-only'],15,name+'-check');run(['bend',fixture,'-o',folder/'subject.js'],30,name+'-emit-js');run(['bend',fixture,'-o',folder/'subject.c'],30,name+'-emit-c');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',folder/'subject.c','-pthread','-lm','-o',folder/'subject.native'],120,name+'-clang')
   js=run(['node',folder/'subject.js'],5,name+'-js');native=run([folder/'subject.native','--threads','1','--gpu','off'],5,name+'-native');jr=[json.loads(x) for x in js.splitlines()];nr=[json.loads(x) for x in native.splitlines()];assert len(jr)==72 and jr==nr
   orig=[json.loads(x) for x in (a.baseline/(rec['label']+'-js-run.stdout')).read_text().splitlines()];assert len(orig)==72
   differences=[];I.walk(orig,jr,rec['schema'],differences) if hasattr(I,'walk') else None
   item.update(status='COMPILING_BOTH_BACKENDS_72_EQUAL_MUTANT_RECORDS',programPins={n:sha(folder/n) for n in ['subject.js','subject.c','subject.native']});outputs[rec['label']]=jr;originals[rec['label']]=orig;save()
  witnesses=[]
  for getter in ['cached','raw']:
   combined=[];baseline=[]
   for scene in range(9):
    for schema in ['motion','health']:
     key=getter+'-'+schema;combined.extend(outputs[key][scene*8:scene*8+8]);baseline.extend(originals[key][scene*8:scene*8+8])
   I.independent(baseline);assert not I.differences(baseline);diff=I.differences(combined);assert diff,variant+' was not detected in '+getter
   for schema in ['motion','health']:assert outputs[getter+'-'+schema]!=originals[getter+'-'+schema],variant+' not observed in '+schema
   witnesses.append({'getter':getter,'recordsPerBackend':144,'differenceCount':len(diff),'witness':diff[:8]})
  r['variants'].append({'variant':variant,'status':'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE','witnesses':witnesses});save()
 assert len(r['cases'])==16 and len(r['variants'])==4;r['status']='FOUR_REACHED_SLOT_TX_MUTANTS_BOTH_SCHEMAS_CACHED_RAW_BOTH_BACKENDS_DETECTED';save()
except BaseException as e:r.update(status='FAIL',error=repr(e));save();raise
