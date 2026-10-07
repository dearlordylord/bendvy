"""Select immutable historical mutant evidence; no child execution."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-mutants-v1'
OUT.mkdir(exist_ok=True)


def sha(data):
    return hashlib.sha256(data).hexdigest()


runs = {
    'original-source-v2': 'handler-mutants-source-1791406676461764447',
    'repair-v3': 'whole-marker-source-repair-1791409447790784560',
    'repair-v4': 'whole-marker-source-repair-v4-1791409622691681510',
    'repair-v5': 'whole-marker-source-repair-v5-1791409847322581972',
    'repair-v6': 'whole-marker-source-repair-v6-1791409886258517688',
    'complete-js': 'mutants-complete-cheap-1791410160619766954',
}
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
            elif path.suffix not in ['.json', '.stdout', '.stderr', '.mjs']:
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

names = ['full-mutant-oracle.py', 'full-mutant-complete-consumer.mjs',
         'full-mutant-lost-retry-expected.json', 'full-mutant-premature-publication-expected.json',
         'full-mutant-whole-marker-rollback-expected.json', 'run-mutants-complete-cheap.py',
         'prepare-mutants-handoff.py', 'verify-mutants-handoff.py']
source = {name: sha((H / name).read_bytes()) for name in names}
report = '''# Registered handler controlled semantic defects

Three actual compiling variants each produced all24 application strings: two nominal schemas × six failure positions × eight physical checkpoints, plus12 requirement refusals. All complete outputs matched separate independent96/12 variant models before checking precise defects in both schemas. Original normal prefixes and complete refusal observations remain identical. Lost retry removes the pending transition after exit failure; premature publication exposes Flow before an exit handler succeeds; whole-marker rollback restores the real finite component/resource/machine/event/queue World and loses earlier committed handler work. Its actual Local owners and attempt/delivery logs move back from the failed World, and external registry cursors retain actual updates. No scalar surrogate or arbitrary Type clone API is used.

The complete variant models also account for later markers and Level transitions; witnesses alone are not the gate. Complete physical arrays/stamps, owned payloads, liveness/allocator, event streams/readers, queue, metadata, Local and cursor observations are retained. All six emit30/Node5 subjects exited0 with empty stderr. Source-qualified lost-retry/premature closures reuse their original checks byte exactly; whole-marker uses the retained v6 successful source closure. No normal JS, TS, source or resolver probes were replayed in this cohort.

Earlier whole-marker v2–v5 source failures remain losslessly archived: computed match order, forward helper reference, missing local World type annotations and nonexistent String.is_eq. V6 uses the existing String equality operation and source-checks successfully. Source checker output is not mathematical validity or proof credit; no --verdict was run. Archives retain plans, receipts, frozen Bend closures, generated JS and complete raw consumer outputs, excluding private environment maps and dependency trees. Original absolute paths/hashes remain historical, not rebased replay promises.

This is bounded development semantic evidence. Final resolver-qualified acceptance remains pending; no timing, Native mutant execution, production adoption, new policy/law/proof or completeIssue49 claim is made. Prior full normal JS/Native and foreign/authority controls retain their separate qualification boundaries.
'''
(OUT / 'REPORT.md').write_text(report)
m = {'status': 'SELECTED_THREE_COMPLETE96_AND12_SEMANTIC_VARIANTS',
     'completeIssue49': False, 'acceptanceQualified': False,
     'performanceQualified': False, 'proofCredit': False,
     'source': source, 'archives': archives,
     'reportSHA256': sha((OUT / 'REPORT.md').read_bytes())}
(OUT / 'manifest.json').write_text(json.dumps(m, indent=2) + '\n')
print(json.dumps({'manifestSHA256': sha((OUT / 'manifest.json').read_bytes()),
                  'compressedBytes': sum((OUT / a['archive']).stat().st_size for a in archives.values())}))
