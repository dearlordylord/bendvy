"""Prepare only or execute an admitted six-subject Native cohort.

Uses the approved ordinary owned-tool snapshot/verify seam; no resolver shortcut.
The complete current source/Node/CLI IO joins remain distinct semantic receipts.
"""
from pathlib import Path
import argparse
import base64
import hashlib
import importlib.util
import json
import os
import re
import shutil
import sys
import time
import types

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CONFIG_TOOL = ROOT / 'experiments/public-relations/promotion-stage/application/next-version/v1/tool-pins.py'
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'scripts'))
import task_runner


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

LOGS = load(ROOT / 'scripts/receipt-logs.py', 'inspect54_backend_logs')
TOOLS = load(CONFIG_TOOL, 'inspect54_approved_tools')
JOIN = types.ModuleType('inspect54_current_joins')
JOIN.__file__ = str(HERE / 'io-check-remaining.py')
exec((HERE / 'io-check-remaining.py').read_text().split('parser = argparse.ArgumentParser()')[0], JOIN.__dict__)
NAMES = ['bend', 'node', 'python', 'taskset', 'clang']
CONFIG_NAMES = ['check.json', 'bend.json', 'bender.json', 'package.json', '.bend.json', 'bend.config.json']


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def encode(value):
    if isinstance(value, bytes):
        return {'rawBase64': base64.b64encode(value).decode()}
    raise TypeError(type(value))


def decode(value):
    if isinstance(value, dict):
        if set(value) == {'rawBase64'}:
            return base64.b64decode(value['rawBase64'])
        return {key: decode(item) for key, item in value.items()}
    if isinstance(value, list):
        return [decode(item) for item in value]
    return value


def inventory(directory):
    return {str(file.relative_to(directory)): sha(file) for file in sorted(directory.rglob('*')) if file.is_file()}


def configurations(out, stage):
    paths = set()
    for root in [ROOT, HERE, Path.cwd(), out, stage, stage / 'src/ecs', stage / HERE.relative_to(ROOT), Path('/home/node/.bend')]:
        for parent in [root, *root.parents]:
            paths.update(parent / name for name in CONFIG_NAMES)
    return {str(path): sha(path) if path.is_file() else None for path in sorted(paths)}


class ProbeLedger:
    def __init__(self, directory, labels, inputs, env):
        directory.mkdir()
        self.directory, self.labels, self.inputs, self.env = directory, labels, inputs, env
        self.index, self.receipts = 0, {}
        self.logs = LOGS.CommandLogs(directory, labels)
        self.runner = task_runner.Runner(self.logs, inputs=inputs, env=env, cwd=ROOT, capture='merged-stdout')

    def execute(self, argv, seconds, env):
        assert env == self.env and seconds == 5
        assert self.index < len(self.labels)
        label = self.labels[self.index]
        self.index += 1
        try:
            result = self.runner.run(label, argv, seconds)
        except BaseException as error:
            result = getattr(error, 'result', None)
            path = self.directory / (label + '.json')
            path.write_text(json.dumps({'argv': list(map(str, argv)), 'seconds': seconds, 'error': str(error),
                                        'exit': result['exit'] if result else None,
                                        'failure': result['failure'] if result else str(error)}, indent=2) + '\n')
            self.receipts[str(path)] = sha(path)
            raise
        path = self.directory / (label + '.json')
        path.write_text(json.dumps({'argv': list(map(str, argv)), 'seconds': seconds,
                                    'exit': result['exit'], 'failure': result['failure'],
                                    'runnerSHA256': result['runnerSHA256']}, indent=2) + '\n')
        self.receipts[str(path)] = sha(path)
        self.guard()
        return result

    def guard(self):
        self.inputs.guard()
        self.logs.guard()
        assert all(sha(path) == digest for path, digest in self.receipts.items())
        assert {str(path) for path in self.directory.iterdir()} == set(self.receipts) | {str(self.directory / name) for name in self.logs.hashes}

    def pins(self):
        return {**self.receipts, **{str(self.directory / name): digest for name, digest in self.logs.hashes.items()}}


def configuration(ledger):
    value = TOOLS.configuration()
    value['cpu'] = 5  # Same CPU as this task's declared commands.
    value['execute'] = ledger.execute
    return value


