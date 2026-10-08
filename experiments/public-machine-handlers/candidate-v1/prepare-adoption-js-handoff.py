"""Archive actual finite relocated handler JS results without backend replay."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
ROOT = H.parents[2]
OUT = H / 'delivery-adoption-js-v1'
OUT.mkdir(exist_ok=True)
sha = lambda data: hashlib.sha256(data).hexdigest()
run = H / 'development/adoption-full-js-1791418106944182739'
receipt = json.loads((run / 'receipt.json').read_text())
assert receipt['status'] == 'PROPOSED_HANDLER_EXTRACTION_FULL96_AND12_PLUS_FOREIGN_JS_PASS'
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
report = '''# #49 prospective core extraction: actual complete JS trace

Root's four uncommitted extracted module bytes and current core dependency closure executed on actual generated JS: all96 complete physical checkpoints plus12 requirement refusals and both schemas'7 complete foreign-world control rows exactly matched unchanged independent oracles. Four subjects emit30/Node5/emit30/Node5 and45 ordinary owned guards passed; all stderr empty. Generated artifacts and complete raw output are retained. The preceding seven source5/75guard typing/negative capsule joins this exact source stage, without checker replay. Full driver refusal instantiations preserve finite observable metadata, not original erased predicate/owner type identity.

The selected reference-v3 source/manifest and successful historical TS capsule remain pinned and archived; TS was not rerun in this cohort. Full independent Bend oracle and consumer bytes remain unchanged. Actual Sys tracked cursors, affine gameplay/commands/Local owners and old-handler commit/publication boundaries remain observed under the two nominal schemas. INTERNAL Data event helper raw IDs remain a trusted integration detail, not a public #53 event ownership API.

Source patches require git apply -p0 because headers omit a/b prefixes. Root alone owns actual core edits. This finite JS trace does not qualify relocated Native, the three semantic mutant variants on the relocated closure, paired performance regression, mathematical proof, production adoption or completeIssue49 closure. Historical Native/mutant capsules qualify their original source closures only. Archives exclude private environment maps, binaries and installed dependencies; their historical paths/pins are provenance, not an offline replay promise.
'''
(OUT / 'REPORT.md').write_text(report)
sourceManifest = H / 'delivery-adoption-source-v1/manifest.json'
names = ['run-adoption-full-js.py', 'prepare-adoption-js-handoff.py',
         'verify-adoption-js-handoff.py']
manifest = {'status': 'FINITE_PROPOSED_HANDLER_EXTRACTION_FULL_JS_TRACE',
            'completeIssue49': False, 'proofCredit': False, 'productionAdopted': False,
            'nativeQualified': False, 'performanceQualified': False,
            'source': {name: sha((H / name).read_bytes()) for name in names},
            'sourceCapsuleManifestSHA256': sha(sourceManifest.read_bytes()),
            'reportSHA256': sha((OUT / 'REPORT.md').read_bytes()),
            'archive': {'name': 'full-js.tar.gz', 'sha256': sha(blob),
                        'historicalDirectory': str(run), 'members': members}}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(sha((OUT / 'manifest.json').read_bytes()))
