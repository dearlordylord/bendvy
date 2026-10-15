"""Source-only mirror of observer.bend's complete pure debug serializers.

Inputs are the executable Data fields derived by the final finite source model,
not backend text. Preserve authored order, every requirement and placement,
including condition leaves with real registry identity.
"""
from stream import listing
from observer import boolean, registry


def condition_leaf(leaf):
    kind, *fields = leaf
    if kind == 'StateChanged':
        namespace, identity, name, access = fields
        return f'changed({namespace}:{identity}:{name}:{listing(access)})'
    if kind == 'InState':
        return 'in(' + fields[0] + ')'
    assert kind == 'Constant'
    return 'constant(' + boolean(fields[0]) + ')'


def condition_description(value):
    name, access, leaves = value
    return name + ':' + listing(access) + ':' + listing([condition_leaf(leaf) for leaf in leaves])


def condition_binding(value):
    identity, description = value
    return str(identity) + ':' + condition_description(description)


def condition_placement(value):
    position, namespace, identity, slot, description = value
    return f'{position}:{namespace}:{identity}:{slot}:' + ('none' if description is None else condition_description(description))


def requirements(values):
    return listing([kind + ':' + str(identity) for kind, identity in values])


def step(value):
    kind, *fields = value
    if kind == 'System':
        return f'system:{fields[0]}:{fields[1]}'
    if kind == 'Phase':
        return 'phase:' + fields[0]
    assert kind == 'Barrier'
    return 'barrier'


def planned_step(value):
    current, needs = value
    return step(current) + ':' + requirements(needs)


def placement(value):
    kind, position, *fields = value
    if kind == 'System':
        namespace, identity, name, condition, needs = fields
        return f'{position}:system:{namespace}:{identity}:' + ('none' if name is None else name) + f':{condition}:' + requirements(needs)
    if kind == 'Phase':
        name, needs = fields
        return f'{position}:phase:{name}:' + requirements(needs)
    assert kind == 'Barrier'
    return f'{position}:barrier:' + requirements(fields[0])


def debug_binding(value):
    namespace, identity, name, access, cursor, slot, clauses = value
    return registry(namespace, identity, name, access, cursor) + ':' + slot + ':' + listing([name + ':' + mode for name, mode in clauses])


def schema_entry(value):
    category, key, name, *policy = value
    return category + ':' + key + ':' + name + (':' + policy[0] if policy else '')


def application(value):
    schema, bindings, rows, rendered = value
    return ('schema=' + listing([schema_entry(entry) for entry in schema])
            + ';bindings=' + listing([debug_binding(binding) for binding in bindings])
            + ';rows={' + rows + '};rendered=' + listing(rendered))


def schedule_description(value):
    app, namespace, name, steps = value
    return ('application={' + application(app) + f'}};namespace={namespace};name={name};steps='
            + listing([planned_step(current) for current in steps]))


def detailed_description(value):
    original, placements = value
    return schedule_description(original) + ';placements=' + listing([placement(current) for current in placements])


def debug(value):
    if value is None:
        return 'disabled'
    original, bindings, placements = value
    return (detailed_description(original)
            + ';conditions=' + listing([condition_binding(binding) for binding in bindings])
            + ';conditionPlacements=' + listing([condition_placement(current) for current in placements]))


def schedule_observations(values):
    names = {'Entered': 'entered', 'Ran': 'ran', 'Skipped': 'skipped'}
    return listing(['applied' if kind == 'Applied' else names[kind] + ':' + str(value) for kind, value in values])


def selftest():
    assert condition_leaf(('InState', 'Flow')) == 'in(Flow)'
    assert condition_leaf(('Constant', False)) == 'constant(false)'
    assert requirements([('component', 1), ('resource', 2), ('service', 3)]) == '[component:1, resource:2, service:3]'
    assert planned_step((('Barrier',), [])) == 'barrier:[]'
    assert condition_placement((0, 1, 3, 7, None)) == '0:1:3:7:none'
    assert debug(None) == 'disabled'
    assert schedule_observations([('Ran', 1), ('Skipped', 2), ('Applied', None)]) == '[ran:1, skipped:2, applied]'


if __name__ == '__main__':
    selftest()
    print('Complete debug projection invariants PASS; final main not bound')
