"""Complete AppA normal report, derived before backend execution from c75db5e15."""
import json
import os
from pathlib import Path
ROOT = Path('/workspace/formal-proofs/bendvy-worktrees/public-audit61-app-a/experiments/public-audit61/app-a-v1')
CORE = Path('/workspace/formal-proofs/bendvy/src/ecs')
def q(value):
    return json.dumps(value, ensure_ascii=False)
def ctor(name, *fields):
    return name + '{' + ', '.join(fields) + '}'
def ls(values):
    return '[' + ', '.join(values) + ']'
def core(module, name):
    return os.path.relpath(CORE / module, ROOT)[:-5] + '.' + name
NONE = ctor('None')
def some(value):
    return ctor('Some', value)
def node(a, b):
    return f'node(leaf:{a},leaf:{b})'
def column(value=None, added=0, changed=0):
    payload = 'none' if value is None else 'some(' + value + ')'
    stamps = '[]' if value is None else f'[1:{added}:{changed}]'
    return f'Column{{values=leaf:{payload};stamps={stamps}}}'
class State:
    def __init__(self):
        self.next_id = 1
        self.high = 0
        self.live = 'leaf:False'
        self.capacity = 1
        self.depth = 0
        self.array = None
        self.scalar = None
        self.scalar_changed = 0
        self.counter = node(10, 11)
        self.pending = 0
        self.inverses = 0
        self.registered = False
        self.clock = 0
    def reserve_bundle(self):
        # world.reserve_id grows reserved-index Bool storage; finish publishes
        # activation and delivery callbacks, without executing either.
        self.next_id, self.high = 2, 1
        self.live, self.capacity, self.depth = node('False', 'False'), 2, 1
        self.pending = 2
    def flush_bundle(self):
        # Commands first activate id1. Ordered bundle recipe replaces array then
        # scalar, each advancing clock and setting its lifecycle stamp.
        self.live = node('False', 'True')
        self.array, self.scalar = node(7, 9), '11'
        self.scalar_changed = 2
        self.clock, self.pending, self.inverses = 2, 0, 1
    def register(self):
        self.registered = True
    def run_schedule(self):
        # Scalar tx uses existing id1: added stays2, changed becomes3.
        # Counter field tx replaces its affine Array without advancing World clock.
        self.scalar, self.scalar_changed = '15', 3
        self.counter, self.clock = node(21, 22), 3
    def world(self):
        arrays = column(self.array, 1, 1)
        scalars = column(self.scalar, 2, self.scalar_changed)
        regs = '[2:CounterTransaction:[Counter], 1:ScalarTransaction:[scalar]]' if self.registered else '[]'
        return (f'namespace=1|next={self.next_id}|high={self.high}|live={self.live}'
                f'|capacity={self.capacity}|depth={self.depth}|store=arrays={{{arrays}}};scalars={{{scalars}}}'
                f'|resources=Counter={self.counter};Sibling={node(100,101)};receipts=inverses={self.inverses};returned=[];errors=[];quarantines=0'
                f'|events=[]|pending={self.pending}|registrations={regs}|nextSystem={3 if self.registered else 1}|clock={self.clock}')
def owners(cursor):
    registry = lambda ident, name, access: ctor('observe.RegistryView', '1', str(ident), q(name), ls([q(access)]), str(cursor))
    clauses = ls([ctor(core('ordinary-query-declaration.bend', 'Clause'), q('scalar'), ctor(core('ordinary-query-declaration.bend', 'Write')))])
    return ctor('observe.OwnerViews', registry(1,'ScalarTransaction','scalar'), q('AuditPipeline'), clauses, registry(2,'CounterTransaction','Counter'))
def views():
    value = lambda payload: ctor(core('inspector.bend','Value'), ctor(core('component.bend','Found'), payload), ctor('True'), ctor('True'))
    return ctor('inspect.Views', '0', value(ls(['7','9'])), value('15'), ls(['21','22']))
def render():
    state = State()
    snapshots = []
    def snapshot(stage, owner=NONE, selected=NONE):
        snapshots.append(ctor('Snapshot', q(stage), q(state.world()), owner, selected))
    snapshot('created')
    state.reserve_bundle()
    snapshot('bundle-committed-before-flush')
    state.flush_bundle()
    snapshot('explicit-flush')
    state.register()
    snapshot('registered', some(owners(0)))
    state.run_schedule()
    snapshot('after-schedule-before-inspect', some(owners(3)))
    snapshot('after-inspect', some(owners(3)), some(views()))
    snapshot('after-repeated-inspect', some(owners(3)), some(views()))
    observations = [ctor(core('schedule.bend','Entered'),q('Installed')),ctor(core('schedule.bend','Ran'),'1'),ctor(core('schedule.bend','Applied')),ctor(core('schedule.bend','Ran'),'2'),ctor(core('schedule.bend','Applied'))]
    return (ctor('Report', ls(snapshots), ls(observations), q('Finished:AuditPipeline')) + '\n').encode()
if __name__ == '__main__':
    import sys
    sys.stdout.buffer.write(render())
