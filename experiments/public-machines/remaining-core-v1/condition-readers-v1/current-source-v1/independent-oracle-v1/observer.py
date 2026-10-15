"""Exact Data projection of checked current-source-v1/observer.bend.

Registry records and actual allocated IDs are inputs from final source modeling.
No backend stdout or metadata catalog supplies values.
"""
from stream import listing


def boolean(value):
    return str(value).lower()


def level(value):
    return {'Low': '0', 'Middle': '1', 'High': '2'}[value]


def transition(value, show):
    if value.startswith('initial:'):
        return 'Initial>' + show(value[8:])
    old, new = value.split('>')
    return show(old) + '>' + show(new)


def stream(value, show):
    batches = listing([str(at) + ':' + listing([transition(event, show)]) for at, event in value.batches])
    positions = listing([f'{identity}:{cursor}:{registered}' for identity, cursor, registered in value.positions])
    return f'batches={batches},positions={positions},dropped={value.dropped},frameStart={value.frame_start}'


def machine(value, show):
    if value.value is None:
        slot = 'missing'
    else:
        pending = 'none' if value.pending is None else show(value.pending) + ':false'
        previous = 'none' if value.previous is None else show(value.previous)
        slot = show(value.value) + f'(pending={pending},previous={previous},changed={boolean(value.changed)})'
    return slot + ';stream=' + stream(value.stream, show) + f';revision={value.revision}'


def world(app, registrations, namespace=1):
    metadata = listing([f'{identity}:{name}:{listing(access)}' for identity, name, access in reversed(registrations)])
    return (f'ns={namespace};next=1;high=0;capacity=1;depth=0;live=[false];cells=[none]:stamps=[];'
            + 'flow=' + machine(app.flow, lambda value: value) + ';level=' + machine(app.level, level)
            + ';queue=0;registrations=' + metadata + f';nextSystem={len(registrations)+1};componentClock={app.clock};busEvents=0')


def registry(namespace, identity, name, access, cursor):
    return f'{namespace}:{identity}:{name}:{listing(access)}:{cursor}'


def reading(value, show):
    if value is None:
        return 'none'
    values, lagged = value
    return listing([transition(event, show) for event in values]) + ':lagged=' + boolean(lagged)


def reader(value, show):
    namespace, identity, name, access, cursor, stream_namespace, stream_id, last = value
    return ('registry=' + registry(namespace, identity, name, access, cursor)
            + f';reader={stream_namespace}:{stream_id};last=' + reading(last, show))


def owners(fast, slow):
    return 'fast={' + reader(fast, level) + '};slow={' + reader(slow, lambda value: value) + '}'


def changed(instance, namespace, identity, name, access):
    return registry(namespace, identity, name, access, instance.cursor) + f';revision={instance.revision}'


def bindings(app, fast_id, slow_id, fast_changed, slow_changed):
    fast = f'system={fast_id};wanted=Play;changed={{{changed(app.fast_changed_level, *fast_changed)}}}'
    slow = f'system={slow_id};wanted=2;changed={{{changed(app.slow_changed_flow, *slow_changed)}}}'
    return 'fast={' + fast + '};slow={' + slow + '}'


def selftest():
    assert transition('initial:High', level) == 'Initial>2'
    assert transition('Boot>Play', lambda value: value) == 'Boot>Play'
    assert reading((['initial:Low'], False), level) == '[Initial>0]:lagged=false'
    assert reading(None, level) == 'none'


if __name__ == '__main__':
    selftest()
    print('Checked observer projection invariants PASS; IDs await final main')
