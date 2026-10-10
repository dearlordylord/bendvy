#!/usr/bin/env python3
"""Prepare finite automatic-App plans; execute only the unchanged leaf collector."""
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
        raise ValueError('Selected CPU11 must be allowed')
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
        raise ValueError('Preparation interpreter must be selected Python')
    output.mkdir()
    oracle_paths = {}
    for subject, name, expected_sha in (
        ('normal', 'normal', 'bc1b4261fdb46bb20439688160d13d064b3f65452827f0dcbc796c396ed74e60'),
        ('mutant', 'filter', 'a7c06aac98e8d335e3f003f0749c1190bb6858fd0843471e4778092a021aeb56')):
        raw = (HERE / 'oracle-v1' / (name + '-expected.stdout')).read_bytes()
        if hashlib.sha256(raw).hexdigest() != expected_sha:
            raise ValueError('Independent complete oracle changed')
        oracle_paths[subject] = (output / (subject + '-expected.stdout.gz'), raw)
        oracle_paths[subject][0].write_bytes(gzip.compress(raw, mtime=0))
    if oracle_paths['normal'][1] == oracle_paths['mutant'][1]:
        raise ValueError('Reached control must reject complete normal oracle')
    # Only preparation/subject/oracle joins differ. Execution implementation,
    # guards, shared lock, raw streams and terminal receipt are reused byte-exact.
    extras = [COLLECTOR, Path(__file__), config_path, runner_path,
              ROOT / 'scripts/evidence_boundary.py', HERE / 'SOURCE.json',
              HERE / 'SOURCE-MUTANT.json', HERE / 'ORACLE-PROVENANCE.json', HERE / 'README.md']
    extras.extend(path for path in (HERE / 'oracle-v1').rglob('*') if path.is_file())
    extras.extend(path for path in (HERE / 'checks/normal-source11').iterdir() if path.is_file())
    extras.extend(path for path in (HERE / 'checks/filter-source01').iterdir() if path.is_file())
    extras.extend(Path(value) for value in tools.values())
    extras.extend(oracle_paths[subject][0] for subject in oracle_paths)
    shared_pins = {str(path.resolve(strict=True)): collector.sha(path) for path in extras}
    rows = []
    for role, subject in [('js', 'normal'), ('js', 'mutant'), ('native', 'normal'), ('native', 'mutant')]:
        manifest_name = 'SOURCE.json' if subject == 'normal' else 'SOURCE-MUTANT.json'
        manifest = json.loads((HERE / manifest_name).read_text())
        inventory = manifest['sourceInventory']
        entry = Path(manifest['entrypoint'])
        if {path: collector.sha(path) for path in inventory} != inventory:
            raise ValueError('Frozen source inventory changed')
        closure = collector.validate_imports(entry, inventory)
        check = HERE / 'checks' / ('normal-source11' if subject == 'normal' else 'filter-source01')
        result = json.loads((check / 'receipt.json').read_text())
        if result['exitCode'] != 0 or 'ALL PROOFS CHECK' not in (check / 'stdout').read_text():
            raise ValueError('Development source prerequisite not satisfied')
        stage = output / (subject + '-' + role)
        stage.mkdir()
        generated = stage / ('scenario.c' if role == 'native' else 'scenario.js')
        native = stage / 'scenario.native'
        commands = [{'label': 'emit', 'argv': [tools['taskset'], '-c', '11', tools['bend'], str(entry), '-o', str(generated)], 'capSeconds': 30}]
        if role == 'native':
            commands += [{'label': 'build', 'argv': [tools['taskset'], '-c', '11', tools['clangWrapper'], '-O3', str(generated), '-o', str(native), '-pthread', '-lm'], 'capSeconds': 120},
                         {'label': 'consumer', 'argv': [tools['taskset'], '-c', '11', str(native), '--threads', '1', '--gpu', 'off'], 'capSeconds': 5}]
        else:
            commands += [{'label': 'consumer', 'argv': [tools['taskset'], '-c', '11', tools['node'], str(generated)], 'capSeconds': 5}]
        oracle_path, raw = oracle_paths[subject]
        baseline_path, baseline = oracle_paths['normal']
        plan = {'scope': 'Complete finite two-schema automatic App registration/descriptions and detached snapshots '+subject+' '+role+'; no body execution/schedule/full56/performance claim',
                'role': role, 'subject': subject, 'entrypoint': str(entry), 'stage': str(HERE),
                'sourceInventory': inventory, 'importClosure': closure, 'pins': inventory | shared_pins,
                'resourceRoots': resources, 'environment': config.environment(), 'cwd': str(HERE),
                'tools': tools, 'commands': commands, 'oracle': str(oracle_path),
                'oracleSHA256': hashlib.sha256(raw).hexdigest(), 'oracleBytes': len(raw),
                'normalOracle': str(baseline_path), 'normalOracleSHA256': hashlib.sha256(baseline).hexdigest(),
                'normalOracleBytes': len(baseline), 'generated': str(generated), 'native': str(native),
                'postConsumer': 'Entire independently authored stdout equality; reached Inspector control rejects entire normal baseline; empty runtime stderr',
                'sourceEvidenceScope': 'Routine development cap5 success; no portable pre/post source acceptance claim',
                'executionReuse': {'collector': str(COLLECTOR), 'sha256': collector.sha(COLLECTOR), 'unchanged': True},
                'cpuSelection': {'cpu': 11, 'allowedAtPreparation': sorted(os.sched_getaffinity(0)), 'scope': 'Functional execution only; no resource or performance comparison'}}
        plan_path = stage / 'plan.json'
        plan_path.write_text(json.dumps(plan, indent=2)+'\n')
        rows.append({'role': role, 'subject': subject, 'path': str(plan_path), 'sha256': collector.sha(plan_path),
                     'execute': [tools['python'], str(COLLECTOR), 'run', str(plan_path), '--admitted-sha256', collector.sha(plan_path)]})
    (output / 'SEQUENCE.json').write_text(json.dumps({'sequence': rows, 'condition': 'Run once in listed order. Stop on any failed receipt; no unchanged retry. Native only after both JS whole-oracle successes.', 'unchangedCollector': collector.sha(COLLECTOR)}, indent=2)+'\n')
    print(json.dumps(rows, indent=2))


if __name__ == '__main__':
    main()
