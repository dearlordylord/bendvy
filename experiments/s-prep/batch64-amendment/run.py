#!/usr/bin/env python3
"""One timer-free full-field feasibility construction; no comparison/metric."""
import argparse,hashlib,json,os,pathlib,subprocess,sys
H=pathlib.Path(__file__).resolve().parents[1]/'fivehour-measurement';sys.path.insert(0,str(H));import guard
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--js-core',type=pathlib.Path,required=True);p.add_argument('--native-core',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--batch',type=int,default=64);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
tools={'python':str(pathlib.Path(sys.executable).resolve()),'node':'/home/node/.local/share/mise/installs/node/24.20.0/bin/node','bend':'/home/node/.bend/bin/bend','clang':'/home/node/.local/bin/clang'};env=guard.tool_environment(tools)
r={'status':'INCOMPLETE','batch':a.batch,'clockFree':True,'measurementOrRatioSelected':False,'commands':[],'cases':[],'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpu':11,'tools':{k:{'path':v,'sha256':sha(pathlib.Path(v))} for k,v in tools.items()},'sources':{str(q):sha(q) for q in [pathlib.Path(__file__),H/'prepare-bend.py',H/'prepare-ts.py',H/'semantic-check.py']}}
def cmd(xs,limit=5):
 guard.deadline(limit+5)
 import importlib.util
 # Reuse reviewed bounded subreaper supervisor rather than an unbounded wait.
 s=importlib.util.spec_from_file_location('packet',H/'packet.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);m.ENV=env
 logs=[]
 try:out=m.child(xs,limit,logs)
 finally:r['commands']+=logs;(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
 return out
try:
 for schema in ('Health','Motion'):
  ts=a.output/(schema+'-reference.mjs');cmd([tools['python'],H/'prepare-ts.py','--source',guard.PROJECT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ts,'--schema',schema,'--batch',str(a.batch)])
  text=ts.read_text();assert 'performance.now()' in text;ts.write_text(text.replace('performance.now()','0'));assert 'performance.now()' not in ts.read_text();r['sources'][str(ts)]=sha(ts)
  tsraw=a.output/(schema+'-reference.json');tsraw.write_text(cmd([tools['node'],ts]))
  for backend,core in [('JS',a.js_core),('Native',a.native_core)]:
   folder=a.output/(schema+'-'+backend);cmd([tools['python'],H/'prepare-bend.py','--core',core,'--output',folder,'--schema',schema,'--batch',str(a.batch)])
   for q in [folder/'measurement-bend.bend',folder/'batch.bend']:
    text=q.read_text();text=text.replace('IO.now()','IO.pure(Nat,0n)');q.write_text(text);assert 'IO.now()' not in text;r['sources'][str(q)]=sha(q)
   entry=folder/'batch.bend';r['sources'].update(guard.bend_closure(entry,[folder,core]));checked=cmd([tools['bend'],entry,'--check-only']);assert 'ALL PROOFS CHECK' in checked
   artifact=folder/('batch.js' if backend=='JS' else 'batch.c');cmd([tools['bend'],entry,'-o',artifact],30)
   if backend=='JS':run=[tools['node'],artifact]
   else:
    native=folder/'batch-native';cmd([tools['clang'],'-O3',artifact,'-pthread','-lm','-o',native],120);run=[native,'--threads','1','--gpu','off']
   raw=folder/'raw.txt';raw.write_text(cmd(run));receipt=folder/'full-records.json';cmd([tools['python'],H/'semantic-check.py','--bend-output',raw,'--ts-output',tsraw,'--schema',schema,'--batch',str(a.batch),'--evidence',receipt]);r['cases'].append({'schema':schema,'backend':backend,'receipt':str(receipt),'receiptSHA256':sha(receipt),'artifactSHA256':sha(artifact),'records':a.batch+1,'status':'EVERY_FULL_RECORD_PASS'})
 r['status']='TIMER_FREE_BOTH_SCHEMA_BOTH_BACKEND_FULL_RECORDS_PASS'
except Exception as error:r['status']='FAIL';r['error']=repr(error)
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status']);raise SystemExit(r['status']=='FAIL')
