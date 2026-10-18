"""Rebuild the immutable verbose grammar from decoded actual LC1 fields.

Only punctuation/declared constructor names are static. Every state value,
dynamic name, tree branch, ordered item and repeated record comes from input.
"""
import json
from primitives import Chars, InvalidLC1, Leaf, Node


def text(value: Chars) -> str:
    return value.ascii_bytes().decode('ascii')


def listing(values):
    return '[' + ', '.join(values) + ']'


def boolean(value):
    return 'True' if value else 'False'


def tree(value, leaf):
    if isinstance(value, Leaf):
        return 'leaf:' + leaf(value.value)
    if isinstance(value, Node):
        return 'node(' + tree(value.left, leaf) + ',' + tree(value.right, leaf) + ')'
    raise InvalidLC1('unknown decoded tree')


def key(value):
    return f"{value['index']}:{value['generation']}"


def handle(value):
    return f"{value['namespace']}:{key(value)}"


def optional(value, render):
    return 'None' if value is None else 'Some(' + render(value) + ')'


def payload(value):
    kind = value['kind']
    if kind == 'Position':
        return 'Position{' + tree(value['coordinates'], str) + ';' + str(value['frame']) + '}'
    if kind == 'Velocity':
        return 'Velocity{' + tree(value['rates'], str) + ';' + boolean(value['moving']) + '}'
    if kind == 'Selected':
        return 'Selected{' + str(value['group']) + '}'
    raise InvalidLC1('unknown decoded physical payload')


def allocator(value):
    phases = ['Consumed', 'Pending', 'Live', 'DeadRetained', 'Free']
    slots = tree(value['slots'], lambda slot: str(slot['generation']) + ':' + phases[slot['phase']])
    return (f"next={value['next']};high={value['high']};capacity={value['capacity']};"
            f"depth={value['depth']};slots=" + slots + ';free='
            + listing(map(str, value['free'])) + ';order=' + listing(key(v) for v in value['order']))


def column(value):
    if value['variant'] != 0:
        return text(value['legacy'])
    values = tree(value['values'], lambda v: 'none' if v is None else 'some(' + payload(v) + ')')
    stamps = listing(f"{v['id']}:{v['added']}:{v['changed']}" for v in value['stamps'])
    return 'Column{values=' + values + ';stamps=' + stamps + '}'


def access_names(values):
    return listing(text(value) for value in values)


def world(value):
    pending = ''.join(['Raw;', 'Observed;'][kind] for kind in value['pending_kinds']) + 'end'
    registrations = listing(str(v['id']) + ':' + text(v['name']) + ':' + access_names(v['access'])
                            for v in value['registrations'])
    return (f"namespace={value['namespace']}|allocator={{" + allocator(value['allocator'])
            + '}|store={main={' + column(value['main']) + '};aux={' + column(value['aux'])
            + '};flag={' + column(value['flag']) + '}}|resource={MotionLedger{'
            + tree(value['ledger']['totals'], str) + ';' + str(value['ledger']['epoch'])
            + '};sibling=Unit}|events=' + listing(map(str, value['events'])) + '|pending='
            + str(value['pending_count']) + ':' + pending + '|registrations=' + registrations
            + f"|nextSystem={value['next_system']}|clock={value['clock']}")


def reservation(value):
    if value['variant'] == 0:
        return 'Reserved(' + handle(value['handle']) + ')'
    return 'ReservationRefused(' + ['MissingEntity', 'CapacityExceeded', 'NamespaceExhausted',
                                   'SystemIdExhausted'][value['error']] + ')'


def frame(value):
    return (f"count={value['count']};iteration={value['iteration']};phase={value['phase']};target="
            + optional(value['target'], handle) + ';pending=' + optional(value['pending'], handle)
            + ';foreign=' + handle(value['foreign']) + ';stale='
            + listing(handle(v) for v in value['stale']) + ';reservations='
            + listing(reservation(v) for v in value['reservations']))


def local(value):
    return (f"namespace={value['namespace']};id={value['id']};name=" + text(value['name'])
            + ';access=' + access_names(value['access']) + ';owner=' + tree(value['capture'], str))


def four(values):
    if len(values) != 4:
        raise InvalidLC1('Four requires four fields')
    return dict(zip('abcd', values))


def view(value):
    kind = value['kind']
    if kind == 'Position':
        return {'coordinates': four(value['coordinates']), 'frame': value['frame']}
    if kind == 'Velocity':
        return {'rates': four(value['rates']), 'moving': value['moving']}
    if kind == 'Selected':
        return {'group': value['group']}
    raise InvalidLC1('unknown decoded view')


