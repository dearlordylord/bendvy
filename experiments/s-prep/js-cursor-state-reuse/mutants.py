#!/usr/bin/env python3
import pathlib,json,hashlib,sys,os,argparse
H=pathlib.Path(__file__).resolve().parent;ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{7});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','cpu':7,'cases':[]}
try:
 for schema in ['motion','health']:
  source=pathlib.Path('/tmp/bendvy-cursor-state-'+schema+'.js');s=source.read_text();start=s.index('function __cursor_state_reuse_5(');body=s[start:]
  mutations=[('lost-ids','__cursor_state_reuse_owner["values"] = __cursor_state_reuse_rhs_6;','void __cursor_state_reuse_rhs_6;'),('lost-restore','(_main_0[_x_0 % _main_0.length] = _x_1, _main_0)','(_main_0)')]
  for label,old,new in mutations:
   assert old in body;changed=s[:start]+body.replace(old,new);subject=a.output/(schema+'-'+label+'.js');subject.write_text(changed);witness=a.output/(schema+'-'+label+'-witness.js');code,log=execute(['node','--expose-internals',str(H/'query-witness.cjs'),str(subject),str(witness)],5);assert code==0,log;code,log=execute(['node',str(witness)],5);(a.output/(schema+'-'+label+'.txt')).write_text(log);assert code!=0 and 'AssertionError' in log;assert subject.read_text()==changed;r['cases'].append({'schema':schema,'mutation':label,'sourceSHA256':sha(source),'subjectSHA256':sha(subject),'derivedSHA256':sha(witness),'parserAndDerivationPass':True,'runtimeRejected':True,'capSeconds':5})
 r['status']='FOUR_COMPILING_ACTUAL_RESTORE_AND_IDS_OMISSION_COUNTEREXAMPLES_DETECTED'
except Exception as e:r.update(status='FAILED',error=repr(e))
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r));sys.exit(0 if r['status'].endswith('DETECTED') else 1)
