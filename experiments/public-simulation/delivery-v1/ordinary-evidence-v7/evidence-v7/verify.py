"""Verify retained current simulation delivery without launching children."""
import gzip
import hashlib
import importlib.util
import io
import json
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
LEAF = '/workspace/formal-proofs/bendvy/experiments/public-simulation/delivery-v1/ordinary-evidence-v7'
PLAN_HASHES = {
    LEAF + '/plan.json': '62ddc7cedc20c28cf19886fcbae47cd22464653dcc6075a78c48de26f048b5fa',
    LEAF + '/reached-hit-death-v1/plan.json': 'de303c94e974a1612b59662ef5c14a4cfbb600e49d470abba9c013ce1f46f56e',
    LEAF + '/reached-hit-death-v1/death-only-plan-v1.json': 'c6e45e26cb4d0c4c1dd9a7100143a6cfa8b107219bf8f21c1769e6cb3de87431',
    LEAF + '/reached-hit-death-v1/death-only-plan-v2.json': '417b5200f0db2f86bd9e93c1bc910493577986fc1d9161be5ba5a491f64049fa',
}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def verified():
    manifest = json.loads((HERE / 'MANIFEST.json').read_bytes())
    base = (HERE / manifest['basePacket']['relativePath']).resolve()
    for name, key in [('MANIFEST.json', 'manifestSHA256'), ('verify.py', 'verifierSHA256')]:
        assert sha((base / name).read_bytes()) == manifest['basePacket'][key]
    spec = importlib.util.spec_from_file_location('retained_simulation_v6', base / 'verify.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    old_plan, old_receipt, raws = module.verified()
    originals = dict(raws)
    names = set()
    for row in manifest['members']:
        assert row['source'] not in names
        names.add(row['source'])
        path = HERE / row['archive']
        assert not path.is_symlink() and path.is_file()
        assert Path(row['archive']).parts[0] == 'archive' and '..' not in Path(row['archive']).parts
        packed = path.read_bytes()
        assert sha(packed) == row['archiveSHA256']
        raw = gzip.decompress(packed)
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        raws[row['source']] = raw
    assert {str(p.relative_to(HERE)) for p in (HERE / 'archive').iterdir()} == {r['archive'] for r in manifest['members']}
    controls = LEAF + '/reached-hit-death-v1'
    with tarfile.open(fileobj=io.BytesIO(raws[controls + '/variant-stages.tar.gz']), mode='r:gz') as archive:
        for member in archive.getmembers():
            assert member.isfile() and member.name.startswith('stages/')
            assert '..' not in Path(member.name).parts
            key = '/tmp/bendvy63-reached-hit-death-source-v1/' + member.name.removeprefix('stages/')
            assert key not in raws
            raws[key] = archive.extractfile(member).read()

    def data(path):
        return json.loads(raws[str(path)])

    def check_run(plan_path, count, status, guards):
        assert sha(raws[plan_path]) == PLAN_HASHES[plan_path]
        plan = data(plan_path)
        output = Path(plan['outputRoot'])
        receipt = data(output / 'receipt.json')
        assert receipt['planSHA256'] == sha(raws[plan_path])
        assert receipt['status'] == status and receipt['closedResolverQualified'] is False
        assert len(receipt['commands']) == count and len(receipt['guards']) == guards
        if status != 'INCOMPLETE':
            assert not receipt.get('error') and not receipt.get('guardFailures')
        old_validator = controls + '/validator-history/de303/validate-reached-controls.py.source'
        for path, digest in plan['pins'].items():
            if path.startswith('/workspace/') or path.startswith(plan['stageRoot']) or path.startswith('/tmp/bendvy63-reached-hit-death-source-v1/'):
                raw = raws[path]
                if path == controls + '/validate-reached-controls.py' and digest == sha(raws[old_validator]):
                    raw = raws[old_validator]
                assert sha(raw) == digest, path
        for planned, actual in zip(plan['commands'][:count], receipt['commands']):
            assert actual['label'] == planned['label'] and actual['argv'] == planned['argv']
            assert actual['capSeconds'] == planned['capSeconds']
            assert actual['exit'] == 0 and actual['failure'] is None
            assert actual['runnerSHA256'] == plan['pins']['/workspace/formal-proofs/bendvy/scripts/task_runner.py']
            for stream in ['stdout', 'stderr']:
                raw = raws[str(output / (actual['label'] + '.' + stream))]
                binding = actual[stream]
                assert raw.hex() == binding['rawHex']
                if 'sha256' in binding:
                    assert sha(raw) == binding['sha256'] and len(raw) == binding['bytes']
                else:
                    assert status == 'INCOMPLETE' and actual['label'] == 'omit-death-JS-emit'
                if stream == 'stderr':
                    assert raw == b''
        for probe in receipt['probes']:
            assert probe['exit'] == 0 and probe['failure'] is None
            assert probe['capSeconds'] == 5 and probe['argv'][:3] == ['/usr/bin/taskset', '-c', '5']
            for stream in ['stdout', 'stderr']:
                raw = raws[str(output / (probe['label'] + '.' + stream))]
                assert raw.hex() == probe[stream]['rawHex']
        previous_raw = {}
        previous_generated = {}
        labels = ['initial-pre', 'initial-acquired']
        labels += [command['label'] + '-' + suffix for command in receipt['commands'] for suffix in ['pre', 'acquired', 'post']]
        labels += ['final']
        assert len(labels) == guards
        for index, binding in enumerate(receipt['guards']):
            assert sha(raws[binding['path']]) == binding['sha256']
            guard = data(binding['path'])
            assert guard['label'] == labels[index] and guard['unchanged'] is True
            assert guard['ordinaryToolsVerified'] is (index != 0)
            assert guard['actualPins'] == dict(plan['pins'], **{plan_path: sha(raws[plan_path])})
            for path, digest in guard['stagePins'].items():
                assert sha(raws[str(Path(plan['stageRoot']) / path)]) == digest
            for path, digest in guard['rawPins'].items():
                assert sha(raws[str(output / path)]) == digest
            for path, digest in guard['generated'].items():
                assert sha(raws[str(output / path)]) == digest
            assert previous_raw.items() <= guard['rawPins'].items()
            assert previous_generated.items() <= guard['generated'].items()
            previous_raw = guard['rawPins']
            previous_generated = guard['generated']
        for path, digest in receipt['generated'].items():
            assert sha(raws[str(output / path)]) == digest
        return plan, receipt

    plan, normal = check_run(LEAF + '/plan.json', 7, 'RELOCATED_SIMULATION_SEMANTIC_DELIVERY_PASS_NOT_TIMING_OR_FULL_PARITY', 24)
    assert len(normal['probes']) == 140
    for label in ['TS', 'JS-run', 'Native-run']:
        assert normal['cases'][label]['completeMatch'] is True
        assert raws[str(Path(plan['outputRoot']) / (label + '.stdout'))] == originals[str(Path(old_plan['outputRoot']) / (label + '.stdout'))]
    hit_plan, hit = check_run(controls + '/plan.json', 3, 'INCOMPLETE', 12)
    _, failed_death = check_run(controls + '/death-only-plan-v1.json', 2, 'INCOMPLETE', 9)
    death_plan, death = check_run(controls + '/death-only-plan-v2.json', 3, 'REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT', 12)
    assert death['cases']['omit-death-JS-run']['reachedControlMatch'] is True
    posthoc = data(controls + '/posthoc-retained-hit.json')
    assert sha(raws[posthoc['originalCollector']['receiptPath']]) == posthoc['originalCollector']['receiptSha256']
    assert hit['error'] == posthoc['originalCollector']['receiptError']
    assert posthoc['originalCollector']['status'] == 'INCOMPLETE'
    validator = {}
    exec(compile(raws[controls + '/validate-reached-controls.py'], 'retained-validator', 'exec'), validator)
    validator['read_regular'] = lambda path: raws[str(Path(path).resolve())]
    for role, current in [('omit-hit', hit_plan), ('omit-death', death_plan)]:
        output = Path(current['outputRoot'])
        assert validator['validate'](role, raws[str(output / (role + '-JS-run.stdout'))], raws[str(output / (role + '-JS-run.stderr'))], plan=current) is True
    return {'status': 'PASS_RETAINED_CURRENT_SIMULATION_AND_REACHED_EVENT_CONTROLS', 'members': len(manifest['members']), 'ordinaryCommands': 7, 'ordinaryGuards': 24, 'posthocHit': True, 'deathCommands': 3, 'historicalIncompleteAttempts': 2, 'timingOrFullParity': False, 'newChildren': 0}


if __name__ == '__main__':
    print(json.dumps(verified()))
