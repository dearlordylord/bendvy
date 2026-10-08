"""Rebase retained defects onto developmental typed two-helper stage; no children."""
import hashlib
import io
import json
import shutil
import tarfile
import time
from pathlib import Path

H = Path(__file__).resolve().parent
ROOT = H.parents[2]
sha = lambda data: hashlib.sha256(data).hexdigest()
normal = H / 'development/handler-helper-source-controls-1791425283404374668'
plan = json.loads((normal / 'plan.json').read_text())
receipt = json.loads((normal / 'receipt.json').read_text())
assert receipt['status'] == 'DEVELOPMENT_HANDLER_HELPERS_SEVEN_SOURCE_DIAGNOSTICS_PASS_NO_FINAL_RESOLVER_OR_RUNTIME'
assert receipt['planSHA256'] == sha((normal / 'plan.json').read_bytes())
assert all(sha(Path(p).read_bytes()) == digest for p, digest in plan['pins'].items())
baseline = Path(plan['stage'])
assert {str(p.relative_to(baseline)): sha(p.read_bytes()) for p in baseline.rglob('*')
        if p.is_file()} == plan['inventory']
oldManifestPath = H / 'delivery-mutants-v1/manifest.json'
oldManifest = json.loads(oldManifestPath.read_text())
assert sha(oldManifestPath.read_bytes()) == '8c1c878aa8deba3f05f7dff81afb31eb23535be3f20ca6e2297362a5d6ed2671'
a = oldManifest['archives']['complete-js']
blob = (oldManifestPath.parent / a['archive']).read_bytes()
assert sha(blob) == a['sha256']
with tarfile.open(fileobj=io.BytesIO(blob), mode='r:gz') as tar:
    archived = {}
    for name, record in a['members'].items():
        data = tar.extractfile(name).read()
        assert sha(data) == record['sha256'] and len(data) == record['bytes']
        archived[name] = data

def original(variant, name):
    choices = [key for key in archived if '/' + variant + '/' in key
               and key.endswith('/candidate-v1/' + name)]
    assert len(choices) == 1, (variant, name, choices)
    return choices[0], archived[choices[0]]


def handler_imports(data):
    text = data.decode()
    for before, after in [('../../../src/ecs/world.bend', 'world.bend'),
                          ('../../../src/ecs/system.bend', 'system.bend'),
                          ('../../public-machines/machine.bend', 'machine.bend')]:
        text = text.replace('import ' + before + ' as ', 'import ' + after + ' as ')
    return text.encode()


def fixture_imports(data):
    text = data.decode()
    for before, after in [('../../public-machines/machine.bend', '../../../src/ecs/machine.bend'),
                          ('../../public-machines/stream.bend', '../../../src/ecs/machine-stream.bend'),
                          ('handlers-tracked.bend', '../../../src/ecs/machine-handlers.bend'),
                          ('event-stream.bend', '../../../src/ecs/internal/machine-handler-events.bend')]:
        text = text.replace('import ' + before + ' as ', 'import ' + after + ' as ')
    return text.encode()

out = H / 'development' / ('handler-helper-mutant-rebase-' + str(time.time_ns()))
out.mkdir()
record = {'status': 'SOURCE_ONLY_UNEXECUTED_TWO_HELPER_MUTANT_REBASE',
          'normalPlan': str(normal / 'plan.json'), 'normalPlanSHA256': sha((normal / 'plan.json').read_bytes()),
          'normalReceipt': str(normal / 'receipt.json'), 'normalReceiptSHA256': sha((normal / 'receipt.json').read_bytes()),
          'selectedHistoricalManifest': str(oldManifestPath), 'selectedHistoricalManifestSHA256': sha(oldManifestPath.read_bytes()),
          'historicalSourceArchive': str(oldManifestPath.parent / a['archive']),
          'historicalSourceArchiveSHA256': a['sha256'], 'baselineOracle': str(H / 'full-expected.json'), 'baselineOracleSHA256': sha((H / 'full-expected.json').read_bytes()), 'baselineOracleQualifiedPlan': str(H / 'development/adoption-full-js-1791418106944182739/plan.json'), 'baselineOracleQualifiedPlanSHA256': sha((H / 'development/adoption-full-js-1791418106944182739/plan.json').read_bytes()), 'variants': {}}
