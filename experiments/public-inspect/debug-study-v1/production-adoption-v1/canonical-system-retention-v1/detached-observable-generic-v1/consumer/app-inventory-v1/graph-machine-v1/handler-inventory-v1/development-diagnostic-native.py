#!/usr/bin/env python3
"""Focused direct development: prepare only, then a separately admitted guarded run.

No relocated imports, installed resolver discovery, Native, or performance work.
This does not establish complete installed-tool/resolver qualification.
"""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
import sys
import stat
from pathlib import Path

ROOT = Path('/workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention')
HERE = Path(__file__).resolve().parent



def sha(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Pinned/generated/raw file must be regular and non-symlink')
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, 'rb') as source:
        if not stat.S_ISREG(os.fstat(source.fileno()).st_mode):
            raise ValueError('Pinned/generated/raw descriptor must be regular')
        return hashlib.sha256(source.read()).hexdigest()


def write_raw(path, data):
    path = Path(path)
    if path.exists() or path.is_symlink():
        raise ValueError('Raw capture must start absent and non-symlink')
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, 'wb') as output:
        if not stat.S_ISREG(os.fstat(output.fileno()).st_mode):
            raise ValueError('Raw capture descriptor is not regular')
        output.write(data)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Raw capture changed file type')


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def prepare(out, oracle, kind):
    if kind != 'normal':
        raise ValueError('Known complete consuming entry required')
    entry_name = {'normal': 'main.bend', 'mutant': 'main-inspector-filter.bend', 'handler-drop': 'main-drop-handlers.bend'}[kind]
    inventory_name = {'normal': 'main-identities.json', 'mutant': 'inspector-filter-identities.json', 'handler-drop': 'drop-handlers-identities.json'}[kind]
    role = {'normal': 'normal', 'mutant': 'inspector-filter', 'handler-drop': 'handler-drop'}[kind]
    oracle_name = role + '-expected.json'
    join_name = 'CONSTRUCTOR-JOIN.json'
    synthetic_name = role + '-synthetic.stdout'
    expected_sha = json.loads((Path(oracle) / 'source-basis.json').read_text())[{'normal': 'normalExpectedSHA256', 'mutant': 'mutantExpectedSHA256', 'handler-drop': 'handlerDropExpectedSHA256'}[kind]]
    out = Path(out).resolve()
    oracle = Path(oracle).resolve()
    parser = load('scenario_parser', HERE / 'parse-handlers.py')
    identities = json.loads((HERE / inventory_name).read_text())
    if parser.build_identities(HERE / entry_name) != identities:
        raise ValueError('Frozen original source/constructor inventory changed')
    if sha(oracle / oracle_name) != expected_sha or json.loads((oracle / 'source-basis.json').read_text())[{'normal': 'normalExpectedSHA256', 'mutant': 'mutantExpectedSHA256', 'handler-drop': 'handlerDropExpectedSHA256'}[kind]] != expected_sha:
        raise ValueError('Independent whole oracle changed')
    config = ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py'
    configuration = load('native_configuration', config)
    preparation_runner = load('native_preparation_runner', ROOT / 'scripts/task_runner.py')
    resources = preparation_runner.Inputs(directories=configuration.RESOURCE_ROOTS).expected
    installed = configuration.candidate()
    tools = {'bend': '/home/node/.bend/bin/bend-2.0.35', 'node': '/home/node/.local/share/mise/installs/node/24.20.0/bin/node', 'python': str(Path(sys.executable).resolve()), 'taskset': str(Path('/usr/bin/taskset').resolve(strict=True))}
    tools.update({'clangWrapper': str(Path(configuration.TOOL_PATHS['clangWrapper']).resolve(strict=True)), 'clangBinary': str(Path(configuration.TOOL_PATHS['clang']).resolve(strict=True))})
    migration = HERE.parents[3]
    extra = [HERE.parent.parent.parent / 'parse-scenario.py',
             HERE.parent.parent.parent / 'app-run-v1/nominal-carrier-v1/accumulated-v1/parse-app.py',
             HERE.parent.parent / 'parse-inventory.py', HERE.parent / 'parse-graph-machine.py',
             Path(__file__), HERE / 'parse-handlers.py', HERE / inventory_name,
             ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py',
             Path('/home/node/.bend/bend2/base.bend'),
             migration / 'MIGRATION.json', migration / 'ORACLE-BINDING.json',
             oracle / join_name, oracle / 'source-basis.json', oracle / 'expected.py', oracle / 'synthetic.py',
             oracle / 'MODEL-CHECKS.json', oracle / 'TRANSPORT-CHECKS.json',
             oracle / 'historical-expected.json', oracle / 'historical-drop-handlers-expected.json',
             oracle / 'historical-inventory-expected.json',
             HERE / 'test-diagnostic-js-boundary.py', HERE / 'DIAGNOSTIC-JS-BOUNDARY-CONTROLS.json',
             HERE / 'diagnostic-js-boundary.stdout', HERE / 'diagnostic-js-boundary.stderr', *map(Path, tools.values())]
    for selected in ('normal', 'inspector-filter', 'handler-drop'):
        extra.extend(oracle / (selected + suffix) for suffix in
                     ('-expected.json', '-identities.json', '-synthetic.stdout'))
    for selected in ('05-normal', '06-normal', '06-mutant'):
        attempt = migration / 'source-attempts' / selected
        extra.extend(attempt / name for name in ('SOURCE.json', 'result.json', 'post.json', 'stdout', 'stderr'))
    # Preserve failed source prerequisites and the resource adaptation explicitly.
    extra.extend([migration / 'source-resources-v1/current-cpu5.json',
                  migration / 'source-prerequisite-v1/root-host-20261009.json',
                  migration / 'source-prerequisite-v1/actual-source-attempt02/manifest.json',
                  migration / 'source-prerequisite-v1/actual-source-attempt02/verification-result.json',
                  migration / 'source-attempts/snapshot-archive.json'])
    extra.extend(sorted((migration / 'source-prerequisite-v1/actual-source-attempt02/objects').glob('*.gz')))
    extra.extend(sorted((migration / 'source-attempts/objects').glob('*.gz')))
    for selected in ('07-boundary-mutant',):
        extra.extend(migration / 'source-attempts' / selected / name
                     for name in ('SOURCE.json', 'result.json', 'post.json', 'stdout', 'stderr'))
    extra.extend([migration / 'diagnostic-native-v1/PREPARATION.json', migration / 'diagnostic-native-v1/collector.patch', migration / 'diagnostic-native-v1/parent-js-development.py.source', config, HERE / 'test-diagnostic-native-boundary.py', HERE / 'NATIVE-BOUNDARY-CONTROLS.json', HERE / 'native-boundary.stdout', HERE / 'native-boundary.stderr'])
    extra.extend(Path(path) for path in installed['inputFiles'])
    js_actual = migration / 'diagnostic-js-v1/actual-js-v1'
    extra.extend([js_actual / 'manifest.json', js_actual / 'verification-result.json'])
    extra.extend(sorted((js_actual / 'objects').glob('*.gz')))
    actual_js = json.loads((js_actual / 'verification-result.json').read_text())
    if actual_js['cohorts']['normal']['status'] != 'DIAGNOSTIC_JS_PASS' or actual_js['cohorts']['normal']['wholeOracleSHA256'] != expected_sha:
        raise ValueError('Actual whole normal JS prerequisite differs')
    pins = dict(identities['sourceSHA256'])
    for path, digest in json.loads((oracle / 'source-basis.json').read_text())['sources'].items():
        if sha(path) != digest:
            raise ValueError('Independent full source basis changed')
        pins[path] = digest
    pins.update({str(path.resolve(strict=True)): sha(path) for path in extra})
    env = configuration.environment()
    generated = out / 'scenario.c'
    native = out / 'scenario.native'
    plan = {'scope': 'DIAGNOSTIC ONLY Native actual complete detached Inspector behavior; source5 cli_verdict/book_promises remains UNMET; no acceptance/#56 closure/performance claim',
            'diagnosticOnly': True, 'sourcePrerequisite': 'UNMET', 'acceptance': False,
            'sourceValidation': 'Stock -o emission runs book_read/book_load/book_valid; does not replace extra --check-only cli_verdict/book_promises',
            'kind': kind, 'expectedSHA256': expected_sha, 'entrypoint': identities['entrypoint'], 'constructorInventory': str(HERE / inventory_name),
            'pins': pins, 'environment': env, 'cwd': str(HERE), 'oracle': str(oracle / oracle_name),
            'join': str(oracle / join_name), 'generated': str(generated), 'native': str(native),
            'resourceRoots': resources, 'actualJSPrerequisite': actual_js['cohorts']['normal'],
            'tools': tools, 'commands': [
                {'label': 'emit', 'argv': [tools['taskset'], '-c', '11', tools['bend'], identities['entrypoint'], '-o', str(generated)], 'capSeconds': 30},
                {'label': 'build', 'argv': [tools['taskset'], '-c', '11', tools['clangWrapper'], '-O3', str(generated), '-o', str(native), '-pthread', '-lm'], 'capSeconds': 120},
                {'label': 'consumer', 'argv': [tools['taskset'], '-c', '11', str(native), '--threads', '1', '--gpu', 'off'], 'capSeconds': 5}],
            'postConsumer': 'DIAGNOSTIC ONLY strict entire preserved historical graph/App/resource/handler report plus independent same-ordinary-declaration detached Inspector rows and repeated/disabled owner preservation; both reached controls additionally reject the entire normal oracle; fixture cursor0 is independent of registered cursors; no full56/Native/performance claim'}
    out.mkdir(parents=True, exist_ok=False)
    (out / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(sha(out / 'plan.json'))


def run(plan_path, expected_sha):
    plan_path = Path(plan_path).resolve(strict=True)
    if sha(plan_path) != expected_sha:
        raise ValueError('Admitted plan digest mismatch')
    plan = json.loads(plan_path.read_text())
    if plan.get('diagnosticOnly') is not True or plan.get('sourcePrerequisite') != 'UNMET' or plan.get('acceptance') is not False:
        raise ValueError('Diagnostic source prerequisite/acceptance scope differs')
    if 11 not in os.sched_getaffinity(0):
        raise ValueError('Diagnostic CPU11 is outside actual allowed affinity')
    actual_python = str(Path(sys.executable).resolve(strict=True))
    if actual_python != plan['tools']['python'] or sha(actual_python) != plan['pins'][actual_python]:
        raise ValueError('Actual executor interpreter path/hash differs from admitted plan')
    if {path: sha(path) for path in plan['pins']} != plan['pins']:
        raise ValueError('Frozen boundary changed before helper import')
    out = plan_path.parent
    parser = load('scenario_parser', HERE / 'parse-handlers.py')
    runner = load('task_runner', ROOT / 'scripts/task_runner.py')
    boundary = load('evidence_boundary', ROOT / 'scripts/evidence_boundary.py')
    inventory = json.loads(Path(plan['constructorInventory']).read_text())
    pins = dict(plan['pins'])
    pins[str(plan_path)] = expected_sha
    generated = Path(plan['generated'])
    native = Path(plan['native'])
    record = {'diagnosticOnly': True, 'sourcePrerequisite': 'UNMET', 'acceptance': False, 'scope': plan['scope'], 'planSHA256': expected_sha, 'commands': [], 'guards': []}

    def guard(label):
        for artifact in (generated, native):
            if str(artifact) in pins and (artifact.is_symlink() or not artifact.is_file()):
                raise ValueError('Generated artifact must be a regular non-symlink file')
        actual = {path: sha(path) for path in pins}
        unchanged = actual == pins and parser.build_identities(plan['entrypoint']) == inventory and runner.Inputs(directories=plan['resourceRoots']).expected == plan['resourceRoots']
        receipt = {'label': label, 'actualPins': actual, 'unchanged': unchanged}
        target = out / (label + '.guard.json')
        target.write_text(json.dumps(receipt, indent=2) + '\n')
        record['guards'].append({'path': str(target), 'sha256': sha(target)})
        if not unchanged:
            raise ValueError('Source/oracle/tool/helper boundary changed: ' + label)

    with boundary.ReceiptBoundary(record, out / 'receipt.json', [('final boundary', lambda: guard('final'))]):
        for command in plan['commands']:
            label = command['label']
            guard(label + '-pre')
            with boundary.GuardBoundary([('post boundary', lambda: guard(label + '-post'))]):
                with open('/tmp/bendvy-parity-heavy.lock', 'a') as lock:
                    fcntl.flock(lock, fcntl.LOCK_EX)
                    try:
                        guard(label + '-acquired')
                        artifact = generated if label == 'emit' else native
                        if label in ('emit', 'build') and (artifact.exists() or artifact.is_symlink()):
                            raise ValueError('Generated output must start absent')
                        result = runner.execute_result(command['argv'], command['capSeconds'], plan['environment'], plan['cwd'], 'split')
                    finally:
                        fcntl.flock(lock, fcntl.LOCK_UN)
                row = dict(command)
                for key, value in result.items():
                    if isinstance(value, bytes):
                        target = out / (label + '.' + key)
                        write_raw(target, value)
                        row[key] = {'path': str(target), 'sha256': sha(target), 'bytes': len(value)}
                        pins[str(target)] = row[key]['sha256']
                    else:
                        row[key] = value
                record['commands'].append(row)
                artifact = generated if label == 'emit' else native
                if label in ('emit', 'build') and (artifact.exists() or artifact.is_symlink()):
                    # Bind partial output before interpreting child failure.
                    pins[str(artifact)] = sha(artifact)
                    record['generatedSHA256' if label == 'emit' else 'nativeSHA256'] = pins[str(artifact)]
                if result['exit'] != 0 or result['failure'] is not None:
                    raise ValueError('Owned child failed: ' + label)
                if label in ('emit', 'build'):
                    if str(artifact) not in pins:
                        raise ValueError('Emit did not produce a regular non-symlink artifact')
                else:
                    if result['stderr']:
                        raise ValueError('Consumer stderr is not empty')
                    actual = parser.normalize(result['stdout'].decode(), inventory, json.loads(Path(plan['join']).read_text()))
                    expected_bytes = Path(plan['oracle']).read_bytes()
                    if hashlib.sha256(expected_bytes).hexdigest() != plan['expectedSHA256']:
                        raise ValueError('Whole oracle changed')
                    parser.BASE.strict_equal(actual, json.loads(expected_bytes))
                    if plan['kind'] in ('mutant', 'handler-drop'):
                        try:
                            parser.BASE.strict_equal(actual, json.loads((Path(plan['oracle']).parent / 'normal-expected.json').read_text()))
                        except ValueError:
                            record['unchangedBaselineRejected'] = True
                        else:
                            raise ValueError('Reached mutant did not reject unchanged whole baseline')
                    record['wholeOracleSHA256'] = plan['expectedSHA256']
        record['status'] = 'DIAGNOSTIC_NATIVE_PASS'


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest='command', required=True)
    preparation = sub.add_parser('prepare')
    preparation.add_argument('output')
    preparation.add_argument('oracle_directory')
    preparation.add_argument('kind', choices=('normal',))
    execution = sub.add_parser('run')
    execution.add_argument('plan')
    execution.add_argument('admitted_sha256')
    args = parser.parse_args()
    if args.command == 'prepare':
        prepare(args.output, args.oracle_directory, args.kind)
    else:
        run(args.plan, args.admitted_sha256)


if __name__ == '__main__':
    main()
