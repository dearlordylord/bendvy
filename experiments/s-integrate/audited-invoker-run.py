#!/usr/bin/env python3
"""Actual retained Audit join; complete values, both schemas/backends."""
import pathlib,sys,tempfile,shutil,json,hashlib,importlib.util
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,paired,command,CHECK
spec=importlib.util.spec_from_file_location('oracle',HERE/'transaction-ab-oracle.py');o=importlib.util.module_from_spec(spec);spec.loader.exec_module(o)
worlds={line.split('=',1)[0]:line for line in o.expected().splitlines() if any(':'+v+'=' in line for v in ['A','FAIL','RETRY'])}
expected=[]
for schema in ['motion','health']:
 expected += ['A:attempt:1',schema+':A-result:success:escaped=1:4:pings=[1]',worlds[schema+':A'],'after-A','B:attempt:2',schema+':failed:failure7:escaped=1:5:pings=[]',worlds[schema+':FAIL'],'after-failed-B','B:attempt:3',schema+':retry:success:escaped=1:6:pings=[2]',worlds[schema+':RETRY'],'after-retry-B']
expected='\n'.join(expected)
# Actual dependency closure, rather than an unrelated source directory snapshot.
names=['audited-invoker-controls.bend','audited-invoker.bend','transaction-dispatch-adapters.bend','transaction.bend','types.bend','storage.bend','identity.bend','commands.bend','payload.bend','observations.bend','observation-render.bend','storage-stage-fixture.bend','query.bend','systems.bend','schedule.bend','capture.bend','dispatcher.bend','readers.bend','streams.bend']
r={'scope':'retained real Audit through closed opaque A/B success/failure/retry; no full dispatcher acceptance','hashes':{n:hashlib.sha256((HERE/n).read_bytes()).hexdigest() for n in names},'oracle_sha256':hashlib.sha256((HERE/'transaction-ab-oracle.py').read_bytes()).hexdigest(),'expected_sha256':hashlib.sha256(expected.encode()).hexdigest(),'original':None,'mutants':{},'negative_controls':{}}
with tempfile.TemporaryDirectory(prefix='audited-invoker-') as d:
 for label in ['original','audit_effect_dropped']:
  folder=pathlib.Path(d)/label;folder.mkdir()
  for n in names:shutil.copyfile(HERE/n,folder/n)
  if label!='original':
   p=folder/'audited-invoker.bend';s=p.read_text();assert 'D.audit_log(audit,text)' in s;p.write_text(s.replace('D.audit_log(audit,text)','IO.pure(D.Audit,audit)'))
  out=paired(build(folder/'audited-invoker-controls.bend',folder))
  if label=='original':
   assert out==expected,{'expected':expected,'actual':out};r['original']={'complete_equal':True,'lines':len(out.splitlines()),'observed':out}
  else:
   assert out!=expected,label
   i=next(i for i,(a,b) in enumerate(zip(out.splitlines(),expected.splitlines())) if a!=b)
   r['mutants'][label]={'compiling_native_js':True,'first_difference':{'line':i+1,'actual':out.splitlines()[i],'expected':expected.splitlines()[i]},'observed':out}
 folder=pathlib.Path(d)/'negative';folder.mkdir()
 shutil.copyfile(HERE/'dispatcher.bend',folder/'dispatcher.bend')
 for n in names:
  if not (folder/n).exists():shutil.copyfile(HERE/n,folder/n)
 for label,source,diagnostic in [('duplicate_audit','import Base\nimport ./dispatcher.bend as D\ndef bad(owner:D.Audit) -> D.Audit & D.Audit:\n  (owner,owner)\n','consumed more than once'),('cross_schema_token','import Base\nimport ./audited-invoker.bend as V\nimport ./types.bend as T\ndef bad(owner:V.Wrapped<transaction.Tx<storage.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,storage.Handle<T.MotionSchema>,storage.Command<T.Position,T.Velocity,T.Selected>>>) -> V.Wrapped<transaction.Tx<storage.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,storage.Handle<T.MotionSchema>,storage.Command<T.Position,T.Velocity,T.Selected>>>:\n  V.motion_set_main0(owner,T.VitalsToken{},30)\n','T.VitalsToken')]:
  if label=='cross_schema_token':source=source.replace('import Base\n','import Base\nimport ./transaction.bend as transaction\nimport ./storage.bend as storage\n')
  p=folder/(label+'.bend');p.write_text(source);out=command([CHECK,p,'--check-only'],expected=1);assert diagnostic in out,out;r['negative_controls'][label]={'rejected':True,'diagnostic':out,'source':source}
(HERE/'audited-invoker-evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print('ACTUAL RETAINED AUDIT INVOKER PASS')
