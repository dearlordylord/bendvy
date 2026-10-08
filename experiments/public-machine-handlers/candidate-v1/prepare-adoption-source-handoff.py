"""Archive finite production-proposal source controls; no child tools or runtime qualification."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-adoption-source-v1'
OUT.mkdir(exist_ok=True)
sha = lambda data: hashlib.sha256(data).hexdigest()
run = H / 'development/adoption-source-controls-1791417894671205302'
receipt = json.loads((run / 'receipt.json').read_text())
assert receipt['status'] == 'PROPOSED_HANDLER_EXTRACTION_SEVEN_SOURCE_CONTROLS_PASS_NO_RUNTIME'
assert receipt['probeCommandsExecuted'] == 75 and len(receipt['commands']) == 7
buffer = io.BytesIO()
members = {}
with tarfile.open(fileobj=buffer, mode='w') as tar:
    selected = {str(p.relative_to(run)): p.read_bytes() for p in run.rglob('*')
                if p.is_file() and p.name != 'private-environment.json'
                and ('stage' not in p.relative_to(run).parts or p.suffix == '.bend')}
    old = H / 'development/adoption-source-controls-1791417761354677918'
    for name in ['plan.json', 'wrapper-original.py']:
        selected['unexecuted-original/' + name] = (old / name).read_bytes()
    for name, data in sorted(selected.items()):
        info = tarfile.TarInfo(name)
        info.size, info.mode, info.mtime = len(data), 0o644, 0
        tar.addfile(info, io.BytesIO(data))
        members[name] = {'sha256': sha(data), 'bytes': len(data)}
blob = gzip.compress(buffer.getvalue(), mtime=0)
(OUT / 'source-controls.tar.gz').write_bytes(blob)
report = '''# #49 prospective core extraction: finite source controls

Seven actual source5 subjects with75 ordinary owned guards passed on root's four uncommitted extracted modules and byte-pinned current core dependencies: normal two-schema full driver, matched authority sibling, real foreign control, and four exact affine/schema/read/undeclared-access diagnostic refusals. Three positive checker stdout streams are exactly58 bytes and stderr empty. This is --check-only typing, including an IO driver, not --verdict safe or mathematical proof. Four negative exit1 stderr hashes match their retained intended diagnostics exactly; exit codes alone grant no credit.

The stage binds every copied current root dependency and the three generic machine modules plus INTERNAL Data handler event helper. Full fixture imports change module identity only. Retained fixture public-machines/world helper also rebinds M to the extracted machine so Slot identities do not diverge; conditions remains unchanged. No generic clone, captured-owner or #53 public event policy is introduced. Raw internal event reader IDs require trusted consumer authority checks and retain fixture capacity/skip assumptions. Root alone writes production src; fixture/candidate staging does not adopt that code.

The first unexecuted plan/wrapper are retained. Initial copy-only preparation failed on a missing retained world helper before any checker/probe; that dependency was then explicitly staged and rebound. Separate old/new original-checker portability failures and prior semantic evidence retain their own capsules. Source patches have path headers without a/b prefixes: apply with git apply -p0, rather than default stripping. All generated source bodies remain original declarations apart from reviewed import paths.

This capsule retains source/stage/plans/raw/guards without private environments, binaries or installed dependency trees. No JS/Native runtime, three changed-closure semantic mutations, paired regression, mathematical proof, production adoption or completeIssue49 claim. Historical runtime capsules qualify their original imports/core only. The next changed-closure JS/full96+12/foreign plan remains separate and unexecuted at this handoff.
'''
(OUT / 'REPORT.md').write_text(report)
names = ['run-adoption-source-controls.py', 'prepare-adoption-source-handoff.py',
         'verify-adoption-source-handoff.py']
manifest = {'status': 'FINITE_PROPOSED_HANDLER_EXTRACTION_SOURCE_CONTROLS',
            'completeIssue49': False, 'proofCredit': False, 'runtimeQualified': False,
            'productionAdopted': False,
            'source': {name: sha((H / name).read_bytes()) for name in names},
            'reportSHA256': sha((OUT / 'REPORT.md').read_bytes()),
            'archive': {'name': 'source-controls.tar.gz', 'sha256': sha(blob),
                        'historicalDirectory': str(run), 'members': members}}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(sha((OUT / 'manifest.json').read_bytes()))
