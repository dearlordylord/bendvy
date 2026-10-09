#!/usr/bin/env python3
"""Stage the complete ECS consumer with relative imports; launch no backend."""
import argparse
import hashlib
import io
import stat
import json
import os
import re
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SUBJECT = HERE.parent / 'bend-v1'
IMPORT = re.compile(r'^(import\s+)(\S+)(.*)$', re.MULTILINE)
HISTORICAL_CORE = '/workspace/formal-proofs/bendvy/src/ecs/'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def regular_bytes(path):
    """Refuse leaf aliases/non-files before consuming immutable input bytes."""
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, 'rb') as stream:
        if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):
            raise ValueError('regular preparation input required')
        return stream.read()


def archived():
    index = json.loads(regular_bytes(SUBJECT / 'development-evidence-index.json'))
    with tarfile.open(fileobj=io.BytesIO(regular_bytes(SUBJECT / 'development-evidence.tar.gz'))) as archive:
        members = archive.getmembers()
        names = [m.name for m in members]
        assert len(names) == len(set(names)) and set(names) == set(index)
        assert all(m.isfile() for m in members)
        data = {m.name: archive.extractfile(m).read() for m in members}
    assert all(digest(data[name]) == expected for name, expected in index.items())
    return data


def relative_source(recorded):
    if recorded.startswith(HISTORICAL_CORE):
        return 'src/ecs/' + recorded[len(HISTORICAL_CORE):]
    assert recorded.startswith('experiments/public-simulation/')
    assert '..' not in Path(recorded).parts and not Path(recorded).is_absolute()
    return recorded


def expected_stage():
    archive = archived()
    pins = json.loads(archive['full-js-v1/sources.json'])
    correction = json.loads(regular_bytes(SUBJECT / 'candidate-source-correction.json'))
    sources = {}
    for recorded, expected in pins.items():
        relative = relative_source(recorded)
        current = regular_bytes(ROOT / relative)
        if digest(current) != expected:
            assert relative == 'experiments/public-simulation/bend-v1/geometry.bend'
            assert expected == correction['executedSha256']
            assert digest(current) == correction['candidateSha256']
            assert archive[correction['executedArchiveMember']] == current + b'\n'
        assert relative not in sources
        sources[relative] = current
    transformed = {}
    for relative, original in sources.items():
        def relocate(match):
            prefix, target, suffix = match.groups()
            if target == 'Base':
                return match.group(0)
            if target.startswith(HISTORICAL_CORE):
                dependency = relative_source(target)
            else:
                assert not Path(target).is_absolute() and target.endswith('.bend'), ('Unexpected import', relative, target)
                dependency = os.path.normpath(str(Path(relative).parent / target))
            assert dependency in sources, ('Unfrozen dependency', relative, dependency)
            target = os.path.relpath(dependency, str(Path(relative).parent))
            if not target.startswith('.'):
                target = './' + target
            return prefix + target + suffix
        transformed[relative] = IMPORT.sub(relocate, original.decode()).encode()
    # Historical raw evidence remains unchanged; the relocated program has not run.
    manifest = {'scope': 'Relocated execution preparation only; no backend acceptance.',
                'entry': 'experiments/public-simulation/bend-v1/main.bend',
                'sources': {name: {'inputSha256': digest(sources[name]),
                                  'stagedSha256': digest(value)}
                            for name, value in sorted(transformed.items())},
                'base': {'name': 'Base', 'qualification': 'Installed Base/tool identity must be frozen by execution cohort.'}}
    return manifest, transformed


def prepare(destination):
    assert not destination.exists(), 'Refuse to overwrite a stage'
    manifest, transformed = expected_stage()
    for relative, value in transformed.items():
        path = destination / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(value)
    (destination / 'stage.json').write_text(json.dumps(manifest, indent=2) + '\n')
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('destination', type=Path)
    arguments = parser.parse_args()
    result = prepare(arguments.destination.resolve())
    print(json.dumps({'sources': len(result['sources']), 'entry': result['entry'], 'scope': result['scope']}))
