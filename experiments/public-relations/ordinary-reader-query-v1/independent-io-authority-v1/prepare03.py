"""Prepare the existing direct collector's exact JS -> Native plans; no child runs."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
COLLECTOR = ROOT / 'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py'

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def prepare(oracle_path):
    oracle = Path(oracle_path).resolve(strict=True)
    expected = gzip.decompress(oracle.read_bytes())
    basis = json.loads((oracle.parent / 'SOURCE-BASIS.json').read_text())
    assert basis['sourcePins']
    def basis_path(name):
        absolute = Path(name)
        if absolute.is_absolute() and (absolute.is_relative_to(ROOT / "src/ecs") or absolute.parent in (HERE, HERE.parent / "mutation-composition-v1")):
            return absolute
        if name in ('consumer.bend', 'main.bend', 'render.bend'):
            return HERE / name
        if name.startswith('mutation-composition-v1/'):
            return HERE.parent / name
        if name.startswith('src/ecs/'):
            return ROOT / name
        raise ValueError('Unknown oracle source label: ' + name)
    basis_pins = {str(basis_path(name).resolve(strict=True)): digest for name, digest in basis['sourcePins'].items()}
    assert all(sha(path) == digest for path, digest in basis_pins.items())
    assert expected and expected.endswith(b'\n') and len(expected.splitlines()) == 2
    collector = load('collector', COLLECTOR)
    runner = load('task_runner', ROOT / 'scripts/task_runner.py')
    config_path = ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
    config = load('installed_config', config_path)
    guard = load('plan_guard', collector.PLAN_GUARD)
    entry = HERE / 'main.bend'
    inventory = {}

    def visit(path):
        path = path.resolve(strict=True)
        if str(path) in inventory:
            return
        inventory[str(path)] = sha(path)
        for target in re.findall(r'^import\s+(\S+)', path.read_text(), re.M):
            if target != 'Base':
                visit(path.parent / target)

    visit(entry)
    closure = collector.validate_imports(entry, inventory)
    tools = {'bend': config.TOOL_PATHS['bend'], 'node': config.TOOL_PATHS['node'],
             'python': str(Path(sys.executable).resolve()), 'taskset': '/usr/bin/taskset',
             'clangWrapper': config.TOOL_PATHS['clangWrapper'], 'clangBinary': config.TOOL_PATHS['clang']}
    extra = [COLLECTOR, collector.PLAN_GUARD, ROOT / 'scripts/task_runner.py',
             ROOT / 'scripts/evidence_boundary.py', config_path, Path(__file__),
             HERE / 'SOURCE-CHECK02.json', ROOT / 'src/ecs/world-namespace.c',
             ROOT / 'src/ecs/world-namespace.js', ROOT / 'experiments/public-relations/ordinary-reader-query-v1/TS-REUSE.json',
             Path('/home/node/.bend/bend2/base.bend'), *map(Path, tools.values()), *map(Path, config.LINK_INPUTS)]
    check = json.loads((HERE / 'SOURCE-CHECK02.json').read_text())
    assert check['developmentCheckExit'] == 1 and check['expectedForeignDependentDefinitions'] == 9
    assert check['sources'] == {str(path.resolve()): sha(path) for path in HERE.glob('*.bend')}
    for key in ('stdout', 'stderr'):
        path = Path(check[key]['path'])
        assert sha(path) == check[key]['sha256']
        extra.append(path)
    extra += [path for path in oracle.parent.iterdir() if path.is_file()]
    extra += list(map(Path, basis_pins))
    revalidation_path = HERE / 'JS-REVALIDATION.json'
    revalidation = json.loads(revalidation_path.read_text())
    assert revalidation['status'] == 'PASS_RETAINED_IO_AUTHORITY_JS_NOT_FRESH_RUN' and revalidation['freshRun'] is False
    assert revalidation['oracleSHA256'] == hashlib.sha256(expected).hexdigest() and revalidation['bytes'] == len(expected)
    previous_plan_path = HERE / 'runtime02/js/plan.json'
    previous_plan = json.loads(previous_plan_path.read_text())
    previous_receipt_path = previous_plan_path.parent / 'receipt.json'
    previous_receipt = json.loads(previous_receipt_path.read_text())
    assert sha(previous_plan_path) == revalidation['originalPlanSHA256']
    assert sha(previous_receipt_path) == revalidation['originalReceiptSHA256'] and previous_receipt['status'] == 'INCOMPLETE'
    assert all(sha(path) == digest for path, digest in previous_plan['pins'].items())
    extra += [revalidation_path, previous_plan_path, previous_receipt_path, Path(previous_plan['generated'])]
    extra += list(map(Path, previous_plan['pins']))
    extra += [Path(row['path']) for row in previous_receipt['guards']]
    extra += [Path(row[stream]['path']) for row in previous_receipt['commands'] for stream in ('stdout', 'stderr')]
    pins = inventory | {str(path.resolve(strict=True)): sha(path) for path in extra}
    resource_roots = runner.Inputs(directories=config.RESOURCE_ROOTS).expected
    rows = []
    for role in ('native',):
        out = HERE / 'runtime03' / role
        out.mkdir(parents=True, exist_ok=False)
        generated = out / ('scenario.js' if role == 'js' else 'scenario.c')
        native = out / 'scenario.native'
        prefix = [tools['taskset'], '-c', '3']
        commands = [{'label': 'emit', 'argv': prefix + [tools['bend'], str(entry), '-o', str(generated)], 'capSeconds': 30}]
        if role == 'js':
            commands += [{'label': 'consumer', 'argv': prefix + [tools['node'], str(generated)], 'capSeconds': 5}]
        else:
            commands += [{'label': 'build', 'argv': prefix + [tools['clangWrapper'], '-O3', str(generated), '-o', str(native), '-pthread', '-lm'], 'capSeconds': 120},
                         {'label': 'consumer', 'argv': prefix + [str(native), '--threads', '1', '--gpu', 'off'], 'capSeconds': 5}]
        plan = {'scope': 'Two nominal schemas, canonical independently IO-created receiver/peer Worlds, actual foreign source/target relate and source unrelate plus accepted receiver-local relate/unrelate and inverse queries; complete receiver/peer/reader/owner observations; finite ordinary semantics only',
                'role': role, 'subject': 'normal', 'entrypoint': str(entry), 'stage': str(HERE),
                'sourceInventory': inventory, 'importClosure': closure, 'pins': pins,
                'resourceRoots': resource_roots, 'environment': config.environment(), 'cwd': str(HERE),
                'tools': tools, 'commands': commands, 'oracle': str(oracle),
                'oracleSHA256': hashlib.sha256(expected).hexdigest(), 'oracleBytes': len(expected),
                'normalOracle': str(oracle), 'normalOracleSHA256': hashlib.sha256(expected).hexdigest(), 'normalOracleBytes': len(expected),
                'generated': str(generated), 'native': str(native),
                'postConsumer': 'Exact complete independent two-schema stdout and empty stderr; no TS IO allocation, proof, universal identity or performance claim'}
        guard.validate(plan, output_dir=out)
        target = out / 'plan.json'
        target.write_text(json.dumps(plan, indent=2) + '\n')
        rows.append({'role': role, 'path': str(target), 'sha256': sha(target),
                     'argv': [tools['python'], str(COLLECTOR), 'run', str(target), sha(target)]})
    freeze = {'plans': rows, 'sources': inventory, 'collectorSHA256': sha(COLLECTOR)}
    (HERE / 'FREEZE03.json').write_text(json.dumps(freeze, indent=2) + '\n')
    launch = {'freezeSHA256': sha(HERE / 'FREEZE03.json'), 'sequence': rows,
              'order': 'Retained complete JS posthoc revalidation (original INCOMPLETE unchanged), then only fresh Native; no JS rerun or comparison'}
    (HERE / 'LAUNCH03.json').write_text(json.dumps(launch, indent=2) + '\n')
    print(json.dumps(launch, indent=2))

if __name__ == '__main__':
    prepare(sys.argv[1])
