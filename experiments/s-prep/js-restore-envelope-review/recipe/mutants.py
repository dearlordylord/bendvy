#!/usr/bin/env python3
"""Compiling omitted-field and premature-Ledger-publication counterexamples."""
from pathlib import Path
import argparse,json,sys,os,hashlib
R=Path('/workspace/formal-proofs/bendvy');H=Path(__file__).resolve().parent;sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','mutants':[],'commands':[],'scope':'Generated-JS counterexamples only, no source/core mutants'}
def run(argv,label,expected=0):
 code,out=execute(list(map(str,argv)),5);log=a.output/(label+'.txt');log.write_text(out);r['commands'].append({'argv':list(map(str,argv)),'cap':5,'exit':code,'outputSHA':sha(log)});assert code==expected,out[-1000:];return out
try:
 for schema in ['motion','health']:
  src=(Path('/tmp/bendvy-restore-envelope-frozen-v1')/(schema+'.js'));text=src.read_text();baseline=(Path('/tmp/bendvy-restore-envelope-witness')/(schema+'-candidate-run.txt')).read_text()
  mainIndex=2 if schema=='motion' else 3
  ledgerIndex=1 if schema=='motion' else 2
  cases=[('omit-main-a',f'__restore_envelope_main["value"]["a"] = __restore_envelope_main_rhs_{mainIndex};','',False),('omit-ledger-cached',f'__restore_envelope_ledger["value"]["cached"] = __restore_envelope_ledger_rhs_{ledgerIndex};','',False),('early-ledger','const __restore_envelope_fold_rhs_0 =','__restore_envelope_ledger["value"]["cached"] = _ledger_cached_0;\nconst __restore_envelope_fold_rhs_0 =',True)]
  for label,old,new,exception in cases:
   assert text.count(old)==1;mut=a.output/(schema+'-'+label+'.js');mut.write_text(text.replace(old,new,1));run(['node','--check',mut],schema+'-'+label+'-syntax');derived=a.output/(schema+'-'+label+'-observed.js');run(['node','--expose-internals',H/('exception-witness.cjs' if exception else 'fold-witness.cjs'),mut,derived,schema],schema+'-'+label+'-derive');code,out=execute(['node',str(derived)],5);log=a.output/(schema+'-'+label+'-result.txt');log.write_text(out)
   if exception:assert code==1 and 'AssertionError' in out
   else:assert code in [0,1] and out!=baseline
   r['mutants'].append({'schema':schema,'label':label,'programSHA':sha(mut),'observedExit':code,'outputSHA':sha(log),'detection':'early publication fails old-ledger boundary assertion' if exception else 'full witness observation differs or asserted cached/raw relation fails'})
 r['status']='SIX_COMPILING_OMISSION_AND_EARLY_LEDGER_COUNTEREXAMPLES_DETECTED'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'status':r['status'],'error':r.get('error'),'mutants':len(r['mutants'])}));sys.exit(0 if r['status'].endswith('_DETECTED') else 1)
