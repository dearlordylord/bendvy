#!/usr/bin/env python3
"""Keep experiments disposable: no tracked payloads, at most 100 local entries.

Temporary experiment READMEs state Why: and Remove when:. Durable behavioral
tests belong with tests, examples or benchmarks; raw evidence objects do not.
Reads the Git index and a bounded directory listing, never experiment payloads.
Use --clean to discard local temporary work, retaining the policy README.
"""
import argparse
import os
from pathlib import Path
import re
import shutil

from task_runner import run

LIMIT = 100


def tracked_errors(paths):
    forbidden = [p for p in paths if (
        p.startswith('experiments/') and p != 'experiments/README.md'
    )]
    if not forbidden:
        return []
    return [f'{len(forbidden)} tracked experiment/archive files; remove obsolete '
            'packages, retain only justified runnable tests outside experiments. '
            'Examples: ' + ', '.join(forbidden[:3])]


def local_errors(root):
    folder = root / 'experiments'
    if folder.is_symlink():
        return ['experiments must be a real temporary directory, not a symlink']
    if not folder.exists():
        return []
    pending = [folder]
    experiments = set()
    count = 0
    while pending:
        current = pending.pop()
        with os.scandir(current) as entries:
            for entry in entries:
                count += 1
                if count > LIMIT:
                    return [f'experiments exceeds {LIMIT} local entries; '
                            'discard finished work and put build outputs in disposable temp dirs']
                path = Path(entry.path)
                relative = path.relative_to(folder)
                if len(relative.parts) == 1 and relative.name != 'README.md':
                    if not entry.is_dir(follow_symlinks=False):
                        return ['temporary experiments need their own directory and purpose README']
                    experiments.add(path)
                if entry.is_symlink():
                    return ['temporary experiments cannot contain symlinks']
                if entry.is_dir(follow_symlinks=False):
                    pending.append(path)
    errors = []
    for experiment in sorted(experiments):
        readme = experiment / 'README.md'
        if not readme.is_file() or readme.stat().st_size > 8192:
            errors.append(f'{experiment.name}: add a short README with Why: and Remove when:')
            continue
        text = readme.read_text()
        if not all(re.search(r'^' + label + r'[ \t]*\S[^\n]*$', text, re.M)
                   for label in ['Why:', 'Remove when:']):
            errors.append(f'{experiment.name}: state a current purpose and removal condition')
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--working-tree', action='store_true',
                        help='inspect current files during an unstaged cleanup')
    parser.add_argument('--clean', action='store_true',
                        help='discard local experiments, preserving only the policy README')
    args = parser.parse_args()
    if args.clean:
        folder = args.root / 'experiments'
        if folder.is_symlink():
            raise SystemExit('Refusing to clean a symlink')
        if folder.exists():
            for path in folder.iterdir():
                if path.name == 'README.md':
                    continue
                if path.is_dir() and not path.is_symlink():
                    shutil.rmtree(path)
                else:
                    path.unlink()
        print('Temporary experiments cleared')
        return 0
    result = run(['git', 'ls-files', '-z'], cwd=args.root, timeout=15,
                 capture_output=True, check=True)
    paths = [os.fsdecode(p) for p in result.stdout.split(b'\0') if p]
    if args.working_tree:
        paths = [p for p in paths if (args.root / p).exists()]
    errors = tracked_errors(paths)
    if not errors:
        errors = local_errors(args.root)
    print('\n'.join(errors) if errors else 'Disposable experiment state PASS')
    return bool(errors)


if __name__ == '__main__':
    raise SystemExit(main())
