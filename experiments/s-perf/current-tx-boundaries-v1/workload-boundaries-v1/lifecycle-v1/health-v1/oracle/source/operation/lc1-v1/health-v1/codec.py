"""Independent closed LC1 Health schema; pending final source-freeze binding."""
from primitives import (Chars, InvalidLC1, Leaf, Node, Reader, encode_bool,
                        encode_nat, encode_string, encode_u32)


def record(tag, *fields):
    return ('record', tag.encode('ascii'), fields)


def sequence(item):
    return ('list', item)


def option(item):
    return ('option', item)


def tree(item):
    return ('tree', item)


def enum(maximum):
    return ('enum', maximum)


SCHEMAS = {}
SCHEMAS['Key'] = record('k', ('index', 'u'), ('generation', 'u'))
SCHEMAS['Handle'] = record('K', ('namespace', 'u'), ('index', 'u'), ('generation', 'u'))
SCHEMAS['Slot'] = record('z', ('generation', 'u'), ('phase', enum(4)))
SCHEMAS['Stamp'] = record('e', ('id', 'u'), ('added', 'u'), ('changed', 'u'))
SCHEMAS['Registration'] = record('g', ('id', 'u'), ('name', 's'), ('access', sequence('s')))
SCHEMAS['Vitals'] = record('P', ('levels', tree('u')), ('reserve', 'u'), ('class', 'u'))
SCHEMAS['Armor'] = record('V', ('layers', tree('u')), ('grade', 'u'))
SCHEMAS['Tracked'] = record('G', ('group', 'u'))
SCHEMAS['Ledger'] = record('J', ('totals', tree('u')), ('epoch', 'u'))
SCHEMAS['Four'] = ('four',)
SCHEMAS['VitalsView'] = record('p', ('levels', 'Four'), ('reserve', 'u'), ('class', 'u'))
SCHEMAS['ArmorView'] = record('v', ('layers', 'Four'), ('grade', 'u'))
SCHEMAS['LedgerView'] = record('j', ('totals', 'Four'), ('epoch', 'u'))
SCHEMAS['Allocator'] = record('A', ('next', 'u'), ('high', 'u'), ('capacity', 'u'),
                              ('depth', 'n'), ('slots', tree('Slot')),
                              ('free', sequence('u')), ('order', sequence('Key')))
SCHEMAS['World'] = record('W', ('namespace', 'u'), ('allocator', 'Allocator'),
    ('main', ('column', 'Vitals')), ('aux', ('column', 'Armor')), ('flag', ('column', 'Tracked')),
    ('ledger', 'Ledger'), ('sibling', 'unit'), ('events', sequence('n')), ('pending_count', 'n'),
    ('pending_kinds', sequence(enum(1))), ('registrations', sequence('Registration')),
    ('next_system', 'u'), ('clock', 'u'))
SCHEMAS['Reservation'] = ('reservation',)
SCHEMAS['Frame'] = record('F', ('count', 'u'), ('iteration', 'u'), ('phase', 'u'),
    ('target', option('Handle')), ('pending', option('Handle')), ('foreign', 'Handle'),
    ('stale', sequence('Handle')), ('reservations', sequence('Reservation')))
SCHEMAS['Local'] = record('L', ('namespace', 'u'), ('id', 'u'), ('name', 's'),
                          ('access', sequence('s')), ('capture', tree('u')))
SCHEMAS['Row'] = record('r', ('handle', 'Handle'), ('main', ('access', 'VitalsView')),
                       ('aux', ('access', 'ArmorView')), ('flag', ('access', 'Tracked')))
SCHEMAS['Seen'] = record('d', ('handle', 'Handle'), ('kind', enum(2)))
SCHEMAS['Boundary'] = record('B', ('frame', 'Frame'), ('rows', sequence('Row')),
    ('ledger', 'LedgerView'), ('lookups', 'Four'), ('stale', sequence('Seen')),
    ('before', 'World'), ('after', 'World'))
