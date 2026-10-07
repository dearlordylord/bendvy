#!/usr/bin/env python3
"""Freeze the exact bounded runner and reused ordinary installed snapshot."""
import argparse
import gzip
import json
import os
import pathlib

from importlib.util import module_from_spec, spec_from_file_location

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = spec_from_file_location('controls_execution', HERE / 'controls-execute.py')
execution = module_from_spec(spec)
spec.loader.exec_module(execution)
gate = execution.gate


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    assert not out.exists()
    held = ROOT / '.artifacts/machines-stream-opt-controls-freeze-v1/plan.json'
    prepared = json.loads(held.read_text())
    prior = ROOT / '.artifacts/machines-stream-opt-linear-native-freeze-v1'
    prior_plan = json.loads((prior / 'plan.json').read_text())
    prior_receipt = json.loads((prior / 'receipt.json').read_text())
    assert prior_receipt['status'] == 'FULL65537_LINEAR_OBSERVER_NATIVE_MODEL_PASS_NO_ISSUE_ACCEPTANCE'
    assert prior_receipt['planSHA256'] == gate.sha(prior / 'plan.json')
    expected = execution.decoded(prior_plan['installedTools'])
    assert all(gate.sha(p) == h for p, h in expected['pins'].items())
    assert all(gate.tree(pathlib.Path(p)) == inventory for p, inventory in prior_plan['resources'].items())
    assert all(gate.tree(pathlib.Path(p)) == inventory for p, inventory in prepared['stageInventories'].items())
    assert all(gate.sha(p) == h for p, h in prepared['sources'].items())
    out.mkdir()
    env_bytes = (prior / 'environment.private.json').read_bytes()
    assert gate.sha(prior / 'environment.private.json') == prior_plan['privateEnvironmentMapSHA256']
    private = out / 'environment.private.json'
    descriptor = os.open(private, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(descriptor, 'wb') as stream:
        stream.write(env_bytes)
    (out / 'expected.json.gz').write_bytes((prior / 'expected.json.gz').read_bytes())
    sources = dict(prepared['sources'])
    additional = [HERE / 'controls-execute.py', HERE / 'controls-freeze.py', HERE / 'mutant-oracles.py', HERE.parent / 'run-semantic.py', HERE.parent / 'mutations.py', ROOT / 'scripts/owned-tool-pins.py', held, prior / 'plan.json', prior / 'receipt.json', prior / 'environment.private.json', prior / 'expected.json.gz', HERE.parent / 'evidence/primary-ts-v1/expected.json.gz']
    additional += [HERE.parent / (n + '-model.py') for n in ['skip', 'foreign', 'overflow']]
    additional += [HERE.parent.parent / 'evidence/check-preflight-v6' / (n[:-5] + '.stderr') for n in execution.controls.NEGATIVES]
    sources.update({str(p): gate.sha(p) for p in additional})
    commands = []
    for job in prepared['commands']:
        job = dict(job)
        job['newArtifacts'] = []
        if 'expectedStderrSHA256' in job:
            job['argv'] = [expected['taskset'], '-c', '7', expected['tools']['bend'], job['argv'][-1], '--check-only']
            job['validate'] = 'negative'
        else:
            job['argv'] = [a.replace(str(held.parent), str(out)) for a in job['argv']]
            if job['label'].endswith('-emit'):
                job['newArtifacts'] = [job['argv'][-1].split('/')[-1]]
            else:
                job['validate'] = 'mutant'
                job['oracleArtifact'] = job['mutant'] + '-expected.json.gz'
                body = json.dumps(execution.oracles.expected(job['mutant'], execution.model), sort_keys=True).encode()
                (out / job['oracleArtifact']).write_bytes(gzip.compress(body))
        commands.append(job)
    directories = list(prepared['stageInventories']) + list(prior_plan['resources'])
    files = sorted(set(sources) | set(expected['pins']) | {str(private), str(out / 'expected.json.gz')} | {str(out / j['oracleArtifact']) for j in commands if 'oracleArtifact' in j})
    inputs = execution.runner.Inputs(files=files, directories=directories)
    configuration_bases = [str(out), *prepared['stageInventories']]
    configuration_bases += [str(pathlib.Path(p) / 'experiments/public-machines/followup') for p in prepared['stageInventories']]
    ldd_count = len(expected['tools']) - len(expected['skip_ldd'])
    plan = {'status': 'FROZEN_NOT_EXECUTED_REVIEW_REQUIRED', 'scope': prepared['scope'], 'sources': sources, 'preservedPreparedPlanSHA256': gate.sha(held), 'installedTools': gate.encoded(expected), 'installedSnapshotReusedFrom': {'receiptSHA256': gate.sha(prior / 'receipt.json'), 'source': str(prior), 'filePinsUnchanged': True, 'completeEnvironmentUnchanged': True, 'initialDiscovery': False}, 'resources': prior_plan['resources'], 'stageInventories': prepared['stageInventories'], 'inputFiles': files, 'inputDirectories': directories, 'inputSnapshot': inputs.expected, 'configurationBases': configuration_bases, 'configuration': gate.configurations([pathlib.Path(p) for p in configuration_bases]), 'privateEnvironmentMapSHA256': gate.sha(private), 'privateValuesExcluded': True, 'expectedModelSHA256': __import__('hashlib').sha256(gzip.decompress((out / 'expected.json.gz').read_bytes())).hexdigest(), 'commands': commands, 'initialArtifacts': gate.tree(out), 'maxChildren': len(commands) * (2 * ldd_count + 1), 'toolProbePlan': {'initialDiscovery': False, 'ordinaryVerifyBeforeAfterEverySubject': True, 'filesPinned': len(expected['pins']), 'lddPerVerification': ldd_count, 'verificationCount': 2 * len(commands), 'plannedLddChildren': 2 * len(commands) * ldd_count, 'sharedInputsBeforeAfterEveryChild': True}, 'generatedArtifactsInitiallyAbsent': all(not (out / n).exists() for j in commands for n in j['newArtifacts'])}
    (out / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(json.dumps({'status': plan['status'], 'planSHA256': gate.sha(out / 'plan.json'), 'subjects': len(commands), 'children': plan['maxChildren']}))


if __name__ == '__main__':
    main()
