"""Select immutable historical mutant evidence; no child execution."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-qualification-v1'
OUT.mkdir(exist_ok=True)


def sha(data):
    return hashlib.sha256(data).hexdigest()


runs = {'native-emission': 'mutant-native-diagnostic-1791412440412315995',
        'ordinary-controls': 'controls-qualified-1791412550172483507'}
archives = {}
for label, name in runs.items():
    root = H / 'development' / name
    buffer = io.BytesIO()
    members = {}
    with tarfile.open(fileobj=buffer, mode='w') as tar:
        for path in sorted(root.rglob('*')):
            if not path.is_file() or path.is_symlink():
                continue
            rel = path.relative_to(root)
            if 'stage' in rel.parts:
                if path.suffix != '.bend':
                    continue
            elif path.name == 'private-environment.json':
                continue
            elif path.suffix not in ['.json', '.stdout', '.stderr', '.mjs', '.c']:
                continue
            data = path.read_bytes()
            info = tarfile.TarInfo(str(rel))
            info.size, info.mode, info.mtime = len(data), 0o644, 0
            tar.addfile(info, io.BytesIO(data))
            members[str(rel)] = {'sha256': sha(data), 'bytes': len(data)}
    blob = gzip.compress(buffer.getvalue(), mtime=0)
    filename = label + '.tar.gz'
    (OUT / filename).write_bytes(blob)
    archives[label] = {'historicalDirectory': str(root.resolve()), 'archive': filename,
                       'sha256': sha(blob), 'members': members}

names = ['run-mutant-native-diagnostic.py', 'run-controls-qualified.py',
         'prepare-qualification-handoff.py', 'verify-qualification-handoff.py']
source = {name: sha((H / name).read_bytes()) for name in names}
report = '''# Registered handler ordinary resolver qualification

Fresh complete owned tool/library/config/discovery/environment/source/stage/generated/raw guards qualified nine source roots and four retained generated JS consumers. Five positive roots passed with empty stderr; four authority negatives matched exact original stderr bytes and empty stdout, with matched positive definitions. All four complete physical consumers retained the original full raw output hashes and independent foreign/three96+12 variant oracles/witnesses. Five fresh snapshot probes and135 boundary probes are preserved. No normal TS/JS/Native or JS emission was repeated. IO source checking is typing evidence, not safeproof or --verdict.

A separate fresh snapshot5 plus25 ordinary guards qualified one actual whole-marker-rollback schemaA source/C-emission diagnostic. Its same six applications preserve all48 positive checkpoints and6 actual finite refusals; C emission succeeded. No Clang or Native execution occurred. Native complete mutant coverage remains pending. Original combined-emission timeouts and v2-v5 source failures remain in earlier selected capsules.

Archives retain exact plans, receipts, frozen Bend source closures, generated C and raw/probe outputs without private environment maps, binaries or dependency trees. Paths/hashes remain historical rather than rebased replay promises. This adds resolver qualification to the existing closed finite foreign/authority/JS mutant controls, not mathematical proof, timing, production adoption or completeIssue49. Native refusal labels retain observable metadata equivalence rather than original erased owner/predicate type identity.
'''
(OUT / 'REPORT.md').write_text(report)
m = {'status': 'SELECTED_ORDINARY_CONTROLS_AND_NATIVE_EMISSION_QUALIFICATION',
     'completeIssue49': False, 'acceptanceQualified': False,
     'performanceQualified': False, 'proofCredit': False,
     'source': source, 'archives': archives,
     'reportSHA256': sha((OUT / 'REPORT.md').read_bytes())}
(OUT / 'manifest.json').write_text(json.dumps(m, indent=2) + '\n')
print(json.dumps({'manifestSHA256': sha((OUT / 'manifest.json').read_bytes()),
                  'compressedBytes': sum((OUT / a['archive']).stat().st_size for a in archives.values())}))
