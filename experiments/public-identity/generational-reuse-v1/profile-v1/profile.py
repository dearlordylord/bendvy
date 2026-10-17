"""Four guarded full-workload diagnostic runs; preparation never executes a backend."""
import argparse
import base64
import fcntl
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = next(path for path in HERE.parents if (path / 'scripts/task_runner.py').is_file())
sys.path.insert(0, str(ROOT / 'scripts'))
import task_runner
from evidence_boundary import GuardBoundary, ReceiptBoundary


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def decode_snapshot(value):
    if isinstance(value, dict):
        if set(value) == {'base64'}:
            return base64.b64decode(value['base64'])
        return {key: decode_snapshot(item) for key, item in value.items()}
    if isinstance(value, list):
        return [decode_snapshot(item) for item in value]
    return value


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def read(path):
    return json.loads(Path(path).read_text())


def validate_output(raw, expected, iterations):
    lines = raw.splitlines()
    if len(lines) != iterations or any(json.loads(line) != expected for line in lines):
        raise ValueError('Complete ten-application JSON observation mismatch')


def cohort(directory, plan_hash, before_hash=None):
    """Accept a complete correct stock cohort, including a statistical REGRESSION."""
    directory = Path(directory)
    plan_path = directory / 'plan.json'
    if sha(plan_path) != plan_hash:
        raise ValueError('Stock plan identity changed')
    plan = read(plan_path)
    stage = Path(plan['output'])
    receipt_path = stage / 'receipt.json'
    receipt = read(receipt_path)
    contract = plan['contract']
    if receipt['status'] not in ('NO_CONFIRMED_REGRESSION', 'REGRESSION'):
        raise ValueError('Stock cohort is incomplete or incorrect')
    if receipt['contract'] != contract or receipt['cpu'] != 11:
        raise ValueError('Stock workload/CPU differs')
    if receipt.get('injectedSlowdownMs') != 0 or 'candidateProvider' in receipt:
        raise ValueError('Only unchanged default stock workload is accepted')
    if receipt['baselineArchiveSHA256'] != plan['baselineArchiveSHA256']:
        raise ValueError('Frozen baseline archive differs')
    expected_path = stage / 'baseline/examples/query-composition/expected.json'
    expected = read(expected_path)
    expected['checkpoints'] = [point for point in expected['checkpoints']
                               if point['label'] != 'foreign-collision-reference']
    if contract['iterations'] != 10 or len(expected['checkpoints']) != 22:
        raise ValueError('Unexpected frozen workload shape')
    roles = ('TS', 'baseline-JS', 'baseline-Native', 'candidate-JS', 'candidate-Native')
    labels = {f'warmup-{index}-{role}' for index in range(contract['warmups']) for role in roles}
    labels.update(f'pair-{index}-{role}' for index in range(contract['pairs']) for role in roles)
    commands = receipt['commands']
    required_setup = {'version-Bend', 'version-Node', 'version-Clang', 'reference-head', 'reference-clean'}
    required_setup.update(f'{role}-{stage}' for role in ('baseline', 'candidate')
                          for stage in ('checker', 'js-emit', 'c-emit', 'native-build'))
    if {command['label'] for command in commands} != labels | required_setup or len(commands) != len(labels | required_setup):
        raise ValueError('Incomplete stock command inventory')
    if any(command['exit'] != 0 for command in commands):
        raise ValueError('Failed stock command')
    if len(receipt['timings']) != contract['pairs'] or len(receipt['pairs']) != contract['pairs'] * 2:
        raise ValueError('Incomplete stock measurements')
    outer_path = directory / 'receipt.json'
    outer = read(outer_path)
    if outer['planSHA256'] != plan_hash or len(outer['commands']) != 1:
        raise ValueError('Stock outer receipt/plan mismatch')
    command = outer['commands'][0]
    expected_exit = 0 if receipt['status'] == 'NO_CONFIRMED_REGRESSION' else 1
    if command['exit'] != expected_exit or command['failure'] is not None:
        raise ValueError('Stock supervisory command failed or timed out')
    outer_stdout, outer_stderr = directory / 'cohort.stdout', directory / 'cohort.stderr'
    if sha(outer_stdout) != outer['stdoutSHA256'] or sha(outer_stderr) != outer['stderrSHA256']:
        raise ValueError('Stock outer raw log/receipt mismatch')
    if outer_stderr.read_bytes() or json.loads(outer_stdout.read_text())['status'] != receipt['status']:
        raise ValueError('Stock terminal output is incorrect')
    if receipt['status'] == 'NO_CONFIRMED_REGRESSION' and outer.get('benchmarkReceiptSHA256') != sha(receipt_path):
        raise ValueError('Stock inner/outer receipt mismatch')
    pins = {str(path): sha(path) for path in (plan_path, receipt_path, expected_path,
                                              outer_path, outer_stdout, outer_stderr)}
    command_map = {command['label']: command for command in commands}
    raw_paths = {path.stem.removesuffix('.stdout'): path for path in stage.glob('*.stdout.gz')}
    if set(raw_paths) != labels:
        raise ValueError('Stock full-output log membership differs')
    for label, path in raw_paths.items():
        raw = gzip.decompress(path.read_bytes())
        if hashlib.sha256(raw).hexdigest() != command_map[label]['stdoutSHA256']:
            raise ValueError('Stock raw log/receipt mismatch')
        validate_output(raw, expected, contract['iterations'])
        pins[str(path)] = sha(path)
    for role, sources in receipt['sources'].items():
        actual = {str(path.relative_to(stage / role)): sha(path)
                  for folder in ('src/ecs', 'examples/query-composition')
                  for path in (stage / role / folder).rglob('*') if path.is_file()}
        if actual != sources:
            raise ValueError('Staged stock source drift: ' + role)
        pins.update({str(stage / role / path): digest for path, digest in sources.items()})
    for relative, digest in receipt['artifacts'].items():
        path = stage / relative
        if sha(path) != digest:
            raise ValueError('Stock generated artifact drift')
        pins[str(path)] = digest
    generated = stage / 'candidate/workshop.js'
    if before_hash is not None and sha(generated) != before_hash:
        raise ValueError('Wrong immediate pre-generation artifact')
    return {'plan': str(plan_path), 'planSHA256': plan_hash, 'receipt': str(receipt_path),
            'receiptSHA256': sha(receipt_path), 'generated': str(generated),
            'generatedSHA256': sha(generated), 'pins': pins}, expected, plan


