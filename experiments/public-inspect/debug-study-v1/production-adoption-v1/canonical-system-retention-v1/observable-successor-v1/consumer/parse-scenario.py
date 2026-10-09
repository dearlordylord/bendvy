#!/usr/bin/env python3
"""Strict whole-DTO join for pure Bend Data output; never consumes partial fields.

The identity map is authored before compilation from the actual entrypoint and
its source imports. It preserves the pinned compiler's book_load/name_key
namespace rules, rather than accepting arbitrary constructors by basename.
"""
import argparse
import hashlib
import json
import os
import re
from pathlib import Path

TOKEN = re.compile(r'\s*("(?:[^"\\]|\\.)*"|[0-9]+n?|[^\s{},\[\]]+|[{},\[\]])')
IMPORT = re.compile(r'^import\s+(\S+)\s+as\s+(\w+)\s*(?:#.*)?$', re.M)


def string_value(token):
    result = []
    index = 1
    while index < len(token) - 1:
        char = token[index]
        index += 1
        if char != "\\":
            if ord(char) < 32:
                raise ValueError("Unescaped string control")
            result.append(char)
            continue
        if index >= len(token) - 1:
            raise ValueError("Truncated string escape")
        escape = token[index]
        index += 1
        if escape in {'n': '\n', 't': '\t', 'r': '\r', '0': '\0', '\\': '\\', '"': '"'}:
            result.append({'n': '\n', 't': '\t', 'r': '\r', '0': '\0', '\\': '\\', '"': '"'}[escape])
        elif escape == 'u' and token[index:index + 1] == '{':
            end = token.find('}', index + 1)
            digits = token[index + 1:end]
            if end < 0 or not re.fullmatch('[0-9a-f]+', digits):
                raise ValueError("Invalid Bend Unicode escape")
            scalar = int(digits, 16)
            if scalar > 0x10FFFF:
                raise ValueError("Unicode escape out of range")
            result.append(chr(scalar))
            index = end + 1
        else:
            raise ValueError("Unknown Bend string escape")
    return ''.join(result)


def string_term(value):
    result = ['"']
    escapes = {10: 'n', 9: 't', 13: 'r', 0: '0', 92: '\\', 34: '"'}
    for char in value:
        code = ord(char)
        if code in escapes:
            result.append('\\' + escapes[code])
        elif code < 32 or code == 127 or 0xD800 <= code <= 0xDFFF:
            result.append('\\u{' + format(code, 'x') + '}')
        else:
            result.append(char)
    return ''.join(result) + '"'


def parse_term(text):
    tokens = []
    at = 0
    while at < len(text):
        matched = TOKEN.match(text, at)
        if not matched:
            if text[at:].isspace():
                break
            raise ValueError(f"Unparsed byte at {at}")
        tokens.append(matched.group(1))
        at = matched.end()
    index = 0

    def take():
        nonlocal index
        if index >= len(tokens):
            raise ValueError("Truncated term")
        item = tokens[index]
        index += 1
        return item

    def fields(end):
        values = []
        if index < len(tokens) and tokens[index] == end:
            take()
            return values
        while True:
            values.append(value())
            punctuation = take()
            if punctuation == end:
                return values
            if punctuation != ',':
                raise ValueError(f"Expected comma or {end}")

    def value():
        token = take()
        if token == '[':
            return fields(']')
        if token.startswith('"'):
            return string_value(token)
        if re.fullmatch('[0-9]+n?', token):
            if token.endswith('n'):
                return {'nat': int(token[:-1])}
            number = int(token)
            if number > 0xFFFFFFFF:
                raise ValueError("U32 out of range")
            return number
        if token in '{}],':
            raise ValueError("Unexpected punctuation")
        if take() != '{':
            raise ValueError("Expected constructor fields")
        return {'constructor': token, 'fields': fields('}')}

    result = value()
    if index != len(tokens):
        raise ValueError("Trailing term tokens")
    if text not in (render_term(result), render_term(result) + '\n'):
        raise ValueError("Whole term canonical byte roundtrip failed")
    return result


