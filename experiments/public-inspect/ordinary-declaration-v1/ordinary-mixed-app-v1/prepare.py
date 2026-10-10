#!/usr/bin/env python3
"""Prepare complete mixed App cohorts for the unchanged guarded leaf collector."""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import types

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
COLLECTOR = ROOT / 'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py'


def load(name, path):
    module = types.ModuleType(name)
    module.__file__ = str(path)
    exec(compile(path.read_bytes(), str(path), 'exec'), module.__dict__)
    return module


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output')
    args = parser.parse_args()
    output = Path(args.output).resolve()
    if output.exists() or output.is_symlink():
        raise ValueError('Fresh preparation directory required')
    if 11 not in os.sched_getaffinity(0):
        raise ValueError('CPU11 must be allowed')
    collector = load('reviewed_leaf', COLLECTOR)
    config_path = ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
    config = load('selected_config', config_path)
    runner_path = ROOT / 'scripts/task_runner.py'
    runner = load('reviewed_runner', runner_path)
    resources = runner.Inputs(directories=config.RESOURCE_ROOTS).expected
    tools = {'bend': '/home/node/.bend/bin/bend-2.0.35',
             'node': '/home/node/.local/share/mise/installs/node/24.20.0/bin/node',
             'python': '/usr/bin/python3.11', 'taskset': '/usr/bin/taskset',
             'clangWrapper': '/tmp/bendvy-clang19-diagnostic/clang19',
             'clangBinary': '/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang'}
    if Path(tools['python']).resolve() != Path(os.sys.executable).resolve():
        raise ValueError('Use selected preparation Python')
    catalogue = json.loads((HERE / 'oracle-v1/ORACLES.json').read_text())
    eof = json.loads((HERE / 'PRODUCTION-EOF-TRANSPORT.json').read_text())
    transport = {row['file']: row for row in eof['rows'] if row['nonWhitespaceEqual']}
    checked_transport_paths = []
    for path, row in transport.items():
        archive = Path(path).parent / 'checks/eof-transport-repair/checked-input.bend.source.gz'
        checked_raw = gzip.decompress(archive.read_bytes())
        current_raw = Path(path).read_bytes()
        if (hashlib.sha256(checked_raw).hexdigest() != row['checkedRawSha256']
                or hashlib.sha256(current_raw).hexdigest() != row['currentSha256']
                or checked_raw.split() != current_raw.split()):
            raise ValueError('Historical/current EOF transport join changed')
        checked_transport_paths.append(archive)
    selections = {}
    for key, selection in catalogue.items():
        raw = gzip.decompress((HERE / 'oracle-v1' / (key + '.stdout.gz')).read_bytes())
        if len(raw) != selection['bytes'] or hashlib.sha256(raw).hexdigest() != selection['sha256']:
            raise ValueError('Independent whole oracle drift: ' + key)
        manifest = json.loads(Path(selection['sourceManifest']).read_text())
        inventory = manifest['sourceInventory']
        entry = Path(manifest['entrypoint'])
        if {path: collector.sha(path) for path in inventory} != inventory:
            raise ValueError('Current frozen source drift: ' + key)
        closure = collector.validate_imports(entry, inventory)
        schema = 'a' if key.startswith('a-') else 'other'
        if key.endswith('companion'):
            check = HERE / 'checks' / ('full-a05' if schema == 'a' else 'full-other02')
        else:
            check = entry.parent / 'checks' / ('a01' if schema == 'a' else 'other01')
        terminal = json.loads((check / 'terminal.json').read_text())
        if terminal['exitCode'] != 0 or b'ALL PROOFS CHECK' not in (check / 'stdout').read_bytes():
            raise ValueError('Development source prerequisite missing: ' + key)
        checked = terminal['sourceInventory']
        if set(checked) != set(inventory):
            raise ValueError('Checked/current subject membership differs')
        for path, old_sha in checked.items():
            if old_sha == inventory[path]:
                continue
            row = transport.get(path)
            if row is None or row['checkedRawSha256'] != old_sha or row['currentSha256'] != inventory[path]:
                raise ValueError('Unreviewed source delta since check')
        selections[key] = (entry, inventory, closure, check, raw)
    for schema in ('a', 'other'):
        if selections[schema + '-normal'][4] == selections[schema + '-cursor-control'][4]:
            raise ValueError('Reached control must reject full normal baseline')
    extras = [COLLECTOR, Path(__file__), config_path, runner_path, ROOT / 'scripts/evidence_boundary.py',
              HERE / 'PRODUCTION-SOURCE.json', HERE / 'PRODUCTION-EOF-TRANSPORT.json',
              HERE / 'PRODUCTION-CHECK-PLAN.json', HERE / 'BACKEND-SCOPE.md', HERE / 'ORACLE-PROVENANCE.json']
    extras.extend(path for path in (HERE / 'oracle-v1').rglob('*') if path.is_file())
    extras.extend(Path(value) for value in tools.values())
    extras.extend(checked_transport_paths)
    for entry, inventory, closure, check, raw in selections.values():
        extras.extend(path for path in check.iterdir() if path.is_file())
    extras.extend(Path(selection['sourceManifest']) for selection in catalogue.values())
    extras.extend(HERE / folder / 'README.md' for folder in ('production-factory-v1', 'production-cursor-control-v1'))
    shared = {str(path.resolve(strict=True)): collector.sha(path) for path in extras}
    sequence = [('js', key) for key in ('a-normal', 'other-normal', 'a-cursor-control',
                                       'other-cursor-control', 'a-companion', 'other-companion')]
    sequence += [('native', key) for key in ('a-normal', 'other-normal', 'a-cursor-control', 'other-cursor-control')]
    output.mkdir()
    rows = []
    for role, key in sequence:
        entry, inventory, closure, check, raw = selections[key]
        schema = 'a' if key.startswith('a-') else 'other'
        subject = 'mutant' if key.endswith('cursor-control') else 'normal'
        baseline_key = schema + ('-companion' if key.endswith('companion') else '-normal')
        oracle = HERE / 'oracle-v1' / (key + '.stdout.gz')
        baseline = HERE / 'oracle-v1' / (baseline_key + '.stdout.gz')
        baseline_raw = selections[baseline_key][4]
        stage = output / (key + '-' + role)
        stage.mkdir()
        generated = stage / ('scenario.c' if role == 'native' else 'scenario.js')
        native = stage / 'scenario.native'
        commands = [{'label': 'emit', 'argv': [tools['taskset'], '-c', '11', tools['bend'], str(entry), '-o', str(generated)], 'capSeconds': 30}]
        if role == 'native':
            commands += [{'label': 'build', 'argv': [tools['taskset'], '-c', '11', tools['clangWrapper'], '-O3', str(generated), '-o', str(native), '-pthread', '-lm'], 'capSeconds': 120},
                         {'label': 'consumer', 'argv': [tools['taskset'], '-c', '11', str(native), '--threads', '1', '--gpu', 'off'], 'capSeconds': 5}]
        else:
            commands += [{'label': 'consumer', 'argv': [tools['taskset'], '-c', '11', tools['node'], str(generated)], 'capSeconds': 5}]
        plan = {'scope': 'Complete finite ordinary mixed App ' + key + ' ' + role + '; no schedule/performance/full56 qualification',
                'role': role, 'subject': subject, 'cohort': key, 'entrypoint': str(entry), 'stage': str(HERE),
                'sourceInventory': inventory, 'importClosure': closure, 'pins': inventory | shared,
                'resourceRoots': resources, 'environment': config.environment(), 'cwd': str(HERE),
                'tools': tools, 'commands': commands, 'oracle': str(oracle),
                'oracleSHA256': hashlib.sha256(raw).hexdigest(), 'oracleBytes': len(raw),
                'normalOracle': str(baseline), 'normalOracleSHA256': hashlib.sha256(baseline_raw).hexdigest(),
                'normalOracleBytes': len(baseline_raw), 'generated': str(generated), 'native': str(native),
                'sourceEvidenceScope': 'Development cap5 success on checked bytes; EOF-only token-equal successor explicit; no portable source acceptance',
                'postConsumer': 'Entire independent stdout equality; reached cursor control rejects entire corresponding production baseline; empty runtime stderr',
                'executionReuse': {'collector': str(COLLECTOR), 'sha256': collector.sha(COLLECTOR), 'unchanged': True},
                'cpuSelection': {'cpu': 11, 'allowedAtPreparation': sorted(os.sched_getaffinity(0)), 'scope': 'Functional checks only'}}
        path = stage / 'plan.json'
        path.write_text(json.dumps(plan, indent=2) + '\n')
        digest = collector.sha(path)
        rows.append({'role': role, 'cohort': key, 'path': str(path), 'sha256': digest,
                     'execute': [tools['python'], str(COLLECTOR), 'run', str(path), digest]})
    (output / 'SEQUENCE.json').write_text(json.dumps({'sequence': rows, 'condition': 'Once in listed order, each conditional on preceding whole PASS. Stop any failure; no unchanged retries.', 'unchangedCollector': collector.sha(COLLECTOR)}, indent=2) + '\n')
    print(json.dumps(rows, indent=2))


if __name__ == '__main__':
    main()