def prepare(output):
    recipe = read(HERE / 'recipe.json')
    before, expected, before_plan = cohort(recipe['before'], recipe['beforePlanSHA256'], recipe['beforeArtifactSHA256'])
    after, after_expected, stock = cohort(recipe['after'], recipe['afterPlanSHA256'])
    if expected != after_expected or before_plan['contract'] != stock['contract']:
        raise ValueError('Before/after full workload differs')
    basis = read(HERE / 'SOURCE-BASIS.json')
    for path, digest in basis['importClosure'].items():
        if sha(path) != digest:
            raise ValueError('Immediate pre-generation imported source changed')
    # Use the same stock Node and exact environment; do not resolve a new alias.
    node = stock['tools']['node']
    if node != before_plan['tools']['node'] or stock['environment'] != before_plan['environment']:
        raise ValueError('Stock Node/environment differs between roles')
    tools_snapshot = Path(stock['toolSnapshot'])
    snapshot = read(tools_snapshot)
    if sha(tools_snapshot) != stock['pins'][str(tools_snapshot)]:
        raise ValueError('Stock tool snapshot changed')
    pins = {**before['pins'], **after['pins'], **snapshot['pins']}
    for path in (Path(__file__), HERE / 'profile.mjs', HERE / 'recipe.json', HERE / 'SOURCE-BASIS.json',
                 ROOT / 'scripts/task_runner.py', ROOT / 'scripts/evidence_boundary.py',
                 ROOT / 'scripts/receipt-logs.py', Path(stock['ownedToolPins']), tools_snapshot):
        pins[str(path)] = sha(path)
    output = Path(output).resolve()
    if output.exists():
        raise ValueError('Profile output must start absent')
    commands = []
    for role, binding in (('before', before), ('after', after)):
        for mode in ('cpu', 'heap'):
            label = role + '-' + mode
            commands.append({'label': label, 'role': role, 'mode': mode, 'capSeconds': 5,
                             'profile': str(output / (label + '.profile.json')),
                             'argv': [snapshot['taskset'], '-c', '11', node, str(HERE / 'profile.mjs'),
                                      mode, binding['generated'], str(output / (label + '.profile.json'))]})
    plan = {'scope': recipe['scope'], 'before': before, 'after': after, 'commands': commands,
            'pins': pins, 'environment': stock['environment'], 'cwd': stock['cwd'], 'cpu': 11,
            'python': stock['tools']['python'], 'node': node, 'toolSnapshot': str(tools_snapshot),
            'ownedToolPins': stock['ownedToolPins'], 'expected': expected, 'iterations': 10,
            'output': str(output), 'recipeSHA256': sha(HERE / 'recipe.json'),
            'profileOptions': {'cpuIntervalMicroseconds': 100, 'heapSamplingInterval': 32768,
                               'includeObjectsCollectedByMajorGC': True, 'includeObjectsCollectedByMinorGC': True,
                               'gcDrainMilliseconds': 20, 'warmups': 0, 'generatedBodyEdits': 0}}
    output.mkdir(parents=True)
    (output / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(sha(output / 'plan.json'))


def execute(path, expected_sha):
    path = Path(path).resolve()
    if sha(path) != expected_sha:
        raise ValueError('Profile plan is not the reviewed identity')
    plan = read(path)
    output = Path(plan['output'])
    if path != output / 'plan.json' or plan['cpu'] != 11 or plan['python'] != str(Path(sys.executable).resolve()):
        raise ValueError('Wrong plan/output/executing Python')
    if 11 not in os.sched_getaffinity(0):
        raise ValueError('CPU11 unavailable')
    logs_module = load('profile_logs', ROOT / 'scripts/receipt-logs.py')
    logs = logs_module.CommandLogs(output, [command['label'] for command in plan['commands']])
    inputs = task_runner.Inputs(files=[path, *plan['pins']])
    profiles = {}
    guards = {}
    receipt = {'scope': plan['scope'], 'planSHA256': expected_sha, 'commands': [], 'profiles': {},
               'interpretation': 'CPU/allocation attribution only. V8 sampled allocation includes collected objects; not RSS/physical-byte totals or a speed verdict.'}

    def guard():
        inputs.guard()
        logs.guard()
        if any(sha(name) != digest for name, digest in plan['pins'].items()):
            raise ValueError('Frozen profile input changed')
        if {str(p) for p in output.glob('*.profile.json')} != set(profiles):
            raise ValueError('Unexpected profile membership')
        if any(sha(name) != digest for name, digest in profiles.items()):
            raise ValueError('Published profile changed')
        if any(sha(name) != digest for name, digest in guards.items()):
            raise ValueError('Published guard changed')

    def publish_guard(label):
        guard()
        target = output / (label + '.guard.json')
        value = {'unchanged': True, 'actualPins': inputs.snapshot(), 'profiles': dict(profiles),
                 'rawLogs': dict(logs.hashes)}
        target.write_text(json.dumps(value, indent=2) + '\n')
        guards[str(target)] = sha(target)
        receipt['guards'] = dict(guards)

    owned = load('profile_tool_pins', plan['ownedToolPins'])
    snapshot = decode_snapshot(read(plan['toolSnapshot']))

    def tools_guard():
        owned.verify(snapshot, execute=lambda argv, cap, env: task_runner.execute_result(argv, cap, env=env, capture='split'),
                     tools=snapshot['tools'], resource_roots=snapshot['resource_roots'], ldd=snapshot['ldd'],
                     taskset=snapshot['taskset'], cpu=snapshot['cpu'], env=plan['environment'],
                     skip_ldd=snapshot['skip_ldd'], capture_mode='split')

    runner = task_runner.Runner(logs, inputs=inputs, env=plan['environment'], cwd=plan['cwd'], capture='split')
    with open('/tmp/bendvy-parity-heavy.lock', 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        with ReceiptBoundary(receipt, output / 'receipt.json', [('inputs/raw/profiles', guard), ('tools/resources', tools_guard)]):
            tools_guard()
            publish_guard('initial')
            for command in plan['commands']:
                publish_guard(command['label'] + '-pre')
                attempt = {**command, 'status': 'INCOMPLETE'}
                receipt['commands'].append(attempt)
                try:
                    with GuardBoundary([('postinputs/raw/profiles', guard)]):
                        result = runner.run(command['label'], command['argv'], 5, expected=None)
                        attempt.update({key: result[key] for key in ('exit', 'failure', 'runnerSHA256')})
                        profile_path = Path(command['profile'])
                        if profile_path.is_file():
                            profiles[str(profile_path)] = sha(profile_path)
                        if result['exit'] != 0 or result['failure'] is not None or result['stderr']:
                            raise ValueError('Profile child failed or wrote stderr')
                        validate_output(result['stdout'], plan['expected'], plan['iterations'])
                        data = read(profile_path)
                        if data['mode'] != command['mode'] or data['zeroExits'] != 1:
                            raise ValueError('Profile did not retain exact IO completion')
                        profile = data['profile']
                        if command['mode'] == 'cpu':
                            if not profile.get('nodes'):
                                raise ValueError('Missing CPU profile')
                        elif not profile.get('head') or not profile.get('samples'):
                            raise ValueError('Missing sampled allocation profile')
                        receipt['profiles'][command['label']] = {'path': str(profile_path), 'sha256': sha(profile_path),
                                                                'validatedApplications': 10, 'checkpointsPerApplication': 22}
                        attempt['status'] = 'COMPLETE_FULL_OUTPUT_VALIDATED'
                except BaseException as error:
                    if hasattr(error, 'result'):
                        attempt.update({key: error.result[key] for key in ('exit', 'failure', 'runnerSHA256')})
                    raise
                finally:
                    primary = sys.exc_info()[1]
                    if Path(command['profile']).is_file():
                        profiles[command['profile']] = sha(command['profile'])
                    receipt['rawLogs'] = dict(logs.hashes)
                    # ReceiptBoundary still runs all guards if this publication fails.
                    if primary is None:
                        publish_guard(command['label'] + '-post')
                    else:
                        try:
                            publish_guard(command['label'] + '-post')
                        except BaseException as post_error:
                            primary.add_note('postguard publication: ' + str(post_error))
            receipt['status'] = 'COMPLETE_CPU_ALLOCATION_DIAGNOSTICS_PASS_NO_VERDICT'


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_subparsers(dest='mode', required=True)
    preparation = modes.add_parser('prepare')
    preparation.add_argument('--output', required=True, type=Path)
    execution = modes.add_parser('execute')
    execution.add_argument('--plan', required=True, type=Path)
    execution.add_argument('--plan-sha256', required=True)
    args = parser.parse_args()
    if args.mode == 'prepare':
        prepare(args.output)
    else:
        execute(args.plan, args.plan_sha256)


if __name__ == '__main__':
    main()
