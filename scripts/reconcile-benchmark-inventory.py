"""Reconcile the preserved runner-membership ERROR without replaying measurements."""
import argparse
import gzip
import hashlib
import json
import random
import statistics
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'benchmarks'))
from decision import assess

def digest(data):
    return hashlib.sha256(data).hexdigest()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', type=Path)
    args = parser.parse_args()
    directory = args.directory.resolve()
    raw = (directory / 'receipt.json').read_bytes()
    receipt = json.loads(raw)
    assert receipt['status'] == 'ERROR'
    assert receipt['error'] == 'Current source inventory changed during benchmark'
    assert receipt['injectedSlowdownMs'] == 0 and 'candidateProvider' not in receipt
    contract = json.loads((ROOT / 'benchmarks/contract.json').read_bytes())
    assert receipt['contract'] == contract
    original = (directory / 'original-run.py').read_bytes()
    assert digest(original) == receipt['currentSourceHashes']['benchmarks/run.py']
    marker = b'        current = list((ROOT / "src/ecs").glob("*.bend")) + list(HERE.glob("*.py")) + [HERE / "contract.json"]\n'
    assert original.count(marker) == 1
    corrected = original.replace(marker, marker + b"        current.append(ROOT / 'scripts/task_runner.py')\n")
    assert (ROOT / 'benchmarks/run.py').read_bytes() == corrected
    current = list((ROOT / 'src/ecs').glob('*.bend')) + list((ROOT / 'benchmarks').glob('*.py'))
    current += [ROOT / 'benchmarks/contract.json', ROOT / 'scripts/task_runner.py']
    assert {str(p.relative_to(ROOT)) for p in current} == set(receipt['currentSourceHashes'])
    for name, expected in receipt['currentSourceHashes'].items():
        data = original if name == 'benchmarks/run.py' else (ROOT / name).read_bytes()
        assert digest(data) == expected
    for role in ('baseline', 'candidate'):
        stage = directory / role
        actual = {str(p.relative_to(stage)): digest(p.read_bytes())
                  for folder in (stage / 'src/ecs', stage / 'examples/query-composition')
                  for p in folder.rglob('*') if p.is_file()}
        assert actual == receipt['sources'][role]
    for name, expected in receipt['artifacts'].items():
        assert digest((directory / name).read_bytes()) == expected
    reference = ROOT / '.references/bevy-ts'
    actual = {str(p.relative_to(reference)): digest(p.read_bytes())
              for p in (reference / 'packages/core/src').rglob('*') if p.is_file()}
    assert actual == receipt['referenceHashes']
    expected = json.loads((directory / 'baseline/examples/query-composition/expected.json').read_bytes())
    expected['checkpoints'] = [p for p in expected['checkpoints'] if p['label'] != 'foreign-collision-reference']
    commands = {c['label']: c for c in receipt['commands']}
    assert len(commands) == len(receipt['commands']) and all(c['exit'] == 0 for c in commands.values())
    roles = ['TS', 'baseline-JS', 'baseline-Native', 'candidate-JS', 'candidate-Native']
    labels = [f'warmup-{i}-{role}' for i in range(contract['warmups']) for role in roles]
    labels += [f'pair-{i}-{role}' for i in range(contract['pairs']) for role in roles]
    outputs = {}
    for label in labels:
        data = gzip.decompress((directory / (label + '.stdout.gz')).read_bytes())
        assert digest(data) == commands[label]['stdoutSHA256']
        lines = data.decode().splitlines()
        assert len(lines) == contract['iterations'] and all(json.loads(line) == expected for line in lines)
        outputs[label] = digest(data)
    assert len(receipt['timings']) == contract['pairs']
    rng = random.Random(contract['seed'])
    orders = {}
    for backend in ('JS', 'Native'):
        orders[backend] = [False, True] * (contract['pairs'] // 2)
        rng.shuffle(orders[backend])
    reconstructed = []
    for i, timing in enumerate(receipt['timings']):
        groups = [['TS']]
        for backend in ('JS', 'Native'):
            group = ['baseline-' + backend, 'candidate-' + backend]
            groups.append(list(reversed(group)) if orders[backend][i] else group)
        rng.shuffle(groups)
        assert timing['pair'] == i and timing['order'] == [role for group in groups for role in group]
        assert set(timing['milliseconds']) == set(roles)
        for role in roles:
            assert timing['milliseconds'][role] == commands[f'pair-{i}-{role}']['elapsedMs']
        for backend in ('JS', 'Native'):
            reconstructed.append(dict(pair=i, backend=backend,
                                      baselineMs=timing['milliseconds']['baseline-' + backend],
                                      candidateMs=timing['milliseconds']['candidate-' + backend]))
    assert reconstructed == receipt['pairs']
    result = assess(reconstructed, contract['pairs'], contract['alpha'])
    medians = {role: statistics.median(t['milliseconds'][role] for t in receipt['timings']) for role in roles}
    derived = dict(originalReceiptSHA256=digest(raw), originalStatus='ERROR',
                   reconciliationChecks='Performed after execution; no historical PASS relabeling',
                   originalHarnessSHA256=digest(original), correctedHarnessSHA256=digest(corrected),
                   reconcilerSHA256=digest(Path(__file__).read_bytes()), outputHashes=outputs,
                   result=result, mediansMs=medians,
                   descriptiveTargets={'JS/TS': medians['candidate-JS']/medians['TS'],
                                       'Native/TS': medians['candidate-Native']/medians['TS']})
    target = directory / 'reconciliation.json'
    assert not target.exists()
    target.write_text(json.dumps(derived, indent=2) + '\n')
    print(json.dumps({'result': result, 'descriptiveTargets': derived['descriptiveTargets']}))

if __name__ == '__main__':
    main()
