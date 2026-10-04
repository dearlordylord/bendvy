#!/usr/bin/env python3
"""Independent mixed-target FIFO observation contract; no Bend execution."""
import copy
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('storage_contract', HERE / 'storage-observation-contracts.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def apply_model(before, operations, tick):
    w = copy.deepcopy(before)
    changes = []
    def emit(kind, entity):
        changes.append({'kind': kind, 'handle': C.handle(w, entity)})
    for command in operations:
        entity = command['id']
        found = next((r for r in w['rows'] if r['id'] == entity), None)
        op = command['op']
        if op == 'spawn':
            assert found is None and 0 < entity < w['next']
            found = copy.deepcopy(command['row'])
            if found['main'] is not None:
                found['added'] = found['changed'] = tick
                emit('Added', entity)
                emit('Changed', entity)
            w['rows'].append(found)
        elif found is None:
            continue
        elif op == 'insert_main':
            if found['main'] is None:
                found['added'] = tick
                emit('Added', entity)
            found['main'] = copy.deepcopy(command['main'])
            found['changed'] = tick
            emit('Changed', entity)
        elif op == 'remove_main':
            if found['main'] is not None:
                found['main'] = None
                found['added'] = found['changed'] = 0
                emit('Removed', entity)
        elif op == 'despawn':
            if found['main'] is not None:
                emit('Removed', entity)
            emit('Despawned', entity)
            w['rows'].remove(found)
        else:
            raise AssertionError(op)
    w['rows'].sort(key=lambda r: r['id'])
    w['pending'] = []
    return {'snapshot': C.snapshot(w), 'changes': changes}


def fixture(schema):
    w = C.world(schema, 1)
    w['next'] = 8  # Seven genuine reservations are a runtime-fixture prerequisite.
    w['rows'] = [C.row(schema, 1, 10, True, True), C.row(schema, 3, None, True, True),
                 C.row(schema, 4, 50, flag=True), C.row(schema, 6, 60)]
    operations = [dict(op='insert_main', id=i, main=C.main_value(schema, x))
                  for i, x in [(4,71), (1,80), (3,30), (1,81), (2,90)]]
    operations += [dict(op='remove_main', id=4),
                   dict(op='insert_main', id=4, main=C.main_value(schema,72)),
                   dict(op='despawn', id=1),
                   dict(op='insert_main', id=1, main=C.main_value(schema,99)),
                   dict(op='spawn', id=7, row=C.row(schema,7,70,True,True))]
    return w, operations


def run():
    results = []
    for schema in ('Motion', 'Health'):
        before, operations = fixture(schema)
        valid = apply_model(before, operations, 8)
        assert [r['id'] for r in valid['snapshot']['world']['rows']] == [3,4,6,7]
        assert [(e['kind'], e['handle']['id']) for e in valid['changes']] == [
            ('Changed',4), ('Changed',1), ('Added',3), ('Changed',3), ('Changed',1),
            ('Removed',4), ('Added',4), ('Changed',4), ('Removed',1), ('Despawned',1),
            ('Added',7), ('Changed',7)]
        reverse_logs = copy.deepcopy(valid)
        reverse_logs['changes'].reverse()
        reordered = copy.deepcopy(valid)
        reordered['snapshot']['world']['rows'].reverse()
        reversed_fifo = apply_model(before, list(reversed(operations)), 8)
        predicate = lambda observed: observed == apply_model(before, operations, 8)
        results.append(C.check_case(schema + '/mixed-target-FIFO', predicate, valid,
                                   [('reversed-log', reverse_logs), ('physical-order', reordered),
                                    ('reversed-FIFO', reversed_fifo)]))
    return {'scope': 'preimplementation independent SI-CMD-FIFO mixed-target observation predicates',
            'runtimeExecuted': False, 'proof': False, 'cases': results,
            'rejectedObservations': sum(r['perturbedObservationsRejected'] for r in results)}


if __name__ == '__main__':
    print(json.dumps(run(), indent=2))
