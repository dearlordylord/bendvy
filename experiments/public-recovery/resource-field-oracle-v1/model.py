"""Independent finite source model and literal observer formatting.

SOURCE-BASIS binds the final checked source. No runtime,
compiler, generated artifact or other author's oracle is consulted.
"""
from dataclasses import asdict
from pathlib import Path
import gzip
import hashlib
import json
from state_model import State, Record, matrix, pair, seeded_args, retry_args

HERE = Path(__file__).resolve().parent


def element(values):
    assert len(values) == 2
    return f'node(leaf:{values[0]},leaf:{values[1]})'


def array(values):
    # Outer Array leaves contain full inner Array owners; retain both layers.
    assert len(values) == 2
    return f'node(leaf:{element(values[0])},leaf:{element(values[1])})'


def items(values, render):
    return ''.join(render(value) + ';' for value in values) + '[]'


def show_args(args):
    return (f'first={array(args.first)}:element={element(args.element)}'
            f':second={array(args.second)}:rejected={element(args.rejected)}'
            f':fail={args.fail}')


def show_record(record):
    if record.kind == 'Replaced':
        return 'replaced:' + array(record.value)
    assert record.kind == 'Swapped'
    return f'swapped:{record.index}:' + element(record.value)


def world(state):
    resource = (f'target={array(state.target)}:siblings={{samePayloadSibling='
                f'{array(state.same_sibling)}:otherAffine={element(state.other_sibling)}}}')
    return (f'ns={state.namespace}:next=1:high=0:capacity=1:depth=0:live=leaf:False'
            f':store=Unit:resource={{{resource}}}:events=[]:pending=0'
            f':regs=[1:selected-recovery:[Target]]:sid=2:clock={state.clock}')


def owner(state):
    return (f'{state.namespace}:1:selected-recovery:[Target]:cursor={state.cursor}'
            f':capture={element(state.capture)}')


def snapshot(label, state):
    return label + '|world={' + world(state) + '}|owner={' + owner(state) + '}\n'


def derive_schema(namespace):
    state = State(namespace, registered=True)
    lines = [snapshot('registered', state)]
    traces = []
    recovered_input = None
    for label, seed, fail in [('commit', 100, False), ('failed', 200, True),
                              ('retry-failed', None, True), ('retry-success', None, False)]:
        if seed is not None:
            args = seeded_args(seed, fail)
        else:
            assert recovered_input is not None
            args = retry_args(*recovered_input, fail)
        lines.append('input:' + label + '|' + show_args(args) + '\n')
        elements, records = state.run(args)
        lines.append('returned:' + label + '|output={arrays=[]:elements='
                     + items(elements, element) + '}|recovered={'
                     + items(records, show_record) + '}\n')
        outcome = 'failed' if fail else 'success'
        observed_label = label + ':' + outcome
        if fail:
            recovered_input = (elements, records)
            recovered = retry_args(elements, records, True)
            observed_label += '|retryOwners={' + show_args(recovered) + '}'
        else:
            recovered_input = None
        lines.append(snapshot(observed_label, state))
        traces.append({'label': label, 'input': asdict(args), 'state': asdict(state),
                       'outputElements': elements, 'recovery': [asdict(r) for r in records]})
    lines.append(snapshot('terminal', state))
    return ''.join(lines), traces


def derive():
    workshop, a = derive_schema(1)
    garden, b = derive_schema(2)
    # Scenario ends each line with LF; the one Base IO.print adds another LF.
    return ('Workshop\n' + workshop + 'Garden\n' + garden + '\n').encode(), [a, b]


def selftest():
    from state_model import selftest as operation_selftest
    operation_selftest()
    assert array(matrix(10)) == ('node(leaf:node(leaf:10,leaf:11),'
                                 'leaf:node(leaf:12,leaf:13))')
    assert items([], show_record) == '[]'
    raw, traces = derive()
    assert raw.endswith(b'\n\n') and raw.count(b'\n') == 31
    assert raw.count(b'input:') == raw.count(b'returned:') == 8
    assert raw.count(b'|retryOwners=') == 4
    for trace in traces:
        assert [step['state']['target'] for step in trace] == [
            matrix(120), matrix(120), matrix(120), matrix(220)]
        assert trace[1]['input'] == trace[2]['input']
        assert trace[2]['input'] | {'fail': False} == trace[3]['input']
        assert all(step['state']['clock'] == step['state']['cursor'] == 0 for step in trace)
        assert all(step['state']['capture'] == pair(700) for step in trace)
        assert all(step['state']['same_sibling'] == matrix(800) for step in trace)
        assert all(step['state']['other_sibling'] == pair(900) for step in trace)
    return raw, traces


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    raw, traces = selftest()
    if args.write:
        (HERE / 'expected.stdout').write_bytes(raw)
        (HERE / 'expected.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
        (HERE / 'state-trace.json').write_text(json.dumps(traces, indent=2) + '\n')
    print(json.dumps({'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}))
