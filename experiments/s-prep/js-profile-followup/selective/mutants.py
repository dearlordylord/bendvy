#!/usr/bin/env python3
"""Compiling generated-JS omission/ordering counterexamples, not Bend/core mutants."""
from pathlib import Path
import argparse,json,sys,os,hashlib
R=Path('/workspace/formal-proofs/bendvy');H=Path(__file__).resolve().parent;sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Fresh compiling emitted-JS causal counterexamples on actual Fold helper; no source compiler/core mutation or universal refinement','mutants':[],'commands':[]}
def run(args,label,expect=0):
 code,out=execute(list(map(str,args)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,args)),'cap':5,'exit':code,'outputSHA':sha(f)});assert code==expect,out[-500:];return out
try:
 for schema in ['motion','health']:
  source=Path('/tmp/bendvy-followup-'+schema+'-selective.js');text=source.read_text();parent=Path('/tmp/bendvy-followup-selective-witness')/(schema+'-candidate-run.txt');baseline=parent.read_text()
  cases=[('total','__fold_state_reuse_owner["total"] = __fold_state_reuse_rhs_16;',''),('ledger','__fold_state_reuse_owner["ledger"] = __fold_state_reuse_rhs_9;',''),('undo','__fold_state_reuse_owner["undo"] = __fold_state_reuse_rhs_12;',''),('exception-order','const __fold_state_reuse_rhs_0 =','__fold_state_reuse_owner["total"] = ((_total_0 + _value_0) >>> 0);\nconst __fold_state_reuse_rhs_0 =')]
  for label,old,new in cases:
   assert text.count(old)==1;mutant=a.output/(schema+'-'+label+'.js');mutant.write_text(text.replace(old,new,1));run(['node','--check',mutant],schema+'-'+label+'-syntax');derived=a.output/(schema+'-'+label+'-witness.js');run(['node','--expose-internals',H/'fold-witness.cjs',mutant,derived,schema],schema+'-'+label+'-derive');code,out=execute(['node',str(derived)],5);log=a.output/(schema+'-'+label+'-observed.txt');log.write_text(out);assert code in [0,1] and out!=baseline
   if label=='exception-order':assert 'AssertionError' in out and 'pending-flush-canary' not in out.split('AssertionError')[0]
   r['mutants'].append({'schema':schema,'label':label,'programSHA':sha(mutant),'witnessSHA':sha(derived),'exit':code,'detection':'complete observation differs or intended assertion fails','outputSHA':sha(log)})
 r['status']='EIGHT_COMPILING_FOLD_OMISSION_AND_EXCEPTION_ORDER_COUNTEREXAMPLES_DETECTED'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error'),'mutants':len(r['mutants'])}));sys.exit(0 if r['status'].endswith('_DETECTED') else 1)