def joins(source, node, cardinality, check, files):
    result = [JOIN.join_receipt(source, 'source', files), JOIN.join_actual_node(node, files),
              JOIN.join_cardinality_partial(cardinality, files)]
    path = Path(check).resolve()
    receipt = json.loads(path.read_text())
    plan_path = path.parent / 'plan.json'
    plan = json.loads(plan_path.read_text())
    assert receipt['planSHA256'] == sha(plan_path)
    assert receipt['status'] == 'CLI_IO_CHECK_REMAINING_COMPLETE_PASS'
    assert receipt['commands'] == [{'label': 'check-cli-generated-js-io', 'exit': 0, 'failure': None}]
    current = task_runner.Inputs(files=plan['files'], directories=map(Path, plan['directories']))
    assert current.expected == plan['inputs']
    assert (path.parent / 'check-cli-generated-js-io.stdout').read_bytes() == (JOIN.oracle_module('check-bend-oracle-v2.py') + '\n').encode()
    for name, digest in receipt['logs'].items():
        raw = path.parent / name
        assert sha(raw) == digest
        files.add(raw)
    files.update(map(Path, plan['files']))
    files.update([path, plan_path, Path(plan['oracle'])])
    result.append({'kind': 'complete-current-check-CLI-generated-JS-IO', 'receipt': str(path),
                   'receiptSHA256': sha(path), 'plan': str(plan_path), 'planSHA256': sha(plan_path)})
    directories = set()
    for result_join in result:
        prior_plan = json.loads(Path(result_join['plan']).read_text())
        directories.update(map(Path, prior_plan['directories']))
    return result, directories


