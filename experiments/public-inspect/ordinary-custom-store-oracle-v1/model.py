"""Independent source-only ordinary custom Store model; full consumer pending freeze.

No runtime output is an input. State fixtures and exact printing will be bound
only to the frozen consumer. These primitives mirror existing public traversal.
"""


def alive_handles(world):
    # World.collect_tail traverses highWater..1 and prepends, yielding ascending.
    return [(world['namespace'], i) for i in range(1, world['highWater'] + 1)
            if world['live'][i]]


def population(world, entries, columns, enabled=True):
    if not enabled:
        return None
    handles = alive_handles(world)
    return {'alive': len(handles), 'components': [
        {'key': key, 'count': sum(i in columns[key] for _, i in handles)}
        for kind, key in entries if kind == 'component']}


def filtered_dump(world, entries, columns, resources, show, ids=None,
                  required=(), limit=None, enabled=True):
    if not enabled:
        return None
    handles = alive_handles(world)
    rows = []
    for namespace, entity in handles:
        if limit is not None and len(rows) >= limit:
            break
        if ids is not None and entity not in ids:
            continue
        if not all(entity in columns.get(key, {}) for key in required):
            continue
        rows.append({'entity': (namespace, entity), 'components': [
            {'key': key, 'value': show(key, columns[key][entity])}
            for kind, key in entries
            if kind == 'component' and entity in columns[key]]})
    # Existing resource traversal is global, even at component limit zero.
    return {'alive': len(handles), 'rows': rows, 'resources': [
        {'key': key, 'value': show(key, resources[key])}
        for kind, key in entries if kind == 'resource' and key in resources]}
