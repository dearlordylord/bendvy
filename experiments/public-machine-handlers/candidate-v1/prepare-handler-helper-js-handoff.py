"""Archive actual finite relocated handler JS results without backend replay."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
ROOT = H.parents[2]
OUT = H / 'delivery-handler-helper-js-v1'
OUT.mkdir(exist_ok=True)
sha = lambda data: hashlib.sha256(data).hexdigest()
run = H / 'development/handler-helper-full-js-1791425801485958497'
receipt = json.loads((run / 'receipt.json').read_text())
assert receipt['status'] == 'STAGED_HANDLER_HELPERS_FULL96_AND12_PLUS_FOREIGN_JS_PASS'
assert receipt['probeCommandsExecuted'] == 45 and len(receipt['commands']) == 4
selected = {str(p.relative_to(run)): p.read_bytes() for p in run.rglob('*')
            if p.is_file() and p.name != 'private-environment.json'}
for name in ['delivery-manifest.json', 'reference-v3.mjs',
             'portable-reference-v1/manifest.json', 'portable-reference-v1/REPORT.md',
             'portable-reference-v1/objects.tar.gz']:
    selected['historical-selected-reference/' + name] = (ROOT / 'experiments/public-machine-handlers' / name).read_bytes()
buffer = io.BytesIO()
members = {}
with tarfile.open(fileobj=buffer, mode='w') as tar:
    for name, data in sorted(selected.items()):
        info = tarfile.TarInfo(name)
        info.size, info.mode, info.mtime = len(data), 0o644, 0
        tar.addfile(info, io.BytesIO(data))
        members[name] = {'sha256': sha(data), 'bytes': len(data)}
blob = gzip.compress(buffer.getvalue(), mtime=0)
(OUT / 'full-js.tar.gz').write_bytes(blob)
report = """# #49 staged package helpers: fresh full JS trace

Two proposed generic helper modules and the sole provider import migration on byte-pinned current root core executed on fresh generated JS: all96 complete physical checkpoints plus12 requirement refusals and both schemas'7 foreign-world rows exactly matched unchanged independent oracles. Four subjects emit30/Node5 twice and45 ordinary guards passed with empty stderr. Prior developmental seven-source zero-probe capsule joins this stage without source replay. Refusal instantiations retain finite observable metadata, not erased predicate/owner type identity.

Selected reference-v3 manifest/source and successful historical TS capsule remain pinned and archived; TS was not rerun. Full Bend oracle/consumer bytes join the prior qualified closure before copying. Actual tracked Sys cursors, affine gameplay/commands/Local owners and old-handler commit/publication boundaries retain complete observed traces. Internal raw event IDs remain trusted integration, not general public event ownership policy. No stream/later-key/captured-owner changes.

Root alone adopts production modules. These two helper modules remain staged; fresh Native normal/foreign and three changed-closure mutation variants plus root regression remain required. This finite trace is not mathematical proof, performance qualification or completeIssue49 closure. Archives exclude private environments and installed dependencies; historical path pins are provenance, not offline replay promises.
"""
(OUT / 'REPORT.md').write_text(report)
sourceManifest = H / 'delivery-handler-helper-source-v1/manifest.json'
names = ['run-handler-helper-full-js.py', 'prepare-handler-helper-js-handoff.py',
         'verify-handler-helper-js-handoff.py']
manifest = {'status': 'FINITE_TWO_HELPER_STAGED_FULL_JS_TRACE',
            'completeIssue49': False, 'proofCredit': False, 'productionAdopted': False,
            'nativeQualified': False, 'performanceQualified': False,
            'source': {name: sha((H / name).read_bytes()) for name in names},
            'sourceCapsuleManifestSHA256': sha(sourceManifest.read_bytes()),
            'reportSHA256': sha((OUT / 'REPORT.md').read_bytes()),
            'archive': {'name': 'full-js.tar.gz', 'sha256': sha(blob),
                        'historicalDirectory': str(run), 'members': members}}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(sha((OUT / 'manifest.json').read_bytes()))