def prepare(args):
    out = ROOT / '.artifacts' / ('inspect54-promotion-native-' + str(time.time_ns()))
    out.mkdir()
    stage = out / 'stage'
    stage.mkdir()
    files, source = set(), set()
    for name in ['cardinality-io-main.bend', 'check-io-main.bend']:
        JOIN.closure(HERE / name, source)
    source.update(HERE / name for name in ['native-backends.py', 'io-check-remaining.py', 'cardinality-oracle.py', 'check-bend-oracle-v2.py'])
    # Read Git only in the ordinary caller environment, before private tool env.
    tracked_result = task_runner.execute_result(['git', 'ls-files'], 5, env=os.environ.copy(), cwd=ROOT, capture='split')
    assert tracked_result['exit'] == 0 and tracked_result['failure'] is None
    tracked = set(tracked_result['stdout'].decode().splitlines())
    records = []
    for original in sorted(source):
        relative = original.relative_to(ROOT)
        key = relative.as_posix()
        assert key in tracked or key.startswith('experiments/public-inspect/promotion-stage/')
        assert not original.is_symlink()
        target = stage / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(original, target)
        assert sha(original) == sha(target)
        records.append({'path': key, 'origin': 'tracked' if key in tracked else 'selected-owned',
                        'sourceSHA256': sha(original), 'stageSHA256': sha(target)})
    files.update(source)
    source_inventory = out / 'source-inventory.json'
    source_inventory.write_text(json.dumps({'rule': 'actual transitive closure; tracked union selected owned files', 'files': records}, indent=2) + '\n')
    files.add(source_inventory)
    current_joins, directories = joins(args.source, args.node, args.cardinality, args.check, files)
    js_path = Path(args.js).resolve()
    js_receipt = json.loads(js_path.read_text())
    js_plan_path = js_path.parent / 'plan.json'
    js_plan = json.loads(js_plan_path.read_text())
    assert js_receipt['planSHA256'] == sha(js_plan_path)
    assert js_receipt['status'] == 'FULL_CARDINALITY_CHECK_STANDALONE_JS_IO_PASS'
    assert js_receipt['commands'] == [{'label': name + suffix, 'exit': 0, 'failure': None} for name in ['cardinality', 'check'] for suffix in ['-emit-js', '-run-js-io']]
    assert js_receipt['probeCount'] == 45
    prior = task_runner.Inputs(files=js_plan['files'], directories=[Path(js_plan['stage']), *map(Path, js_plan['directories'])])
    assert prior.expected == js_plan['inputs']
    assert inventory(Path(js_plan['stage'])) == js_plan['inventory']
    assert configurations(js_path.parent, Path(js_plan['stage'])) == js_plan['configurationStates']
    for name, oracle_name in [('cardinality', 'cardinality-oracle.py'), ('check', 'check-bend-oracle-v2.py')]:
        assert (js_path.parent / (name + '-run-js-io.stdout')).read_bytes() == (JOIN.oracle_module(oracle_name) + '\n').encode()
    for name, digest in js_receipt['logs'].items():
        raw = js_path.parent / name
        assert sha(raw) == digest
        files.add(raw)
    for field in ['generated', 'probePins']:
        for raw, digest in js_receipt[field].items():
            assert sha(raw) == digest
            files.add(Path(raw))
    files.update(map(Path, js_plan['files']))
    files.update([js_path, js_plan_path, Path(js_plan['privateEnvironment'])])
    directories.update([Path(js_plan['stage']), *map(Path, js_plan['directories'])])
    current_joins.append({'kind': 'complete-standalone-JS-IO', 'receipt': str(js_path), 'receiptSHA256': sha(js_path), 'plan': str(js_plan_path), 'planSHA256': sha(js_plan_path)})
    files.update([CONFIG_TOOL, ROOT / 'scripts/owned-tool-pins.py', ROOT / 'scripts/task_runner.py',
                  ROOT / 'scripts/receipt-logs.py', ROOT / '.references/sources.json'])
    files.update((ROOT / '.references/bend2/bend2').rglob('*.ts'))
    oracle = out / 'oracle.json'
    oracle.write_text(json.dumps({'cardinality': JOIN.oracle_module('cardinality-oracle.py'),
                                 'check': JOIN.oracle_module('check-bend-oracle-v2.py')}, indent=2) + '\n')
    files.add(oracle)
    env = TOOLS.configuration()['env']
    private = out / 'private-environment.json'
    private.write_text(json.dumps(env, sort_keys=True))
    private.chmod(0o600)
    prepare_inputs = task_runner.Inputs(files=files, directories=[stage, *directories])
    ledger = ProbeLedger(out / 'prepare-probes', ['prepare-ldd-' + name for name in NAMES], prepare_inputs, env)
    preparation = {'status': 'INCOMPLETE', 'scope': 'ordinary owned tool snapshot preparation only; no emission/runtime'}
    try:
        tools = TOOLS.shared.snapshot(**configuration(ledger))
        assert ledger.index == 5
        preparation['status'] = 'OWNED_TOOL_SNAPSHOT_COMPLETE'
        files.update(map(Path, ledger.pins()))
        files.update(map(Path, tools['pins']))
        commands = []
        prefix = [tools['taskset'], '-c', '5']
        for name in ['cardinality', 'check']:
            entry = stage / HERE.relative_to(ROOT) / (name + '-io-main.bend')
            target = out / (name + '.c')
            binary = out / (name + '.native')
            commands.extend([
                {'label': name + '-emit-c', 'argv': prefix + [tools['tools']['bend'], str(entry), '-o', str(target)], 'seconds': 30, 'generated': str(target), 'oracle': None},
                {'label': name + '-compile-native', 'argv': prefix + [tools['tools']['clang-wrapper'], '-O3', str(target), '-pthread', '-lm', '-o', str(binary)], 'seconds': 120, 'generated': str(binary), 'oracle': None},
                {'label': name + '-run-native-io', 'argv': prefix + [str(binary), '--threads', '1', '--gpu', 'off'], 'seconds': 5, 'oracle': name},
            ])
        inputs = task_runner.Inputs(files=files, directories=[stage, *directories])
        plan = {'status': 'PREPARED_UNADMITTED', 'kind': 'native-io', 'files': sorted(map(str, files)),
                'directories': sorted(map(str, directories)), 'inputs': inputs.expected,
                'stage': str(stage), 'inventory': inventory(stage), 'sourceInventory': str(source_inventory),
                'tools': tools, 'toolConfigurationAuthority': str(CONFIG_TOOL), 'configurationStates': configurations(out, stage),
                'privateEnvironment': str(private), 'environmentSHA256': sha(private), 'joins': current_joins,
                'oracle': str(oracle), 'commands': commands, 'prepareProbeCount': ledger.index,
                'executionProbeLabels': ['guard-' + str(index) + '-ldd-' + name for index in range(13) for name in NAMES],
                'outputEncoding': 'raw UTF-8 exact original pure String plus one IO.print LF; no trimming/JSON decoding',
                'scope': 'Exactly two Native IO fixtures, complete 74/84-line two-schema oracles plus IO LF. Ordinary snapshot/verify guards and genuine Sys/Sch check observations. No negative/mutant/proof/performance/full54 acceptance; diagnostic instrumentation excluded from feature timing.'}
        path = out / 'plan.json'
        path.write_text(json.dumps(plan, indent=2, default=encode) + '\n')
        print(path)
        print(sha(path))
    except BaseException as error:
        preparation['error'] = str(error)
        raise
    finally:
        preparation['probeCount'] = ledger.index
        preparation['probePins'] = ledger.pins()
        (out / 'prepare-receipt.json').write_text(json.dumps(preparation, indent=2) + '\n')
        print(out)


