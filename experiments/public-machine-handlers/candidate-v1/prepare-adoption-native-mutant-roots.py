"""Freeze retained successful Native partition sources on current mutants; no children."""
import hashlib
import io
import json
import shutil
import tarfile
import time
from pathlib import Path
H = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
rebase = H / 'development/adoption-mutant-rebase-1791420043965302876/manifest.json'
assert sha(rebase.read_bytes()) == '8a13cdf4b9bf2356274e64cbd718170fb10534c942b92aa82c40ab7e43fefe4e'
r = json.loads(rebase.read_text())
mp = H / 'delivery-native-mutants-v1/manifest.json'
m = json.loads(mp.read_text())
archives = {}
for key, item in m['archives'].items():
    blob = (mp.parent / item['archive']).read_bytes()
    assert sha(blob) == item['sha256']
    with tarfile.open(fileobj=io.BytesIO(blob), mode='r:gz') as t:
        data = {}
        for name, record in item['members'].items():
            b = t.extractfile(name).read()
            assert sha(b) == record['sha256'] and len(b) == record['bytes']
            data[name] = b
        archives[key] = data
specs = [
    ('whole-marker-rollback', 'A', 'first-whole-a', '/whole-marker-rollback/A/', 'native-a.bend', ['exit0','exit1','transition0','transition1','enter0','enter1']),
    ('whole-marker-rollback', 'B', 'remaining-five-failed', '/whole-marker-rollback/B/', 'native-b.bend', ['exit0','exit1','transition0','transition1','enter0','enter1']),
    ('lost-retry', 'A', 'remaining-five-failed', '/lost-retry/A/', 'native-a.bend', ['exit0','exit1','transition0','transition1','enter0','enter1']),
    ('lost-retry', 'B', 'remaining-five-failed', '/lost-retry/B/', 'native-b.bend', ['exit0','exit1','transition0','transition1','enter0','enter1']),
    ('premature-publication', 'A', 'remaining-five-failed', '/premature-publication/A/', 'native-a.bend', ['exit0','exit1','transition0','transition1','enter0','enter1']),
    ('premature-publication', 'B-exit', 'phase-exit-emission', '/exit/', 'native-phase.bend', ['exit0','exit1']),
    ('premature-publication', 'B-transition', 'phase-native-failed', '/transition/', 'native-phase.bend', ['transition0','transition1']),
    ('premature-publication', 'B-enter0', 'enter-native-final', '/0/', 'native-enter-single.bend', ['enter0']),
    ('premature-publication', 'B-enter1', 'enter-native-final', '/1/', 'native-enter-single.bend', ['enter1']),
]
out = H / 'development' / ('adoption-native-mutant-roots-' + str(time.time_ns()))
out.mkdir()
record = {'status':'SOURCE_ONLY_UNEXECUTED_PARTITIONS', 'rebase':str(rebase), 'rebaseSHA256':sha(rebase.read_bytes()), 'historicalManifest':str(mp), 'historicalManifestSHA256':sha(mp.read_bytes()), 'generatorSHA256':sha(Path(__file__).read_bytes()), 'roots':{}}
for variant, label, archive, segment, filename, cases in specs:
    matches = [n for n in archives[archive] if segment in n and n.endswith('/' + filename)]
    assert len(matches) == 1, matches
    member = matches[0]; wrapper = archives[archive][member]
    base = Path(r['variants'][variant]['stage'])
    assert {str(p.relative_to(base)):sha(p.read_bytes()) for p in base.rglob('*') if p.is_file()} == r['variants'][variant]['inventory']
    stage = out / (variant + '-' + label); shutil.copytree(base, stage)
    fixture = stage / 'experiments/public-machine-handlers/candidate-v1'
    (fixture / filename).write_bytes(wrapper)
    schema = label[0]; names = ['schema' + schema + '_' + c + suffix for c in cases for suffix in ['', '_missing']]
    expected = json.loads((fixture / ('full-mutant-' + variant + '-expected.json')).read_text())['bend']
    text = ''.join(n + '|[' + ', '.join(expected[n]) + ']\n' for n in names)
    (stage / 'expected.stdout').write_text(text)
    record['roots'][variant + '-' + label] = {'stage':str(stage), 'entry':str(fixture / filename), 'historicalArchive':archive, 'historicalMember':member, 'wrapperSHA256':sha(wrapper), 'names':names, 'positiveCheckpoints':len(cases)*8, 'refusalCases':len(cases), 'expectedSHA256':sha(text.encode()), 'inventory':{str(p.relative_to(stage)):sha(p.read_bytes()) for p in stage.rglob('*') if p.is_file()}}
record['scope'] = 'Same nine successful historical partition roots byte-exact on current relocated mutant closures. Unchanged independent full96+12 models subsetted in original order. No checks/C emission/compilation/runtime/kill/proof/adoption. Never execute historical combined premature B or combined enter timeout roots.'
(out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
print(out / 'manifest.json'); print(sha((out / 'manifest.json').read_bytes()))
