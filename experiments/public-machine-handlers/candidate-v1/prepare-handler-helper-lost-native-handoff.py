"""Archive retained split lost-retry Native evidence; no children or replay."""
import argparse
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
p = argparse.ArgumentParser()
p.add_argument('--reconciliation', required=True)
args = p.parse_args()
rr = Path(args.reconciliation).resolve()
r = json.loads(rr.read_text())
assert r['status'] == 'READ_ONLY_CURRENT_HELPER_LOST_NATIVE_FULL96_AND12_RECONCILED'
assert all(not r[k] for k in ['completeIssue49', 'proofCredit', 'productionAdopted', 'performanceQualified'])
directories = {
    'timeout': H / 'development/handler-helper-mutants-native-lost-retry-1791427610353568836',
    'diagnostic': H / 'development/handler-helper-lost-exit-a-diagnostic-1791428738577520584',
    'exit': H / 'development/handler-helper-lost-exit-a-runtime-1791429499901621710',
    'A': H / 'development/handler-helper-lost-remaining-A-1791429784371141481',
    'B': H / 'development/handler-helper-lost-remaining-B-1791429786254727649',
    'unexecuted-diagnostic': H / 'development/handler-helper-lost-exit-a-diagnostic-1791428640788903971',
    'phase-mapping': H / 'development/handler-helper-lost-phase-roots-1791428313895176759',
    'remaining-mapping': H / 'development/handler-helper-lost-remaining-phase-roots-1791429613529900433',
    'queue': H / 'development/c4-blocking-queue',
    'reconciliation': rr.parent,
}
selected = {}
for label, directory in directories.items():
    for f in directory.rglob('*'):
        if f.is_file() and f.name != 'private-environment.json' and f.suffix in [
                '.json', '.py', '.bend', '.mjs', '.c', '.stdout', '.stderr']:
            selected[label + '/' + str(f.relative_to(directory))] = f.read_bytes()
obs = H / 'development/handler-helper-lost-exit-diagnostic-lock-refusal.json'
selected['lock-refusal-observation.json'] = obs.read_bytes()
for path, digest in r['inputs'].items():
    assert sha(Path(path).read_bytes()) == digest, path
assert sha(selected['reconciliation/full96-and12.stdout']) == r['unionSHA256']
OUT = H / 'delivery-handler-helper-native-mutant-lost-retry-v1'
OUT.mkdir(exist_ok=True)
members = {}
buffer = io.BytesIO()
with tarfile.open(fileobj=buffer, mode='w') as t:
    for name, data in sorted(selected.items()):
        info = tarfile.TarInfo(name)
        info.size = len(data)
        info.mode = 0o644
        info.mtime = 0
        t.addfile(info, io.BytesIO(data))
        members[name] = {'sha256': sha(data), 'bytes': len(data)}
blob = gzip.compress(buffer.getvalue(), mtime=0)
(OUT / 'native.tar.gz').write_bytes(blob)
report = '''# #49 staged helpers: lost-retry Native mutation

Fresh actual lost-retry runs retain the original full-A emission timeout as inconclusive. Narrowing changes only the driver partition: first exit-A16+2, remaining transition/enter-A32+4, then exit/transition/enter-B48+6. Source5/emit30/Clang120/run5 caps are unchanged; first emitted C is reused for its two-subject compile/runtime stage. Source checks provide typing, not mathematical validity.

The diagnostic passed2 subjects/25 ordinary probes; first runtime passed2/25, remaining-A8/85 and B12/125. A separate read/hash-only reconciliation joins every current-source inventory, actual raw output, generated hash, configuration, environment and probe ledger. The six original16+2 subsets concatenate all24 observations,96 physical checkpoints and12 refusals, exactly matching the unchanged fresh JS independent model. No old C or old semantic kills transfer.

The old full-A timeout, initially unexecuted diagnostic plan, and zero-child lock refusal are preserved. The later queue shim changes only blocking flock acquisition; actual runner/plan bytes are unchanged. Generic frozen runner prose85/205 is stale; actual A/B probe counts85/125 above are authoritative. Finite refusal metadata equivalence does not assert predicate/owner type identity. Private environments, binaries and installed dependencies are excluded from portable archives; their historical hashes remain. No proof, performance, two-helper root adoption or issue closure is claimed.
'''
(OUT / 'REPORT.md').write_text(report)
sources = ['prepare-handler-helper-lost-phase-roots.py',
           'prepare-handler-helper-lost-remaining-phase-roots.py',
           'run-handler-helper-lost-exit-a-diagnostic.py',
           'run-handler-helper-lost-exit-a-runtime.py',
           'run-handler-helper-lost-remaining-native.py',
           'reconcile-handler-helper-lost-native-union.py',
           'prepare-handler-helper-lost-native-handoff.py',
           'verify-handler-helper-lost-native-handoff.py']
m = {'status': 'FINITE_CURRENT_HELPER_LOST_NATIVE_SPLIT_UNION',
     'completeIssue49': False, 'proofCredit': False, 'productionAdopted': False,
     'performanceQualified': False, 'source': {n: sha((H / n).read_bytes()) for n in sources},
     'reportSHA256': sha((OUT / 'REPORT.md').read_bytes()),
     'historicalDirectories': {n: str(d) for n, d in directories.items()},
     'archive': {'name': 'native.tar.gz', 'sha256': sha(blob), 'members': members},
     'unionSHA256': r['unionSHA256'], 'reconciliationSHA256': sha(rr.read_bytes()),
     'jsCapsuleManifestSHA256': sha((H / 'delivery-handler-helper-mutants-js-v1/manifest.json').read_bytes())}
(OUT / 'manifest.json').write_text(json.dumps(m, indent=2) + '\n')
print(sha((OUT / 'manifest.json').read_bytes()))
