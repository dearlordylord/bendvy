"""Exact private component overlay on unchanged ordinary-v7 source preparation."""
import importlib.util
import os
from pathlib import Path
BASE_PATH = Path('/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/ordinary-evidence-v7/prepare-current.py')
SPEC = importlib.util.spec_from_file_location('tx_get_fusion_base_prepare', BASE_PATH)
BASE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BASE)
SUBJECT = BASE.SUBJECT
archived = BASE.archived
digest = BASE.digest
CANDIDATE = Path('/workspace/formal-proofs/bendvy-worktrees/identity38-io-creation/src/ecs/component.bend')
CANDIDATE_SHA256 = '2ac93488b8ffb14d81c33325f4affd284eb2f7484c7c2831d1decf63a0d43c52'
BEFORE_SHA256 = '0e41557cc6b8101490eaa7f4bf5fbdf896a2646e9b2359d7daf41db6de45988c'
def expected_stage():
    manifest, transformed = BASE.expected_stage()
    rel = 'src/ecs/component.bend'
    if manifest['sources'][rel]['inputSha256'] != BEFORE_SHA256:
        raise ValueError('component baseline drift')
    raw = BASE.regular_bytes(CANDIDATE)
    if digest(raw) != CANDIDATE_SHA256:
        raise ValueError('private candidate drift')
    def relocate(match):
        prefix, target, suffix = match.groups()
        if target == 'Base':
            return match.group(0)
        dependency = os.path.normpath(str(Path(rel).parent / target))
        if dependency not in transformed:
            raise ValueError('candidate import outside qualified stage')
        target = os.path.relpath(dependency, str(Path(rel).parent))
        if not target.startswith('.'):
            target = './' + target
        return prefix + target + suffix
    staged = BASE.IMPORT.sub(relocate, raw.decode()).encode()
    transformed[rel] = staged
    manifest['sources'][rel]['inputSha256'] = CANDIDATE_SHA256
    manifest['sources'][rel]['stagedSha256'] = digest(staged)
    manifest['experiment'] = 'tx_get return fusion only; root input is unchanged'
    return manifest, transformed
