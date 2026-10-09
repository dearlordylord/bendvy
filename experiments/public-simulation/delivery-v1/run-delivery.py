"""Relocated #63 delivery adapter using ordinary snapshot/verify and Runner."""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import stat
import sys
import types
HERE = Path(__file__).resolve().parent
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def regular(path):
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    try:
        if not stat.S_ISREG(os.fstat(fd).st_mode): raise ValueError('regular delivery input required')
        with os.fdopen(fd, 'rb', closefd=False) as stream: return stream.read()
    finally: os.close(fd)

def publish(path, raw):
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, 'wb') as stream: stream.write(raw)

def load(name, path, pins):
    raw = regular(path)
    if sha(raw) != pins[str(Path(path).resolve())]: raise ValueError('helper drift before import')
    module = types.ModuleType(name); module.__file__ = str(path); sys.modules[name] = module
    exec(compile(raw, str(path), 'exec'), module.__dict__)
    return module

def encoded(value):
    if isinstance(value, bytes): return {'rawHex': value.hex()}
    if isinstance(value, dict): return {k: encoded(v) for k, v in value.items()}
    if isinstance(value, (tuple, list)): return [encoded(v) for v in value]
    return value

def admitted(path, digest):
    if sha(regular(path)) != digest: raise ValueError('exact delivery plan required')
    plan = json.loads(regular(path)); pins = dict(plan['pins']); pins[str(Path(path).resolve())] = digest
    actual = str(Path(sys.executable).resolve(strict=True))
    if actual != plan['python'] or sha(regular(actual)) != pins[actual]: raise ValueError('delivery interpreter drift')
    if any(sha(regular(p)) != expected for p, expected in pins.items()): raise ValueError('delivery input drift before imports')
    if str(Path(__file__).resolve()) not in pins: raise ValueError('collector must be pinned')
    return plan, pins

