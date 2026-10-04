#!/usr/bin/env python3
"""Bounded child for existing full-field oracles; no checksum substitute."""
import sys,json,pathlib,hashlib
import importlib.util,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3];HERE=pathlib.Path(__file__).resolve().parent
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def run(cmd):
 p=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=5);return {"exitCode":p.returncode},p.stdout
R=load('method_readers_worker',ROOT/'experiments/s-integrate/measurement-samples-readers-run.py')
V=load('method_failure_worker',ROOT/'experiments/s-perf/failure-validate.py')
workload,backend=sys.argv[1:3];out=pathlib.Path(sys.argv[3]).read_text();ref=json.loads(pathlib.Path(sys.argv[5]).read_text());case={}
if workload=='readers':case['fullFieldOutcome']=R.checked(backend,out,'Motion',1024,ref)
else:
 raw=pathlib.Path(sys.argv[4])
 dm,decoded=run(['node',ROOT/'experiments/s-perf/failure-quiet-decode.mjs','Motion',raw]);case['decodePhase']=dm;assert dm['exitCode']==0
 d=json.loads(decoded);captures=d['captures'];counts=[{'system':x,'value':{'a':captures[x],'b':0,'c':0,'d':0}} for x in ['DisposeTransient','Observe','PublicationObserver','B','A','Seed']] if backend=='TS' else None
 countline=json.dumps(counts,separators=(',',':'))+':'+str(sum(e['kind']=='FailureResult' for e in d['events'])) if backend=='TS' else d['countLine']
 raw='FAILURE-TIMING:'+str(int(d['elapsed']))+'\n'+'\n'.join(d['effects'])+'\n'+'\n'.join('FAILURE-DEFERRED:'+json.dumps(e,separators=(',',':')) for e in d['events'])+'\nFAILURE-COUNTS:'+countline
 case['fullFieldOutcome']=V.validate(raw,ref)['validation'];case['innerMilliseconds']=d['elapsed'];case['completeTupleSHA256']=hashlib.sha256(json.dumps({'events':d['events'],'effects':d['effects']},sort_keys=True,separators=(',',':')).encode()).hexdigest()
print(json.dumps(case))
