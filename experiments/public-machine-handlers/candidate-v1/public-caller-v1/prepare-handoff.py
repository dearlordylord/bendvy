"""Archive finite independent caller source/JS observations without children."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path
H = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
R = H / 'cheap-js-1791432084271257355'
p = json.loads((R / 'plan.json').read_text())
r = json.loads((R / 'receipt.json').read_text())
assert r['status'] == 'INDEPENDENT_CALLER_FOURTEEN_COMPLETE_JS_OBSERVATIONS_PASS'
assert r['planSHA256'] == sha((R / 'plan.json').read_bytes()) and r['probeCommandsExecuted'] == 25
assert len(r['commands']) == 2 and all(c['exit'] == 0 and c['failure'] is None for c in r['commands'])
selected = {str(f.relative_to(R)): f.read_bytes() for f in R.rglob('*')
            if f.is_file() and f.name != 'private-environment.json'}
for name, digest in r['logs'].items(): assert sha(selected[name]) == digest
for path, digest in r['probePins'].items(): assert sha(selected[str(Path(path).relative_to(R))]) == digest
for path, digest in r['generated'].items(): assert sha(selected[str(Path(path).relative_to(R))]) == digest
for rel, digest in p['inventory'].items(): assert sha(selected['stage/' + rel]) == digest
for f in H.glob('development-*'):
    if f.is_file(): selected['history/' + f.name] = f.read_bytes()
for name in ['source-review-manifest-before-reader-fix.json', 'expected-before-missing-slot-revision.json', 'expected-before-missing-reader-control.json']:
    selected['history/' + name] = (H / name).read_bytes()
OUT = H / 'delivery-v1'
OUT.mkdir(exist_ok=True)
items = {}; buffer = io.BytesIO()
with tarfile.open(fileobj=buffer, mode='w') as t:
    for name, data in sorted(selected.items()):
        info = tarfile.TarInfo(name); info.size = len(data); info.mode = 0o644; info.mtime = 0
        t.addfile(info, io.BytesIO(data)); items[name] = {'sha256': sha(data), 'bytes': len(data)}
blob = gzip.compress(buffer.getvalue(), mtime=0)
(OUT / 'source-js.tar.gz').write_bytes(blob)
report = """# Independent public handler caller: finite JS development evidence

The caller independently assembles actual core worlds, affine component/resource/Local owners, registered phase systems and a separate tracked reader registry. It imports only core modules plus the two qualified proposed core helpers; no experimental runtime helper. Single-machine markers preserve failure/retry/commit/publication and later self-queue boundaries without selecting disputed inter-machine policy.

All fourteen full JSON observations on two nominal schemas matched a concrete independently authored oracle: initial, failed transition, retry, next marker, false condition, missing machine requirement and nonempty-stream MissingReader refusal. Sys cursor and namespace-validated stream Reader position are distinct owners. A source review caught a missing-reader stream restoration bug before execution; the repaired refusal returns actual Sys.Failed and the reached complete control preserves publications and registry cursor. Existing source and oracle drafts are retained, not silently replaced with observed outputs.

Actual development source5 passed but its tool output was transcribed; it is not byte-exact raw source acceptance or mathematical proof. Fresh JS emit30/Node5, CPU8 and twenty-five owned guards passed, with empty stderr and full independent JSON equality. Historical tools/config/environment receipts were reused only after byte guards; no old runtime evidence transfers. Private environments and installed dependencies are excluded. This qualifies the bounded caller on JS; Native, final source/refusal qualification, feature timing, production helper adoption and full issues48/49 remain outstanding. No new API, law, capture/Local/owned-event policy, performance threshold or stream representation is selected.
"""
(OUT / 'REPORT.md').write_text(report)
names = ['types.bend','world.bend','systems.bend','application.bend','main.bend','consumer.mjs','expected-draft.json','oracle-before-source.json','PLAN.md','source-review-manifest.json','run-cheap-js.py','prepare-handoff.py','verify-handoff.py']
m = {'status':'FINITE_INDEPENDENT_CALLER_JS_DEVELOPMENT', 'completeIssue49':False, 'proofCredit':False, 'nativeQualified':False, 'productionAdopted':False, 'performanceQualified':False,
     'source':{n:sha((H/n).read_bytes()) for n in names}, 'reportSHA256':sha((OUT/'REPORT.md').read_bytes()),
     'archive':{'name':'source-js.tar.gz','sha256':sha(blob),'members':items,'historicalDirectory':str(R)},
     'planSHA256':sha((R/'plan.json').read_bytes()),'receiptSHA256':sha((R/'receipt.json').read_bytes())}
(OUT/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
print(sha((OUT/'manifest.json').read_bytes()))
