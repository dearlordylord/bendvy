"""Archive finite prospective-core normal/foreign Native evidence without tools."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-handler-helper-native-v1'
OUT.mkdir(exist_ok=True)
sha = lambda data: hashlib.sha256(data).hexdigest()
runs = {'normal': 'handler-helper-normal-native-1791426418232820419',
        'foreign': 'handler-helper-foreign-native-1791426963529956264',
        'operational-reconciliation': 'handler-helper-native-finalization-failure'}
archives = {}
for label, name in runs.items():
    root = H / 'development' / name
    if label == 'operational-reconciliation':
        classification = json.loads((root / 'reconciliation.json').read_text())
        assert classification['status'] == 'READ_ONLY_NATIVE_SUBJECTS_AND_EXPLICIT_DERIVED_UNION_RECONCILED'
    else:
        receipt = json.loads((root / 'receipt.json').read_text())
        assert 'PASS' in receipt['status'] and receipt['probeCommandsExecuted'] == (65 if label == 'normal' else 35)
    selected = {str(p.relative_to(root)): p.read_bytes() for p in root.rglob('*')
                if p.is_file() and p.name != 'private-environment.json'
                and p.suffix in ['.json', '.bend', '.mjs', '.py', '.c', '.stdout', '.stderr']}
    if label == 'operational-reconciliation':
        alias = H / 'development/handler-helper-native-metadata-alias-refusal'
        for filename in ['observation.json', 'wrapper.py']:
            selected['metadata-alias-refusal/' + filename] = (alias / filename).read_bytes()
    buffer = io.BytesIO()
    members = {}
    with tarfile.open(fileobj=buffer, mode='w') as tar:
        for path, data in sorted(selected.items()):
            info = tarfile.TarInfo(path)
            info.size, info.mode, info.mtime = len(data), 0o644, 0
            tar.addfile(info, io.BytesIO(data))
            members[path] = {'sha256': sha(data), 'bytes': len(data)}
    blob = gzip.compress(buffer.getvalue(), mtime=0)
    filename = label + '.tar.gz'
    (OUT / filename).write_bytes(blob)
    archives[label] = {'archive': filename, 'sha256': sha(blob),
                       'historicalDirectory': str(root), 'members': members}
report = """# #49 staged package helpers: Native normal and foreign traces

Fresh two-helper normal Native A/B partitions executed48 complete checkpoints and6 refusal cases each, concatenating the exact unchanged96+12 independent oracle. Six subjects emit30/Clang120/run5 per schema and65 owned guards completed successfully with empty stderr. The wrapper subsequently exited1: its final command-log membership guard rejected the derived concatenation .stdout beside actual raw logs. The original erroneous PASS receipt remains unchanged and is not terminal acceptance. A separately reviewed read-only reconciliation checked exact source/config/tool/environment/generated/probe hashes, every actual raw log, full per-schema observations and the only extra file's exact raw concatenation. Its separate classification links the original plan/receipt and transcribed actual terminal observation; the latter is not original stderr bytes. No backend was replayed.

Separate foreign Native3 subjects emit30/Clang120/run5 and35 guards passed both schemas'7 real foreign-control rows. Its plan explicitly requires the normal reconciliation, not the original receipt status alone. Environment copied byte-exact, private Clang snapshot reused, CPU8/thread1/GPUoff; no source/JS/TS baseline or old C replay. Refusal metadata equivalence is not original erased predicate/owner type identity.

These immutable staged two-helper modules join developmental source7/zero probes and fresh fullJS4/45. Root alone adopts production code; no stream/later-key/captured-owner/general event policy changes. Archives retain source/C/raw/guards and operational failure/reconciliation histories, exclude private environments/binaries/installed dependencies. Three mutation variants and root paired regression remain required. Finite trace evidence is not mathematical proof, timing qualification, adoption or issue closure.
"""
(OUT / 'REPORT.md').write_text(report)
names = ['run-handler-helper-normal-native.py', 'run-handler-helper-foreign-native.py',
         'full-foreign-native.bend', 'prepare-handler-helper-native-handoff.py',
         'verify-handler-helper-native-handoff.py', 'reconcile-handler-helper-native-finalization.py']
manifest = {'status': 'FINITE_STAGED_HANDLER_HELPERS_NATIVE_NORMAL_AND_FOREIGN',
            'completeIssue49': False, 'proofCredit': False, 'productionAdopted': False,
            'mutationQualified': False, 'performanceQualified': False,
            'source': {name: sha((H / name).read_bytes()) for name in names},
            'sourceCapsuleManifestSHA256': sha((H / 'delivery-handler-helper-source-v1/manifest.json').read_bytes()),
            'jsCapsuleManifestSHA256': sha((H / 'delivery-handler-helper-js-v1/manifest.json').read_bytes()),
            'reportSHA256': sha((OUT / 'REPORT.md').read_bytes()), 'archives': archives}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(sha((OUT / 'manifest.json').read_bytes()))
