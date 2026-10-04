#!/usr/bin/env python3
import pathlib,sys,re,hashlib,json,tempfile,shutil,importlib.util
HERE=pathlib.Path(__file__).resolve().parent;sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,paired
spec=importlib.util.spec_from_file_location('oracle',HERE/'structural-invoker-oracle.py');o=importlib.util.module_from_spec(spec);spec.loader.exec_module(o);expected=o.expected()
def closure(p,files):
 if p.name in files:return
 files[p.name]=p
 for v in re.findall(r'^import (\./\S+\.bend)',p.read_text(),re.M):closure((p.parent/v).resolve(),files)
files={};closure(HERE/'structural-invoker-controls.bend',files)
r={'scope':'actual two-schema Cleanup/Inserts/Dispose command joins; independent actual setup, no earlier A/B/capture/reader acceptance','hashes':{n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in files.items()},'oracle_sha256':hashlib.sha256((HERE/'structural-invoker-oracle.py').read_bytes()).hexdigest(),'expected_sha256':hashlib.sha256(expected.encode()).hexdigest(),'original':None,'mutants':{}}
def mutate(folder,label):
 p=folder/'structural-invoker.bend';s=p.read_text()
 if label=='cleanup_wrong_target':
  for n in ['motion','health']:
   st=s.index('def '+n+'_cleanup(world:');en=s.index('\ndef ',st+1);b=s[st:en];assert ',world,p)' in b;s=s[:st]+b.replace(',world,p)',',world,b)').replace(',b:S.Handle',',+b:S.Handle')+s[en:]
 elif label=='inserts_order_swapped':
  for n in ['motion','health']:
   st=s.index('def '+n+'_inserts(world:');en=s.index('\ndef ',st+1);b=s[st:en];head,body=b.split('\n',1);assert ',a,a80)' in body and ',a,a81)' in body;body=body.replace(',a,a80)',',a,swap_temp)').replace(',a,a81)',',a,a80)').replace(',a,swap_temp)',',a,a81)');s=s[:st]+head+'\n'+body+s[en:]
 elif label=='dispose_r_preserved':
  for n in ['motion','health']:
   st=s.index('def '+n+'_dispose(world:');head,body=s[st:].split('\n',1);end=body.index('\ndef ') if '\ndef ' in body else len(body);b=body[:end];old=n+'_despawn('+n+'_despawn('+n+'_despawn('+n+'_despawn('+n+'_remove(Batch{world,[]},c),a),p),r),c)';new=n+'_despawn('+n+'_despawn('+n+'_despawn('+n+'_remove(Batch{world,[]},c),a),p),c)';assert old in b;s=s[:st]+head+'\n'+b.replace(old,new)+body[end:]
 p.write_text(s)
with tempfile.TemporaryDirectory(prefix='structural-invoker-') as d:
 for label in ['original','cleanup_wrong_target','inserts_order_swapped','dispose_r_preserved']:
  folder=pathlib.Path(d)/label;folder.mkdir()
  for n,p in files.items():shutil.copyfile(p,folder/n)
  if label!='original':mutate(folder,label)
  out=paired(build(folder/'structural-invoker-controls.bend',folder))
  if label=='original':assert out==expected,{'expected':expected,'actual':out};r['original']={'complete_equal':True,'lines':len(out.splitlines()),'observed':out}
  else:
   assert out!=expected,label
   i=next(i for i,(a,b) in enumerate(zip(out.splitlines(),expected.splitlines())) if a!=b);r['mutants'][label]={'compiling_native_js':True,'first_difference':{'line':i+1,'actual':out.splitlines()[i],'expected':expected.splitlines()[i]},'observed':out}
(HERE/'structural-invoker-evidence.json').write_text(json.dumps(r,indent=2)+'\n');print('ACTUAL STRUCTURAL INVOKER PASS')
