#!/usr/bin/env python3
"""Full sequence validation of linear private staging; not public E11 acceptance."""
import pathlib,tempfile,shutil,sys,json,hashlib
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,paired
names=['transaction-staging-controls.bend','transaction.bend','types.bend','storage.bend']
r={'scope':'65536 actual staged Ping values plus1024 actual Type commands with all4 array fields and metadata compared','hashes':{n:hashlib.sha256((HERE/n).read_bytes()).hexdigest() for n in names},'cases':{}}
with tempfile.TemporaryDirectory(prefix='transaction-staging-') as d:
 for label,replacement in [('original',None),('ping_order_unreversed',('List.reverse(&2,U32,pings)','pings')),('command_order_unreversed',('List.reverse(&1,C,commands)','commands'))]:
  folder=pathlib.Path(d)/label;folder.mkdir()
  for n in names:shutil.copyfile(HERE/n,folder/n)
  if replacement:
   p=folder/'transaction.bend';s=p.read_text();assert replacement[0] in s;p.write_text(s.replace(*replacement))
  out=paired(build(folder/'transaction-staging-controls.bend',folder),quoted=True)
  assert out==('True' if label=='original' else 'False'),(label,out)
  r['cases'][label]={'native_js_equal':True,'complete_validation':out}
(HERE/'transaction-staging-evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print('LINEAR PRIVATE STAGING SEQUENCE GATE PASS')