assert receipt['probeCommandsExecuted'] == 0 and len(receipt['commands']) == 7
assert all(sha((normal / name).read_bytes()) == digest for name, digest in receipt['logs'].items())
baseHandler = baseline / 'src/ecs/machine-handlers.bend'
assert baseHandler.read_bytes() == handler_imports((H / 'handlers-tracked.bend').read_bytes())
baseMarker = baseline / 'experiments/public-machine-handlers/candidate-v1/full-marker.bend'
assert baseMarker.read_bytes() == fixture_imports((H / 'full-marker.bend').read_bytes())
for variant in ['lost-retry', 'premature-publication', 'whole-marker-rollback']:
    stage = out / variant
    shutil.copytree(baseline, stage)
    changes = {}
    key, oldHandler = original(variant, 'handlers-tracked.bend')
    target = stage / 'src/ecs/machine-handlers.bend'
    data = handler_imports(oldHandler)
    target.write_bytes(data)
    if variant != 'whole-marker-rollback':
        changes['src/ecs/machine-handlers.bend'] = {'baselineSHA256': sha(baseHandler.read_bytes()),
                  'historicalMember': key, 'historicalSHA256': sha(oldHandler),
                  'relocatedSHA256': sha(data), 'scope': 'Same retained one-line controlled defect; import paths only rebased'}
    else:
        assert data == baseHandler.read_bytes()
        for name in ['full-marker.bend', 'mutant-whole-marker-snapshot.bend']:
            key, data = original(variant, name)
            relocated = fixture_imports(data)
            destination = stage / 'experiments/public-machine-handlers/candidate-v1' / name
            before = destination.read_bytes() if destination.exists() else None
            destination.write_bytes(relocated)
            changes[str(destination.relative_to(stage))] = {'baselineSHA256': sha(before) if before else None,
                       'historicalMember': key, 'historicalSHA256': sha(data),
                       'relocatedSHA256': sha(relocated), 'scope': 'Retained finite full inverse and marker fault; imports only rebased, actual Local/registry owners preserved'}
    normalExpected = H / 'full-expected.json'
    qualifiedJS = H / 'development/adoption-full-js-1791418106944182739'
    qualifiedPlan = json.loads((qualifiedJS / 'plan.json').read_text())
    assert sha(normalExpected.read_bytes()) == qualifiedPlan['inventory']['experiments/public-machine-handlers/candidate-v1/full-expected.json']
    shutil.copyfile(normalExpected, stage / 'experiments/public-machine-handlers/candidate-v1/full-expected.json')
    expected = H / ('full-mutant-' + variant + '-expected.json')
    assert sha(expected.read_bytes()) == oldManifest['source'][expected.name]
    oracle = stage / 'experiments/public-machine-handlers/candidate-v1' / expected.name
    shutil.copyfile(expected, oracle)
    consumer = H / 'full-mutant-complete-consumer.mjs'
    assert sha(consumer.read_bytes()) == oldManifest['source'][consumer.name]
    shutil.copyfile(consumer, oracle.parent / consumer.name)
    record['variants'][variant] = {'stage': str(stage), 'changes': changes,
                                 'independentOracle': str(expected), 'independentOracleSHA256': sha(expected.read_bytes()),
                                 'completeConsumer': str(consumer), 'completeConsumerSHA256': sha(consumer.read_bytes()),
                                 'inventory': {str(p.relative_to(stage)): sha(p.read_bytes())
                                               for p in stage.rglob('*') if p.is_file()}}
record['scope'] = 'No source checks/emissions/runtime/proof or mutant kills yet. Same actual defects/full96+12 independent models; two-helper staged baseline modules/core unchanged except explicit controlled defects. Native reuse successful A/B then prematureB exit/transition/enter0/enter1 roots; do not repeat combined timed-out roots. No policy/law/cap changes.'
(out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
print(out / 'manifest.json')
print(sha((out / 'manifest.json').read_bytes()))
