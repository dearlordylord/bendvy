"""Read-only pre-child command/artifact joins for detached-v2 development plans."""
import hashlib
import json
import os
from pathlib import Path
import re
import stat


class InvalidPlan(ValueError):
    pass


def validate_stderr_policy(plan):
    if 'consumerStderrPolicy' not in plan:
        return None
    policy = plan['consumerStderrPolicy']
    keys = {'kind', 'elapsedNs', 'bytes', 'digest', 'intervals'}
    if not isinstance(policy, dict) or set(policy) != keys:
        raise InvalidPlan('invalid consumer telemetry policy fields')
    if policy['kind'] != 'interval-telemetry-v1' or policy['elapsedNs'] != 'decimal-string':
        raise InvalidPlan('unsupported consumer telemetry policy')
    if any(type(policy[key]) is not int for key in ('bytes', 'digest', 'intervals')):
        raise InvalidPlan('telemetry expectations must be integers')
    if policy['bytes'] < 0 or not 0 <= policy['digest'] <= 0xffffffff or policy['intervals'] <= 0:
        raise InvalidPlan('invalid telemetry expectation bounds')
    if type(plan.get('oracleBytes')) is not int or policy['bytes'] != plan['oracleBytes']:
        raise InvalidPlan('telemetry byte count differs from full oracle')
    return policy


def validate_consumer_stderr(plan, stdout, stderr):
    policy = validate_stderr_policy(plan)
    if policy is None:
        if stderr:
            raise InvalidPlan('Consumer stderr is not empty')
        return None
    if not stderr.endswith(b'\n') or stderr.count(b'\n') != 1:
        raise InvalidPlan('telemetry must be exactly one LF-terminated JSON line')
    try:
        pairs = json.loads(stderr.decode('ascii'), object_pairs_hook=list)
        if not isinstance(pairs, list) or [key for key, _ in pairs] != ['elapsedNs', 'bytes', 'digest', 'intervals']:
            raise InvalidPlan('unexpected or duplicate telemetry keys')
        value = dict(pairs)
    except (UnicodeError, ValueError, TypeError) as error:
        raise InvalidPlan('invalid telemetry JSON') from error
    if stderr != (json.dumps(value, separators=(',', ':')) + '\n').encode('ascii'):
        raise InvalidPlan('telemetry JSON must use the declared compact encoding')
    if not isinstance(value['elapsedNs'], str) or re.fullmatch('[0-9]+', value['elapsedNs']) is None:
        raise InvalidPlan('elapsedNs must be an ASCII decimal string')
    if any(type(value[key]) is not int or value[key] != policy[key] for key in ('bytes', 'digest', 'intervals')):
        raise InvalidPlan('telemetry expectations differ')
    digest = 2166136261
    for byte in stdout:
        digest = ((digest ^ byte) * 16777619) & 0xffffffff
    if len(stdout) != value['bytes'] or digest != value['digest'] or len(stdout.splitlines()) != value['intervals']:
        raise InvalidPlan('telemetry differs from complete captured stdout')
    return value


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


def _ts_code(source):
    """Mask comments and strings for keyword detection; keep module literals separately."""
    clean = list(source)
    code = list(source)
    token = re.compile(r"//[^\n]*|/\*[\s\S]*?\*/|'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\"|`(?:\\.|[^`\\])*`")
    for match in token.finditer(source):
        value = match.group()
        for index in range(match.start(), match.end()):
            if source[index] != '\n':
                code[index] = ' '
                if value.startswith('//') or value.startswith('/*'):
                    clean[index] = ' '
        # This bounded syntax does not admit loading modules in template expressions.
        if value.startswith('`') and re.search(r'\bimport\b[\s\S]*\(', value):
            raise InvalidPlan('unsupported import in template expression')
    return ''.join(clean), ''.join(code)


