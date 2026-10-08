"""Archive finite prospective-core normal/foreign Native evidence without tools."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-adoption-native-v1'
OUT.mkdir(exist_ok=True)
sha = lambda data: hashlib.sha256(data).hexdigest()
runs = {'normal': 'adoption-normal-native-1791418734208022501',
        'foreign': 'adoption-foreign-native-1791419366637172002'}
archives = {}
for label, name in runs.items():
    root = H / 'development' / name
    receipt = json.loads((root / 'receipt.json').read_text())
    assert 'PASS' in receipt['status'] and receipt['probeCommandsExecuted'] == (65 if label == 'normal' else 35)
    selected = {str(p.relative_to(root)): p.read_bytes() for p in root.rglob('*')
                if p.is_file() and p.name != 'private-environment.json'
                and p.suffix in ['.json', '.bend', '.mjs', '.py', '.c', '.stdout', '.stderr']}
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
report = '''# #49 prospective core extraction: actual Native normal and foreign traces

Fresh normal Native A/B partitions executed all48 complete positive checkpoints and6 requirement refusal cases per schema, then concatenated exact unchanged96+12 oracle bytes. Six subjects emit30/Clang120/run5 per schema and65 ordinary owned guards passed; no old C or source/JS/TS replay. Refusal cases each retain4 full observation lines; metadata equivalence does not claim original erased owner/predicate type identity.

Separate actual Native foreign control emitted/compiled/ran both nominal schemas'7 complete rows each through a thin IO-only append/print seam. Three subjects emit30/Clang120/run5 and35 guards passed; the original private environment was SHA-validated/pinned and copied exactly. The real callback/Local owners, registry cursor, pending machine and gameplay world remain preserved at actual foreign registration refusal. All emission/compile/runtime stderr is empty. Normal full96+12 union and all14 foreign rows match unchanged independent oracles.

Both cohorts join root's actual four uncommitted extracted modules and current dependency closure already source7/75 and full JS4/45 qualified. Source and JS capsule manifests remain pinned; helpers retain their internal/trusted boundary, not a general #53 event ownership policy. The allocated Clang19 snapshot/env are reused unchanged, CPU8/runtime thread1/GPUoff; no dependency or performance criterion changes. Root alone owns src and has not delivered these draft modules.

Archives retain full source/stages/tool-config/raw/probe receipts/generated C and all observations. Private environment maps, binaries and installed dependencies are excluded; binary hashes are historical receipts, not portable offline replay promises. Three actual semantic mutants on this relocated source closure and paired regression remain unmet. Historical mutation capsules qualify original imports/core only. This is finite Native trace evidence, not mathematical proof, timings, production adoption or completeIssue49 closure.
'''
(OUT / 'REPORT.md').write_text(report)
names = ['run-adoption-normal-native.py', 'run-adoption-foreign-native.py',
         'full-foreign-native.bend', 'prepare-adoption-native-handoff.py',
         'verify-adoption-native-handoff.py']
manifest = {'status': 'FINITE_PROPOSED_HANDLER_EXTRACTION_NATIVE_NORMAL_AND_FOREIGN',
            'completeIssue49': False, 'proofCredit': False, 'productionAdopted': False,
            'mutationQualified': False, 'performanceQualified': False,
            'source': {name: sha((H / name).read_bytes()) for name in names},
            'sourceCapsuleManifestSHA256': sha((H / 'delivery-adoption-source-v1/manifest.json').read_bytes()),
            'jsCapsuleManifestSHA256': sha((H / 'delivery-adoption-js-v1/manifest.json').read_bytes()),
            'reportSHA256': sha((OUT / 'REPORT.md').read_bytes()), 'archives': archives}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(sha((OUT / 'manifest.json').read_bytes()))
