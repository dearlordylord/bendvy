"""Task-local configuration of the delivered owned-tool-pins helper."""
from pathlib import Path
import importlib.util,os,shutil,sys
D=Path(__file__).resolve().parent;R=D.parents[5];H=R/'experiments/public-relations/promotion-stage/current-core-replay/guarded-v2'
sys.path.insert(0,str(R/'experiments/s-prep/fivehour-connected-gates'));import supervisor
sys.path.insert(0,str(H));import raw_supervisor
spec=importlib.util.spec_from_file_location('shared_owned_tools',R/'scripts/owned-tool-pins.py');shared=importlib.util.module_from_spec(spec);spec.loader.exec_module(shared)
CLANG=Path('/tmp/bendvy-clang19-diagnostic/root');WRAPPER=Path('/tmp/bendvy-clang19-diagnostic/clang19')
def configuration():
 env=os.environ.copy();env.update({'BEND_NO_TELEMETRY':'1','BENDVY_CLANG19_ROOT':str(CLANG),'LD_LIBRARY_PATH':':'.join(map(str,[CLANG/'usr/lib/aarch64-linux-gnu',CLANG/'usr/lib/llvm-19/lib',Path('/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu')]))})
 return {'execute':raw_supervisor.execute,'tools':{'bend':shutil.which('bend'),'node':shutil.which('node'),'python':sys.executable,'taskset':shutil.which('taskset'),'clang-wrapper':str(WRAPPER),'clang':str(CLANG/'usr/lib/llvm-19/bin/clang')},'resource_roots':['/home/node/.bend/bend2',str(CLANG/'usr/lib/llvm-19/lib/clang/19')],'ldd':shutil.which('ldd'),'taskset':shutil.which('taskset'),'cpu':8,'env':env,'skip_ldd':['clang-wrapper'],'capture_mode':'merged-stdout'}
def snapshot():return shared.snapshot(**configuration())
def verify(previous):shared.verify(previous,**configuration())
