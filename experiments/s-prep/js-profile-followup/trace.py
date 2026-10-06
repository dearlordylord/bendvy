#!/usr/bin/env python3
"""Read-only full65 V8 inlining/deopt diagnosis; no comparative clocks."""
from pathlib import Path
import sys,os,json,argparse,hashlib,importlib.util,re
R=Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--parent',type=Path,required=True);p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Actual full65 inlining/deoptimization diagnosis; no elapsed comparison','cpu':7,'commands':[],'roles':[]}
def run(args,label):
 code,out=execute(list(map(str,args)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,args)),'cap':5,'exit':code,'outputSHA':sha(f)});assert code==0,out[-1000:];return out
try:
 ref=a.output/'reference.mjs';run([sys.executable,R/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',R/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema',a.schema,'--batch','64'],'prepare');ts=json.loads(run(['node',ref],'ts'))
 spec=importlib.util.spec_from_file_location('V',R/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
 for role,program in [('parent',a.parent),('candidate',a.candidate)]:
  derived=a.output/(role+'.js');derived.write_text('if(!process.stdout._handle||typeof process.stdout._handle.setBlocking!=="function")throw Error("stdout transport");process.stdout._handle.setBlocking(true);\n'+program.read_text());raw=run(['node','--trace-turbo-inlining','--trace-deopt',derived],role);records=[x for x in raw.splitlines() if x.startswith('{')];assert len(records)==65
  for line,w in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,a.schema,False,256,w);assert V.normalized(json.loads(line),a.schema)==w['final']
  traces=[x for x in raw.splitlines() if not x.startswith('{') and not x.startswith('BATCH-MILLISECONDS:')];(a.output/(role+'-trace.txt')).write_text('\n'.join(traces)+'\n');selected=[x for x in traces if '__fold_state_reuse_' in x or 'flatfold_'+a.schema.lower() in x or 'journalledger_health' in x or 'deoptimizing' in x]
  (a.output/(role+'-selected-trace.txt')).write_text('\n'.join(selected)+'\n');r['roles'].append({'role':role,'inputSHA':sha(program),'derivedSHA':sha(derived),'worlds':65,'traceLines':len(traces),'deoptLines':sum('deoptimizing' in x for x in traces),'selectedLines':len(selected)})
 r['status']='BOTH_FULL65_INLINING_DEOPT_DIAGNOSIS_PASS'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error'),'roles':r['roles']}));sys.exit(0 if r['status'].endswith('_PASS') else 1)
