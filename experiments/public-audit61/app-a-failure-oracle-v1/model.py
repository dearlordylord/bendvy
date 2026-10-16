"""Independent complete AppA resource-failure oracle; no runtime output input."""
import importlib.util
from pathlib import Path

BASE = Path(__file__).resolve().parents[1] / 'app-a-oracle-v1/model.py'
spec = importlib.util.spec_from_file_location('app_a_normal_model', BASE)
normal = importlib.util.module_from_spec(spec)
spec.loader.exec_module(normal)
normal.ROOT = Path('/workspace/formal-proofs/bendvy-worktrees/audit61-app-a-resource-failure/experiments/public-audit61/app-a-failure-v1')
ctor, ls, q, core = normal.ctor, normal.ls, normal.q, normal.core


def owners(component_cursor, resource_cursor):
    def registry(ident, name, access, cursor):
        return ctor('observe.RegistryView', '1', str(ident), q(name),
                    ls([q(access)]), str(cursor))
    clauses = ls([ctor(core('ordinary-query-declaration.bend', 'Clause'),
                       q('scalar'), ctor(core('ordinary-query-declaration.bend', 'Write')))])
    return ctor('observe.OwnerViews',
                registry(1, 'ScalarTransaction', 'scalar', component_cursor),
                q('AuditPipeline'), clauses,
                registry(2, 'CounterTransaction', 'Counter', resource_cursor))


def views():
    def value(payload):
        return ctor(core('inspector.bend', 'Value'),
                    ctor(core('component.bend', 'Found'), payload),
                    ctor('True'), ctor('True'))
    return ctor('inspect.Views', '0', value(ls(['7', '9'])), value('15'), ls(['10', '11']))


def render():
    state = normal.State()
    snapshots = []

    def snapshot(stage, owner=normal.NONE, selected=normal.NONE):
        snapshots.append(ctor('Snapshot', q(stage), q(state.world()), owner, selected))

    snapshot('created')
    state.reserve_bundle()
    snapshot('bundle-committed-before-flush')
    state.flush_bundle()
    snapshot('explicit-flush')
    state.register()
    snapshot('registered', normal.some(owners(0, 0)))
    # The first transaction commits. Its barrier precedes the resource system.
    state.scalar, state.scalar_changed, state.clock = '15', 3, 3
    # The second transaction replaces Counter then fails: its inverse restores
    # the old Counter. It neither rewinds the earlier commit nor moves its cursor.
    snapshot('after-schedule-before-inspect', normal.some(owners(3, 0)))
    snapshot('after-inspect', normal.some(owners(3, 0)), normal.some(views()))
    snapshot('after-repeated-inspect', normal.some(owners(3, 0)), normal.some(views()))
    observations = [ctor(core('schedule.bend', 'Entered'), q('Installed')),
                    ctor(core('schedule.bend', 'Ran'), '1'),
                    ctor(core('schedule.bend', 'Applied')),
                    ctor(core('schedule.bend', 'Ran'), '2')]
    # Failure returns before the second barrier and preserves the typed error.
    return (ctor('Report', ls(snapshots), ls(observations), q('Failed:AuditPipeline'),
                 normal.some(ctor('systems.ResourceFailed'))) + '\n').encode()


if __name__ == '__main__':
    import sys
    sys.stdout.buffer.write(render())
