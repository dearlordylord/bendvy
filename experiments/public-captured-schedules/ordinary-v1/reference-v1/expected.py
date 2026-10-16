"""Independent source-derived full TS heterogeneous nested schedule oracle."""
from pathlib import Path
from copy import deepcopy
import json
import gzip
import hashlib

HERE = Path(__file__).resolve().parent


def derive(root):
    query_capture = dict(left=[1, 2], right=[3, 4], calls=0, readings=[])
    resource_capture = dict(values=[100, 101], calls=0, readings=[])
    args = dict(queryDelta=1, resourceDelta=10, resourceFail=False, resourceEnabled=True)
    values, stamps = {1: 10, 2: 20}, {1: 2, 2: 2}
    counter, cursor, frame, tick = 10, 0, 1, 2
    order, rows = [], []

    def record(phase, result):
        world = dict(version=1, frame=frame, tick=tick, entityCount=3,
                     entities=[dict(id=i, components=({'Value': values[i]} if i in values else {}), relations={}) for i in [1, 2, 3]],
                     resources={'Counter': counter}, machines={}, pendingCommands=[])
        rows.append(deepcopy(dict(root=root, phase=phase, result=result, args=args, order=order,
                                  queryCapture=query_capture, resourceCapture=resource_capture, world=world,
                                  population=dict(entities=3, components={'Value': 2}), streams=[])))

    record('populated', {'ok': True})
    for phase, delta, fail, allow in [('first', 10, False, True), ('resource-skip', 999, False, False), ('resource-failure', 2, True, True), ('retry', 3, False, True)]:
        args.update(resourceDelta=delta, resourceFail=fail, resourceEnabled=allow)
        frame += 1
        order = ['outer', 'query', 'inner', 'condition']
        tick += 1  # actual phase system outer
        tick += 1  # query callback entry
        query_capture['calls'] += 1
        seen = []
        query_capture['readings'].append(seen)
        for identity in sorted(values):
            if stamps[identity] <= cursor:
                continue
            seen.append(values[identity])
            values[identity] += 1
            stamps[identity] = tick
            query_capture['left'] = [x + 1 for x in query_capture['left']]
            query_capture['right'] = [x + 10 for x in query_capture['right']]
        cursor = tick
        tick += 1  # actual phase system inner
        if allow:
            tick += 1
            order.append('resource')
            resource_capture['calls'] += 1
            resource_capture['readings'].append(counter)
            resource_capture['values'] = [x + delta for x in resource_capture['values']]
            if not fail:
                counter += delta
        if fail:
            result = {'ok': False, 'error': {'kind': 'SystemFailure', 'system': 'resource-counter', 'error': 'ResourceFailed'}}
        else:
            tick += 1  # real applyDeferred marker (empty queue)
            result = {'ok': True}
        record(phase, result)
    assert [r['world']['tick'] for r in rows] == [2, 7, 11, 15, 20]
    assert values == {1: 11, 2: 21} and counter == 23
    assert query_capture == dict(left=[3, 4], right=[23, 24], calls=4, readings=[[10, 20], [], [], []])
    assert resource_capture == dict(values=[115, 116], calls=3, readings=[10, 20, 20])
    assert rows[1]['resourceCapture'] == rows[2]['resourceCapture']
    assert rows[2]['world']['resources'] == rows[3]['world']['resources']
    return rows


def expected():
    return derive('CapturedScheduleAlpha') + derive('CapturedScheduleBeta')


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
