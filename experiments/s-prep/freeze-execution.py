#!/usr/bin/env python3
"""Freeze a proposed execution boundary; no acceptance/session/start receipt."""
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
spec = importlib.util.spec_from_file_location('boundary', HERE / 'segment-run.py')
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
sha = M.digest
names = subprocess.check_output(['git', 'ls-files', 'experiments'], cwd=ROOT, text=True).splitlines()
excluded = {*M.EDITABLE, 'experiments/s-prep/execution-proposal.json'}
protected = {name: sha(ROOT / name) for name in sorted(names) if name not in excluded}
tools = [Path(shutil.which(name)).resolve() for name in ('bend', 'node', 'clang', 'python3', 'git', 'taskset')]
tools.extend([Path('/home/node/.bend/bend2/base.bend'), Path('/home/node/.local/opt/dnd-clang14/usr/lib/llvm-14/bin/clang')])
record = {
    'status': 'PROPOSED_NOT_ACCEPTED',
    'baseline': subprocess.check_output(['git', 'rev-parse', '56b72f6'], cwd=ROOT, text=True).strip(),
    'deliverySourceCommit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
    'checkout': '/workspace/formal-proofs/bendvy-worktrees/autoresearch23-focus',
    'artifactRoot': str(M.ARTIFACTS), 'editable': sorted(M.EDITABLE), 'commitPaths': sorted(M.EDITABLE),
    'protectedSources': protected, 'tools': {str(path): sha(path) for path in tools},
    'commands': {'benchmark': 'python3 experiments/s-prep/segment-run.py benchmark',
                 'checks': 'python3 experiments/s-prep/segment-run.py checks'},
    'environment': dict(M.ENV, TMPDIR='task-owned per invocation under artifactRoot'),
    'metric': 'arithmetic mean of two seven-sample JS candidate cohort medians (ms), lower is better',
    'scopeRestriction': 'Existing imports/declaration/type/layout-preserving body edits only; occupancy representation needs integrated controls and explicit transition',
    'budgetSeconds': 3600, 'proposedPacketCap': 8,
    'checkCPU': 'main/owned/mutations/evaluator2; E11/access retain9',
    'referenceManifestSHA256': sha(HERE / 'baseline.json'),
}
(HERE / 'execution-proposal.json').write_text(json.dumps(record, indent=2)+'\n')
M.verify_manifest(record)
print(json.dumps({'status': 'PROPOSED_FROZEN_NOT_ACCEPTED', 'protectedFiles': len(protected), 'tools': len(tools)}))
