"""Check exact staged ownership, or stage an explicit path manifest."""
import argparse
import json
import os
from pathlib import Path, PurePosixPath
import task_runner


def owned_paths(manifest):
    names = manifest['paths']
    if not names or len(names) != len(set(names)):
        raise ValueError('nonempty unique owned paths required')
    for name in names:
        path = PurePosixPath(name)
        if path.is_absolute() or '..' in path.parts or str(path) != name or name == '.':
            raise ValueError('owned paths must be normalized repository-relative files')
    return set(names)


def check_owned(allowed, staged):
    foreign = set(staged) - set(allowed)
    if foreign:
        raise ValueError('staged outside ownership: ' + repr(sorted(foreign)))


def git(root, *args):
    return task_runner.run(['git', *args], cwd=root, timeout=5,
                           env={k: v for k, v in os.environ.items() if not k.startswith('GIT_')},
                           capture_output=True, check=True).stdout


def stage(root, manifest_path, add=False):
    root = Path(root)
    allowed = owned_paths(json.loads(Path(manifest_path).read_text()))
    def current():
        return [p.decode() for p in git(root, 'diff', '--cached', '--name-only', '-z').split(b'\0') if p]
    check_owned(allowed, current())
    if add:
        for name in allowed:
            path = root / name
            if path.is_dir():
                raise ValueError('list files, not directories: ' + name)
            if not path.exists() and not path.is_symlink():
                git(root, 'ls-files', '--error-unmatch', '--', name)
        git(root, '--literal-pathspecs', 'add', '--', *sorted(allowed))
        check_owned(allowed, current())
    return current()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest', type=Path)
    parser.add_argument('--root', type=Path, default=Path.cwd())
    parser.add_argument('--add', action='store_true')
    args = parser.parse_args()
    for name in stage(args.root, args.manifest, args.add):
        print(name)


if __name__ == '__main__':
    main()
