"""Select immutable historical mutant evidence; no child execution."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path

H = Path(__file__).resolve().parent
OUT = H / 'delivery-native-mutants-v1'
OUT.mkdir(exist_ok=True)


def sha(data):
    return hashlib.sha256(data).hexdigest()


runs = {'first-whole-a': 'mutant-native-first-1791412910835105733',
        'remaining-five-failed': 'mutants-native-remaining-1791413205340312973',
        'phase-exit-emission': 'premature-b-phase-diagnostic-1791414296590264641',
        'phase-native-failed': 'premature-b-phase-native-1791414875143569136',
        'enter-native-final': 'premature-b-enter-native-1791415621985356212'}
final = json.loads((H / 'development' / runs['enter-native-final'] / 'receipt.json').read_text())
assert final['status'] == 'THREE_NATIVE_COMPLETE96_AND12_VARIANTS_ENTER_SINGLE_UNIONS_PASS'
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

names = ['run-mutant-native-first.py', 'run-mutants-native-remaining.py',
         'run-premature-b-phase-diagnostic.py', 'run-premature-b-phase-native.py',
         'run-premature-b-enter-native.py',
         'prepare-native-mutants-handoff.py', 'verify-native-mutants-handoff.py']
source = {name: sha((H / name).read_bytes()) for name in names}
report = '''# Registered handler complete Native semantic variants

All three actual controlled defects executed on Native in both nominal schemas. Each schema partition produced all48 complete positive checkpoints and6 actual requirement refusals; each A+B byte union exactly matched its original independent96+12 variant oracle. Whole-marker-A reuses the previously qualified exact emitted C; remaining groups wholeB, lostA/B and prematureA check source5/emit30/compile120/run5. Original full PrematureB emission timed out before producing C; its complete source/raw/probes and inconclusive failure remain immutable. Three actual PrematureB phase roots retain the same original predicates/callbacks/owners/core and complete16+2 physical subsets each. Exit phase source/C emission is qualified once then reused for compile/run; transition source5/emit30/compile120/run5 succeeded. The two-predicate enter source5 then timed out with no C/runtime; its receipt/source/raw remain inconclusive. Two original single-predicate enter0/enter1 roots each retain complete8+1 and use source5/emit30/compile120/run5, together originalenter16+2 then fullB48+6. The firstA cohort is compile120/run5 only. All runtime stderr is empty. No combined-root emission, normal baseline or successful wholeA was replayed.

Finite Data array inverse preserves actual Local owners/logs and external registry cursors; earlier committed component/resource/events/commands are incorrectly rolled back by the controlled mutant. Lost retry and premature publication are the same actual source patches as the JS complete variants. Source and model bytes join their selected immutable history; native refusal instantiations preserve finite observable metadata rather than original erased owner/predicate type identity. Ordinary tool/library/config/discovery/environment/source/stage/raw/generated guards and their actual25+180+25+70+85 owned execution probe receipts remain archived (the stopped original20 plan had205 planned).

Historical plans, source closures, full generated C and complete raw outputs are retained losslessly without private environment maps, binaries or dependency trees. Binary hashes are historical receipts, not portable replay promises. Earlier combined-emission timeouts/source failures remain in prior selected capsules. This is finite executable semantic qualification, not mathematical proof, timing, production core adoption or automatic completeIssue49 closure.
'''
(OUT / 'REPORT.md').write_text(report)
m = {'status': 'SELECTED_THREE_NATIVE_COMPLETE96_AND12_VARIANTS',
     'completeIssue49': False, 'acceptanceQualified': False,
     'performanceQualified': False, 'proofCredit': False,
     'source': source, 'archives': archives,
     'reportSHA256': sha((OUT / 'REPORT.md').read_bytes())}
(OUT / 'manifest.json').write_text(json.dumps(m, indent=2) + '\n')
print(json.dumps({'manifestSHA256': sha((OUT / 'manifest.json').read_bytes()),
                  'compressedBytes': sum((OUT / a['archive']).stat().st_size for a in archives.values())}))