SCHEMAS['Output'] = record('O', ('frame', 'Frame'), ('boundary', option('Boundary')))
SCHEMAS['Call'] = record('R', ('operation', enum(3)), ('id', 'u'), ('status', enum(2)),
                         ('local', 'Local'), ('output', option('Output')))
SCHEMAS['Owners'] = record('N', ('select', 'Local'), ('reserve', 'Local'), ('dispose', 'Local'),
    ('observe', 'Local'), ('frame', 'Frame'), ('digest', 'u'),
    ('boundaries', sequence('Boundary')), ('calls', sequence('Call')))
SCHEMAS['Step'] = ('step',)
SCHEMAS['Observation'] = ('observation',)
SCHEMAS['Log'] = record('t', ('name', 's'), ('steps', sequence('Step')), ('status', enum(3)),
                        ('observations', option(sequence('Observation'))))
SCHEMAS['State'] = record('T', ('namespace', 'u'), ('ids', ('fixed', 4, 'u')),
    ('status', enum(3)), ('world', 'World'), ('foreign', 'World'), ('owners', 'Owners'),
    ('logs', sequence('Log')))


def resolve(schema):
    return SCHEMAS.get(schema, schema) if isinstance(schema, str) else schema


def emit(schema, value):
    schema = resolve(schema)
    if schema == 'u':
        yield encode_u32(value)
    elif schema == 'n':
        yield encode_nat(value)
    elif schema == 'bool':
        yield encode_bool(value)
    elif schema == 's':
        yield encode_string(value)
    elif schema == 'unit':
        if value != 0:
            raise InvalidLC1('unknown Unit constructor')
        yield b'0'
    else:
        kind = schema[0]
        if kind == 'record':
            yield schema[1]
            for name, child in schema[2]:
                yield from emit(child, value[name])
        elif kind == 'enum':
            if type(value) is not int or not 0 <= value <= schema[1]:
                raise InvalidLC1('unknown declared enum variant')
            yield encode_u32(value)
        elif kind == 'list':
            yield b'q' + str(len(value)).encode('ascii') + b';'
            for item in value:
                yield from emit(schema[1], item)
        elif kind == 'option':
            yield b'0' if value is None else b'1'
            if value is not None:
                yield from emit(schema[1], value)
        elif kind == 'fixed':
            if len(value) != schema[1]:
                raise InvalidLC1('wrong fixed product size')
            for item in value:
                yield from emit(schema[2], item)
        elif kind == 'four':
            yield b'f'
            yield from emit(('fixed', 4, 'u'), value)
        elif kind == 'tree':
            stack = [value]
            while stack:
                current = stack.pop()
                if isinstance(current, Leaf):
                    yield b'l'
                    yield from emit(schema[1], current.value)
                elif isinstance(current, Node):
                    yield b'a'
                    stack.extend((current.right, current.left))
                else:
                    raise InvalidLC1('unknown tree constructor')
        elif kind == 'column':
            yield b'C'
            yield from emit(enum(3), value['variant'])
            if value['variant'] == 0:
                yield from emit(tree(option(schema[1])), value['values'])
                yield from emit(sequence('Stamp'), value['stamps'])
            else:
                yield from emit('s', value['legacy'])
        elif kind == 'access':
            yield from emit(enum(2), value['variant'])
            if value['variant'] == 0:
                yield from emit(schema[1], value['value'])
        elif kind == 'reservation':
            yield b'h'
            yield from emit(enum(1), value['variant'])
            yield from emit('Handle' if value['variant'] == 0 else enum(3),
                            value['handle'] if value['variant'] == 0 else value['error'])
        elif kind in ('step', 'observation'):
            maximum = 2 if kind == 'step' else 3
            variant = value['variant']
            yield from emit(enum(maximum), variant)
            if kind == 'step' and variant == 0:
                yield from emit('u', value['id'])
                yield from emit('u', value['condition'])
            elif (kind == 'step' and variant == 1) or (kind == 'observation' and variant == 0):
                yield from emit('s', value['name'])
            elif kind == 'observation' and variant in (1, 2):
                yield from emit('u', value['id'])
        else:
            raise InvalidLC1('unknown encoder schema')


