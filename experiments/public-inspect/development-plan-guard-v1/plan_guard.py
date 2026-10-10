"""Read-only pre-child command/artifact joins for detached-v2 development plans."""
import hashlib
import os
from pathlib import Path
import re
import stat


class InvalidPlan(ValueError):
    pass


def _path(value):
    if not isinstance(value, str) or not value:
        raise InvalidPlan('path must be a nonempty string')
    path = Path(value)
    if not path.is_absolute() or str(path) != value or '..' in path.parts or '.' in value.split('/'):
        raise InvalidPlan('path must be lexical absolute canonical: ' + value)
    for item in (path, *path.parents):
        if item.is_symlink():
            raise InvalidPlan('symlink path component: ' + str(item))
    return path


def _pinned(path, pins):
    digest = pins.get(str(path))
    if not isinstance(digest, str) or re.fullmatch('[0-9a-f]{64}', digest) is None:
        raise InvalidPlan('missing SHA256 pin: ' + str(path))
    return digest


def validate(plan, *, output_dir):
    """Raise InvalidPlan before any child; return fixed fresh output paths.

    The collector passes actual plan_path.parent as output_dir. Stage remains
    metadata; legacy prepare uses its source directory, runtime03 its output.
    Existing guards remain responsible for complete pin/import/resource checks.
    """
    try:
        if not isinstance(plan['scope'], str):
            raise InvalidPlan('scope must be a string')
        environment = plan['environment']
        if not isinstance(environment, dict) or any(not isinstance(k, str) or not isinstance(v, str) for k, v in environment.items()):
            raise InvalidPlan('environment must map strings to strings')
        resources = plan['resourceRoots']
        if not isinstance(resources, dict):
            raise InvalidPlan('resourceRoots must be a mapping')
        for root, entries in resources.items():
            _path(root)
            if not isinstance(entries, dict) or any(not isinstance(k, str) or not isinstance(v, str) for k, v in entries.items()):
                raise InvalidPlan('resource inventory must map strings to strings')
        role = plan['role']
        if role not in ('js', 'native'):
            raise InvalidPlan('unsupported development role')
        entry = _path(plan['entrypoint'])
        if not _path(plan['stage']).is_dir() or not _path(plan['cwd']).is_dir():
            raise InvalidPlan('stage and cwd must be existing directories')
        out = _path(str(output_dir))
        if not out.is_dir():
            raise InvalidPlan('output directory must already exist')
        inventory, closure, pins = plan['sourceInventory'], plan['importClosure'], plan['pins']
        if not isinstance(pins, dict):
            raise InvalidPlan('pins must be a mapping')
        if not isinstance(inventory, dict) or not isinstance(closure, list) or len(closure) != len(set(closure)) or set(closure) != set(inventory):
            raise InvalidPlan('inventory/closure mismatch')
        for source, digest in inventory.items():
            _path(source)
            if _pinned(Path(source), pins) != digest:
                raise InvalidPlan('source pin mismatch: ' + source)
        if str(entry) not in inventory:
            raise InvalidPlan('entrypoint absent from inventory/closure')
        fd = os.open(entry, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
        with os.fdopen(fd, 'rb') as stream:
            if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):
                raise InvalidPlan('entrypoint must be a regular file')
            if hashlib.sha256(stream.read()).hexdigest() != inventory[str(entry)]:
                raise InvalidPlan('entrypoint bytes differ from pin')
        generated = _path(plan['generated'])
        expected_generated = out / ('scenario.js' if role == 'js' else 'scenario.c')
        if generated != expected_generated:
            raise InvalidPlan('generated output differs from fixed cohort path')
        native = _path(plan['native'])
        if native != out / 'scenario.native':
            raise InvalidPlan('native output differs from fixed cohort path')
        labels = ['emit', 'consumer'] if role == 'js' else ['emit', 'build', 'consumer']
        commands = plan['commands']
        if [command['label'] for command in commands] != labels:
            raise InvalidPlan('unexpected command stages/order')
        tools = plan['tools']
        required = ['python', 'taskset', 'bend', 'node'] if role == 'js' else ['python', 'taskset', 'bend', 'clangWrapper']
        for tool in required:
            _pinned(_path(tools[tool]), pins)
        expected_caps = [30, 5] if role == 'js' else [30, 120, 5]
        if any(type(command['capSeconds']) is not int for command in commands) or [command['capSeconds'] for command in commands] != expected_caps:
            raise InvalidPlan('development command caps differ from existing schema')
        first = commands[0]['argv']
        if not isinstance(first, list) or len(first) < 3 or first[:2] != [tools['taskset'], '-c'] or not isinstance(first[2], str) or re.fullmatch('[0-9]+', first[2]) is None:
            raise InvalidPlan('unsupported taskset prefix')
        prefix = first[:3]
        expected = [prefix + [tools['bend'], str(entry), '-o', str(generated)]]
        if role == 'js':
            expected += [prefix + [tools['node'], str(generated)]]
        else:
            expected += [prefix + [tools['clangWrapper'], '-O3', str(generated), '-o', str(native), '-pthread', '-lm'],
                         prefix + [str(native), '--threads', '1', '--gpu', 'off']]
        if [command['argv'] for command in commands] != expected:
            raise InvalidPlan('actual argv differs from pinned entry/artifact/tool joins')
        outputs = [generated, native]
        outputs += [out / 'receipt.json']
        for label in labels:
            outputs += [out / (label + '.stdout'), out / (label + '.stderr')]
            outputs += [out / (label + '-' + phase + '.guard.json') for phase in ('pre', 'acquired', 'post')]
        outputs += [out / 'final.guard.json']
        inputs = set(pins) | set(inventory) | {str(entry)}
        if len(outputs) != len(set(outputs)) or any(str(path) in inputs for path in outputs):
            raise InvalidPlan('output aliases frozen input or another output')
        for path in outputs:
            _path(str(path))
            if path.exists():
                raise InvalidPlan('output must start absent: ' + str(path))
        return tuple(str(path) for path in outputs)
    except (KeyError, TypeError, OSError) as error:
        raise InvalidPlan('malformed or inaccessible development plan: ' + str(error)) from error
