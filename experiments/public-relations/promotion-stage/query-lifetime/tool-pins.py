"""Read-only prospective installed-tool, resource and resolved-library pins."""
from pathlib import Path
import hashlib,os,re,shutil,subprocess,sys
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
CLANG_ROOT=Path('/tmp/bendvy-clang19-diagnostic/root')
WRAPPER=Path('/tmp/bendvy-clang19-diagnostic/clang19')
LIBPATH=':'.join(map(str,[CLANG_ROOT/'usr/lib/aarch64-linux-gnu',CLANG_ROOT/'usr/lib/llvm-19/lib',Path('/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu')]))
def snapshot():
 files=set();binaries=[Path(shutil.which('bend')).resolve(),Path(shutil.which('node')).resolve(),Path(sys.executable).resolve(),Path(shutil.which('taskset')).resolve(),WRAPPER.resolve(),(CLANG_ROOT/'usr/lib/llvm-19/bin/clang').resolve()]
 files.update(binaries)
 for root in [Path('/home/node/.bend/bend2'),CLANG_ROOT/'usr/lib/llvm-19/lib/clang/19']:
  assert root.is_dir(),root
  files.update(p.resolve() for p in root.rglob('*') if p.is_file())
 logs={};env=os.environ.copy();env['LD_LIBRARY_PATH']=LIBPATH
 for binary in binaries:
  if binary==WRAPPER.resolve():continue
  child=subprocess.run(['ldd',str(binary)],env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=5);assert child.returncode==0,(binary,child.stdout);logs[str(binary)]=child.stdout
  assert 'not found' not in child.stdout,(binary,child.stdout)
  for line in child.stdout.splitlines():
   if 'warning: setlocale:' in line:continue
   for name in re.findall(r'(/[^\s()]+)',line):
    p=Path(name);assert p.is_file(),p;files.add(p.resolve())
 return {'scope':'Prospective consumed installed binaries, installed Bend Base/effects, Clang resources and resolved ELF libraries; compiled Bend compiler is embedded in pinned executable, no separate installed TS compiler claimed','pins':{str(p):sha(p) for p in sorted(files)},'resolvedLibraries':logs,'environment':{'BENDVY_CLANG19_ROOT':str(CLANG_ROOT),'wrapperLD_LIBRARY_PATH':LIBPATH,'clangResourceDir':str(CLANG_ROOT/'usr/lib/llvm-19/lib/clang/19'),'gccToolchain':'/usr','CPU':9}}
def verify(s):
 assert snapshot()['pins']==s['pins'],'installed tool/resource/library set or bytes changed'
