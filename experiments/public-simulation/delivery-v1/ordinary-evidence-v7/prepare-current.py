"""Build the current-root full source stage for the ordinary #63 successor."""
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import stat

HERE = Path(__file__).resolve().parent
DELIVERY = HERE.parent
ROOT = HERE.parents[3]
LEGACY_PATH = DELIVERY / 'prepare.py'
LEGACY_SPEC = importlib.util.spec_from_file_location('ordinary_v6_prepare', LEGACY_PATH)
LEGACY = importlib.util.module_from_spec(LEGACY_SPEC)
LEGACY_SPEC.loader.exec_module(LEGACY)

SUBJECT = LEGACY.SUBJECT
HISTORICAL_CORE = LEGACY.HISTORICAL_CORE
IMPORT = LEGACY.IMPORT
archived = LEGACY.archived
digest = LEGACY.digest
relative_source = LEGACY.relative_source
TRANSITIONS_PATH = HERE / 'source-transitions.json'
V6_PLAN_PATH = DELIVERY / 'ordinary-evidence-v6' / 'archive' / '000-bendvy63-ordinary-delivery-plan-v6.json.gz'


def regular_bytes(path):
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, 'rb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):
            raise ValueError('regular current-source input required')
        return stream.read()


def reachable(entry, transformed):
    found = set()
    pending = [entry]
    while pending:
        relative = pending.pop()
        if relative in found:
            continue
        if relative not in transformed:
            raise ValueError(f'unpinned reachable source: {relative}')
        found.add(relative)
        for match in IMPORT.finditer(transformed[relative].decode()):
            target = match.group(2)
            if target == 'Base':
                continue
            dependency = os.path.normpath(str(Path(relative).parent / target))
            if dependency not in transformed:
                raise ValueError(f'unpinned import: {relative} -> {dependency}')
            pending.append(dependency)
    return sorted(found)


def expected_stage():
    historical = archived()
    source_pins = json.loads(historical['full-js-v1/sources.json'])
    transitions = json.loads(regular_bytes(TRANSITIONS_PATH))
    old_plan = json.loads(gzip.decompress(regular_bytes(V6_PLAN_PATH)))
    if digest(gzip.decompress(regular_bytes(V6_PLAN_PATH))) != transitions['historicalPlanSha256']:
        raise ValueError('historical v6 plan binding changed')
    if old_plan.get('scope') != 'Complete relocated106-source fixed simulation JS/Native and observed pinnedTS; ordinary snapshot/verify, no closed resolver/timing/fullparity claim':
        raise ValueError('unexpected v6 plan scope')

    changed = transitions['currentUnreachableTransitions']
    correction = json.loads(regular_bytes(SUBJECT / 'candidate-source-correction.json'))
    sources = {}
    for recorded, historical_sha in source_pins.items():
        relative = relative_source(recorded)
        current = regular_bytes(ROOT / relative)
        current_sha = digest(current)
        if current_sha != historical_sha:
            if relative == 'experiments/public-simulation/bend-v1/geometry.bend':
                expected_geometry = transitions['recordedGeometryCorrection']
                if (historical_sha != expected_geometry['historicalSha256']
                        or current_sha != expected_geometry['currentSha256']
                        or historical_sha != correction['executedSha256']
                        or current_sha != correction['candidateSha256']
                        or historical[correction['executedArchiveMember']] != current + b'\n'):
                    raise ValueError('recorded geometry EOF correction changed')
            else:
                transition = changed.get(relative)
                if transition != {'historicalSha256': historical_sha, 'currentSha256': current_sha}:
                    raise ValueError(f'unreviewed current-source drift: {relative}')
        elif relative in changed:
            raise ValueError(f'recorded source transition no longer applies: {relative}')
        sources[relative] = current

    if set(changed) != {
        'src/ecs/inspector-query-projection.bend',
        'src/ecs/inspector-query.bend',
        'src/ecs/schema-fragments.bend',
        'src/ecs/world-io.bend',
    }:
        raise ValueError('current-source transition scope changed')

    transformed = {}
    for relative, original in sources.items():
        def relocate(match):
            prefix, target, suffix = match.groups()
            if target == 'Base':
                return match.group(0)
            if target.startswith(HISTORICAL_CORE):
                dependency = relative_source(target)
            else:
                if Path(target).is_absolute() or not target.endswith('.bend'):
                    raise ValueError(f'unexpected import: {relative} -> {target}')
                dependency = os.path.normpath(str(Path(relative).parent / target))
            if dependency not in sources:
                raise ValueError(f'unfrozen dependency: {relative} -> {dependency}')
            target = os.path.relpath(dependency, str(Path(relative).parent))
            if not target.startswith('.'):
                target = './' + target
            return prefix + target + suffix
        transformed[relative] = IMPORT.sub(relocate, original.decode()).encode()

    entry = 'experiments/public-simulation/bend-v1/main.bend'
    current_reachable = reachable(entry, transformed)
    if len(sources) != 106 or len(current_reachable) != 51:
        raise ValueError('current full-stage/import-closure shape changed')
    if set(changed).intersection(current_reachable):
        raise ValueError('changed non-reachable source entered the compiled import closure')
    manifest = {
        'scope': 'Current-root 106-source stage; all 51 entry-reachable sources match current root bytes after exact import relocation; semantic delivery only.',
        'entry': entry,
        'sources': {
            name: {
                'historicalInputSha256': source_pins[recorded],
                'inputSha256': digest(sources[name]),
                'stagedSha256': digest(value),
            }
            for recorded, name in sorted((recorded, relative_source(recorded)) for recorded in source_pins)
            for value in (transformed[name],)
        },
        'sourceAudit': {
            'sourceCount': len(sources),
            'reachableCount': len(current_reachable),
            'reachableSources': current_reachable,
            'currentUnreachableTransitions': sorted(changed),
            'historicalPlanSha256': transitions['historicalPlanSha256'],
        },
        'base': {'name': 'Base', 'qualification': 'Installed Base/tool identity is frozen by the successor execution plan.'},
    }
    return manifest, transformed


def prepare(destination):
    destination = Path(destination)
    if destination.exists() or destination.is_symlink():
        raise ValueError('refuse to overwrite a current-source stage')
    manifest, transformed = expected_stage()
    for relative, contents in transformed.items():
        path = destination / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(contents)
    (destination / 'stage.json').write_text(json.dumps(manifest, indent=2) + '\n')
    return manifest
