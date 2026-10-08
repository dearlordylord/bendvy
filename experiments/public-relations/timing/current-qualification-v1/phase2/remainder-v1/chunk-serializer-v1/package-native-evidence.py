"""Archive retained Native qualification; no child processes or live acceptance."""
from pathlib import Path
import gzip, hashlib, io, json, tarfile
H = Path(__file__).resolve().parent
R = H.parents[6]
D = R / '.artifacts/relations-chunk-native-1791421638715628916'
O = H / 'native-evidence-v1'
O.mkdir(exist_ok=True)
sha = lambda b: hashlib.sha256(b).hexdigest()
files = {}
objects = {}
path_keys = {}
def add(key, path):
    assert path.name != 'private-environment.json'
    data = path.read_bytes()
    digest = sha(data)
    files[key] = digest
    objects[digest] = data
    path_keys[str(path)] = key
plan = json.loads((D / 'plan.json').read_text())
for path in sorted(D.rglob('*')):
    if path.is_file() and 'stage' not in path.relative_to(D).parts and path.name != 'private-environment.json' and path.suffix in ('.json', '.stdout', '.stderr', '.raw'):
        add('native/' + str(path.relative_to(D)), path)
for name, digest in plan['pins'].items():
    path = Path(name)
    assert sha(path.read_bytes()) == digest
    if path.name == 'private-environment.json':
        continue
    if path.is_relative_to(R):
        rel = path.relative_to(R)
        if '.artifacts' in rel.parts and path.suffix in ('.js', '.c'):
            continue
        if path.suffix in ('.json', '.stdout', '.stderr', '.raw', '.bend', '.mjs', '.py', '.md', '.gz'):
            add('bound/' + str(rel), path)
    elif '/.references/bevy-ts/packages/core/src/' in name or name.endswith('/.references/bend2/bend2/main.ts') or name.endswith('/.references/bend2/bend2/bend.ts'):
        add('external-reference/' + name.split('/.references/', 1)[1], path)
for command in plan['commands']:
    for field in ('oracle', 'forcedOracle'):
        if field in command:
            add('oracle/' + Path(command[field]).name, Path(command[field]))
add('oracle/remainder-manifest.json', H.parent / 'expected/manifest.json')
add('oracle/initial-manifest.json', H.parents[1] / 'expected/manifest.json')
for name in ('native-preparation.json', 'native-proposal.json'):
    add('authored/' + name, H / name)
for path in (H / 'review-history/native-e857').rglob('*'):
    if path.is_file():
        add('review-history/native-e857/' + str(path.relative_to(H / 'review-history/native-e857')), path)
with (O / 'objects.tar.gz').open('wb') as raw:
    with gzip.GzipFile(filename='', fileobj=raw, mode='wb', mtime=0) as zipped:
        with tarfile.open(fileobj=zipped, mode='w') as archive:
            for digest, data in sorted(objects.items()):
                info = tarfile.TarInfo(digest)
                info.size = len(data)
                info.mtime = 0
                info.mode = 0o644
                archive.addfile(info, io.BytesIO(data))
index = {'files': files, 'pathKeys': path_keys, 'objects': {s: len(b) for s, b in objects.items()}, 'archiveSHA256': sha((O / 'objects.tar.gz').read_bytes()), 'scope': 'Retained Native four full30 cases and two refusal controls only; no timing/population1024/full-family/proof acceptance.', 'excluded': 'Private environments, executable/tool/library bytes, generated JS/C/binaries, caches. Historical absolute paths are identifiers resolved through pathKeys to archive objects, never opened by verifier. C effect order is local hash-bound review; capsule cannot reconstruct generated C.'}
(O / 'index.json').write_text(json.dumps(index, indent=2) + '\n')
print(len(files), len(objects), (O / 'objects.tar.gz').stat().st_size)
