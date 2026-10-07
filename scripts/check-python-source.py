#!/usr/bin/env python3
"""Reject syntax, tuple filesystem calls and unshared entrypoint execution."""
import argparse
import ast
import pathlib
from task_runner import run

PATH_METHODS = {'read_text', 'read_bytes', 'write_text', 'write_bytes',
                'exists', 'is_file', 'is_dir', 'mkdir', 'glob', 'rglob'}


def entrypoint_scope(name):
    path = pathlib.Path(name)
    if path.is_absolute():
        try:
            path = path.relative_to(pathlib.Path(__file__).resolve().parents[1])
        except ValueError:
            return False
    parts = path.parts
    if len(parts) >= 3 and parts[0] == 'experiments' and parts[1].startswith('public-'):
        return path.suffix == '.py'
    return (len(parts) >= 2 and parts[0] in ('benchmarks', 'docs', 'examples', 'scripts')
            and path.suffix == '.py' and path.name != 'task_runner.py'
            and not path.name.startswith('test-'))


def check(name, source):
    try:
        tree = ast.parse(source, filename=name)
    except SyntaxError as error:
        print(f'{name}:{error.lineno}: {error.msg}')
        return False
    valid = True
    entrypoint = entrypoint_scope(name)
    for node in ast.walk(tree):
        if (isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute)
                and isinstance(node.func.value, ast.Tuple)
                and node.func.attr in PATH_METHODS):
            print(f'{name}:{node.lineno}: tuple has no {node.func.attr} method')
            valid = False
        if entrypoint:
            if (isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute)
                    and isinstance(node.func.value, ast.Name)
                    and node.func.value.id == 'subprocess'
                    and node.func.attr in ('Popen', 'run', 'check_output', 'check_call', 'call')):
                print(f'{name}:{node.lineno}: use the shared task_runner process implementation')
                valid = False
            if (isinstance(node, ast.Import)
                    and any(n.name in ('supervisor', 'supervise', 'raw_supervisor') for n in node.names)):
                print(f'{name}:{node.lineno}: forbidden alternate supervisor import')
                valid = False
    return valid


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--staged', action='store_true')
    parser.add_argument('files', nargs='*')
    args = parser.parse_args()
    if args.staged:
        names = run([
            'git', 'diff', '--cached', '--name-only', '--diff-filter=ACMR',
            '-z', '--', '*.py'], timeout=5, capture_output=True, check=True).stdout.decode().split('\0')
        sources = [(name, run(['git', 'show', ':' + name], timeout=5,
                             capture_output=True, check=True).stdout)
                   for name in names if name]
    else:
        sources = [(name, pathlib.Path(name).read_bytes()) for name in args.files]
    return 0 if all([check(name, source) for name, source in sources]) else 1


if __name__ == '__main__':
    raise SystemExit(main())
