"""#57 subject binding to existing guarded command/timer/profile machinery.

Preparation is offline. Execution is root-only after one batched launch review.
No child process implementation or generalized benchmark runner is introduced.
"""
import argparse
import fcntl
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import random
import statistics
import sys

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
SUBJECT = HERE.parent
ORACLE = Path('/tmp/bendvy-restore59-oracle/experiments/public-debug-trace/deferred-delivery-oracle-v1/timing-allocation-v1')
PROFILE = ROOT / 'experiments/public-identity/generational-reuse-v1/profile-v1/profile.mjs'
COLLECTOR = ROOT / 'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py'


def sha(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Expected regular non-symlink input: ' + str(path))
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(Path(path).read_text())


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def fnv(raw):
    value = 2166136261
    for byte in raw:
        value = ((value ^ byte) * 16777619) & 0xffffffff
    return value


def telemetry():
    value = {"loadavg": Path("/proc/loadavg").read_text().strip(), "cpuStat": next(line for line in Path("/proc/stat").read_text().splitlines() if line.startswith("cpu11 "))}
    for name, path in (("pressure", "/proc/pressure/cpu"), ("frequency", "/sys/devices/system/cpu/cpu11/cpufreq/scaling_cur_freq")):
        if Path(path).is_file(): value[name] = Path(path).read_text().strip()
    return value


def prepare(output, quiet_context):
    """Bind only after all four unchanged plain correctness roles are complete."""
    pins = {}
    plans = {}
    expected = {}
    for mode in ('enabled', 'disabled'):
        raw = (ORACLE / (mode + '.expected.stdout')).read_bytes()
        gz = ORACLE / (mode + '.expected.stdout.gz')
        if gzip.decompress(gz.read_bytes()) != raw:
            raise ValueError('Independent plain/gzip oracle differs')
        expected[mode] = {'path': str(gz), 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest(), 'fnv1a32': fnv(raw)}
        for role in ('js', 'native'):
            directory = Path('/tmp/bendvy57-' + mode + '-first-actual01/normal') / role
            plan = read(directory / 'plan.json'); receipt = read(directory / 'receipt.json')
            if receipt.get('status') != 'COMPLETE_CONSUMER_DEVELOPMENT_PASS':
                raise ValueError('Plain correctness prerequisite not complete: ' + str(directory))
            if any(row.get('exit') != 0 or row.get('failure') is not None for row in receipt['commands']):
                raise ValueError('Plain correctness prerequisite failed')
            if plan['oracleBytes'] != len(raw) or plan['oracleSHA256'] != expected[mode]['sha256']:
                raise ValueError('Plain plan uses different complete oracle')
            pins.update(plan['pins'])
            for name in ('plan.json', 'receipt.json', 'consumer.stdout', 'consumer.stderr'):
                path = directory / name; pins[str(path)] = sha(path)
            if (directory / 'consumer.stdout').read_bytes() != raw or (directory / 'consumer.stderr').read_bytes():
                raise ValueError('Plain full stdout/stderr mismatch')
            generated = Path(plan['generated']); pins[str(generated)] = sha(generated)
            if role == 'native': pins[plan['native']] = sha(plan['native'])
            plans[mode, role] = plan
        for name in (mode, mode + '-timing'):
            path = SUBJECT / ('SOURCE-FREEZE-' + name + '.json'); freeze = read(path)
            for key, digest in freeze['sourcePins'].items():
                if sha(key) != digest: raise ValueError('Frozen subject changed')
            pins.update(freeze['sourcePins']); pins[str(path)] = sha(path)
    common = plans['enabled', 'js']
    if any(p['tools'] != common['tools'] or p['environment'] != common['environment'] or p['resourceRoots'] != common['resourceRoots'] for p in plans.values()):
        raise ValueError('Correctness prerequisites differ in tools/environment/resources')
    contract_path = ROOT / 'benchmarks/contract.json'; contract = read(contract_path)
    tools = common['tools']; output = Path(output).resolve()
    if output.exists(): raise ValueError('Measurement output must start absent')
    quiet_context = Path(quiet_context).resolve(strict=True)
    for path in (Path(__file__), PROFILE, COLLECTOR, contract_path, quiet_context,
                 ROOT / 'scripts/task_runner.py', ROOT / 'scripts/receipt-logs.py', ROOT / 'scripts/evidence_boundary.py',
                 ORACLE / 'SOURCE-BASIS.json', ORACLE / 'enabled.expected.stdout', ORACLE / 'disabled.expected.stdout',
                 ORACLE / 'enabled.expected.stdout.gz', ORACLE / 'disabled.expected.stdout.gz'):
        pins[str(path)] = sha(path)
    for path, digest in pins.items():
        if sha(path) != digest: raise ValueError('Pinned prerequisite drift: ' + path)
    commands = []; artifacts = {}; prefix = [tools['taskset'], '-c', '11']
    def add(label, argv, cap, kind, **extra):
        commands.append(dict(label=label, argv=prefix + argv, capSeconds=cap, kind=kind, **extra))
    for mode in ('enabled', 'disabled'):
        entry = SUBJECT / (mode + '-timing.bend')
        js = output / (mode + '.js'); c = output / (mode + '.c'); native = output / (mode + '.native')
        add(mode + '-emit-js', [tools['bend'], str(entry), '-o', str(js)], 30, 'artifact', artifact=str(js))
        add(mode + '-emit-c', [tools['bend'], str(entry), '-o', str(c)], 30, 'artifact', artifact=str(c))
        add(mode + '-build', [tools['clangWrapper'], '-O3', str(c), '-o', str(native), '-pthread', '-lm'], 120, 'artifact', artifact=str(native))
        artifacts[mode, 'js'] = [tools['node'], str(js)]
        artifacts[mode, 'native'] = [str(native), '--threads', '1', '--gpu', 'off']
    for backend in ('js', 'native'):
        for warmup in range(contract['warmups']):
            for mode in ('enabled', 'disabled'):
                add(f'{backend}-warmup{warmup}-{mode}', artifacts[mode, backend], 5, 'timing', mode=mode, backend=backend, warmup=True)
    generator = random.Random(contract['seed'])
    for backend in ('js', 'native'):
        orders = [('enabled', 'disabled')] * (contract['pairs'] // 2) + [('disabled', 'enabled')] * (contract['pairs'] // 2)
        if len(orders) != contract['pairs']: raise ValueError('Existing pair count must be even')
        generator.shuffle(orders)
        for pair, order in enumerate(orders):
            for mode in order:
                add(f'{backend}-pair{pair}-{mode}', artifacts[mode, backend], 5, 'timing', mode=mode, backend=backend, pair=pair, warmup=False)
    for mode in ('enabled', 'disabled'):
        for kind in ('cpu', 'heap'):
            profile = output / (mode + '-' + kind + '.profile.json')
            add(mode + '-' + kind, [tools['node'], str(PROFILE), kind, plans[mode, 'js']['generated'], str(profile)], 5, 'profile', mode=mode, profileKind=kind, profile=str(profile))
    plan = dict(scope='Finite Workshop complete ordinary lifecycle plus full report construction: 21steps/31checkpoints/10runs per process. Different required On/Off trace report bytes. No isolated-hook, TS comparison, speed, threshold or full-parity claim.',
                output=str(output), cpu=11, cwd=str(SUBJECT), tools=tools, environment=common['environment'], resourceRoots=common['resourceRoots'], pins=pins,
                expected=expected, commands=commands, quietContext=str(quiet_context), warmups=contract['warmups'], pairs=contract['pairs'], seed=contract['seed'],
                profileOptions=dict(cpuIntervalMicroseconds=100, heapSamplingBytes=32768, includeCollectedMajor=True, includeCollectedMinor=True, drainMilliseconds=20),
                timingScope='Timer begins before fresh World creation, full lifecycle and UTF8 capture/hash in region; flush after end. Profiling separately includes startup/import/IO; sampled estimates not RSS or exact allocated bytes.')
    output.mkdir(); path = output / 'plan.json'; path.write_text(json.dumps(plan, indent=2) + '\n'); print(str(path), sha(path))


def execute(path, digest):
    """Use existing command ownership, immutable logs and failure-safe receipts."""
    path = Path(path).resolve(strict=True)
    if sha(path) != digest: raise ValueError('Unreviewed plan identity')
    plan = read(path); out = Path(plan['output'])
    if path != out / 'plan.json' or plan['cpu'] != 11 or str(Path(sys.executable).resolve()) != plan['tools']['python']:
        raise ValueError('Wrong plan location/CPU/interpreter')
    if 11 not in os.sched_getaffinity(0): raise ValueError('CPU11 unavailable')
    for name, expected in plan['pins'].items():
        if sha(name) != expected: raise ValueError('Input drift before helper import')
    sys.path.insert(0, str(ROOT / 'scripts'))
    import task_runner
    from evidence_boundary import GuardBoundary, ReceiptBoundary
    logs = load('trace57_measurement_logs', ROOT / 'scripts/receipt-logs.py').CommandLogs(out, [c['label'] for c in plan['commands']])
    inputs = task_runner.Inputs(files=[path, *plan['pins']], directories=plan['resourceRoots'])
    if task_runner.Inputs(directories=plan['resourceRoots']).expected != plan['resourceRoots']:
        raise ValueError('Installed resource membership drift')
    published = {}; guard_pins = {}
    receipt = dict(scope=plan['scope'], planSHA256=digest, commands=[], observations=[], profiles={}, guards={})
    runner = task_runner.Runner(logs, inputs=inputs, env=plan['environment'], cwd=plan['cwd'], capture='split')
    def guard():
        inputs.guard(); logs.guard()
        for name, expected in {**published, **guard_pins}.items():
            if sha(name) != expected: raise ValueError('Published evidence drift')
    def publish(label):
        guard(); target = out / (label + '.guard.json')
        if target.exists(): raise ValueError('Guard must start absent')
        target.write_text(json.dumps(dict(unchanged=True, actualPins=inputs.snapshot(), artifacts=published, rawLogs=logs.hashes), indent=2) + '\n')
        guard_pins[str(target)] = sha(target); receipt['guards'] = dict(guard_pins)
    expected = {mode: gzip.decompress(Path(value['path']).read_bytes()) for mode, value in plan['expected'].items()}
    for mode, raw in expected.items():
        info = plan['expected'][mode]
        if len(raw) != info['bytes'] or hashlib.sha256(raw).hexdigest() != info['sha256'] or fnv(raw) != info['fnv1a32']:
            raise ValueError('Independent full oracle differs')
    with open('/tmp/bendvy-parity-heavy.lock', 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        with ReceiptBoundary(receipt, out / 'receipt.json', [('inputs/logs/artifacts', guard)]):
            publish('initial')
            for command in plan['commands']:
                label = command['label']; publish(label + '-pre')
                target = command.get('artifact', command.get('profile'))
                if target and Path(target).exists(): raise ValueError('Prospective output exists')
                attempt = dict(command, status='INCOMPLETE', resourceBefore=telemetry()); receipt['commands'].append(attempt)
                try:
                    with GuardBoundary([('post evidence', guard)]):
                        result = runner.run(label, command['argv'], command['capSeconds'], expected=None)
                        attempt.update({k: result[k] for k in ('exit', 'failure', 'runnerSHA256')})
                        if result['exit'] != 0 or result['failure'] is not None: raise ValueError('Child failed: ' + label)
                        if command['kind'] == 'artifact':
                            if result['stdout'] or result['stderr']: raise ValueError('Emit/build wrote unexpected streams')
                            published[target] = sha(target)
                        else:
                            if result['stdout'] != expected[command['mode']]: raise ValueError('Complete output mismatch: ' + label)
                            if command['kind'] == 'timing':
                                timer_record = json.loads(result['stderr'])
                                if list(timer_record) != ['elapsedNs', 'bytes', 'digest'] or result['stderr'] != (json.dumps(timer_record, separators=(',', ':')) + '\n').encode(): raise ValueError('Unexpected timer protocol')
                                if not isinstance(timer_record['elapsedNs'], str) or not timer_record['elapsedNs'].isascii() or not timer_record['elapsedNs'].isdecimal(): raise ValueError('Invalid timer duration')
                                info = plan['expected'][command['mode']]
                                if type(timer_record['bytes']) is not int or type(timer_record['digest']) is not int or timer_record['bytes'] != info['bytes'] or timer_record['digest'] != info['fnv1a32']: raise ValueError('Timer full-byte/digest mismatch')
                                receipt['observations'].append(dict(label=label, mode=command['mode'], backend=command['backend'], warmup=command['warmup'], pair=command.get('pair'), **timer_record))
                            else:
                                if result['stderr']: raise ValueError('Profile child wrote stderr')
                                data = read(target); profile = data['profile']
                                if data['mode'] != command['profileKind'] or data['zeroExits'] != 1: raise ValueError('Profile completion mismatch')
                                if command['profileKind'] == 'cpu':
                                    if not profile.get('nodes'): raise ValueError('Missing CPU nodes')
                                elif not profile.get('head') or not profile.get('samples'): raise ValueError('Missing sampled heap')
                                published[target] = sha(target); receipt['profiles'][label] = dict(path=target, sha256=published[target], interpretation='Separate CPU samples or sampled allocations including collected objects; not elapsed verdict/RSS/exact physical allocation')
                        attempt['status'] = 'COMPLETE_FULL_OUTPUT_VALIDATED'
                except BaseException as error:
                    if hasattr(error, 'result'): attempt.update({k: error.result[k] for k in ('exit', 'failure', 'runnerSHA256')})
                    raise
                finally:
                    if target and Path(target).is_file(): published[target] = sha(target)
                    receipt['rawLogs'] = dict(logs.hashes)
                    attempt['resourceAfter'] = telemetry()
                    primary = sys.exc_info()[1]
                    try: publish(label + '-post')
                    except BaseException as error:
                        if primary is None: raise
                        primary.add_note('postguard publication: ' + str(error))
            receipt['summary'] = []
            for backend in ('js', 'native'):
                for mode in ('enabled', 'disabled'):
                    values = [int(v['elapsedNs']) for v in receipt['observations'] if v['backend'] == backend and v['mode'] == mode and not v['warmup']]
                    if len(values) != plan['pairs']: raise ValueError('Incomplete timing observations')
                    receipt['summary'].append(dict(backend=backend, mode=mode, count=len(values), medianNs=statistics.median(values), minimumNs=min(values), maximumNs=max(values)))
            receipt['status'] = 'COMPLETE_FINITE_TIMING_AND_SAMPLED_PROFILES_NO_PERFORMANCE_VERDICT'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(); sub = parser.add_subparsers(dest='action', required=True)
    p = sub.add_parser('prepare'); p.add_argument('--output', required=True); p.add_argument('--quiet-context', required=True)
    p = sub.add_parser('execute'); p.add_argument('--plan', required=True); p.add_argument('--plan-sha256', required=True)
    args = parser.parse_args()
    if args.action == 'prepare': prepare(args.output, args.quiet_context)
    else: execute(args.plan, args.plan_sha256)