def render_term(value):
    if isinstance(value, list):
        return '[' + ', '.join(map(render_term, value)) + ']'
    if isinstance(value, str):
        return string_term(value)
    if type(value) is int:
        return str(value)
    if isinstance(value, dict) and set(value) == {'nat'}:
        return str(value['nat']) + 'n'
    if isinstance(value, dict) and set(value) == {'constructor', 'fields'}:
        return value['constructor'] + '{' + ', '.join(map(render_term, value['fields'])) + '}'
    raise ValueError('Unexpected raw term shape')


def source_inventory(entrypoint):
    entrypoint = Path(entrypoint).resolve(strict=True)
    imports, namespaces, hashes = {}, {}, {}

    def visit(source, namespace):
        source = source.resolve(strict=True)
        if source in namespaces:
            return
        namespaces[source] = namespace
        data = source.read_bytes()
        hashes[str(source)] = hashlib.sha256(data).hexdigest()
        aliases = {}
        for name, alias in IMPORT.findall(data.decode()):
            if not name.endswith('.bend') or name.startswith('0x') or '@' in name:
                raise ValueError('Unadmitted dynamic source import')
            child = (source.parent / name).resolve(strict=True)
            aliases[alias] = child
            child_ns = os.path.relpath(child, entrypoint.parent).removesuffix('.bend')
            visit(child, child_ns)
        imports[source] = aliases

    visit(entrypoint, '')
    return entrypoint, imports, namespaces, hashes


def build_identities(entrypoint):
    entry, imports, namespaces, hashes = source_inventory(entrypoint)
    dto = imports[entry]['DTO']
    driver = imports[entry]['Driver']
    aliases = imports[dto]
    identities = {}

    def add(source, raw, semantic):
        prefix = namespaces[source]
        token = (prefix + '.' if prefix else '') + raw
        if token in identities:
            raise ValueError('Duplicate constructor identity')
        identities[token] = semantic

    for raw in ['Report', 'Failure']:
        add(entry, raw, 'Output.' + raw)
    for raw in ['ScenarioReport', 'Snapshot', 'WorldSnapshot', 'Columns', 'Column', 'Cell', 'RegistrySnapshot', 'RowValues', 'RejectedArgs']:
        add(dto, raw, raw)
    for raw in ['Run', 'PositionReplaced', 'RefusedRegistration']:
        add(dto, raw, 'Operation.' + raw)
    for raw in ['Plain', 'Transient', 'Observed']:
        add(dto, raw, raw)
    add(dto, 'Constructed', 'Storage.Constructed')
    add(aliases['View'], 'FullCell', 'FullCell')
    add(aliases['Lifecycle'], 'Stamp', 'Stamp')
    add(aliases['W'], 'RegistrationMeta', 'RegistrationMeta')
    add(aliases['W'], 'Accepted', 'Accepted')
    add(aliases['Query'], 'Clause', 'Clause')
    for raw in ['Read', 'Write', 'Optional', 'With', 'Without', 'Added', 'Changed']:
        add(aliases['Query'], raw, raw)
    for raw in ['Description', 'Entry']:
        add(aliases['App'], raw, raw)
    sch = imports[driver]['Sch']
    add(sch, 'Phase', 'Step.Phase')
    add(sch, 'System', 'Step.System')
    add(sch, 'Barrier', 'Barrier')
    add(aliases['Cmp'], 'Found', 'Access.Found')
    add(aliases['Cmp'], 'ComponentAbsent', 'ComponentAbsent')
    add(aliases['Q'], 'UserError', 'Error.UserError')
    add(aliases['D'], 'ArrayValue', 'Codec.ArrayValue')
    add(aliases['D'], 'Integer', 'Integer')
    for raw, semantic in [('Some', 'Maybe.Some'), ('None', 'None'), ('Done', 'Result.Done'), ('Fail', 'Result.Fail'), ('Unit', 'Unit'), ('True', 'True'), ('False', 'False')]:
        if raw in identities:
            raise ValueError('Base constructor collision')
        identities[raw] = semantic
    return {'scope': 'Exact frozen source constructor identities, not basename aliases', 'entrypoint': str(entry), 'constructors': identities, 'sourceSHA256': hashes, 'sourceImports': {str(source): {alias: str(child) for alias, child in aliases.items()} for source, aliases in imports.items()},
            'namespaceBasis': '.references/bend2/bend2/bend.ts:952 book_load and :1205 name_key; comp.ts:1851 show_main/:3225 js_book/:6097 show_val'}