def run(path, digest):
    plan, pins = admitted(path, digest)
    if plan.get('samplingHelper') and (not plan.get('quietWindowContext') or plan['quietWindowContext'] == 'NOT_ESTABLISHED'): raise ValueError('Integrator quiet-window context required before sampling imports')
    modules = {name: load(name, file, pins) for name, file in plan['helpers'].items()}
    # Comparator's ordinary prepare import is the previously verified exact module.
    comparator = load('simulation_delivery_compare', plan['comparator'], pins)
    parser = load('simulation_delivery_parser', plan['parser'], pins)
    comparator.parser_functions = lambda: (parser.parse, parser.render)
    ts_joiner = load('simulation_delivery_ts_joiner', plan['tsJoiner'], pins)
    ts_observed = None
    qualification = load('simulation_timing_controls', plan['qualificationValidator'], pins) if plan.get('qualificationValidator') else None
    sampling = load('simulation_timing_sampling', plan['samplingHelper'], pins) if plan.get('samplingHelper') else None
    def telemetry():
        cpu = 'cpu5 '
        result = {'loadavg': Path('/proc/loadavg').read_text().strip(), 'cpuStat': next(line for line in Path('/proc/stat').read_text().splitlines() if line.startswith(cpu))}
        for name, file in [('pressure', Path('/proc/pressure/cpu')), ('frequency', Path('/sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq'))]:
            if file.exists(): result[name] = file.read_text().strip()
        return result
    def observe_after(row, primary=None):
        try: row['telemetryAfter'] = telemetry()
        except BaseException as error:
            row['telemetryFailure'] = {'type': type(error).__name__, 'error': str(error)}
            if primary is None: raise
            primary.add_note('telemetry: ' + type(error).__name__ + ': ' + str(error))
    out = Path(plan['outputRoot']); stage = Path(plan['stageRoot'])
    if out.exists() or out.is_symlink(): raise ValueError('delivery outputs start absent')
    out.mkdir(mode=0o700); receiptpath = out / 'receipt.json'; publish(receiptpath, b'')
    record = {'planSHA256': digest, 'scope': plan['scope'], 'commands': [], 'probes': [], 'guards': [], 'generated': {}, 'cases': {}, 'closedResolverQualified': False}
    input_guard = modules['runner'].Inputs(files=plan['smallInputPaths'] + [str(Path(path).resolve())])
    probe_number = 0; snapshot = None
    resource_config = dict(plan['toolConfiguration']); resource_config['env'] = dict(resource_config['env'])
    def discover(argv, cap, env):
        nonlocal probe_number
        if cap != 5 or argv[:3] != [resource_config['taskset'], '-c', '5'] or env != resource_config['env']: raise ValueError('unexpected probe policy')
        label = 'probe-' + str(probe_number).zfill(3); probe_number += 1
        input_guard.guard()
        result = modules['runner'].execute_result(argv, cap, env, str(stage), 'split')
        row = encoded(result); row.update(label=label, argv=argv, capSeconds=cap); record['probes'].append(row)
        # Completed raw bytes retained before either publication can fail.
        logs.record(label, result['stdout'], result['stderr'])
        input_guard.guard()
        return result
    resource_config['execute'] = discover
    reverse = comparator.stage_joins(stage)
    if reverse != plan['constructorJoins']: raise ValueError('full source-derived constructor join drift')
    cfg = modules['metadata']
    def source_guard(label):
        regular(receiptpath)
        for name, digest in logs.hashes.items():
            if sha(regular(out / name)) != digest: raise ValueError('raw output drift')
        logs.guard(); input_guard.guard()
        actual_stage = {str(p.relative_to(stage)): sha(regular(p)) for p in stage.rglob('*') if p.is_file()}
        if actual_stage != plan['stagePins'] or any(p.is_symlink() for p in stage.rglob('*')): raise ValueError('exact106 source stage drift')
        namespace = cfg.namespace_state(plan['namespaceLiterals'])
        if namespace != plan['namespace']: raise ValueError('tool/loader/config alias drift')
        for name, value in plan['configPresence'].items():
            file = Path(name); actual = sha(regular(file)) if file.is_file() else None
            if file.is_symlink() or actual != value: raise ValueError('ancestor configuration drift')
        generated = {}
        for name in sorted({c['emits'] for c in plan['commands'] if c.get('emits')}):
            file = out / name
            if file.exists() or file.is_symlink():
                raw = regular(file); generated[name] = sha(raw)
                if name in record['generated'] and record['generated'][name] != generated[name]: raise ValueError('generated artifact drift')
        record['generated'].update(generated)
        target = out / (label + '.guard.json')
        data = {'label': label, 'actualPins': {p: sha(regular(p)) for p in pins}, 'stagePins': actual_stage, 'namespace': namespace, 'generated': generated, 'rawPins': dict(logs.hashes), 'ordinaryToolsVerified': snapshot is not None, 'unchanged': True}
        publish(target, (json.dumps(data, indent=2) + '\n').encode()); record['guards'].append({'path': str(target), 'sha256': sha(regular(target))})
    def ordinary_guard(label):
        # Source/config/raw/generated guard always runs AFTER discovery, including
        # on discovery failure; GuardBoundary retains the primary exception.
        with modules['boundary'].GuardBoundary([('source', lambda: source_guard(label))]):
            if snapshot is not None:
                current = modules['tools'].verify(snapshot, **resource_config)
                record.setdefault('toolVerifications', []).append({'label': label, 'snapshot': encoded(current)})
    def final_guard():
        with open(plan['lock'], 'a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            try: ordinary_guard('final')
            finally: fcntl.flock(lock, fcntl.LOCK_UN)
    labels = [command['label'] for command in plan['commands']]
    logs = modules['logs'].CommandLogs(out, labels + ['probe-' + str(i).zfill(3) for i in range(plan['maximumProbeCommands'])])
    runner = modules['runner'].Runner(logs, inputs=input_guard, env=resource_config['env'], cwd=str(stage), capture='split')
    with modules['boundary'].ReceiptBoundary(record, receiptpath, [('final', final_guard)]):
        with open(plan['lock'], 'a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            try:
                source_guard('initial-pre')
                snapshot = modules['tools'].snapshot(**resource_config); record['ordinaryToolSnapshot'] = encoded(snapshot)
                source_guard('initial-acquired')
                for command in plan['commands']:
                    label = command['label']; source_guard(label + '-pre')
                    if command.get('emits') and ((out / command['emits']).exists() or (out / command['emits']).is_symlink()): raise ValueError('Generated target must start absent')
                    ordinary_guard(label + '-acquired')
                    with modules['boundary'].GuardBoundary([('post', lambda: ordinary_guard(label + '-post'))]):
                        row = {'label': label, 'argv': command['argv'], 'capSeconds': command['capSeconds']}; record['commands'].append(row)
                        if sampling is not None: row['telemetryBefore'] = telemetry()
                        try: result = runner.run(label, command['argv'], command['capSeconds'], expected=command.get('expectedExit', 0))
                        except BaseException as error:
                            result = getattr(error, 'result', None)
                            if result is not None: row.update(encoded(result))
                            if sampling is not None: observe_after(row, error)
                            if command.get('emits'):
                                file = out / command['emits']
                                try:
                                    if file.exists() or file.is_symlink(): record['generated'][command['emits']] = sha(regular(file))
                                except BaseException as capture_error:
                                    row['artifactCaptureFailure'] = {'artifact': command['emits'], 'type': type(capture_error).__name__, 'error': str(capture_error)}
                                    error.add_note('partial artifact capture: ' + type(capture_error).__name__ + ': ' + str(capture_error))
                            raise
                        else: row.update(encoded(result))
                        if sampling is not None: observe_after(row)
                        # Bind actual regular partial/generated bytes before interpreting success.
                        if command.get('emits'):
                            file = out / command['emits']; record['generated'][command['emits']] = sha(regular(file))
                        for stream in ['stdout', 'stderr']: row[stream] = {'rawHex': result[stream].hex(), 'sha256': sha(result[stream]), 'bytes': len(result[stream])}
                        if qualification is not None:
                            if command.get('control'):
                                qualification.validate(command['control'], result['stdout'], result['stderr'])
                                record['cases'][label] = {'reachedControlMatch': True}
                            elif result['stderr']: raise ValueError('control build stderr: ' + label)
                        elif result['stderr']: raise ValueError('delivery command stderr: ' + label)
                        if label == 'TS':
                            if result['stdout'] != regular(plan['tsExpected']): raise ValueError('wholeTS reference mismatch')
                            ts_observed = json.loads(result['stdout'])
                            record['cases']['TS'] = {'completeMatch': True, 'stdoutSHA256': sha(result['stdout'])}
                        if label in ['JS-run', 'Native-run']:
                            comparator.validate_report(result['stdout'], reverse)
                            parsed = parser.parse(result['stdout'].decode())
                            schemas = ts_joiner.fields(parsed, 'TwoSchemaReport')
                            if ts_observed is None or len(schemas) != 2 or len(ts_observed) != 2: raise ValueError('TS schema count mismatch')
                            for phases, ts in zip(schemas, ts_observed):
                                if len(phases) != len(ts['phases']) or len(phases) != 14: raise ValueError('TS phase count mismatch')
                                for bend_phase, ts_phase in zip(phases, ts['phases']):
                                    expected = {'label': ts_phase['label'], 'ok': ts_phase['result']['ok'], 'entities': ts_phase['dump']['entities'], 'step': ts_phase['dump']['resources']['Simulation/Step'], 'pendingCount': len(ts_phase['dump']['pendingCommands']), 'readers': ts_phase['readers']}
                                    if ts_joiner.shared(bend_phase) != expected: raise ValueError('Full TS shared checkpoint mismatch')
                            record['cases'][label] = {'completeMatch': True, 'fullOracleSHA256': plan['oracleSHA256'], 'stdoutSHA256': sha(result['stdout'])}
                    if command.get('runtimeArtifact') or label == 'Native-clang':
                        resource_config['tools'] = dict(resource_config['tools'], **{label if qualification is not None else 'generatedNative': str(out / command.get('runtimeArtifact', 'simulation.native'))})
                        snapshot = modules['tools'].snapshot(**resource_config)
                        record['nativeRuntimeSnapshot'] = encoded(snapshot)
                if qualification is not None:
                    if set(record['cases']) != {c['label'] for c in plan['commands'] if c.get('control')}: raise ValueError('complete reached controls required')
                    if sampling is not None:
                        record['observations'] = sampling.summarize(plan['samplingRows'], record['commands'])
                        record['quietWindowContext'] = plan['quietWindowContext']
                        record['status'] = 'COMPLETE_SCOPED_SIMULATION_TIMING_OBSERVATIONS_NOT_STATISTICAL_VERDICT'
                    else: record['status'] = 'REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT'
                else:
                    if set(record['cases']) != {'TS', 'JS-run', 'Native-run'}: raise ValueError('fullmatrix incomplete')
                    record['status'] = 'RELOCATED_SIMULATION_SEMANTIC_DELIVERY_PASS_NOT_TIMING_OR_FULL_PARITY'
            finally: fcntl.flock(lock, fcntl.LOCK_UN)

if __name__ == '__main__': run(sys.argv[1], sys.argv[2])
