"""Read-only prospective installed-tool, resource and resolved-library pins."""
from pathlib import Path
import hashlib,importlib.util,os,re,shutil,subprocess,sys

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

CONFIG_PATH=_runner_root/'scripts/installed-config.py'
_config_spec=importlib.util.spec_from_file_location('feature_installed_config',CONFIG_PATH)
_config=importlib.util.module_from_spec(_config_spec);_config_spec.loader.exec_module(_config)
SELECTED_TOOLS={name:Path(path).resolve() for name,path in _config.TOOL_PATHS.items()}

sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
CLANG_ROOT=Path(_config.CLANG_ROOT)
WRAPPER=SELECTED_TOOLS['clangWrapper']
LIBPATH=':'.join(map(str,[CLANG_ROOT/'usr/lib/aarch64-linux-gnu',CLANG_ROOT/'usr/lib/llvm-19/lib',Path('/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu')]))
def snapshot():
 files={CONFIG_PATH};binaries=[SELECTED_TOOLS['bend'],SELECTED_TOOLS['node'],Path(sys.executable).resolve(),SELECTED_TOOLS['taskset'],WRAPPER.resolve(),SELECTED_TOOLS['clang']]
 files.update(binaries)
 for root in [Path('/home/node/.bend/bend2'),CLANG_ROOT/'usr/lib/llvm-19/lib/clang/19']:
  assert root.is_dir(),root
  files.update(p.resolve() for p in root.rglob('*') if p.is_file())
 logs={};env=os.environ.copy();env['LD_LIBRARY_PATH']=LIBPATH
 for binary in binaries:
  if binary==WRAPPER.resolve():continue
  child=task_runner.run(['ldd',str(binary)],env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=5);assert child.returncode==0,(binary,child.stdout);logs[str(binary)]=child.stdout
  assert 'not found' not in child.stdout,(binary,child.stdout)
  for line in child.stdout.splitlines():
   if 'warning: setlocale:' in line:continue
   for name in re.findall(r'(/[^\s()]+)',line):
    p=Path(name);assert p.is_file(),p;files.add(p.resolve())
 return {'scope':'Prospective consumed installed binaries, installed Bend Base/effects, Clang resources and resolved ELF libraries; compiled Bend compiler is embedded in pinned executable, no separate installed TS compiler claimed','pins':{str(p):sha(p) for p in sorted(files)},'resolvedLibraries':logs,'environment':{'BENDVY_CLANG19_ROOT':str(CLANG_ROOT),'wrapperLD_LIBRARY_PATH':LIBPATH,'clangResourceDir':str(CLANG_ROOT/'usr/lib/llvm-19/lib/clang/19'),'gccToolchain':'/usr','processAffinity':sorted(os.sched_getaffinity(0))}}
def verify(s):
 assert snapshot()['pins']==s['pins'],'installed tool/resource/library set or bytes changed'
