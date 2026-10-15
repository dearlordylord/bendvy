#!/usr/bin/env python3
"""Reject syntax, tuple filesystem calls and unshared entrypoint execution."""
import argparse
import ast
import pathlib
from task_runner import run

# Current frozen execution chains; historical receipts keep their original code.
SOURCE_BOUND_LOADERS = {
    'experiments/public-simulation/delivery-v1/collect-metadata.py',
    'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/development-run.py',
    'experiments/public-decode/adoption-v1/qualification-v1/spine-report-v1/transport.py',
    'experiments/public-decode/adoption-v1/qualification-v1/transport.py',
}
SOURCE_BOUND_PACKAGES = ('experiments/public-inspect/native-debug-call-boundary-v1/',)


def source_bound_loader_scope(name):
    path = pathlib.Path(name)
    if path.is_absolute():
        try:
            path = path.relative_to(pathlib.Path(__file__).resolve().parents[1])
        except ValueError:
            return False
    relative = path.as_posix()
    return (relative in SOURCE_BOUND_LOADERS or
            (relative.startswith(SOURCE_BOUND_PACKAGES) and not path.name.startswith('test-')))


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
    source_bound = source_bound_loader_scope(name)
    for node in ast.walk(tree):
        if (isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute)
                and isinstance(node.func.value, ast.Tuple)
                and node.func.attr in PATH_METHODS):
            print(f'{name}:{node.lineno}: tuple has no {node.func.attr} method')
            valid = False
        if (source_bound and isinstance(node, ast.Call)
                and isinstance(node.func, ast.Attribute) and node.func.attr == 'exec_module'
                and isinstance(node.func.value, ast.Attribute) and node.func.value.attr == 'loader'):
            print(f'{name}:{node.lineno}: compile pinned source bytes; loader.exec_module may read unpinned bytecode')
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


def committed_sources(base, head, merge_base=False):
    """Read committed bytes; a missing base conservatively selects the full tree."""
    def git(*args, check=True):
        return run(['git', *args], timeout=30, capture_output=True, check=check)
    git('rev-parse', '--verify', head + '^{commit}')
    valid = git('rev-parse', '--verify', base + '^{commit}', check=False)
    if valid.returncode:
        base = git('hash-object', '-t', 'tree', '/dev/null').stdout.decode().strip()
    elif merge_base:
        base = git('merge-base', base, head).stdout.decode().strip()
    git('diff', '--check', base, head, '--', '*.bend', '*.py', '*.md',
        '*.c', '*.js', '*.json', '.githooks/*')
    names = git('diff', '--name-only', '--diff-filter=ACMR', '-z',
                base, head, '--', '*.py').stdout.decode().split('\0')
    return [(name, git('show', head + ':' + name).stdout)
            for name in names if name]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--staged', action='store_true')
    modes.add_argument('--diff-base')
    parser.add_argument('--diff-head', default='HEAD')
    parser.add_argument('--merge-base', action='store_true')
    parser.add_argument('files', nargs='*')
    args = parser.parse_args()
    if args.diff_base is not None:
        sources = committed_sources(args.diff_base, args.diff_head, args.merge_base)
    elif args.staged:
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
