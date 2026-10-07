#!/usr/bin/env python3
"""Observe pinned public hierarchy behavior; no Bend capability acceptance."""
import hashlib
import json
import os
from pathlib import Path
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import task_runner


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inventory():
    files = set((ROOT / '.references/bevy-ts/packages/core/src').rglob('*.ts'))
    files.update(HERE / name for name in ('reference.mjs', 'run-reference.py', 'README.md'))
    files.update(ROOT / name for name in ('.references/sources.json', 'scripts/task_runner.py'))
    files.update(ROOT / '.references' / name / file for name, file in (
        ('bevy', 'crates/bevy_ecs/src/hierarchy.rs'),
        ('bend2', 'bend2/base.bend')))
    return {str(p.relative_to(ROOT)): sha(p) for p in sorted(files)}


def main():
    out = HERE / 'evidence' / ('reference-' + str(time.time_ns()))
    out.mkdir(parents=True)
    pins = inventory()
    manifest = json.loads((ROOT / '.references/sources.json').read_text())['sources']
    receipt = {'status': 'INCOMPLETE', 'sources': pins, 'commands': [],
               'scope': 'Public TS hierarchy observations only; no Bend parity, affine disposal, proof or performance acceptance.'}

    def save():
        (out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')

    def run(label, argv):
        assert inventory() == pins, 'input byte or membership drift'
        result = task_runner.execute_result(argv, 5, env=dict(os.environ, BEND_NO_TELEMETRY='1'), capture='split')
        stdout = out / (label + '.stdout')
        stderr = out / (label + '.stderr')
        stdout.write_bytes(result['stdout'])
        stderr.write_bytes(result['stderr'])
        receipt['commands'].append({'label': label, 'argv': list(map(str, argv)), 'capSeconds': 5,
            **{k: v for k, v in result.items() if k not in ('stdout', 'stderr')},
            'stdoutSHA256': sha(stdout), 'stderrSHA256': sha(stderr)})
        save()
        assert result['failure'] is None and result['exit'] == 0, (label, result['failure'], result['stderr'])
        assert not result['stderr'], (label, result['stderr'])
        assert inventory() == pins, 'in-flight input drift'
        return result['stdout']

    save()
    try:
        for name, entry in manifest.items():
            assert run('head-' + name, ['git', '-C', str(ROOT / '.references' / name), 'rev-parse', 'HEAD']).decode().strip() == entry['commit']
        run('node-version', ['node', '--version'])
        data = json.loads(run('hierarchy', ['node', str(HERE / 'reference.mjs')]))
        assert [x['root'] for x in data] == ['HierarchyAlpha', 'HierarchyBeta']
        assert [len(x['records']) for x in data] == [23, 23]
        receipt.update(status='PUBLIC_TS_HIERARCHY_OBSERVED', schemas=2, records=46)
    except Exception as error:
        receipt['error'] = repr(error)
        raise
    finally:
        save()
        print(out, receipt['status'])


if __name__ == '__main__':
    main()
