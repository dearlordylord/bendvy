"""Source-derived strict Data transport; no output-derived names or projections."""
import importlib.util
import json
import os
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
TERM_PATH = ROOT / 'experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/parse-scenario.py'
spec = importlib.util.spec_from_file_location('existing_data_term', TERM_PATH)
TERM = importlib.util.module_from_spec(spec)
spec.loader.exec_module(TERM)


def split(text):
    fields, start, depth = [], 0, 0
    for index, char in enumerate(text):
        depth += char in '<('
        depth -= char in '>)'
        if char == ',' and depth == 0:
            fields.append(text[start:index].strip())
            start = index + 1
    if text[start:].strip():
        fields.append(text[start:].strip())
    return fields


class Transport:
    def __init__(self, entry):
        self.entry = Path(entry).resolve()
        self.sources, self.imports, self.types, self.aliases, self.constructors = {}, {}, {}, {}, {}
        self.visit(self.entry)

    def token(self, path, name):
        prefix = '' if path == self.entry else os.path.relpath(path, self.entry.parent)[:-5] + '.'
        return prefix + name

    def visit(self, path):
        if path in self.sources:
            return
        text = path.read_text()
        self.sources[path] = text
        imports = {}
        for target, alias in re.findall(r'^import (\S+)(?: as (\S+))?$', text, re.M):
            if target == 'Base':
                continue
            child = (path.parent / target).resolve()
            imports[alias or target] = child
            self.visit(child)
        self.imports[path] = imports
        current = None
        declarations = re.sub(r"^(type .+ is Data:) (.+)$", r"\1\n  \2", text, flags=re.M)
        for line in declarations.splitlines():
            match = re.fullmatch(r'type (\w+)(?:<(.*)>)? is Data:', line)
            if match:
                name, params = match.groups()
                current = (path, name)
                self.types[current] = {'params': [p.split(':')[0].strip() for p in split(params or '')], 'constructors': {}}
                continue
            if line and not line.startswith(' '):
                current = None
            if current:
                match = re.fullmatch(r'  (\w+)\{(.*)\}', line)
                if match:
                    ctor, fields = match.groups()
                    fields = [tuple(field.split(':', 1)) for field in split(fields)]
                    fields = [(name.strip(), kind.strip()) for name, kind in fields]
                    self.types[current]['constructors'][ctor] = fields
                    token = self.token(path, ctor)
                    if token in self.constructors:
                        raise ValueError('Source constructor identity collision')
                    self.constructors[token] = (current, ctor, fields)
            match = re.fullmatch(r'def (\w+)\((.*)\) -> Data: (.*)', line)
            if match:
                name, params, value = match.groups()
                self.aliases[path, name] = ([p.split(':')[0].strip().lstrip('~+') for p in split(params)], value)

    def resolve(self, expression, path, env):
        expression = expression.strip().lstrip('~')
        if expression in env:
            return env[expression]
        # Closed Data-valued template aliases use the same source parameters.
        expression = re.sub(r'\((~?\w+(?:,~?\w+)*)\)$', lambda m: '<' + m[1].replace('~', '') + '>', expression)
        head, tail = (expression.split('<', 1) + [''])[:2] if '<' in expression else (expression, '')
        args = [self.resolve(arg, path, env) for arg in split(tail[:-1]) if not arg.startswith('&')]
        if head in ('U32', 'Nat', 'String', 'Bool', 'Unit', 'List', 'Maybe'):
            return (head, args)
        if '.' in head:
            alias, head = head.split('.', 1)
            path = self.imports[path][alias]
        key = (path, head)
        if key in self.aliases:
            params, value = self.aliases[key]
            if len(params) != len(args):
                raise ValueError('Data alias arity mismatch')
            return self.resolve(value, path, dict(zip(params, args)))
        if key not in self.types:
            raise ValueError('Unknown observed source Data type: ' + str(key))
        if len(self.types[key]['params']) != len(args):
            raise ValueError('Nominal Data type arity mismatch')
        return (key, args)

    def convert(self, value, kind):
        head, args = kind
        if head == 'U32':
            if type(value) is not int or not 0 <= value < 2**32:
                raise ValueError('Expected exact U32')
            return value
        if head == 'Nat':
            if type(value) is not dict or set(value) != {'nat'} or type(value['nat']) is not int or value['nat'] < 0:
                raise ValueError('Expected exact Nat')
            return value['nat']
        if head == 'String':
            if type(value) is not str:
                raise ValueError('Expected exact String')
            return value
        if head == 'List':
            if type(value) is not list or len(args) != 1:
                raise ValueError('Expected complete typed List')
            return [self.convert(item, args[0]) for item in value]
        if type(value) is not dict or set(value) != {'constructor', 'fields'} or type(value['fields']) is not list:
            raise ValueError('Expected exact Data constructor')
        token, raw = value['constructor'], value['fields']
        if head in ('Maybe', 'Bool', 'Unit'):
            if head == 'Maybe' and token == 'Some' and len(raw) == 1:
                return {'$': 'Some', 'value': self.convert(raw[0], args[0])}
            if head == 'Maybe' and token == 'None' and not raw:
                return {'$': 'None'}
            if head == 'Bool' and token in ('True', 'False') and not raw:
                return token == 'True'
            if head == 'Unit' and token == 'Unit' and not raw:
                return {'$': 'Unit'}
            raise ValueError('Wrong builtin nominal constructor or arity')
        if token not in self.constructors:
            raise ValueError('Unknown exact constructor namespace')
        actual_type, constructor, fields = self.constructors[token]
        if actual_type != head or len(raw) != len(fields):
            raise ValueError('Wrong nominal constructor or field count')
        path, _ = head
        env = dict(zip(self.types[head]['params'], args))
        return {'$': constructor, **{name: self.convert(item, self.resolve(field, path, env)) for (name, field), item in zip(fields, raw)}}

    def normalize(self, raw):
        return self.convert(TERM.parse_term(raw), self.resolve('Candidate', self.entry, {}))

    def inverse(self, value, kind):
        head, args = kind
        if head in ('U32', 'String'):
            self.convert(value, kind)
            return value
        if head == 'Nat':
            if type(value) is not int or value < 0:
                raise ValueError('Expected semantic exact Nat')
            return {'nat': value}
        if head == 'List':
            if type(value) is not list:
                raise ValueError('Expected semantic full List')
            return [self.inverse(item, args[0]) for item in value]
        if head == 'Bool':
            if type(value) is not bool:
                raise ValueError('Expected semantic Bool')
            return {'constructor': 'True' if value else 'False', 'fields': []}
        if head in ('Maybe', 'Unit'):
            if type(value) is not dict or '$' not in value:
                raise ValueError('Expected semantic builtin tag')
            tag = value['$']
            fields = [self.inverse(value['value'], args[0])] if head == 'Maybe' and tag == 'Some' and set(value) == {'$', 'value'} else []
            raw = {'constructor': tag, 'fields': fields}
            TERM.strict_equal(self.convert(raw, kind), value)
            return raw
        if type(value) is not dict or '$' not in value:
            raise ValueError('Expected semantic nominal record')
        path, _ = head
        fields = self.types[head]['constructors'].get(value['$'])
        if fields is None or set(value) != {'$'} | {name for name, _ in fields}:
            raise ValueError('Semantic constructor fields disagree with source: ' + str((head, value.get('$'), set(value))))
        env = dict(zip(self.types[head]['params'], args))
        return {'constructor': self.token(path, value['$']), 'fields': [self.inverse(value[name], self.resolve(field, path, env)) for name, field in fields]}

    def inventory(self):
        import hashlib
        return {'entrypoint': str(self.entry), 'sourceSHA256': {str(path): hashlib.sha256(text.encode()).hexdigest() for path, text in sorted(self.sources.items())},
                'sourceImports': {str(path): {alias: str(child) for alias, child in sorted(items.items())} for path, items in sorted(self.imports.items())},
                'constructors': {token: {'source': str(kind[0]), 'datatype': kind[1], 'name': name, 'fields': [list(field) for field in fields]} for token, (kind, name, fields) in sorted(self.constructors.items())},
                'termParser': {'path': str(TERM_PATH), 'sha256': hashlib.sha256(TERM_PATH.read_bytes()).hexdigest()},
                'scope': 'Exact nominal constructor identities/typed source fields, complete queue front/back; no runtime evidence'}


def main():
    import argparse
    import hashlib
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    ids = sub.add_parser('identities')
    ids.add_argument('entry'); ids.add_argument('output')
    compare = sub.add_parser('compare')
    for name in ('raw', 'inventory', 'expected', 'expected_sha256'):
        compare.add_argument(name)
    args = parser.parse_args()
    if args.command == 'identities':
        Path(args.output).write_text(json.dumps(Transport(args.entry).inventory(), indent=2) + '\n')
        return
    inventory = json.loads(Path(args.inventory).read_text())
    transport = Transport(inventory['entrypoint'])
    if inventory != transport.inventory():
        raise ValueError('Source/constructor/helper inventory drift')
    expected = Path(args.expected).read_bytes()
    if hashlib.sha256(expected).hexdigest() != args.expected_sha256:
        raise ValueError('Independent whole oracle digest mismatch')
    TERM.strict_equal(transport.normalize(Path(args.raw).read_text()), json.loads(expected))
    print('Complete source-typed observation equals whole independent oracle')


if __name__ == '__main__':
    main()