# These are raw Data field types, not defaults inferred from a observed output.
# They preserve distinctions intentionally erased by the neutral constructor join.
L = lambda item: ('List', item)
M = lambda item: ('Maybe', item)
FIELD_TYPES = {
    'Output.Report': ['ScenarioReport', 'ScenarioReport', 'ScenarioReport'],
    'ScenarioReport': ['String', L('Snapshot')],
    'Snapshot': ['String', 'U32', 'WorldSnapshot', L('RegistrySnapshot'), 'Operation', L(M('Description'))],
    'WorldSnapshot': ['U32', 'U32', 'U32', 'U32', 'Nat', L('Bool'), 'Unit', L('Unit'), 'U32', L('RegistrationMeta'), 'U32', 'U32', 'Columns'],
    'Columns': ['Column', 'Column', 'Column'],
    'Column': ['Storage', L('Cell')],
    'Cell': ['U32', M('FullCell'), 'Stamp'],
    'FullCell': ['Nat', L('U32')],
    'Stamp': ['U32', 'U32'],
    'RegistrySnapshot': ['U32', 'U32', 'String', L('String'), 'U32', 'String', L('Clause')],
    'RegistrationMeta': ['U32', 'String', L('String')],
    'Clause': ['String', 'Mode'],
    'RowValues': ['FullCell', 'FullCell', ('Access', 'FullCell')],
    'RejectedArgs': ['Bool', 'U32'],
    'Description': ['U32', 'String', L('Step'), L('Entry')],
    'Entry': ['U32', 'String', 'String', L('Clause')],
    'Operation.Run': [('Result', 'Error', L('RowValues'))],
    'Operation.PositionReplaced': ['Status', M('FullCell'), M('FullCell')],
    'Operation.RefusedRegistration': ['RejectedArgs', 'WorldSnapshot', 'RegistrySnapshot'],
    'Step.Phase': ['String'],
    'Step.System': ['U32', 'U32'],
    'Storage.Constructed': ['Codec'],
    'Error.UserError': ['Unit'],
    'Codec.ArrayValue': ['Codec'],
}
GROUPS = {
    'Operation': ['Observed', 'Operation.Run', 'Operation.PositionReplaced', 'Operation.RefusedRegistration'],
    'Step': ['Step.Phase', 'Step.System', 'Barrier'],
    'Storage': ['Plain', 'Transient', 'Storage.Constructed'],
    'Error': ['Error.UserError'],
    'Codec': ['Integer', 'Codec.ArrayValue'],
    'Mode': ['Read', 'Write', 'Optional', 'With', 'Without', 'Added', 'Changed'],
    'Bool': ['True', 'False'],
    'Status': ['Accepted'],
}