def parse(reader, schema):
    schema = resolve(schema)
    if schema in ('u', 'n', 'bool', 's'):
        return {'u': reader.u32, 'n': reader.nat, 'bool': reader.boolean, 's': reader.string}[schema]()
    if schema == 'unit':
        reader.literal(b'0')
        return 0
    kind = schema[0]
    if kind == 'record':
        reader.literal(schema[1])
        value = {name: parse(reader, child) for name, child in schema[2]}
        names = {b'P': 'Vitals', b'V': 'Armor', b'G': 'Tracked',
                 b'p': 'Vitals', b'v': 'Armor'}
        if schema[1] in names:
            value['kind'] = names[schema[1]]
        return value
    if kind == 'enum':
        value = reader.u32()
        if value > schema[1]:
            raise InvalidLC1('unknown declared enum variant')
        return value
    if kind == 'list':
        return reader.sequence(lambda: parse(reader, schema[1]))
    if kind == 'option':
        return reader.option(lambda: parse(reader, schema[1]))
    if kind == 'fixed':
        return [parse(reader, schema[2]) for _ in range(schema[1])]
    if kind == 'four':
        reader.literal(b'f')
        return parse(reader, ('fixed', 4, 'u'))
    if kind == 'tree':
        return reader.tree(lambda: parse(reader, schema[1]))
    if kind == 'column':
        reader.literal(b'C')
        variant = parse(reader, enum(3))
        if variant:
            return {'variant': variant, 'legacy': reader.string()}
        return {'variant': 0, 'values': parse(reader, tree(option(schema[1]))),
                'stamps': parse(reader, sequence('Stamp'))}
    if kind == 'access':
        variant = parse(reader, enum(2))
        return dict(variant=variant, **({'value': parse(reader, schema[1])} if variant == 0 else {}))
    if kind == 'reservation':
        reader.literal(b'h')
        variant = parse(reader, enum(1))
        return dict(variant=variant, **({'handle': parse(reader, 'Handle')} if variant == 0
                                      else {'error': parse(reader, enum(3))}))
    if kind in ('step', 'observation'):
        variant = parse(reader, enum(2 if kind == 'step' else 3))
        value = {'variant': variant}
        if kind == 'step' and variant == 0:
            value.update(id=reader.u32(), condition=reader.u32())
        elif (kind == 'step' and variant == 1) or (kind == 'observation' and variant == 0):
            value['name'] = reader.string()
        elif kind == 'observation' and variant in (1, 2):
            value['id'] = reader.u32()
        return value
    raise InvalidLC1('unknown decoder schema')


REPORT_FIELDS = [
    ('count', 'u'), ('iterations', 'u'), ('seed_outcome', 'Outcome'),
    ('reservations', sequence('Reservation')), ('seed_pending', 'World'), ('seed_applied', 'World'),
    ('foreign_outcome', 'Outcome'), ('foreign_reservation', 'Reservation'),
    ('foreign_pending', 'World'), ('foreign_applied', 'World'), ('own_lookup', enum(2)),
    ('foreign_verified', 'World'), ('registered', 'State'), ('final', 'State'),
]
SCHEMAS['Outcome'] = record('E', ('variant', enum(1)))


def encode_report(value):
    pieces = [b'LC1H']
    for name, schema in REPORT_FIELDS:
        field = {'variant': value[name]} if schema == 'Outcome' else value[name]
        pieces.extend(emit(schema, field))
    pieces.append(b'!\n')
    return b''.join(pieces)


def decode_report(raw):
    reader = Reader(raw)
    reader.literal(b'LC1H')
    value = {}
    for name, schema in REPORT_FIELDS:
        field = parse(reader, schema)
        value[name] = field['variant'] if schema == 'Outcome' else field
    reader.literal(b'!\n')
    reader.finish()
    return value
