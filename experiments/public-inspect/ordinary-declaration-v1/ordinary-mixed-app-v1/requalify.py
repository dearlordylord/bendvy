#!/usr/bin/env python3
"""Compare existing actual bytes to an independently repaired transport oracle; no child launch."""
import gzip
import hashlib
import json
from pathlib import Path
import types

ROOT = Path('/workspace/formal-proofs/bendvy')
HERE = Path(__file__).resolve().parent
ORIGINAL = Path('/tmp/bendvy-ordinary-mixed-app-runtime01/a-normal-js')


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load(name, path):
    module = types.ModuleType(name)
    module.__file__ = str(path)
    exec(compile(path.read_bytes(), str(path), 'exec'), module.__dict__)
    return module


def main():
    target = HERE / 'runtime-v2/requalification-a-normal-js'
    if target.exists():
        raise ValueError('Fresh comparison target required')
    plan_path = ORIGINAL / 'plan.json'
    plan = json.loads(plan_path.read_text())
    receipt_path = ORIGINAL / 'receipt.json'
    original = json.loads(receipt_path.read_text())
    if original['status'] != 'INCOMPLETE' or original['guardFailures']:
        raise ValueError('Original failed receipt facts changed')
    if any(row['exit'] != 0 or row['failure'] is not None for row in original['commands']):
        raise ValueError('Original actual command completion missing')
    if len(original['commands']) != 2 or len(original['guards']) != 7:
        raise ValueError('Original full JS command/guard sequence incomplete')
    if sha(plan_path) != original['planSHA256']:
        raise ValueError('Original plan drift')
    for path, expected in plan['pins'].items():
        if sha(path) != expected:
            raise ValueError('Original source/tool/helper/oracle pin drift: ' + path)
    collector = load('reviewed_collector', ROOT / 'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/development.py')
    if collector.validate_imports(plan['entrypoint'], plan['sourceInventory']) != plan['importClosure']:
        raise ValueError('Source closure changed')
    runner = load('reviewed_runner', ROOT / 'scripts/task_runner.py')
    config = load('selected_config', ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py')
    if runner.Inputs(directories=plan['resourceRoots']).expected != plan['resourceRoots']:
        raise ValueError('Compiler/runtime resource scope changed')
    if config.environment() != plan['environment']:
        raise ValueError('Selected environment changed')
    for command in original['commands']:
        for key in ('stdout', 'stderr'):
            stream = command[key]
            if not stream['published'] or sha(stream['path']) != stream['sha256'] or Path(stream['path']).stat().st_size != stream['bytes']:
                raise ValueError('Original command raw drift')
    guard_rows = []
    for row in original['guards']:
        if sha(row['path']) != row['sha256']:
            raise ValueError('Original guard bytes changed')
        guard = json.loads(Path(row['path']).read_text())
        if not guard['unchanged']:
            raise ValueError('Original boundary was not unchanged')
        for path, expected in plan['pins'].items():
            if guard['actualPins'][path] != expected:
                raise ValueError('Original boundary does not bind selected input')
        guard_rows.append(row)
    packet = HERE / 'ordinary-mixed-app-transport-v2'
    basis = json.loads((packet / 'SOURCE-BASIS.json').read_text())
    for path, expected in basis['inputs'].items():
        if sha(path) != expected:
            raise ValueError('Independent source printer/body basis changed')
    selection = json.loads((packet / 'ORACLES.json').read_text())['a-normal']
    oracle_path = packet / 'a-normal.stdout.gz'
    expected = gzip.decompress(oracle_path.read_bytes())
    actual_path = ORIGINAL / 'consumer.stdout'
    actual = actual_path.read_bytes()
    if len(expected) != selection['bytes'] or hashlib.sha256(expected).hexdigest() != selection['sha256'] or actual != expected:
        raise ValueError('Existing full actual output does not equal corrected independent oracle')
    generated = Path(plan['generated'])
    if sha(generated) != original['emitArtifactSHA256'] or (ORIGINAL / 'consumer.stderr').read_bytes():
        raise ValueError('Generated artifact or empty runtime stderr changed')
    target.mkdir(parents=True)
    baseline = target / 'actual-normal-baseline.stdout.gz'
    baseline.write_bytes(gzip.compress(actual, mtime=0))
    result = {'status': 'REQUALIFIED_WHOLE_ACTUAL_OUTPUT_MATCH',
              'scope': 'Existing actual production A0/2 JS only under source-validated nominal transport correction; no backend rerun',
              'originalSession': 59427, 'originalTerminalExit': 1,
              'originalReceipt': str(receipt_path), 'originalReceiptSHA256': sha(receipt_path), 'originalStatus': original['status'],
              'originalPlan': str(plan_path), 'originalPlanSHA256': sha(plan_path),
              'actualStdout': str(actual_path), 'actualStdoutSHA256': sha(actual_path), 'actualStdoutBytes': len(actual),
              'generatedJS': str(generated), 'generatedJSSHA256': sha(generated),
              'correctedOracle': str(oracle_path), 'correctedOracleSHA256': selection['sha256'], 'correctedOracleBytes': selection['bytes'],
              'independentTransportCommit': 'e67dcd0b9999709fb78be832bd1a03b107b05043',
              'modelSHA256': sha(packet / 'model.py'), 'printerRuleAndBasis': str(packet / 'SOURCE-BASIS.json'),
              'printerRuleAndBasisSHA256': sha(packet / 'SOURCE-BASIS.json'),
              'originalGuards': guard_rows, 'currentPinsJoinOriginalGuards': True,
              'sourceInventory': plan['sourceInventory'], 'resourceRoots': plan['resourceRoots'], 'environment': plan['environment'],
              'actualBaseline': str(baseline), 'actualBaselineGzipSHA256': sha(baseline),
              'precedingFailurePreserved': True, 'backendRerun': False, 'originalPlanPassed': False,
              'remainingCasesQualified': False}
    (target / 'receipt.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'comparisonReceipt': str(target / 'receipt.json'), 'status': result['status'], 'actualSHA256': sha(actual_path)}))


if __name__ == '__main__':
    main()
