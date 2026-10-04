#!/usr/bin/env python3
"""Finite actual affine publication/order regression gate, not full E11."""
import hashlib
import json
import pathlib
import re
import shutil
import sys
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / 't05'))
from run import build, paired


def closure():
    names, pending = set(), ['publish-bulk-controls.bend']
    while pending:
        name = pending.pop()
        if name in names:
            continue
        names.add(name)
        pending.extend(re.findall(r'^import \./(\S+\.bend)', (HERE / name).read_text(), re.M))
    return sorted(names)


def main():
    names = closure()
    original = 'List.reverse.go(&1,Command<M,A,F>,List.reverse(&1,Command<M,A,F>,staged),pending)'
    evidence = {'scope': 'actual issued Type commands published onto nonempty queue; finite prerequisite',
                'checkerLimitSeconds': 5, 'runtimeLimitSeconds': 5, 'cases': [], 'mutants': []}
    with tempfile.TemporaryDirectory(prefix='publish-bulk-') as temporary:
        base = pathlib.Path(temporary)
        def copy(label, replacement=None):
            folder = base / label
            folder.mkdir()
            for name in names:
                source = (HERE / name).read_text()
                if name == 'storage.bend' and replacement:
                    assert source.count(original) == 1
                    source = source.replace(original, replacement)
                (folder / name).write_text(source)
            return build(folder / 'publish-bulk-controls.bend', folder)
        programs = copy('original')
        for schema, number in [('Motion', 0), ('Health', 1)]:
            for count in [1, 17, 65537]:
                assert paired(programs, [str(number), str(count)]) == 'true', (schema, count)
                evidence['cases'].append({'schema': schema, 'count': count, 'nativeJsEqual': True})
                print(schema, count, 'PASS', flush=True)
        for label, replacement in [
            ('reverse-staged-order', 'List.reverse.go(&1,Command<M,A,F>,staged,pending)'),
            ('drop-existing-pending', 'staged'),
            ('existing-before-staged', 'List.reverse.go(&1,Command<M,A,F>,List.reverse(&1,Command<M,A,F>,pending),staged)'),
        ]:
            programs = copy(label, replacement)
            for schema, number in [('Motion', 0), ('Health', 1)]:
                assert paired(programs, [str(number), '17']) == 'false', (label, schema)
            evidence['mutants'].append({'name': label, 'compilingNativeJs': True, 'bothSchemasDetected': True})
            print(label, 'DETECTED', flush=True)
    evidence['sources'] = {name: hashlib.sha256((HERE / name).read_bytes()).hexdigest()
                           for name in names + ['publish-bulk-run.py']}
    (HERE / 'publish-bulk-evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print('PUBLISH BULK PASS', flush=True)


if __name__ == '__main__':
    main()
