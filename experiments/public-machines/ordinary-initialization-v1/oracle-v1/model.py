"""Source-only full-wire oracle for the frozen two-schema ordinary consumer."""
import gzip
import hashlib
import json
import re
from pathlib import Path

from state import State, boolean, listing, selftest as state_selftest
from render import OBSERVATIONS, STEPS, watchers, world

HERE = Path(__file__).resolve().parent
FREEZE = json.loads((HERE / 'source-freeze.json').read_text())
SOURCE = Path(FREEZE['snapshot']) / FREEZE['entrypoint']
REGISTRATIONS = [
    (1, 'on-enter-A', ['machine.state:read']),
    (2, 'on-enter-B', ['machine.state:read']),
    (3, 'on-enter-C', ['machine.state:read']),
    (4, 'machine.machine.state.initial-marker', ['machine.machine.state.transition.read']),
    (5, 'machine.changed.fast', ['machine.machine.state.changed']),
    (6, 'machine.changed.slow', ['machine.machine.state.changed']),
    (7, 'machine.transition.fast', ['machine.machine.state.transition.read']),
    (8, 'machine.transition.slow', ['machine.machine.state.transition.read']),
]


def reader_view(cursors):
    return ';'.join(f'{name}{{sys=1:{identity}:machine.transition.{name}:'
                    f'[machine.machine.state.transition.read]:cursor={cursors[index]};stream=1:{identity}}}'
                    for index, (name, identity) in enumerate((('fast', 7), ('slow', 8))))


def actions():
    text = SOURCE.read_text()
    program = text.split('def start_scenario(', 1)[1].split('],scenario_bind', 1)[0]
    found = re.findall(r'(\w+)Action\{"([^"]+)"\s*(?:,\s*(Fixture\.[A-D]\{\}|(?:True|False)\{\}))?\}', program)
    assert len(found) == 40
    assert 'scenario_a() ++ "\\nSCHEMA=B\\n" ++ scenario_b()' in text
    # Reached leaf checks complement the complete entry hash pin. Labels alone
    # cannot establish which provider/callback is invoked.
    for fragment in ['Condition.run_if(', 'False{},fast,world)',
                     'SI.run_tracked(', 'St.open(', 'St.finish(',
                     'List.append(&2,String,trace,[line])',
                     'case ReadFastAction{label,fail}:read_fast_action',
                     'case ReadSlowAction{label,fail}:read_slow_action']:
        assert fragment in text, fragment
    return found


def derive():
    state, cursors, rows, timeline = State(), [0, 0], [], []
    for kind, label, argument in actions():
        status, marker, condition = 'Completed', False, None
        if kind == 'Initialize':
            state.initialize()
        elif kind == 'Insert':
            state.insert(argument[8])
        elif kind == 'Queue':
            state.queue(argument[8])
        elif kind == 'Remove':
            state.remove()
        elif kind == 'Failure':
            state.failure = argument.startswith('True')
        elif kind == 'Marker':
            status, marker = state.marker(), True
        elif kind == 'Conditions':
            condition = state.conditions()
        elif kind == 'SkipFast':
            condition = state.conditions(False)
        elif kind in ('ReadFast', 'ReadSlow'):
            index = int(kind == 'ReadSlow')
            identity = (7, 8)[index]
            values, lagged = state.open_reader(identity)
            attempt = f'values={listing(values)};lagged={boolean(lagged)}'
            failed = argument.startswith('True')
            if failed:
                rows.append('callback=failure:transition-reader-failed;attempt{' + attempt + '}')
            else:
                state.complete_reader(identity)
                cursors[index] = state.clock
                rows.append('callback=success;' + attempt)
        else:
            assert kind == 'Snapshot', kind
        if condition is not None:
            line = f'{label};fast={condition[0]};slow={condition[1]};{world(state, REGISTRATIONS)}'
        else:
            line = (f'{label}:{status};steps={listing(STEPS if marker else [])};'
                    f'observations={listing(OBSERVATIONS if marker else [])};{world(state, REGISTRATIONS)}')
        line += ';watchers{' + watchers(state) + '};readers{' + reader_view(cursors) + '}'
        rows.append(line)
        timeline.append(dict(action=kind, label=label, argument=argument, status=status,
                             userCursors=cursors[:], state=state.snapshot()))
    return rows, timeline


def invariants(timeline):
    by_label = {item['label']: item for item in timeline}
    get = lambda label: by_label[label]['state']
    assert get('duplicate-init-still-A')['defaults'] == 1
    assert get('occupied-insert-C-preserves-pending-B')['pending'] == 'B'
    assert get('initial-C-marker')['current'] == 'B'
    assert get('initial-C-marker')['previous'] == 'C'
    assert get('queued-C-to-B-transition')['events'] == get('initial-C-marker')['events']
    failure = by_label['slow-reader-fails-on-unread-initial-C']
    retry = by_label['slow-reader-retries-same-initial-C']
    assert failure['userCursors'][1] < retry['userCursors'][1]
    assert failure['state']['batches'] == retry['state']['batches']
    assert get('active-fast-condition-false')['watch_cursors'] == get('latest-initial-C')['watch_cursors']
    assert by_label['active-fast-condition-false']['userCursors'] == by_label['latest-initial-C']['userCursors']
    assert get('equal-insert-C-is-new-change')['revision'] == get('condition-read-after-fast-skip')['revision'] + 1
    assert get('init-occupied-no-change')['revision'] == get('equal-insert-C-is-new-change')['revision']
    before = get('missing-slot-condition-false')['batches']
    after = get('reinitialize-missing-default-A')['batches']
    assert after[:-1] == before and after[-1][1] == 'initial:A'
    assert get('reinitialized-change-read')['defaults'] == 2
    assert by_label['failed-initial-enter']['status'].startswith('HandlerFailed:enter:')
    assert get('quiet-retry-does-not-replay')['events'] == get('failed-initial-enter')['events']
    assert len(get('retry-same-owners-after-republish')['events']) == len(get('failed-initial-enter')['events']) + 1
    assert all(item['state']['dropped'] == item['state']['frame_start'] == 0 for item in timeline)
    assert get('final-condition-read')['defaults'] == 2


def selftest():
    state_selftest()
    pins = json.loads((HERE / 'source-pins.json').read_text())
    for path, expected in pins.items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == expected, path
    rows, timeline = derive()
    invariants(timeline)
    assert len(rows) == 47
    wire = ('SCHEMA=A\n' + listing(rows) + '\nSCHEMA=B\n' + listing(rows) + '\n').encode()
    # Both nominal roots use a fresh W.factory(), each returning namespace 1.
    # No shared host allocator is called, and no independently allocated IO
    # namespace claim is implied by repeating this source-derived observation.
    return wire, timeline


if __name__ == '__main__':
    wire, timeline = selftest()
    (HERE / 'expected.stdout').write_bytes(wire)
    (HERE / 'expected.stdout.gz').write_bytes(gzip.compress(wire, mtime=0))
    digest = hashlib.sha256(wire).hexdigest()
    (HERE / 'expected.sha256').write_text(digest + '  expected.stdout\n')
    (HERE / 'timeline.json').write_text(json.dumps(timeline, indent=2) + '\n')
    print(f'PASS {len(wire)} bytes SHA256 {digest}')
