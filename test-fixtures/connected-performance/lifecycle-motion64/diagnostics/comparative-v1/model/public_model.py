"""Public Lifecycle projections from fresh original typed operation captures."""
import copy
from pathlib import Path
import sys
SOURCE = Path(__file__).resolve().parents[3] / 'model'
sys.path.insert(0, str(SOURCE))
import common_model as C
from ts_model import full as original_ts_full

def raw(handle):
    return None if handle is None else dict(namespace=handle.namespace, index=handle.key.index,
                                            generation=handle.key.generation)

def frame(value):
    return dict(count=value.count, iteration=value.iteration, phase=value.phase,
                target=raw(value.target), pending=raw(value.pending), foreign=raw(value.foreign),
                stale=[raw(h) for h in value.stale],
                reservations=[dict(kind='Reserved', handle=raw(h)) for h in value.reservations])

def boundary(value, actor):
    f = value.frame
    return dict(kind='Boundary', iteration=f.iteration, phase=f.phase, target=actor(f.target),
                current=actor(f.pending), reservations=[actor(h) for h in f.reservations],
                rows=[C.row(row, actor) for row in value.rows], ledger=C.ledger(value.ledger),
                currentKind=value.lookups[0], targetKind=value.lookups[1],
                stale=[dict(actor=actor(h), kind=k) for h, k in value.stale])

def variant(value):
    kind, *fields = value
    if kind == 'System':
        return dict(kind=kind, id=fields[0], condition=int(fields[1]))
    if kind in ['Ran', 'Skipped']:
        return dict(kind=kind, id=fields[0])
    if kind in ['Entered', 'Phase']:
        return dict(kind=kind, name=fields[0])
    assert kind in ['Barrier', 'Applied'] and not fields
    return dict(kind=kind)

def bend_public(f):
    p = f['captured']['final']
    keys = list(p.initial_handles) + list(p.frame.reservations)
    assert len(keys) == len(set(keys))
    mapping = {h: i + 1 for i, h in enumerate(keys)}
    def actor(h):
        return None if h is None else mapping[h]
    calls = []
    for call in p.typed_calls:
        value = call['boundary']
        returned_boundary = None if value is None else dict(
            common=boundary(value, actor),
            details=dict(frame=frame(value.frame), lookups=list(value.lookups)))
        calls.append(dict(operation=['Select','Reserve','Dispose','Observe'][call['operation']],
                          id=call['id'], status=['Succeeded','Failed','Refused'][call['status']],
                          output=dict(frame=frame(call['frame']), boundary=returned_boundary)))
    schedules = [dict(name=log['name'], steps=[variant(v) for v in log['steps']],
                      status=dict(kind=['Complete','BodyFailed','Refused','Invalid'][log['status']]),
                      observations=None if log['observations'] is None else
                      [variant(v) for v in log['observations']]) for log in p.typed_logs]
    assert len(calls) == len(schedules) == 384
    return dict(calls=calls, schedules=schedules)

def ts_public(f):
    observations = original_ts_full(f)['method']['observations']
    out = []
    for value in observations:
        pending = value['current'] if value['phase'] == 0 else None
        first_pending = None if pending is None else dict(
            rawId=pending['rawId'], result=dict(kind=pending['result']['kind']))
        first_stale = [dict(rawId=s['rawId'], result=dict(kind=s['result']['kind']))
                       for s in value['stale']]
        # Pinned view getters do not advance reader/resource state. No writes
        # intervene between these original first and repeated public reads.
        out.append(dict(iteration=value['iteration'], phase=value['phase'],
                        rows=copy.deepcopy(value['rows']), firstLedger=copy.deepcopy(value['ledger']),
                        firstPending=first_pending, firstStale=first_stale,
                        foreignChecked=copy.deepcopy(value['foreign']), ledger=copy.deepcopy(value['ledger']),
                        current=copy.deepcopy(value['current']), target=copy.deepcopy(value['target']),
                        stale=copy.deepcopy(value['stale']), foreign=copy.deepcopy(value['foreign'])))
    assert len(out) == 192
    return dict(boundaries=out)
