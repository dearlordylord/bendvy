#!/usr/bin/env python3
"""Execute only the reviewed source-bound queue control freeze."""
import argparse
import base64
import gzip
import hashlib
import importlib.util
import json
import pathlib
import traceback

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


gate = load('controls_gate', HERE.parent / 'run-semantic.py')
runner = load('controls_runner', ROOT / 'scripts/task_runner.py')
tools = load('controls_tools', ROOT / 'scripts/owned-tool-pins.py')
controls = load('controls_subjects', HERE / 'controls.py')
oracles = load('controls_oracles', HERE / 'mutant-oracles.py')
model = load('controls_model', HERE.parent / 'overflow-model.py')


def decoded(value):
    if isinstance(value, dict):
        return base64.b64decode(value['base64']) if set(value) == {'base64'} else {k: decoded(v) for k, v in value.items()}
    if isinstance(value, list):
        return [decoded(v) for v in value]
    return value


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--freeze', type=pathlib.Path, required=True)
    args = parser.parse_args()
    out = args.freeze.resolve()
    plan_path = out / 'plan.json'
    plan_hash = gate.sha(plan_path)
    plan = json.loads(plan_path.read_text())
    expected = decoded(plan['installedTools'])
    environment_path = out / 'environment.private.json'
    assert environment_path.stat().st_mode & 0o777 == 0o600
    assert gate.sha(environment_path) == plan['privateEnvironmentMapSHA256']
    env = json.loads(environment_path.read_text())
    assert hashlib.sha256(json.dumps(env, sort_keys=True, separators=(',', ':'), ensure_ascii=True).encode()).hexdigest() == expected['environment_sha256']
    inputs = runner.Inputs(files=plan['inputFiles'], directories=plan['inputDirectories'])
    assert inputs.expected == plan['inputSnapshot']
    known = gate.tree(out)
    assert known == plan['initialArtifacts'] | {'plan.json': plan_hash}
    records = []
    receipt = {'status': 'INCOMPLETE', 'scope': plan['scope'], 'planSHA256': plan_hash, 'commands': records, 'subjects': [], 'witnesses': []}
    counter = 0

    def guard():
        inputs.guard()
        assert gate.sha(plan_path) == plan_hash
        assert gate.configurations([pathlib.Path(p) for p in plan['configurationBases']]) == plan['configuration']
        assert gate.tree(out) == known

    def child(argv, cap, *, env=env, allowed=()):
        nonlocal known, counter
        assert env == json.loads(environment_path.read_text())
        guard()
        assert counter < plan['maxChildren']
        label = f'child-{counter:03d}'
        counter += 1
        before = dict(known)
        assert not (out / (label + '.stdout.gz')).exists() and not (out / (label + '.stderr')).exists()
        result = runner.execute_result(argv, cap, env=env, cwd=str(ROOT), capture='split')
        stdout = result['stdout']
        stderr = result['stderr']
        (out / (label + '.stdout.gz')).write_bytes(gzip.compress(stdout))
        (out / (label + '.stderr')).write_bytes(stderr)
        records.append({'label': label, 'argv': list(map(str, argv)), 'cap': cap, 'exit': result['exit'], 'failure': result['failure'], 'runnerSHA256': result['runnerSHA256'], 'stdoutSHA256': hashlib.sha256(stdout).hexdigest(), 'stderrSHA256': hashlib.sha256(stderr).hexdigest()})
        after = gate.tree(out)
        assert all(after.get(n) == h for n, h in before.items())
        assert set(after) - set(before) <= {label + '.stdout.gz', label + '.stderr', *allowed}
        known = after
        guard()
        return result

    configuration = dict(execute=child, tools=expected['tools'], resource_roots=expected['resource_roots'], ldd=expected['ldd'], taskset=expected['taskset'], cpu=expected['cpu'], env=env, skip_ldd=expected['skip_ldd'], capture_mode='split')
    try:
        guard()
        expected_bytes = gzip.decompress((out / 'expected.json.gz').read_bytes())
        assert hashlib.sha256(expected_bytes).hexdigest() == plan['expectedModelSHA256']
        assert json.loads(expected_bytes) == model.expected()
        for job in plan['commands']:
            guard()
            tools.verify(expected, **configuration)
            assert all(not (out / n).exists() for n in job['newArtifacts'])
            result = child(job['argv'], job['cap'], allowed=job['newArtifacts'])
            receipt['subjects'].append({'label': job['label'], 'childLabel': records[-1]['label'], 'exit': result['exit'], 'failure': result['failure'], 'produced': {n: known[n] for n in job['newArtifacts'] if n in known}})
            assert result['failure'] is None and result['exit'] == job['expectedExit']
            assert all((out / n).is_file() for n in job['newArtifacts'])
            if job.get('validate') == 'negative':
                assert result['stdout'] == b''
                assert hashlib.sha256(result['stderr']).hexdigest() == job['expectedStderrSHA256']
            if job.get('validate') == 'mutant':
                frozen_expected = json.loads(gzip.decompress((out / job['oracleArtifact']).read_bytes()))
                oracles.validate(job['mutant'], result['stdout'], model, frozen_expected)
                receipt['witnesses'].append({'mutant': job['mutant'], 'witnesses': controls.witness(job['mutant'], result['stdout'], model)})
            tools.verify(expected, **configuration)
            guard()
        assert counter == plan['maxChildren'] and len(receipt['witnesses']) == 5
        receipt['status'] = 'FIVE_REACHED_BOTH_SCHEMA_MUTANTS_FOUR_NEGATIVES_PASS_NO_ISSUE_ACCEPTANCE'
    except BaseException as error:
        receipt['error'] = repr(error)
        receipt['traceback'] = traceback.format_exc()
    finally:
        receipt['artifacts'] = gate.tree(out)
        (out / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({'status': receipt['status'], 'receiptSHA256': gate.sha(out / 'receipt.json'), 'children': counter}))


if __name__ == '__main__':
    main()
