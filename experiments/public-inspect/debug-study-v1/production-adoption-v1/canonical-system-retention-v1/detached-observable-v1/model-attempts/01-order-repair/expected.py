"""Independent fixture model; no compiler output or generated query trace input."""
from copy import deepcopy
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def observation(snapshot, swap_without=False):
    world = snapshot['world']
    cells = {name: {cell['id']: cell for cell in column['cells']}
             for name, column in world['columns'].items()}

    def access(name, entity):
        payload = cells[name][entity]['payload']
        if 'Some' not in payload:
            return {'ComponentAbsent': {}}
        return {'Found': deepcopy(payload['Some'])}

    base, added, changed, without, with_health = [], [], [], [], []
    # Existing World enumeration lists live identities in descending order.
    for entity in range(world['highWater'], 0, -1):
        if not world['liveBits'][entity]:
            continue
        if any('Some' not in cells[name][entity]['payload']
               for name in ('position', 'velocity')):
            continue
        product = {'left': {'left': access('position', entity),
                            'right': access('velocity', entity)},
                   'right': access('health', entity)}
        handle = {'namespace': world['namespace'], 'id': entity}
        base.append({'entity': handle, 'data': product})
        filtered = {'entity': handle,
                    'data': {'left': product, 'right': {'Unit': {}}}}
        stamp = cells['position'][entity]['stamp']
        if stamp['added'] > 0:
            added.append(deepcopy(filtered))
        if stamp['changed'] > 0:
            changed.append(deepcopy(filtered))
        health_present = 'Some' in cells['health'][entity]['payload']
        if health_present == swap_without:
            without.append(deepcopy(filtered))
        if health_present:
            with_health.append(deepcopy(filtered))
    return {'cursor': 0, 'base': base, 'added': added, 'changed': changed,
            'without': without, 'withHealth': with_health}


def expected(handler_drop=False, inspector_swap=False):
    name = 'historical-drop-handlers-expected.json' if handler_drop else 'historical-expected.json'
    whole = json.loads((HERE / name).read_text())
    inventory = whole['Reported']['report']['previous']['inventory']
    for category, result in inventory.items():
        original = result['Reported']['report']
        snapshot = original['observations'][-1]
        observed = observation(snapshot, inspector_swap and category == 'plain')
        before, after = deepcopy(snapshot), deepcopy(snapshot)
        before['label'] = 'before-detached-observations'
        after['label'] = 'after-detached-observations'
        result['Reported']['detached'] = [{'Some': observed},
                                         {'Some': deepcopy(observed)},
                                         {'None': {}},
                                         {'Some': deepcopy(observed)}]
        result['Reported']['detachedOwners'] = [before, after]
    return whole


def historical_projection(whole):
    whole = deepcopy(whole)
    inventory = whole['Reported']['report']['previous']['inventory']
    for result in inventory.values():
        del result['Reported']['detached']
        del result['Reported']['detachedOwners']
    return whole


def write_models():
    result = {}
    for role, kwargs, historical in (
            ('normal', {}, 'historical-expected.json'),
            ('handler-drop', {'handler_drop': True}, 'historical-drop-handlers-expected.json'),
            ('inspector-filter', {'inspector_swap': True}, 'historical-expected.json')):
        value = expected(**kwargs)
        baseline = json.loads((HERE / historical).read_text())
        assert historical_projection(value) == baseline
        raw = (json.dumps(value, indent=2) + '\n').encode()
        (HERE / (role + '-expected.json')).write_bytes(raw)
        result[role] = {'sha256': hashlib.sha256(raw).hexdigest(),
                        'historicalWholePreserved': True}
    assert expected() != expected(inspector_swap=True)
    result['status'] = 'PRE_RUNTIME_MODEL_ONLY'
    result['fixtureCursor'] = 0
    result['registeredCursorBorrow'] = False
    (HERE / 'MODEL-CHECKS.json').write_text(json.dumps(result, indent=2) + '\n')


if __name__ == '__main__':
    write_models()