def run(path):
    path = Path(path).resolve()
    out = path.parent
    plan = decode(json.loads(path.read_text()))
    stage = Path(plan['stage'])
    private = Path(plan['privateEnvironment'])
    assert sha(private) == plan['environmentSHA256']
    env = json.loads(private.read_text())
    os.environ.clear()
    os.environ.update(env)
    original = task_runner.Inputs(files=plan['files'], directories=[stage, *map(Path, plan['directories'])])
    assert original.expected == plan['inputs']
    probe_inputs = task_runner.Inputs(files=[path, *plan['files']], directories=[stage, *map(Path, plan['directories'])])
    ledger = ProbeLedger(out / 'execution-probes', plan['executionProbeLabels'], probe_inputs, env)
    logs = LOGS.CommandLogs(out, [command['label'] for command in plan['commands']])
    generated = {}
    runner = task_runner.Runner(logs, inputs=probe_inputs, env=env, cwd=stage)
    oracle = json.loads(Path(plan['oracle']).read_text())
    receipt = {'status': 'INCOMPLETE', 'planSHA256': sha(path), 'commands': [], 'scope': plan['scope']}
    def guard():
        runner.inputs.guard()
        assert inventory(stage) == plan['inventory']
        assert configurations(out, stage) == plan['configurationStates']
        assert sha(private) == plan['environmentSHA256']
        assert all(sha(file) == digest for file, digest in generated.items())
        logs.guard()
        TOOLS.shared.verify(plan['tools'], **configuration(ledger))
        ledger.guard()
    try:
        guard()
        for command in plan['commands']:
            guard()
            if 'generated' in command:
                assert not Path(command['generated']).exists()
            try:
                result = runner.run(command['label'], command['argv'], command['seconds'])
            except BaseException as error:
                result = getattr(error, 'result', None)
                receipt['commands'].append({'label': command['label'], 'exit': result['exit'] if result else None,
                                            'failure': result['failure'] if result else str(error), 'error': str(error)})
                raise
            receipt['commands'].append({'label': command['label'], 'exit': result['exit'], 'failure': result['failure']})
            if command['oracle']:
                assert result['stdout'] == (oracle[command['oracle']] + '\n').encode(), 'complete raw Native oracle mismatch: ' + command['label']
            if 'generated' in command:
                file = command['generated']
                generated[file] = sha(file)
                runner.inputs = task_runner.Inputs(files=[path, *plan['files'], *generated], directories=[stage, *map(Path, plan['directories'])])
            guard()
        assert ledger.index == len(plan['executionProbeLabels'])
        receipt['status'] = 'FULL_CARDINALITY_CHECK_NATIVE_IO_PASS'
    except BaseException as error:
        receipt['error'] = str(error)
        raise
    finally:
        receipt['generated'] = generated
        receipt['logs'] = dict(logs.hashes)
        receipt['probePins'] = ledger.pins()
        receipt['probeCount'] = ledger.index
        (out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
        print(out)

parser = argparse.ArgumentParser()
parser.add_argument('--prepare', action='store_true')
parser.add_argument('--source')
parser.add_argument('--node')
parser.add_argument('--cardinality')
parser.add_argument('--check')
parser.add_argument('--js')
parser.add_argument('--run')
args = parser.parse_args()
if args.prepare:
    prepare(args)
else:
    run(args.run)
