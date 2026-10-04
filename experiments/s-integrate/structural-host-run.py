#!/usr/bin/env python3
import pathlib,re,sys,hashlib,json,tempfile,shutil,importlib.util
HERE=pathlib.Path(__file__).resolve().parent;sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,paired
spec=importlib.util.spec_from_file_location('oracle',HERE/'structural-host-oracle.py');o=importlib.util.module_from_spec(spec);spec.loader.exec_module(o);expected=o.expected()
def closure(p,files):
 if p.name in files:return
 files[p.name]=p
 for v in re.findall(r'^import (\./\S+\.bend)',p.read_text(),re.M):closure((p.parent/v).resolve(),files)
files={};closure(HERE/'structural-host-controls.bend',files)
r={'scope':'actual D.Runtime<Host> foreign-command wrapper; complete finite owner-return observations','hashes':{n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in files.items()},'oracle_sha256':hashlib.sha256((HERE/'structural-host-oracle.py').read_bytes()).hexdigest(),'expected_sha256':hashlib.sha256(expected.encode()).hexdigest(),'original':None,'mutants':{}}
with tempfile.TemporaryDirectory(prefix='structural-host-') as d:
 for label in ['original','namespace_bypass','runtime_clock_reset','runtime_capture_reset']:
  folder=pathlib.Path(d)/label;folder.mkdir()
  for n,p in files.items():shutil.copyfile(p,folder/n)
  if label=='namespace_bypass':
   p=folder/'commands.bend';s=p.read_text();assert 'U32.is_eq(namespace,foreign)' in s;p.write_text(s.replace('U32.is_eq(namespace,foreign)','True{}'))
  elif label!='original':
   p=folder/'structural-host-adapter.bend';s=p.read_text();start=s.index('def runtime_queued');end=s.index('\ndef insert(',start);head=s[:start];tail=s[end:];s=s[start:end]
   if label=='runtime_clock_reset':assert 'world,registry,readers,clock,audit' in s;s=s.replace('D.Runtime{world,registry,readers,clock,audit','D.Runtime{world,registry,readers,R.clock(),audit')
   else:assert 'D.Runtime{world,registry,readers' in s;s=s.replace('D.Runtime{world,registry,readers','D.Runtime{world,Q.initial(),readers')
   p.write_text(head+s+tail)
  out=paired(build(folder/'structural-host-controls.bend',folder))
  if label=='original':assert out==expected,{'expected':expected,'actual':out};r['original']={'complete_equal':True,'lines':len(out.splitlines()),'observed':out}
  else:
   assert out!=expected,label;i=next(i for i,(a,b) in enumerate(zip(out.splitlines(),expected.splitlines())) if a!=b);r['mutants'][label]={'compiling_native_js':True,'first_difference':{'line':i+1,'actual':out.splitlines()[i],'expected':expected.splitlines()[i]},'observed':out}
(HERE/'structural-host-evidence.json').write_text(json.dumps(r,indent=2)+'\n');print('ACTUAL HOST FOREIGN COMMAND PASS')
