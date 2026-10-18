"""Map independent actual model states to LC1 typed records, without text parsing."""
import copy
from primitives import Chars, Leaf, Node
import capture


def s(value):
    return Chars.from_ascii(value)


def physical(values, item):
    if len(values) == 1:
        return Leaf(item(values[0]))
    assert len(values) > 1 and len(values) & (len(values) - 1) == 0
    middle = len(values) // 2
    return Node(physical(values[:middle], item), physical(values[middle:], item))


def key(value):
    return {'index': value.index, 'generation': value.generation}


def handle(value):
    return dict(namespace=value.namespace, **key(value.key))


def maybe(value, project):
    return None if value is None else project(value)


def payload(value, kind):
    if kind == 'Vitals':
        return {'kind': kind, 'levels': physical(value, int), 'reserve': 9, 'class': 2}
    if kind == 'Armor':
        return {'kind': kind, 'layers': physical(value, int), 'grade': 3}
    return {'kind': kind, 'group': value}


def world(value):
    source = value.allocator
    phases = ['Consumed', 'Pending', 'Live', 'DeadRetained', 'Free']
    allocator = {
        'next': source.next, 'high': source.high, 'capacity': len(source.slots),
        'depth': len(source.slots).bit_length() - 1,
        'slots': physical(source.slots, lambda v: {'generation': v.generation, 'phase': phases.index(v.phase)}),
        'free': list(source.free), 'order': [key(v) for v in source.order],
    }
    columns = []
    for column, kind in zip(value.columns, ['Vitals', 'Armor', 'Tracked']):
        columns.append({
            'variant': 0,
            'values': physical(column.values, lambda v: maybe(v, lambda p: payload(p, kind))),
            'stamps': [{'id': i, 'added': column.stamps[i][0], 'changed': column.stamps[i][1]}
                       for i in column.order],
        })
    return {
        'namespace': value.namespace, 'allocator': allocator,
        'main': columns[0], 'aux': columns[1], 'flag': columns[2],
        'ledger': {'totals': physical(value.ledger, int), 'epoch': 4}, 'sibling': 0,
        'events': [], 'pending_count': len(value.pending),
        'pending_kinds': [0 for _ in value.pending],
        'registrations': [{'id': i, 'name': s(name), 'access': list(map(s, access))}
                          for i, name, access in value.registrations],
        'next_system': value.next_system, 'clock': value.clock,
    }


def reservation(value):
    return {'variant': 0, 'handle': handle(value)}


def frame(value):
    return {
        'count': value.count, 'iteration': value.iteration, 'phase': value.phase,
        'target': maybe(value.target, handle), 'pending': maybe(value.pending, handle),
        'foreign': handle(value.foreign), 'stale': list(map(handle, value.stale)),
        'reservations': list(map(reservation, value.reservations)),
    }


def local(program, index):
    identity = program.ids[index]
    _, name, access = next(v for v in program.world.registrations if v[0] == identity)
    return {'namespace': program.world.namespace, 'id': identity, 'name': s(name),
            'access': list(map(s, access)),
            'capture': physical([program.counts[index], 101 + index], int)}


def access(value, kind):
    if value is None:
        return {'variant': 1}
    if kind == 'Vitals':
        data = {'kind': kind, 'levels': list(value), 'reserve': 9, 'class': 2}
    elif kind == 'Armor':
        data = {'kind': kind, 'layers': list(value), 'grade': 3}
    else:
        data = {'kind': kind, 'group': value}
    return {'variant': 0, 'value': data}


def row(value):
    entity, main, aux, flag = value
    return {'handle': handle(entity), 'main': access(main, 'Vitals'),
            'aux': access(aux, 'Armor'), 'flag': access(flag, 'Tracked')}


def boundary(value):
    assert value.before.snapshot is not None and value.after.snapshot is not None
    return {
        'frame': frame(value.frame), 'rows': list(map(row, value.rows)),
        'ledger': {'totals': list(value.ledger), 'epoch': 4}, 'lookups': list(value.lookups),
        'stale': [{'handle': handle(h), 'kind': kind} for h, kind in value.stale],
        'before': world(value.before.snapshot), 'after': world(value.after.snapshot),
    }


def call(value):
    actual_local = {
        'namespace': value['namespace'], 'id': value['id'], 'name': s(value['name']),
        'access': list(map(s, value['access'])), 'capture': physical(value['capture'], int),
    }
    return {
        'operation': value['operation'], 'id': value['id'], 'status': value['status'],
        'local': actual_local,
        'output': {'frame': frame(value['frame']), 'boundary': maybe(value['boundary'], boundary)},
    }


def schedule(value):
    steps = []
    for entry in value['steps']:
        if entry[0] == 'Barrier':
            steps.append({'variant': 2})
        else:
            steps.append({'variant': 0, 'id': entry[1], 'condition': int(entry[2])})
    observed = []
    for entry in value['observations']:
        observed.append({'variant': 3} if entry[0] == 'Applied' else {'variant': 1, 'id': entry[1]})
    return {'name': s(value['name']), 'steps': steps, 'status': value['status'],
            'observations': observed}


def state(value):
    return {
        'namespace': value.world.namespace, 'ids': list(value.ids), 'status': 0,
        'world': world(value.world), 'foreign': world(value.foreign_world),
        'owners': {
            **{name: local(value, i) for i, name in enumerate(['select', 'reserve', 'dispose', 'observe'])},
            'frame': frame(value.frame), 'digest': value.digest,
            'boundaries': list(map(boundary, value.boundaries)),
            'calls': list(map(call, value.typed_calls)),
        },
        'logs': list(map(schedule, value.typed_logs)),
    }


def report(count=64, iterations=64):
    values = capture.run(count, iterations)
    result = {'count': count, 'iterations': iterations}
    for name in ['seed_pending', 'seed_applied', 'foreign_pending', 'foreign_applied', 'foreign_verified']:
        result[name] = world(values[name])
    result.update(seed_outcome=values['seed_outcome'], foreign_outcome=values['foreign_outcome'],
                  reservations=list(map(reservation, values['reservations'])),
                  foreign_reservation=reservation(values['foreign_reservation']),
                  own_lookup=values['own_lookup'], registered=state(values['registered']), final=state(values['final']))
    return result


def selftest():
    import verbose
    values = capture.run()
    for phase in ['seed_pending', 'seed_applied', 'foreign_pending', 'foreign_applied', 'foreign_verified']:
        assert verbose.world(world(values[phase])) == values[phase].wire()
    for phase in ['registered', 'final']:
        assert verbose.state(state(values[phase])) == values[phase].wire()
    return True


if __name__ == '__main__':
    assert selftest()
    print('PASS typed records expand to immutable Health64 state wire')
