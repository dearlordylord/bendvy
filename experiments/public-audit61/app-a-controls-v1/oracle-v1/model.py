"""Source-only reached omitted-array-install whole countermodel; no output input."""
import importlib.util
from pathlib import Path
BASE = Path(__file__).resolve().parents[2] / 'app-a-oracle-v1' / 'model.py'
spec = importlib.util.spec_from_file_location('normal_app_a', BASE)
n = importlib.util.module_from_spec(spec)
spec.loader.exec_module(n)
ROOT = Path(__file__).resolve().parents[1]
# Actual entry and all local defining-module names have the same path depth.
for module in ('ordinary-query-declaration.bend','component.bend','inspector.bend','schedule.bend'):
    import os
    assert n.core(module,'X') == os.path.relpath(n.CORE/module,ROOT)[:-5]+'.X'
class State(n.State):
    def flush_bundle(self):
        # Omission retains the array Entry in the inverse closure; only scalar
        # public installation writes World, recording clock/stamp1.
        self.live=n.node('False','True')
        self.array,self.scalar=None,'11'
        self.scalar_changed=1
        self.clock,self.pending,self.inverses=1,0,1
    def run_schedule(self):
        self.scalar,self.scalar_changed='15',2
        self.counter,self.clock=n.node(21,22),2
    def world(self):
        return super().world().replace('stamps=[1:2:','stamps=[1:1:')
def views():
    absent=n.ctor(n.core('inspector.bend','Value'),n.ctor(n.core('component.bend','ComponentAbsent')),n.ctor('False'),n.ctor('False'))
    scalar=n.ctor(n.core('inspector.bend','Value'),n.ctor(n.core('component.bend','Found'),'15'),n.ctor('True'),n.ctor('True'))
    return n.ctor('inspect.Views','0',absent,scalar,n.ls(['21','22']))
def render():
    state=State()
    snapshots=[]
    def snapshot(stage,owner=n.NONE,selected=n.NONE):
        snapshots.append(n.ctor('Snapshot',n.q(stage),n.q(state.world()),owner,selected))
    snapshot('created')
    state.reserve_bundle()
    snapshot('bundle-committed-before-flush')
    state.flush_bundle()
    snapshot('explicit-flush')
    state.register()
    snapshot('registered',n.some(n.owners(0)))
    state.run_schedule()
    snapshot('after-schedule-before-inspect',n.some(n.owners(2)))
    snapshot('after-inspect',n.some(n.owners(2)),n.some(views()))
    snapshot('after-repeated-inspect',n.some(n.owners(2)),n.some(views()))
    observations=[n.ctor(n.core('schedule.bend','Entered'),n.q('Installed')),n.ctor(n.core('schedule.bend','Ran'),'1'),n.ctor(n.core('schedule.bend','Applied')),n.ctor(n.core('schedule.bend','Ran'),'2'),n.ctor(n.core('schedule.bend','Applied'))]
    return (n.ctor('Report',n.ls(snapshots),n.ls(observations),n.q('Finished:AuditPipeline'))+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(render())
