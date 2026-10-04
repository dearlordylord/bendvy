#!/usr/bin/env python3
"""Real Type-owner numeric journal canary; not integrated ECS acceptance."""
import pathlib,tempfile,sys,json,shutil,hashlib
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,paired
names=['transaction.bend','transaction-runtime-controls.bend','types.bend']
mutants={
 'fifo_inverse':('MainInverse{handle,old} <> undo','List.append(&2,Inverse<H>,undo,[MainInverse{handle,old}])'),
 'omit_main_inverse':('MainInverse{handle,old} <> undo','undo'),
 'omit_ledger_inverse':('LedgerInverse{old} <> undo','undo'),
 'failure_commits':('Reverted{unwind(W,H,restore_main,restore_ledger,undo,world)}','Committed{world,[],[],[]}'),
}
result={'scope':'actual generic transaction Type-array canary; integrated world/hooks pending','hashes':{n:hashlib.sha256((HERE/n).read_bytes()).hexdigest() for n in names},'original':None,'mutants':{}}
with tempfile.TemporaryDirectory(prefix='transaction-runtime-') as d:
 tmp=pathlib.Path(d)
 for label,replacement in [('original',None),*mutants.items()]:
  folder=tmp/label;folder.mkdir()
  for n in names:shutil.copyfile(HERE/n,folder/n)
  if replacement:
   p=folder/'transaction.bend';s=p.read_text();assert replacement[0] in s;p.write_text(s.replace(*replacement))
  value=paired(build(folder/'transaction-runtime-controls.bend',folder),quoted=True)
  if label=='original':assert value=='20:101:6';result['original']=value
  else:assert value!='20:101:6';result['mutants'][label]=value
(HERE/'transaction-runtime-evidence.json').write_text(json.dumps(result,indent=2)+'\n')
print('GENERIC TRANSACTION CANARY PASS (not integrated acceptance)')
