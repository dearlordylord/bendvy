#!/usr/bin/env python3
"""Pinned eight-world constructor/property-expression diagnosis, not heap bytes."""
import argparse, collections, hashlib, importlib.util, json, os, pathlib, sys

ROOT = pathlib.Path('/workspace/formal-proofs/bendvy')
HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'experiments/s-prep/fivehour-connected-gates'))
from supervisor import execute
parser = argparse.ArgumentParser()
parser.add_argument('--schema', choices=['Motion', 'Health'], required=True)
parser.add_argument('--output', type=pathlib.Path, required=True)
args = parser.parse_args()
args.output.mkdir(exist_ok=False)
os.sched_setaffinity(0, {7})
sha = lambda p: hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
catalog = json.loads((HERE / 'count-inputs.json').read_text())[args.schema]
receipt = {'status': 'INCOMPLETE', 'cpu': 7, 'schema': args.schema, 'inputs': catalog,
           'scope': 'Executed construction/property initialization expressions only; not physical heap bytes, elapsed acceptance or adoption',
           'commands': [], 'cases': []}
def save():
    (args.output / 'evidence.json').write_text(json.dumps(receipt, indent=2) + '\n')
def run(argv, limit=5):
    code, output = execute(list(map(str, argv)), limit)
    receipt['commands'].append({'argv': list(map(str, argv)), 'limitSeconds': limit, 'exit': code})
    save()
    assert code == 0, output[-2000:]
    return output
spec = importlib.util.spec_from_file_location('validator', ROOT / 'experiments/s-integrate/measurement-bend-run.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)
try:
    for role in ['baseline', 'candidate']:
        facts = catalog[role]
        overlay = pathlib.Path(facts['overlay'])
        pins = {str(p.relative_to(overlay)): sha(p) for p in overlay.rglob('*.bend')}
        manifest = json.loads((overlay / 'overlay.json').read_text())
        cache = json.loads((overlay / 'cache-specialization.json').read_text())
        assert len(pins) == 29 and pins == facts['source29Pins'] == manifest['sources'] == cache['runtimeClosure'] == cache['specializedClosure']
        assert manifest['cacheSpecialization'] == cache
        assert cache['runtimeClosureSHA256'] == hashlib.sha256(json.dumps(pins, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
        source = pathlib.Path(facts['js'])
        assert sha(source) == facts['jsSHA256']
        profile = args.output / role
        runner = ROOT / 'experiments/s-prep/js-profile/run.py' if args.schema == 'Motion' else HERE / 'health-profile.py'
        run([sys.executable, runner, '--generated-js', source, '--output', profile, '--cpu', '7', '--no-gc'], 25)
        assert json.loads((profile / 'evidence.json').read_text())['status'] == 'PROFILE_AND_NINE_FULL_WORLDS_PASS'
        original = args.output / (role + '-original-counted.js')
        counted = args.output / (role + '-counted.js')
        root_instrument = ROOT / 'experiments/s-prep/js-allocation-map/instrument.cjs'
        run(['node', '--expose-internals', root_instrument, profile / 'bend.js', original])
        run(['node', '--expose-internals', HERE / 'instrument-fields.cjs', profile / 'bend.js', counted])
        assert original.read_bytes() == counted.read_bytes(), 'Metadata-only instrument extension changed runtime bytes'
        text = run(['node', counted])
        (args.output / (role + '-counted.txt')).write_text(text)
        ts = json.loads((profile / 'TS.observed.txt').read_text())
        worlds = [line for line in text.splitlines() if line.startswith('{')]
        assert len(worlds) == 9
        for line, world in zip(worlds, [ts['warmup'], *ts['samples']]):
            validator.validate(line, args.schema, False, 256, world)
            assert validator.normalized(json.loads(line), args.schema) == world['final']
        reports = [line for line in text.splitlines() if line.startswith('ALLOCATION-COUNTS:')]
        assert len(reports) == 1
        counts = json.loads(reports[0].split(':', 1)[1])
        sites = json.loads(pathlib.Path(str(counted) + '.sites.json').read_text())['sites']
        assert len(counts) == len(sites)
        markers = [(site, n) for site, n in zip(sites, counts) if site['function'] == '__profile_mark' and site['kind'].startswith('object:')]
        assert len(markers) == 1 and markers[0][1] == 1 and markers[0][0]['propertyCount'] == 3
        kinds = collections.Counter()
        properties = 0
        for site, n in zip(sites, counts):
            kinds[site['kind'].split('s-integrate/')[-1]] += n
            properties += n * site['propertyCount']
        assert pins == {str(p.relative_to(overlay)): sha(p) for p in overlay.rglob('*.bend')}
        receipt['cases'].append({'role': role, 'ordinaryConstructors': sum(counts) - 1,
                                 'ordinaryObjectProperties': properties - 3, 'kinds': dict(kinds),
                                 'inputSHA256': sha(source), 'counterSHA256': sha(counted),
                                 'sitesSHA256': sha(str(counted) + '.sites.json'),
                                 'profileRunnerSHA256': sha(runner), 'rootInstrumentSHA256': sha(root_instrument),
                                 'instrumentFieldsSHA256': sha(HERE / 'instrument-fields.cjs'),
                                 'counterRuntimeByteIdenticalToOriginalInstrument': True,
                                 'quietAndCountedNineFullFieldsPass': True})
        save()
    baseline, candidate = receipt['cases']
    keys = set(baseline['kinds']) | set(candidate['kinds'])
    receipt.update(status='PINNED_NINE_FIELDS_CONSTRUCTION_AND_PROPERTY_COUNTS_PASS',
                   constructorDelta=candidate['ordinaryConstructors'] - baseline['ordinaryConstructors'],
                   objectPropertyDelta=candidate['ordinaryObjectProperties'] - baseline['ordinaryObjectProperties'],
                   kindDelta={k: candidate['kinds'].get(k, 0) - baseline['kinds'].get(k, 0) for k in keys if candidate['kinds'].get(k, 0) != baseline['kinds'].get(k, 0)})
except Exception as error:
    receipt.update(status='FAILED', error=repr(error))
finally:
    save()
print(json.dumps({k: receipt.get(k) for k in ['status', 'constructorDelta', 'objectPropertyDelta', 'error']}))
sys.exit(0 if receipt['status'] == 'PINNED_NINE_FIELDS_CONSTRUCTION_AND_PROPERTY_COUNTS_PASS' else 1)
