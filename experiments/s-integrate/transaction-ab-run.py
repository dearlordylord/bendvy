#!/usr/bin/env python3
"""Actual A/B transaction trace; nested schedule/reader/capture gates separate."""
import pathlib,tempfile,sys,json,hashlib,shutil,importlib.util
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,paired
spec=importlib.util.spec_from_file_location('oracle',HERE/'transaction-ab-oracle.py');oracle=importlib.util.module_from_spec(spec);spec.loader.exec_module(oracle)
names=['transaction-ab-controls.bend','transaction-dispatch-adapters.bend','observation-render.bend','observations.bend','transaction.bend','types.bend','storage.bend','identity.bend','commands.bend','payload.bend','storage-stage-fixture.bend','query.bend','systems.bend','schedule.bend','capture.bend']
expected=oracle.expected()
def difference(actual):
 for i,(a,b) in enumerate(zip(actual.splitlines(),expected.splitlines())):
  if a!=b:return {'line':i+1,'expected':b,'actual':a}
 if actual!=expected:return {'expected_lines':len(expected.splitlines()),'actual_lines':len(actual.splitlines())}
 return None
def mutate(folder,label):
 p=folder/'transaction-dispatch-adapters.bend';s=p.read_text()
 if label=='earlier_A_ledger_reverted':
  for n in ['motion','health']:
   start=s.index('def '+n+'_world_ledger_restore');end=s.index('\ndef ',start+1)
   b=s[start:end];assert ',world,old)' in b;s=s[:start]+b.replace(',world,old)',',world,(old - 1 : U32))')+s[end:]
 elif label=='failure_publications_leak':
  for n,sc,m,a,f,l,mode in [('motion','MotionSchema','Position','Velocity','Selected','MotionLedger','MotionMode'),('health','HealthSchema','Vitals','Armor','Tracked','HealthLedger','HealthMode')]:
   args=','.join('T.'+x for x in [sc,m,a,f,l,mode]);w=f'S.World<{args}>';h=f'S.Handle<T.{sc}>';c=f'S.Command<T.{m},T.{a},T.{f}>'
   assert n+'_finish_failure(owner)' in s;s=s.replace(n+'_finish_failure(owner)',f'X.tx_finish_success({w},{h},{c},owner)')
 elif label=='failed_counter_rewound':
  for n,sc,m,a,f,l,mode in [('motion','MotionSchema','Position','Velocity','Selected','MotionLedger','MotionMode'),('health','HealthSchema','Vitals','Armor','Tracked','HealthLedger','HealthMode')]:
   args=','.join('T.'+x for x in [sc,m,a,f,l,mode]);w=f'S.World<{args}>';h=f'S.Handle<T.{sc}>';c=f'S.Command<T.{m},T.{a},T.{f}>';fin=f'X.Finished<{w},{c},{h}>'
   pos=s.index('def '+n+'_finished')
   helper=f'''def {n}_rewind_failed(result:{fin}) -> {fin}:
  match result:
    case X.Reverted{{S.World{{ns,next,rows,pending,ledger,mode}}}}: X.Reverted{{S.World{{ns,(next - 1 : U32),rows,pending,ledger,mode}}}}
    case X.Committed{{world,commands,pings,marks}}: X.Committed{{world,commands,pings,marks}}
'''
   s=s[:pos]+helper+s[pos:];s=s.replace(n+'_finish_failure(owner)',n+'_rewind_failed('+n+'_finish_failure(owner))')
 p.write_text(s)
r={'scope':'actual A commit, closed opaque B failure/retry and explicit barrier; no nested/capture/reader acceptance','hashes':{n:hashlib.sha256((HERE/n).read_bytes()).hexdigest() for n in names},'oracle_sha256':hashlib.sha256((HERE/'transaction-ab-oracle.py').read_bytes()).hexdigest(),'expected_sha256':hashlib.sha256(expected.encode()).hexdigest(),'original':None,'mutants':{}}
with tempfile.TemporaryDirectory(prefix='transaction-ab-') as d:
 for label in ['original','earlier_A_ledger_reverted','failure_publications_leak','failed_counter_rewound']:
  folder=pathlib.Path(d)/label;folder.mkdir()
  for n in names:shutil.copyfile(HERE/n,folder/n)
  if label!='original':mutate(folder,label)
  out=paired(build(folder/'transaction-ab-controls.bend',folder))
  diff=difference(out)
  if label=='original':
   assert diff is None,diff;r['original']={'complete_equal':True,'lines':len(out.splitlines()),'sha256':hashlib.sha256(out.encode()).hexdigest()};(HERE/'transaction-ab-observed.txt').write_text(out+'\n')
  else:
   assert diff is not None,label;r['mutants'][label]={'compiling_native_js':True,'first_difference':diff,'observed':out}
(HERE/'transaction-ab-evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print('ACTUAL A/B TRANSACTION TRACE PASS')
