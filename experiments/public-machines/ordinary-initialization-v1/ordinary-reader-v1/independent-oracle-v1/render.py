"""Exact List.show/String concatenation projection used by the consumer.

No JSON normalization: callback strings and nested lists keep their literal
ordering and comma-space separators. Affine world/registry owners are not copied
by the Bend observer; only its returned executable Data projection is modeled.
"""
from state import boolean, listing


def slot(state):
    if state.current is None:
        return 'missing'
    pending = '-' if state.pending is None else state.pending + '/skip=false'
    previous = state.previous or '-'
    return f'present:{state.current}/pending={pending}/previous={previous}/changed={boolean(state.changed)}'


def stream(state):
    batches = listing(f'{tick}:{listing([value])}' for tick, value in state.batches)
    positions = listing(':'.join(map(str, position)) for position in state.positions)
    return f'batches={batches}/positions={positions}/dropped={state.dropped}/frameStart={state.frame_start}'


def resource(state):
    return (f'slot={slot(state)};revision={state.revision};defaults={state.defaults};'
            f'callbackLog=[];failEnter={boolean(state.failure)};stream={stream(state)}')


def world(state, registrations, namespace=1):
    # W.create's empty arrays are ALeaf arrays with one physical slot. The
    # consumer passes Array.new(U32,0n,0) as its concrete store constructor.
    metadata = listing(f'{identity}:{name}:{listing(access)}' for identity, name, access in reversed(registrations))
    return (f'world{{ns={namespace};nextId=1;highWater=0;live=[false];capacity=1;depth=0;'
            f'store=[0];resource={{{resource(state)}}};events={listing(state.events)};pending=0;'
            f'registrations={metadata};nextSystemId={len(registrations) + 1};clock={state.clock}}}')


def watchers(state, namespace=1, ids=(5, 6)):
    values = []
    for index, name in enumerate(('fast', 'slow')):
        values.append(f'{name}={namespace}:{ids[index]}:machine.changed.{name}:'
                      f'[machine.machine.state.changed]:cursor={state.watch_cursors[index]}:'
                      f'revision={state.watch_revisions[index]}')
    return ';'.join(values)


STEPS = ['barrier', 'phase:apply', 'system:1:0', 'phase:exit', 'system:2:0',
         'phase:transition', 'system:3:0', 'phase:enter', 'system:4:0']
OBSERVATIONS = ['applied', 'entered:apply', 'ran:1', 'entered:exit', 'ran:2',
                'entered:transition', 'ran:3', 'entered:enter', 'ran:4']


def snapshot(label, state, registrations, status='Completed', marker=False):
    return (f'{label}:{status};steps={listing(STEPS if marker else [])};'
            f'observations={listing(OBSERVATIONS if marker else [])};'
            f'{world(state, registrations)};watchers{{{watchers(state)}}}')
