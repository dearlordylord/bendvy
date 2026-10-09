"""Complete preoutput input-codec model, derived from dd375d8a sources only."""
import copy
import json
from pathlib import Path

def c(tag, **fields):
    return {'$': tag, **fields}

def number(value): return c('Number', value=value)
def text(value): return c('Text', value=value)
def saved(x, y):
    return c('Object', fields=[c('Field', name='x', value=number(x)), c('Field', name='y', value=number(y))])
def some(value): return c('Some', value=value)
def incoming(raw): return c('InputView', raw=copy.deepcopy(raw), words=[71, 72], flags=[True, False])
def owner(x, y, original=None, built=False):
    return c('View', x=x, y=y, raw=saved(x, y), original=copy.deepcopy(saved(x, y) if original is None else original),
             words=[71, 72] if built else [81, 82], flags=[True, False] if built else [False, True])

ACCESS = ['constructed-raw-owner', 'constructed-raw-resource']
REGISTRATION = c('RegistrationMeta', id=1, name='constructed-materialization', access=ACCESS)

def snapshot(reserved=False, published=False):
    # Seed actual id1 replacement advances clock1. Reservation id2 is monotonic,
    # survives abort and grows liveness capacity independently of column slots.
    return c('Snapshot',
        meta=c('Meta', namespace=1, nextId=3 if reserved else 2, highWater=2 if reserved else 1,
               capacity=4 if reserved else 2, depth=2 if reserved else 1, events=[],
               registrations=[copy.deepcopy(REGISTRATION)], nextSystemId=2, clock=2 if published else 1),
        live=[False, True, published, False] if reserved else [False, True],
        column=c('ColumnView', supported=True,
            slots=[some(owner(7, 99)), some(owner(7, 8, text('7,8'), True))] if published else [some(owner(7, 99))],
            stamps=[c('Entry', id=2, stamp=c('Stamp', added=2, changed=2)),
                    c('Entry', id=1, stamp=c('Stamp', added=1, changed=1))] if published else
                   [c('Entry', id=1, stamp=c('Stamp', added=1, changed=1))]),
        mail=c('MailView', value=owner(7, 100), retired=[], returned=[], errors=[]), pending=0)

def invalid(raw, path, expected):
    return c('Invalid', path=path, expected=expected, actual=copy.deepcopy(raw))

def report(mode):
    raw = text('7;q') if mode == 'parseRefusal' else number(7) if mode == 'wrongKind' else text('9,8') if mode == 'downstreamRefusal' else text('7,8')
    reserved = mode in ('success', 'failure')
    before = snapshot()
    committed = snapshot(reserved)
    barrier = snapshot(reserved, mode == 'success')
    if mode == 'success': committed['pending'] = 2  # actual activation then delivery
    output = c('Accepted', target=c('Handle', namespace=1, id=2), spawned=True,
               canonical=saved(7, 8), undoAvailable=True)
    if mode == 'parseRefusal':
        error = c('Construction', error=c('Constructor', error=c('ParseError', raw=raw)))
        output = c('Refused', owner=some(incoming(raw)), error=error)
    elif mode == 'wrongKind':
        error = c('Construction', error=c('Validation', error=invalid(raw, '$', 'string')))
        output = c('Refused', owner=some(incoming(raw)), error=error)
    elif mode == 'downstreamRefusal':
        error = c('Operation', error=c('Validation', error=invalid(number(9), '$.x', 'literal')))
        output = c('Refused', owner=some(incoming(raw)), error=error)
    recoveries = []
    if mode == 'failure':
        # Request.project supplies saved Object as packet original, while the
        # actual P retains its different text original plus affine sentinels.
        packet = c('PacketView', owner=some(owner(7, 8, text('7,8'), True)),
                   original=saved(7, 8), canonical=saved(7, 8))
        recoveries = [c('RecoveryView', output=copy.deepcopy(output), packets=[packet])]
    instance = c('InstanceView', namespace=1, id=1, name='constructed-materialization',
                 access=copy.deepcopy(ACCESS), recoveries=recoveries)
    result = c('Failed', error=c('Unit')) if mode == 'failure' else c('Skipped', input=incoming(raw)) if mode == 'skip' else c('Completed', output=output)
    return c('Report', before=before, committed=committed, barrier=barrier, instance=instance, result=result)

def expected():
    cases = c('Cases', **{mode: report(mode) for mode in
              ('success', 'parseRefusal', 'wrongKind', 'downstreamRefusal', 'failure', 'skip')})
    return c('Candidate', first=copy.deepcopy(cases), second=copy.deepcopy(cases))

if __name__ == '__main__':
    Path(__file__).with_name('expected.json').write_text(json.dumps(expected(), indent=2) + '\n')
