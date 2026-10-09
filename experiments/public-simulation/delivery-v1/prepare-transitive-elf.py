"""Prepare readelf for observed targets only; never execute a child or scan a tree."""
import hashlib
import json
import os
from pathlib import Path
import stat
import types
HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def regular_bytes(path):
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    try:
        if not stat.S_ISREG(os.fstat(fd).st_mode):
            raise ValueError('Preparation input must be a regular file')
        with os.fdopen(fd, 'rb', closefd=False) as source:
            return source.read()
    finally:
        os.close(fd)

def target_paths(value):
    targets = value['actualLoadedTargetPaths']
    if not targets or targets != sorted(set(targets)):
        raise ValueError('Observed target inventory must be nonempty sorted unique')
    if any(not isinstance(p, str) or not p.startswith('/') or '..' in Path(p).parts for p in targets):
        raise ValueError('Observed target must be an absolute path without parent traversal')
    actual = sorted({entry['path'] for role in value['actualLoadedBySubject'].values() for entry in role['actualLoaded']})
    if targets != actual:
        raise ValueError('Observed targets must exactly equal actual loader lists')
    return targets

def prepare():
    evidence = HERE / 'metadata-evidence-v5'
    verify_path = evidence / 'verify.py'
    module = types.ModuleType('historical_v5_archive'); module.__file__ = str(verify_path)
    exec(compile(regular_bytes(verify_path), str(verify_path), 'exec'), module.__dict__)
    old, receipt, raws = module.verified()
    value = json.loads(regular_bytes(evidence / 'LOADER-TARGETS.json'))
    if value['actualPlanSHA256'] != receipt['planSHA256'] or value['qualifiesClosedResolver'] is not False:
        raise ValueError('Target inventory provenance mismatch')
    derive_path = evidence / 'derive-loader.py'
    derived = types.ModuleType('historical_v5_targets'); derived.__file__ = str(derive_path)
    exec(compile(regular_bytes(derive_path), str(derive_path), 'exec'), derived.__dict__)
    if derived.derive() != value:
        raise ValueError('Target summary differs from verified archived raw derivation')
    targets = target_paths(value)
    output = Path('/tmp/bendvy63-transitive-elf-v6')
    if output.exists() or output.is_symlink():
        raise ValueError('Metadata output root must start absent')
    pins = dict(old['pins'])
    # Only execution helpers refresh: tools/configs remain tied to actual v5 bytes.
    for path, digest in list(pins.items()):
        raw = regular_bytes(path)
        if path.startswith(str(ROOT)) and path.endswith('.py') and not path.endswith('/installed-config.py'):
            pins[path] = sha(raw)
        elif sha(raw) != digest:
            raise ValueError('Historical tool/config input changed: ' + path)
    helper = ROOT / 'experiments/public-simulation/delivery-v1/prepare-metadata.py'
    namespace_module = types.ModuleType('current_namespace'); namespace_module.__file__ = str(helper)
    source = regular_bytes(helper)
    if sha(source) != pins[str(helper)]:
        raise ValueError('Current preparation helper changed before loading')
    exec(compile(source, str(helper), 'exec'), namespace_module.__dict__)
    literals = list(old['namespaceLiterals']) + targets
    namespace = namespace_module.namespace_state(literals)
    for path in targets:
        resolved = namespace['aliases'][path]['resolved']
        pins[resolved] = sha(regular_bytes(resolved))
    # Exact archive/import closure is bound, not merely its summary JSON.
    manifest = json.loads(regular_bytes(evidence / 'MANIFEST.json'))
    files = [Path(__file__), HERE / 'test-transitive-elf-plan.py', verify_path, evidence / 'MANIFEST.json', evidence / 'LOADER-TARGETS.json', evidence / 'derive-loader.py']
    files += [evidence / row['archive'] for row in manifest['members']]
    for file in files:
        pins[str(file.resolve(strict=True))] = sha(regular_bytes(file))
    taskset = old['commands'][0]['argv'][0]
    readelf = '/usr/bin/aarch64-linux-gnu-readelf'
    if readelf not in pins:
        raise ValueError('Existing readelf tool pin missing')
    commands = []
    for index, path in enumerate(targets):
        label = 'transitive-' + str(index).zfill(2)
        commands.append({'label': label, 'argv': [taskset, '-c', '5', readelf, '-l', '-d', namespace['aliases'][path]['resolved']], 'capSeconds': 5, 'stdout': str(output / (label + '.stdout')), 'stderr': str(output / (label + '.stderr'))})
    return {'scope': 'Observed loader target ELF metadata only; no target main, recursive search or compiler/header/linker/runtime closure', 'status': 'PREPARED_NOT_EXECUTED', 'outputRoot': str(output), 'commands': commands, 'pins': pins, 'python': old['python'], 'environment': old['environment'], 'lock': old['lock'], 'namespaceLiterals': literals, 'namespace': namespace, 'collector': old['collector'], 'actualPriorPlanSHA256': receipt['planSHA256'], 'closedResolverQualified': False, 'nextBoundary': 'Expand transitive RPATH/RUNPATH candidates from actual ELF metadata; observed resolutions are not proof of absent alternate search candidates or legacy HWCAP ordering'}

if __name__ == '__main__':
    print(json.dumps(prepare(), indent=2))
