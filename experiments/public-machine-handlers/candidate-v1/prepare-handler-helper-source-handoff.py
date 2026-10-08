"""Archive finite production-proposal source controls; no child tools or runtime qualification."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-handler-helper-source-v1'
OUT.mkdir(exist_ok=True)
sha = lambda data: hashlib.sha256(data).hexdigest()
run = H / 'development/handler-helper-source-controls-1791425283404374668'
receipt = json.loads((run / 'receipt.json').read_text())
assert receipt['status'] == 'DEVELOPMENT_HANDLER_HELPERS_SEVEN_SOURCE_DIAGNOSTICS_PASS_NO_FINAL_RESOLVER_OR_RUNTIME'
assert receipt['probeCommandsExecuted'] == 0 and len(receipt['commands']) == 7
buffer = io.BytesIO()
members = {}
with tarfile.open(fileobj=buffer, mode='w') as tar:
    selected = {str(p.relative_to(run)): p.read_bytes() for p in run.rglob('*')
                if p.is_file() and p.name != 'private-environment.json'
                and ('stage' not in p.relative_to(run).parts or p.suffix == '.bend')}
    for dirname in ['handler-helper-source-controls-1791425139441435950', 'handler-helper-source-controls-1791425174109469234']:
        old = H / 'development' / dirname
        for name in ['plan.json', 'unexecuted-wrapper.py']:
            selected['unexecuted/' + dirname + '/' + name] = (old / name).read_bytes()
    selected['lock-refusal-observation.json'] = (H / 'development/handler-helper-source-lock-refusal-observation.json').read_bytes()
    for name, data in sorted(selected.items()):
        info = tarfile.TarInfo(name)
        info.size, info.mode, info.mtime = len(data), 0o644, 0
        tar.addfile(info, io.BytesIO(data))
        members[name] = {'sha256': sha(data), 'bytes': len(data)}
blob = gzip.compress(buffer.getvalue(), mtime=0)
(OUT / 'source-controls.tar.gz').write_bytes(blob)
report = """# #49 two-helper package seam: development source controls

Seven source5 checks passed on the immutable stage with two proposed generic machine-world/machine-conditions modules and the sole full-provider helper import migration. Three positive outputs match the retained exact58-byte typing output with empty stderr; four refusals match exact intended diagnostics. No discovery or verification probes ran. This is developmental --check-only typing/refusal evidence, not mathematical proof, final resolver qualification, runtime evidence, source adoption or issue completion.

Current root dependencies are pinned read-only. Helpers preserve original generic bodies with reviewed import paths; trusted caller capability/namespace validation remains outside pure condition metadata. No captured-owner, stream, later-key or general event policy changes. Root alone writes production src.

Both unexecuted earlier plans/wrappers and a prior zero-child lock-refusal transcribed observation are retained. The observation is not byte-exact original stderr. Archive includes immutable source, commands and actual raw logs, excluding private environment and installed dependencies. Fresh full normal/foreign JS and Native plus all three reached mutation variants on this helper closure remain required; previous runtime receipts do not transfer.
"""
(OUT / 'REPORT.md').write_text(report)
names = ['run-handler-helper-source-controls.py', 'prepare-handler-helper-source-handoff.py',
         'verify-handler-helper-source-handoff.py']
manifest = {'status': 'DEVELOPMENT_HANDLER_HELPER_SOURCE_CONTROLS',
            'completeIssue49': False, 'proofCredit': False, 'runtimeQualified': False,
            'productionAdopted': False,
            'source': {name: sha((H / name).read_bytes()) for name in names},
            'reportSHA256': sha((OUT / 'REPORT.md').read_bytes()),
            'archive': {'name': 'source-controls.tar.gz', 'sha256': sha(blob),
                        'historicalDirectory': str(run), 'members': members}}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(sha((OUT / 'manifest.json').read_bytes()))
