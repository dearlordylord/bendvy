#!/usr/bin/env python3
"""Real Type-owner numeric journal canary; not integrated ECS acceptance."""
import pathlib,tempfile,sys,json,shutil,hashlib
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,paired
names=['transaction.bend','transaction-runtime-controls.bend','types.bend','storage.bend','identity.bend','payload.bend','transaction-world-controls.bend']
mutants={
 'fifo_inverse':('MainInverse{handle,old} <> undo','List.append(&2,Inverse<H>,undo,[MainInverse{handle,old}])'),
 'omit_main_inverse':('MainInverse{handle,old} <> undo','undo'),
 'omit_ledger_inverse':('LedgerInverse{old} <> undo','undo'),
 'reserve_reissue':('identity.bend','(next + 1 : U32)','next'),
 'failure_commits':('Reverted{unwind(W,H,restore_main,restore_ledger,undo,world)}','Committed{world,[],[],[]}'),
}
result={'scope':'actual generic transaction Type-array canary; integrated world/hooks pending','hashes':{n:hashlib.sha256((HERE/n).read_bytes()).hexdigest() for n in names},'original':None,'mutants':{}}
with tempfile.TemporaryDirectory(prefix='transaction-runtime-') as d:
 tmp=pathlib.Path(d)
 for label,replacement in [('original',None),*mutants.items()]:
  folder=tmp/label;folder.mkdir()
  for n in names:shutil.copyfile(HERE/n,folder/n)
  if replacement:
   target,old,new=('transaction.bend',*replacement) if len(replacement)==2 else replacement
   p=folder/target;s=p.read_text();assert old in s;p.write_text(s.replace(old,new))
  value=paired(build(folder/'transaction-runtime-controls.bend',folder),quoted=True)
  world_value=paired(build(folder/'transaction-world-controls.bend',folder),quoted=True)
  world_expected='failedId=2:20,21,22,23:meta=7:ledger=101,101,102,103:epoch=4:next=3\nfailedId=2:20,21,22,23:meta=9:2:ledger=101,101,102,103:epoch=4:next=3'
  if label=='original':
   assert world_value==world_expected
   result['world_original']=world_value
  else:
   assert world_value!=world_expected
   result.setdefault('world_mutants',{})[label]=world_value
  if label=='original':assert value=='20:101:6';result['original']=value
  else:
   if label!='reserve_reissue':assert value!='20:101:6'
   result['mutants'][label]=value
(HERE/'transaction-runtime-evidence.json').write_text(json.dumps(result,indent=2)+'\n')
print('GENERIC TRANSACTION CANARY PASS (not integrated acceptance)')
