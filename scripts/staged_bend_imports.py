"""Read-only staged Bend entry/import byte preflight; never executes a compiler.

Follows the pinned loader's leading import block (including comments and aliases).
Owned relative imports resolve from the importing file, not the stage root. Base
and installed/hub imports require explicit library bindings; nothing is fetched.
This checks paths/bytes only, not Bend typing, effects or semantic acceptance.
"""
import hashlib
from pathlib import Path, PurePosixPath
import re


_IMPORT = re.compile(r'import\s+(\S+)(?:\s+as\s+([A-Za-z_]\w*))?\s*(?:#.*)?$')
_SHA = re.compile(r'[0-9a-f]{64}$')


def _relative(name):
    path = PurePosixPath(name)
    if not isinstance(name, str) or not name or path.is_absolute() or path.as_posix() != name or '..' in path.parts or name == '.':
        raise ValueError(f'noncanonical inventory/entry path: {name}')
    return path


def _inventory(root, inventory):
    if not inventory:
        raise ValueError('empty staged inventory')
    checked = {}
    for name, digest in inventory.items():
        _relative(name)
        if not isinstance(digest, str) or not _SHA.fullmatch(digest):
            raise ValueError(f'invalid SHA256: {name}')
        path = root / name
        if not path.is_file() or path.resolve() != path:
            raise RuntimeError(f'missing file or symlink/path alias: {path}')
        if hashlib.sha256(path.read_bytes()).hexdigest() != digest:
            raise RuntimeError(f'staged bytes changed: {path}')
        checked[name] = digest
    return checked


def _imports(path):
    aliases = set()
    for number, raw in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith('#'):
            continue
        if not re.match(r'import(?:\s|$)', line):
            break
        found = _IMPORT.fullmatch(line)
        if found is None or (found[2] is None and found[1] != 'Base'):
            raise RuntimeError(f'malformed leading import: {path}:{number}')
        token, alias = found.groups()
        if alias is not None:
            if alias in aliases or not token.endswith('.bend'):
                raise RuntimeError(f'invalid/duplicate import alias: {path}:{number}')
            aliases.add(alias)
        yield number, token


def verify(stage, entry, inventory, libraries=None, *, scan_all=False):
    """Return consumed paths/SHAs and literal edges after complete byte checks.

    libraries maps exact import tokens (e.g. Base) to {root, entry, inventory}.
    Library inventories are separately pinned, including their relative imports.
    Optional scan_all validates every owned .bend as a root, useful for paired
    cohorts. Unknown files never become implicitly selected; caller freezes this
    helper and returned binding and invokes it at initial/child/final guards.
    """
    stage = Path(stage).resolve()
    if not stage.is_dir():
        raise RuntimeError('missing staged root')
    _relative(entry)
    if not entry.endswith('.bend') or entry not in inventory:
        raise RuntimeError(f'entry not selected: {entry}')
    roots = {'stage': stage}
    inventories = {'stage': _inventory(stage, inventory)}
    bindings = {}
    for token, spec in (libraries or {}).items():
        if not isinstance(token, str) or not token or not (token == 'Base' or Path(token).is_absolute() or token.startswith('0x') or '@' in token):
            raise ValueError('library binding must identify Base or an explicit installed/hub path')
        name = 'library:' + token
        root = Path(spec['root']).resolve()
        _relative(spec['entry'])
        if not root.is_dir() or not spec['entry'].endswith('.bend') or spec['entry'] not in spec['inventory']:
            raise RuntimeError(f'library entry not selected: {token}')
        roots[name] = root
        inventories[name] = _inventory(root, spec['inventory'])
        if Path(token).is_absolute() and Path(token) != root / spec['entry']:
            raise ValueError('absolute library import must bind its literal target')
        bindings[token] = (name, spec['entry'])
    visiting, done, edges = set(), {}, []

    def walk(owner, name):
        key = (owner, name)
        if key in visiting:
            raise RuntimeError(f'import cycle: {owner}/{name}')
        if key in done:
            return
        if name not in inventories[owner]:
            raise RuntimeError(f'import not selected: {owner}/{name}')
        visiting.add(key)
        source = roots[owner] / name
        for number, token in _imports(source):
            if token in bindings:
                target_owner, target = bindings[token]
            else:
                if token == 'Base' or '@' in token or token.startswith('0x') or Path(token).is_absolute():
                    raise RuntimeError(f'unbound pinned library import: {source}:{number}: {token}')
                lexical = source.parent / token
                if not lexical.is_file():
                    raise RuntimeError(f'missing literal import file: {source}:{number}: {token}')
                resolved = lexical.resolve()
                try:
                    target = resolved.relative_to(roots[owner]).as_posix()
                except ValueError as error:
                    raise RuntimeError(f'import escapes owned root: {source}:{number}: {token}') from error
                # The selected lexical target must be the real target: same bytes
                # at another module are not a substitute for the literal path.
                if lexical.absolute() != resolved and any(p.is_symlink() for p in [lexical, *lexical.parents] if p != p.parent):
                    raise RuntimeError(f'import uses symlink alias: {source}:{number}: {token}')
                target_owner = owner
            if target not in inventories[target_owner] or not (roots[target_owner] / target).is_file():
                raise RuntimeError(f'missing/unselected import: {source}:{number}: {token}')
            edges.append({'source': str(source), 'line': number, 'import': token,
                          'target': str(roots[target_owner] / target)})
            walk(target_owner, target)
        visiting.remove(key)
        done[key] = {'owner': owner, 'path': str(source), 'relative': name,
                     'sha256': inventories[owner][name]}

    for root_entry in sorted(n for n in inventory if n.endswith('.bend')) if scan_all else [entry]:
        walk('stage', root_entry)
    return {'entry': str(stage / entry), 'entrySHA256': inventory[entry],
            'consumed': sorted(done.values(), key=lambda item: (item['owner'], item['relative'])),
            'imports': edges, 'scanAll': scan_all}