def _ts_specifiers(source):
    clean, code = _ts_code(source)
    found, covered = [], []
    # Actual reference uses multiline named/type imports and barrel re-exports.
    static = re.compile(r"\b(?:import|export)\b\s*(?:type\s+)?[\w\s{},*$]+?\bfrom\s*(['\"])([^'\"\n]+)\1|\bimport\s*(['\"])([^'\"\n]+)\3")
    for match in static.finditer(clean):
        if not re.match(r'(?:import|export)\b', code[match.start():]):
            continue
        found.append(match.group(2) or match.group(4))
        covered.append((match.start(), match.end()))
    # Quoted export names and any other unsupported re-export clause must not
    # silently turn into a local export with no dependency edge.
    for match in re.finditer(r'\bexport\b\s*(?:type\s*)?(\*|\{)', code):
        if any(start <= match.start() < end for start, end in covered):
            continue
        if match.group(1) == '*':
            raise InvalidPlan('unsupported star re-export syntax')
        end = code.find('}', match.end())
        if end < 0 or re.match(r'\s*from\b', code[end + 1:]):
            raise InvalidPlan('unsupported named re-export syntax')
    # Literal import() edges include erased TS type queries. No type/runtime
    # classification is needed: every literal target must be inventoried.
    query = re.compile(r"\bimport\s*\(\s*(['\"])([^'\"\n]+)\1\s*\)")
    for match in query.finditer(clean):
        if not code[match.start():].startswith('import'):
            continue
        found.append(match.group(2))
        covered.append((match.start(), match.end()))
    for match in re.finditer(r'\bimport\b', code):
        if not any(start <= match.start() < end for start, end in covered):
            raise InvalidPlan('unsupported dynamic/computed/import syntax')
    return found


def validate_ts_imports(entry, inventory):
    """Exact source-bound TS/ESM closure; no package resolver or general TS parser."""
    reached = set()
    def visit(path):
        path = _path(str(path)).resolve(strict=True)
        if str(path) not in inventory:
            raise InvalidPlan('TS import escapes exact frozen source inventory')
        if not path.is_file():
            raise InvalidPlan('TS source must be a regular file')
        if path in reached:
            return
        if path.suffix not in ('.ts', '.mjs', '.js'):
            raise InvalidPlan('unsupported TS source extension')
        if hashlib.sha256(path.read_bytes()).hexdigest() != inventory[str(path)]:
            raise InvalidPlan('TS source bytes differ from frozen inventory')
        reached.add(path)
        for target in _ts_specifiers(path.read_text()):
            if not (target.startswith('./') or target.startswith('../') or target.startswith('/')):
                raise InvalidPlan('bare/package TS import is not admitted')
            if any(char in target for char in ('\\', '?', '#', '%')):
                raise InvalidPlan('unsupported TS module selector')
            # Relative ../ is legitimate inside the pinned graph; the resolved
            # target must still be regular, non-symlink and exactly inventoried.
            literal = path.parent / target
            if any(item.is_symlink() for item in (literal, *literal.parents)):
                raise InvalidPlan('symlink TS dependency')
            visit(literal.resolve(strict=True))
    visit(Path(entry))
    if {str(path) for path in reached} != set(inventory):
        raise InvalidPlan('TS consuming inventory has missing or unused entries')
    return sorted(str(path) for path in reached)


def validate(plan, *, output_dir):
    """Raise InvalidPlan before any child; return fixed fresh output paths.

    The collector passes actual plan_path.parent as output_dir. Stage remains
    metadata; legacy prepare uses its source directory, runtime03 its output.
    Existing guards remain responsible for complete pin/import/resource checks.
    """
    try:
        validate_stderr_policy(plan)
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
        if role not in ('ts', 'js', 'native'):
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
        expected_generated = out / ('scenario.js' if role in ('ts', 'js') else 'scenario.c')
        if generated != expected_generated:
            raise InvalidPlan('generated output differs from fixed cohort path')
        native = _path(plan['native'])
        if native != out / 'scenario.native':
            raise InvalidPlan('native output differs from fixed cohort path')
        labels = ['consumer'] if role == 'ts' else (['emit', 'consumer'] if role == 'js' else ['emit', 'build', 'consumer'])
        commands = plan['commands']
        if [command['label'] for command in commands] != labels:
            raise InvalidPlan('unexpected command stages/order')
        tools = plan['tools']
        required = ['python', 'taskset', 'node'] if role == 'ts' else (['python', 'taskset', 'bend', 'node'] if role == 'js' else ['python', 'taskset', 'bend', 'clangWrapper'])
        for tool in required:
            _pinned(_path(tools[tool]), pins)
        expected_caps = [5] if role == 'ts' else ([30, 5] if role == 'js' else [30, 120, 5])
        if any(type(command['capSeconds']) is not int for command in commands) or [command['capSeconds'] for command in commands] != expected_caps:
            raise InvalidPlan('development command caps differ from existing schema')
        first = commands[0]['argv']
        if not isinstance(first, list) or len(first) < 3 or first[:2] != [tools['taskset'], '-c'] or not isinstance(first[2], str) or re.fullmatch('[0-9]+', first[2]) is None:
            raise InvalidPlan('unsupported taskset prefix')
        prefix = first[:3]
        if role == 'ts':
            expected = [prefix + [tools['node'], str(entry)]]
        else:
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
