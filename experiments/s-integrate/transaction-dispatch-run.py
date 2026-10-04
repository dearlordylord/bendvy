#!/usr/bin/env python3
"""Actual transaction publication→FIFO barrier gate; every runtime/check <=5s."""
import pathlib,tempfile,shutil,sys,json,hashlib
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,paired
names=['transaction.bend','transaction-dispatch-fixture.bend','types.bend','storage.bend','identity.bend','commands.bend','payload.bend','payload-controls.bend']
expected='pending=81,82,83,84:7;80,81,82,83:7;before=20,21,22,23:7;after=81,82,83,84:7\npending=81,82,83,84:9:2;80,81,82,83:9:2;before=20,21,22,23:9:2;after=81,82,83,84:9:2'
mutants={
 'stage_reversed':('List.append(&1,C,commands,[command])','command <> commands'),
 'commit_no_reverse':('List.reverse(&1,S.Command<M,A,F>,commands)','commands'),
}
r={'scope':'actual reserved/spawned live world; same transaction 80 then81 pending Type owners before explicit apply; full fields both schemas','hashes':{n:hashlib.sha256((HERE/n).read_bytes()).hexdigest() for n in names},'expected':expected,'original':None,'mutants':{}}
with tempfile.TemporaryDirectory(prefix='transaction-dispatch-') as d:
 for label,replacement in [('original',None),*mutants.items()]:
  folder=pathlib.Path(d)/label;folder.mkdir()
  for n in names:shutil.copyfile(HERE/n,folder/n)
  if replacement:
   p=folder/'transaction.bend';s=p.read_text();assert replacement[0] in s;p.write_text(s.replace(*replacement))
  out=paired(build(folder/'transaction-dispatch-fixture.bend',folder),quoted=True)
  if label=='original':assert out==expected;r['original']=out
  else:assert out!=expected;r['mutants'][label]=out
(HERE/'transaction-dispatch-evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print('TRANSACTION FIFO BARRIER GATE PASS')
