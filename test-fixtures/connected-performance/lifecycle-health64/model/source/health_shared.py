"""Pinned TS logical Lifecycle evaluation and explicit actor/full-key relation.

This does not normalize any canonical wire. Actors label reservation sequence;
canonical physical keys and generations remain separate complete observations.
"""
import hashlib
import json
from health_program import fields, mix


def row(actor, index, seeded=True):
    return {'rawId': actor, 'main': {'levels': [index, index + 1, index + 2, index + 3], 'reserve': 9, 'class': 2},
            'aux': {'layers': [1, 2, 3, 4], 'grade': 3} if seeded and index % 3 == 0 else None,
            'flag': {'group': 8} if seeded and index % 3 == 1 else None}


def query_hash(rows):
    hashes = []
    for value in rows:
        main = mix(mix(fields(value['main']['levels']), value['main']['reserve']), value['main']['class'])
        aux = 0 if value['aux'] is None else mix(fields(value['aux']['layers']), value['aux']['grade'])
        flag = 0 if value['flag'] is None else mix(1, value['flag']['group'])
        hashes.append(fields([1, value['rawId'], main, aux, flag]))
    return mix(fields(hashes), 0)


def evaluate(count=64, iterations=64, foreign_collision=True):
    live = {index + 1: row(index + 1, index) for index in range(count)}
    stale, reservations, boundaries = [], [], []
    total = 1
    for iteration in range(iterations):
        ordered = sorted(live)
        target = ordered[[0, count // 2, count - 1][iteration % 3]]
        pending = count + iteration + 1
        reservations.append(row(pending, iteration, False))
        for phase in range(3):
            if phase == 1:
                live[pending] = row(pending, iteration, False)
            elif phase == 2:
                stale.append(target)
                del live[target]
            rows = [live[actor] for actor in sorted(live)]
            lookups = [2 if pending in live else 0, 2 if target in live else 0,
                       2 if foreign_collision and 1 in live else 0, 0]
            history = [(actor, 2 if actor in live else 0) for actor in stale]
            stale_hash = mix(fields(fields([1, actor, kind]) for actor, kind in history), 0)
            observation_hash = fields([iteration, phase, query_hash(rows), fields([0, 101, 102, 103, 4]),
                                       fields(lookups), stale_hash])
            total = mix(total, observation_hash)
            boundaries.append({'iteration': iteration, 'phase': phase, 'rows': rows,
                               'lookups': lookups, 'stale': history})
    return {'boundaries': boundaries, 'reservations': reservations,
            'finalRows': [live[actor] for actor in sorted(live)], 'digest': total,
            'captures': [iterations, iterations, iterations, iterations * 3]}


def compare_program(program):
    expected = evaluate(program.frame.count, program.frame.iteration)
    # Each actual initial or returned reservation gets one immutable actor label.
    actual_actors = {value: index + 1 for index, value in enumerate(program.initial_handles)}
    for index, value in enumerate(program.frame.reservations, program.frame.count + 1):
        assert value not in actual_actors
        actual_actors[value] = index
    for actual, logical in zip(program.boundaries, expected['boundaries']):
        rows = []
        for entity, main, aux, flag in actual.rows:
            rows.append({'rawId': actual_actors[entity], 'main': {'levels': main, 'reserve': 9, 'class': 2},
                         'aux': None if aux is None else {'layers': aux, 'grade': 3},
                         'flag': None if flag is None else {'group': flag}})
        assert rows == logical['rows']
        assert actual.ledger == [0, 101, 102, 103]
        assert actual.lookups[:2] == logical['lookups'][:2] and actual.lookups[3] == logical['lookups'][3] == 0
        assert actual.lookups[2] == 0  # Genuine foreign namespace is rejected in Bend.
        assert [(actual_actors[value], kind) for value, kind in actual.stale] == logical['stale']
    assert len(program.boundaries) == len(expected['boundaries'])
    assert program.counts == expected['captures']
    return expected


def selftest():
    value = evaluate()
    assert value['digest'] == 4169183990
    assert evaluate(foreign_collision=False)['digest'] == 4220957302
    assert len(value['boundaries']) == 192
    assert sum(len(boundary['stale']) for boundary in value['boundaries']) == 6112
    assert len(value['finalRows']) == 64
    return True


if __name__ == '__main__':
    assert selftest()
    value = evaluate()
    print('PASS pinned TS logical model', value['digest'], hashlib.sha256(json.dumps(value['finalRows'], separators=(',', ':')).encode()).hexdigest())