def compact_json(value):
    return json.dumps(value, separators=(',', ':'))


def access(value):
    if value['variant'] == 0:
        return 'Found(' + compact_json(view(value['value'])) + ')'
    return ['ComponentAbsent', 'MissingEntity'][value['variant'] - 1]


def row(value):
    return ('handle=' + handle(value['handle']) + ';main=' + access(value['main'])
            + ';aux=' + access(value['aux']) + ';flag=' + access(value['flag']))


def boundary(value):
    ledger = {'totals': four(value['ledger']['totals']), 'epoch': value['ledger']['epoch']}
    return ('Boundary{' + frame(value['frame']) + ';query=' + listing(row(v) for v in value['rows'])
            + ';ledger=' + compact_json(ledger) + ';lookups=' + compact_json(four(value['lookups']))
            + ';staleQueries=' + listing(handle(v['handle']) + '=' + str(v['kind']) for v in value['stale'])
            + ';before={' + world(value['before']) + '};after={' + world(value['after']) + '}}')


def output(value):
    return ('Some{' + frame(value['frame']) + ';boundary='
            + ('None' if value['boundary'] is None else boundary(value['boundary'])) + '}')


def call(value):
    return ('Call{' + ['Select', 'Reserve', 'Dispose', 'Observe'][value['operation']]
            + f";id={value['id']};status=" + ['Succeeded', 'Failed', 'Refused'][value['status']]
            + ';local={' + local(value['local']) + '};output='
            + ('None' if value['output'] is None else output(value['output'])) + '}')


def owners(value):
    names = ['select', 'reserve', 'dispose', 'observe']
    return (';'.join(name + '={' + local(value[name]) + '}' for name in names)
            + ';frame={' + frame(value['frame']) + '};digest=' + str(value['digest'])
            + ';boundaries=' + listing(boundary(v) for v in value['boundaries'])
            + ';calls=' + listing(call(v) for v in value['calls']))


def step(value):
    kind = value['variant']
    if kind == 0:
        return f"System({value['id']},{int(value['condition'])})"
    if kind == 1:
        return 'Phase(' + text(value['name']) + ')'
    return 'Barrier'


def observation(value):
    kind = value['variant']
    if kind == 0:
        return 'Entered(' + text(value['name']) + ')'
    if kind == 3:
        return 'Applied'
    return ['Ran', 'Skipped'][kind - 1] + '(' + str(value['id']) + ')'


def log(value):
    observed = optional(value['observations'], lambda vs: listing(observation(v) for v in vs))
    return ('Log{' + text(value['name']) + ';steps=' + listing(step(v) for v in value['steps'])
            + ';status=' + ['Complete', 'BodyFailed', 'Refused', 'Invalid'][value['status']]
            + ';observations=' + observed + '}')


def state(value):
    return (f"namespace={value['namespace']};ids=" + ','.join(map(str, value['ids']))
            + ';status=' + ['Complete', 'BodyFailed', 'Refused', 'Invalid'][value['status']]
            + ';world={' + world(value['world']) + '};foreignWorld={' + world(value['foreign'])
            + '};owners={' + owners(value['owners']) + '};scheduleRuns='
            + listing(log(v) for v in value['logs']))


def report(value):
    outcomes = ['Success', 'Failure(Unit)']
    return (f"LifecycleRuntime Motion\ncount={value['count']};iterations={value['iterations']}\n"
            + 'seedOutcome=' + outcomes[value['seed_outcome']] + ';reservations='
            + listing(reservation(v) for v in value['reservations'])
            + '\nseedPending={' + world(value['seed_pending']) + '}\nseedApplied={'
            + world(value['seed_applied']) + '}\nforeignSeedOutcome='
            + outcomes[value['foreign_outcome']] + ';reservation='
            + reservation(value['foreign_reservation']) + '\nforeignPending={'
            + world(value['foreign_pending']) + '}\nforeignApplied={' + world(value['foreign_applied'])
            + '}\nforeignOwnLookup=' + ['MissingEntity', 'ComponentAbsent', 'Found'][value['own_lookup']]
            + '\nforeignVerified={' + world(value['foreign_verified']) + '}\nregistered={'
            + state(value['registered']) + '}\nfinal={' + state(value['final']) + '}\n\n').encode('ascii')
