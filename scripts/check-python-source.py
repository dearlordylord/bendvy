#!/usr/bin/env python3
"""Reject syntax errors and literal tuple calls to filesystem methods."""
import argparse
import ast
import pathlib
from task_runner import run

PATH_METHODS = {'read_text', 'read_bytes', 'write_text', 'write_bytes',
                'exists', 'is_file', 'is_dir', 'mkdir', 'glob', 'rglob'}


def check(name, source):
    try:
        tree = ast.parse(source, filename=name)
    except SyntaxError as error:
        print(f'{name}:{error.lineno}: {error.msg}')
        return False
    valid = True
    for node in ast.walk(tree):
        if (isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute)
                and isinstance(node.func.value, ast.Tuple)
                and node.func.attr in PATH_METHODS):
            print(f'{name}:{node.lineno}: tuple has no {node.func.attr} method')
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
