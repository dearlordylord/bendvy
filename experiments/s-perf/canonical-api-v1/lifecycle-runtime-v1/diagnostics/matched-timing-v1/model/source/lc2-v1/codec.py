"""LC2 changes integer representations only; all closed LC1 schemas are reused."""
from legacy import LC1, InvalidLC1, Leaf, Node
from varint import Reader, encode_u32, encode_nat, encode_string


def emit(schema, value):
    schema = LC1.resolve(schema)
    if schema == 'u':
        yield encode_u32(value)
    elif schema == 'n':
        yield encode_nat(value)
    elif schema == 's':
        yield encode_string(value)
    elif schema in ('bool', 'unit'):
        yield from LC1.emit(schema, value)
    else:
        kind = schema[0]
        if kind == 'record':
            yield schema[1]
            for name, child in schema[2]:
                yield from emit(child, value[name])
        elif kind == 'enum':
            if type(value) is not int or not 0 <= value <= schema[1]:
                raise InvalidLC1('unknown declared LC2 enum variant')
            yield encode_u32(value)
        elif kind == 'list':
            yield b'q' + encode_nat(len(value))
            for item in value:
                yield from emit(schema[1], item)
        elif kind == 'option':
            yield b'0' if value is None else b'1'
            if value is not None:
                yield from emit(schema[1], value)
        elif kind == 'fixed':
            if len(value) != schema[1]:
                raise InvalidLC1('wrong LC2 fixed product size')
            for item in value:
                yield from emit(schema[2], item)
        elif kind == 'four':
            yield b'f'
            yield from emit(('fixed', 4, 'u'), value)
        elif kind == 'tree':
            stack = [value]
            while stack:
                node = stack.pop()
                if isinstance(node, Leaf):
                    yield b'l'
                    yield from emit(schema[1], node.value)
                elif isinstance(node, Node):
                    yield b'a'
                    stack.extend((node.right, node.left))
                else:
                    raise InvalidLC1('unknown LC2 physical tree')
        elif kind == 'column':
            yield b'C'
            yield from emit(LC1.enum(3), value['variant'])
            if value['variant'] == 0:
                yield from emit(LC1.tree(LC1.option(schema[1])), value['values'])
                yield from emit(LC1.sequence('Stamp'), value['stamps'])
            else:
                yield encode_string(value['legacy'])
        elif kind == 'access':
            yield from emit(LC1.enum(2), value['variant'])
            if value['variant'] == 0:
                yield from emit(schema[1], value['value'])
        elif kind == 'reservation':
            yield b'h'
            yield from emit(LC1.enum(1), value['variant'])
            yield from emit('Handle' if value['variant'] == 0 else LC1.enum(3),
                            value['handle'] if value['variant'] == 0 else value['error'])
        elif kind in ('step', 'observation'):
            variant = value['variant']
            yield from emit(LC1.enum(2 if kind == 'step' else 3), variant)
            if kind == 'step' and variant == 0:
                yield from emit('u', value['id'])
                yield from emit('u', value['condition'])
            elif (kind == 'step' and variant == 1) or (kind == 'observation' and variant == 0):
                yield encode_string(value['name'])
            elif kind == 'observation' and variant in (1, 2):
                yield from emit('u', value['id'])
        else:
            raise InvalidLC1('unknown LC2 closed schema')


def encode_report(value):
    pieces = [b'LC2M']
    for name, schema in LC1.REPORT_FIELDS:
        field = {'variant': value[name]} if schema == 'Outcome' else value[name]
        pieces.extend(emit(schema, field))
    return b''.join(pieces) + b'!\n'


def decode_report(raw):
    reader = Reader(raw)
    reader.literal(b'LC2M')
    value = {}
    for name, schema in LC1.REPORT_FIELDS:
        field = LC1.parse(reader, schema)
        value[name] = field['variant'] if schema == 'Outcome' else field
    reader.literal(b'!\n')
    reader.finish()
    return value


def to_lc1(raw):
    return LC1.encode_report(decode_report(raw))