def normalize(raw, identities, join):
    def convert(value, expected):
        if expected == 'U32':
            if type(value) is not int or not 0 <= value <= 0xFFFFFFFF:
                raise ValueError('Expected exact U32')
            return value
        if expected == 'String':
            if type(value) is not str:
                raise ValueError('Expected exact String')
            return value
        if expected == 'Nat':
            if not isinstance(value, dict) or set(value) != {'nat'} or type(value['nat']) is not int or value['nat'] < 0:
                raise ValueError('Expected exact finite Nat')
            return dict(value)
        if isinstance(expected, tuple) and expected[0] == 'List':
            if type(value) is not list:
                raise ValueError('Expected exact List')
            return [convert(item, expected[1]) for item in value]
        if not isinstance(value, dict) or set(value) != {'constructor', 'fields'}:
            raise ValueError('Expected exact Data constructor')
        if value['constructor'] not in identities:
            raise ValueError('Unknown exact constructor identity: ' + value['constructor'])
        semantic = identities[value['constructor']]
        fields = value['fields']
        if type(fields) is not list:
            raise ValueError('Invalid constructor fields')
        if semantic == 'Output.Failure':
            raise ValueError('Explicit fixture failure')
        if isinstance(expected, tuple):
            kind = expected[0]
            allowed = {'Maybe': ['Maybe.Some', 'None'], 'Result': ['Result.Done', 'Result.Fail'], 'Access': ['Access.Found', 'ComponentAbsent']}[kind]
            if semantic not in allowed:
                raise ValueError('Wrong generic Data constructor: ' + semantic)
            field_types = ([expected[1]] if semantic in ['Maybe.Some', 'Access.Found', 'Result.Fail'] else
                           [expected[2]] if semantic == 'Result.Done' else [])
        else:
            if semantic not in GROUPS.get(expected, [expected]):
                raise ValueError('Wrong nominal Data constructor: ' + semantic + ' for ' + expected)
            field_types = FIELD_TYPES.get(semantic, [])
        if len(fields) != len(field_types):
            raise ValueError('Wrong field count: ' + semantic)
        converted = [convert(field, kind) for field, kind in zip(fields, field_types)]
        records = join['recordsStripTagExactOrderedFields']
        tagged = join['taggedExactFieldNames']
        flat = join['taggedSingleFieldFlatten']
        if semantic in records or semantic in tagged:
            keys = (records if semantic in records else tagged)[semantic]
            if len(keys) != len(field_types):
                raise ValueError('Independent join field count mismatch')
            record = dict(zip(keys, converted))
            return record if semantic in records else {semantic.split('.')[-1]: record}
        if semantic in flat:
            if len(converted) != 1:
                raise ValueError('Wrong flatten field count: ' + semantic)
            return {semantic.split('.')[-1]: converted[0]}
        if converted:
            raise ValueError('Unexpected nullary fields: ' + semantic)
        if semantic in join['preserveEmptyTags']:
            return {semantic: {}}
        if semantic in join['modeNullaryAsExactString']:
            return semantic
        if semantic in join['booleanNullaryToJSON']:
            return join['booleanNullaryToJSON'][semantic]
        raise ValueError('Unadmitted constructor: ' + semantic)
    return convert(raw, 'Output.Report')


def strict_equal(actual, expected, path='$'):
    if type(actual) is not type(expected):
        raise ValueError('Type mismatch at ' + path)
    if isinstance(actual, dict):
        if set(actual) != set(expected):
            raise ValueError('Field mismatch at ' + path)
        for key in expected:
            strict_equal(actual[key], expected[key], path + '.' + key)
    elif isinstance(actual, list):
        if len(actual) != len(expected):
            raise ValueError('List length mismatch at ' + path)
        for index, (left, right) in enumerate(zip(actual, expected)):
            strict_equal(left, right, path + '[' + str(index) + ']')
    elif actual != expected:
        raise ValueError('Value mismatch at ' + path)


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    identities = sub.add_parser('identities')
    identities.add_argument('entrypoint')
    identities.add_argument('output')
    compare = sub.add_parser('compare')
    compare.add_argument('raw')
    compare.add_argument('identities')
    compare.add_argument('join')
    compare.add_argument('expected')
    args = parser.parse_args()
    if args.command == 'identities':
        Path(args.output).write_text(json.dumps(build_identities(args.entrypoint), indent=2) + '\n')
        return
    inventory = json.loads(Path(args.identities).read_text())
    join = json.loads(Path(args.join).read_text())
    expected_bytes = Path(args.expected).read_bytes()
    if hashlib.sha256(expected_bytes).hexdigest() != join['expectedSHA256']:
        raise ValueError('Independent expected digest mismatch')
    actual = normalize(parse_term(Path(args.raw).read_text()), inventory['constructors'], join)
    strict_equal(actual, json.loads(expected_bytes))
    print('Complete constructor join equals independent oracle')


if __name__ == '__main__':
    main()
