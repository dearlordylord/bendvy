"""Source-derived TS common-query wire, authored before execution."""
from pathlib import Path
from copy import deepcopy
import json
import gzip
import hashlib

HERE = Path(__file__).resolve().parent


def derive(root):
    capture = dict(left=[1, 2], right=[3, 4], calls=0, entered=0, delta=1, failValue=0, readings=[])
    values, result = {}, None
    frame = tick = cursor = 0
    rows = []

    def record(phase):
        entities = [dict(id=i, components=({'Value': values[i]} if i in values else {}), relations={}) for i in ([1, 2, 3] if values else [])]
        world = dict(version=1, frame=frame, tick=tick, entityCount=len(entities), entities=entities, resources={}, machines={}, pendingCommands=[])
        rows.append(deepcopy(dict(root=root, phase=phase, result=result, capture=capture, world=world,
                                  population=dict(entities=len(entities), components={'Value': len(values)}), streams=[])))

    record('initial')
    frame, tick = 1, 1
    capture['calls'] += 1
    capture['readings'].append([])
    cursor = 1
    result = {'ok': True}
    record('empty')
    # One populate system then one deferred marker. The three actual command
    # reservations return IDs1,2,3; marker stamps both present Value cells tick3.
    frame, tick = 2, 3
    values = {1: 10, 2: 20}
    stamps = {1: 3, 2: 3}
    record('populated')

    def run(phase, delta, fail=0):
        nonlocal frame, tick, cursor, values, result, stamps
        frame += 1
        tick += 1  # TS enters once per system, not once per component write.
        capture['delta'], capture['failValue'] = delta, fail
        capture['calls'] += 1
        old_values = deepcopy(values)
        reading, changed = [], []
        capture['readings'].append(reading)
        for i in sorted(values):
            if stamps[i] <= cursor:
                continue
            old = values[i]
            reading.append(old)
            values[i] += delta
            changed.append(i)
            capture['entered'] += 1
            capture['left'] = [x + delta for x in capture['left']]
            capture['right'] = [x + delta * 10 for x in capture['right']]
            if old == fail:
                values = old_values
                result = {'ok': False, 'error': {'kind': 'SystemFailure', 'system': 'captured-query', 'error': {'failedAt': old}}}
                record(phase)
                return
        for i in changed:
            stamps[i] = tick
        cursor = tick
        result = {'ok': True}
        record(phase)

    run('late-failure', 1, 20)
    assert values == {1: 10, 2: 20} and stamps == {1: 3, 2: 3} and cursor == 1
    run('retry', 2)
    assert cursor == 5 and values == {1: 12, 2: 22}
    run('no-changes', 9)
    assert cursor == 6 and capture['readings'][-1] == []
    # External system queues insert on its actual returned first handle, then
    # applyDeferred advances once again and overwrites only that entity.
    frame, tick = 6, 8
    values[1], stamps[1] = 30, 8
    record('external')
    run('changed-one', 3)
    assert values == {1: 33, 2: 22} and cursor == tick == 9
    frame += 1  # condition false: no system entry, tick or capture changes
    record('skip')
    assert capture == dict(left=[10, 11], right=[93, 94], calls=5, entered=5, delta=3, failValue=0, readings=[[], [10, 20], [10, 20], [], [30]])
    assert len(rows) == 9
    return rows


def expected():
    return derive('CapturesQueryAlpha') + derive('CapturesQueryBeta')


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    value = expected()
    raw = (json.dumps(value, separators=(',', ':')) + '\n').encode()
    if args.write:
        (HERE / 'expected.json').write_text(json.dumps(value, indent=2) + '\n')
        (HERE / 'normal.stdout').write_bytes(raw)
        (HERE / 'normal.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
    assert json.loads((HERE / 'expected.json').read_text()) == value
    assert (HERE / 'normal.stdout').read_bytes() == raw
    assert gzip.decompress((HERE / 'normal.stdout.gz').read_bytes()) == raw
    print(json.dumps({'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest(), 'checkpoints': len(value)}))


if __name__ == '__main__':
    main()
