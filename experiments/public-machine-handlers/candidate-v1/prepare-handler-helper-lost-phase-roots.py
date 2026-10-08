"""Source-only phase partitions after lost-A emission timeout; no child execution."""
import hashlib
import json
import shutil
import time
from pathlib import Path

H = Path(__file__).resolve().parent
sha = lambda data: hashlib.sha256(data).hexdigest()
manifestPath = H / 'development/handler-helper-native-mutant-roots-1791426220729435859/manifest.json'
assert sha(manifestPath.read_bytes()) == '0882cabe8ac2d9ed934bf2ef9a233d39c9ce0a5c10e5bce54d90c65a839c1b6e'
mapping = json.loads(manifestPath.read_text())
failed = H / 'development/handler-helper-mutants-native-lost-retry-1791427610353568836'
assert sha((failed / 'receipt.json').read_bytes()) == '4ece1fca14e2e335fc6cafb14935f5a611b62eaa7fadd1a0f3c9ffdd8cdf2036'
out = H / 'development' / ('handler-helper-lost-phase-roots-' + str(time.time_ns()))
out.mkdir()
record = {'status': 'SOURCE_ONLY_UNEXECUTED_LOST_A_PHASE_PROPOSAL', 'historicalPartitionManifest': str(manifestPath), 'historicalPartitionManifestSHA256': sha(manifestPath.read_bytes()), 'failedReceipt': str(failed / 'receipt.json'), 'failedReceiptSHA256': sha((failed / 'receipt.json').read_bytes()), 'roots': {}}
base = Path(mapping['roots']['lost-retry-A']['stage'])
assert {str(f.relative_to(base)): sha(f.read_bytes()) for f in base.rglob('*') if f.is_file()} == mapping['roots']['lost-retry-A']['inventory']
for phase in ['exit', 'transition', 'enter']:
    sourceLabel = 'premature-publication-B-' + phase
    # Existing successful enter roots were one-position only. Reuse the exact
    # existing exit wrapper shape, replacing its two actual failure functions.
    templateRoot = mapping['roots'].get(sourceLabel, mapping['roots']['premature-publication-B-exit'])
    original = Path(templateRoot['entry']).read_bytes()
    assert sha(original) == templateRoot['wrapperSHA256']
    text = original.decode().replace('schemaB', 'schemaA').replace('P.SchemaB', 'P.SchemaA')
    if phase == 'enter':
        text = text.replace('exit0', 'enter0').replace('exit1', 'enter1')
    dst = out / ('A-' + phase)
    shutil.copytree(base, dst)
    fixture = dst / 'experiments/public-machine-handlers/candidate-v1'
    entry = fixture / 'native-lost-phase.bend'
    entry.write_text(text)
    model = json.loads((fixture / 'full-mutant-lost-retry-expected.json').read_text())['bend']
    names = ['schemaA_' + phase + str(i) + suffix for i in [0, 1] for suffix in ['', '_missing']]
    expected = ''.join(n + '|[' + ', '.join(model[n]) + ']\n' for n in names).encode()
    (dst / 'expected.stdout').write_bytes(expected)
    record['roots'][phase] = {'stage': str(dst), 'entry': str(entry), 'schema': 'A', 'names': names, 'positiveCheckpoints': 16, 'refusalCases': 2, 'expectedSHA256': sha(expected), 'templateEntry': templateRoot['entry'], 'templateSHA256': sha(original), 'wrapperSHA256': sha(entry.read_bytes()), 'inventory': {str(f.relative_to(dst)): sha(f.read_bytes()) for f in dst.rglob('*') if f.is_file()}}
record['scope'] = 'Only native wrapper partitions; original actual Full phase/position failure predicates, registered callbacks, owners, models and entire lost mutant closure unchanged. Missing calls retain the previously disclosed finite observable metadata equivalence, not erased predicate type identity. Three complete16+2 subsets concatenate original A48+6; B remains separate and unexecuted. No checker/emitter/runtime or kill claim. First exit-A source5/Cemit30 diagnostic must be reviewed before execution; no identical full-A retry or cap raise.'
(out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
print(out / 'manifest.json')
print(sha((out / 'manifest.json').read_bytes()))
