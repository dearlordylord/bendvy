"""Archive current-module source diagnostics and actual full JS mutants; no children."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path
H = Path(__file__).resolve().parent
OUT = H / 'delivery-adoption-mutants-js-v1'
OUT.mkdir(exist_ok=True)
sha = lambda data: hashlib.sha256(data).hexdigest()
archives = {}
for label, run, probes, count in [('source','adoption-mutants-source-1791420129031621841',35,3),('js','adoption-mutants-js-1791420308252044834',65,6)]:
    root = H / 'development' / run
    receipt = json.loads((root / 'receipt.json').read_text())
    assert receipt['probeCommandsExecuted'] == probes and len(receipt['commands']) == count
    assert all(c['exit']==0 and c['failure'] is None for c in receipt['commands'])
    selected = {str(p.relative_to(root)):p.read_bytes() for p in root.rglob('*') if p.is_file() and p.name != 'private-environment.json' and p.suffix in ['.json','.bend','.mjs','.py','.stdout','.stderr']}
    members={};buffer=io.BytesIO()
    with tarfile.open(fileobj=buffer,mode='w') as tar:
        for name,data in sorted(selected.items()):
            info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644;info.mtime=0
            tar.addfile(info,io.BytesIO(data));members[name]={'sha256':sha(data),'bytes':len(data)}
    blob=gzip.compress(buffer.getvalue(),mtime=0);filename=label+'.tar.gz';(OUT/filename).write_bytes(blob)
    archives[label]={'archive':filename,'sha256':sha(blob),'historicalDirectory':str(root),'members':members}
old=H/'development/adoption-mutants-js-1791420258252330465'
history={'old77ab-plan.json':(old/'plan.json').read_bytes(),'old77ab-wrapper.py':(old/'reviewed-unexecuted-wrapper.py').read_bytes()}
for name,data in history.items():(OUT/name).write_bytes(data)
report='''# #49 current handler-module closure: actual JS semantic mutants

Three relocated actual controlled defects passed source5 typing checks (exact58 stdout, empty stderr,35 guards), then fresh emit30/full consumerNode5 each (six subjects,65 ordinary guards). Each actual variant matched all24 complete strings,96 full positive checkpoints and12 four-line refusal cases against its unchanged independent model. Actual normal differences, prefixes, Local owners/cursors and two-schema targeted witnesses were reached; output hashes equal the historical observations on a freshly emitted public-module closure. No original-source kills are transferred.

Lost retry and premature publication reuse the historical one-line handler defects with import relocation only. Whole-marker rollback retains the finite actual Data inverse and full marker defect; public generic handler is baseline, actual Local/registry owners remain preserved. Root four prospective generic modules/current dependencies are hashjoined; internal machine-handler-events remains a trusted helper, not a general public #53 event policy. No universal Type cloning, capture or owner-policy changes.

The old77ab JS plan and original wrapper remain unexecuted history. Independent review required generated output absence before emission and inclusion in central Runner consumer inputs; corrected287e plan executed once. Initial source-only metadata preparation encountered a KeyError before checks, corrected to the manifest's actual normalPlan/normalReceipt keys. No backend retry or caps increase occurred.

Archives contain complete source/stages, raw outputs, generated JS, guarded tools/configuration receipts and all models/consumers. Private environment maps and installed dependencies are excluded. Source checks are typing only, not mathematical proofs. Current-closure Native mutants and regression remain required; this capsule does not adopt root drafts or close #49, claim performance, or choose new laws/policies. Metadata equivalence does not claim erased owner/predicate type identity.
'''
(OUT/'REPORT.md').write_text(report)
names=['prepare-adoption-mutant-sources.py','run-adoption-mutants-source.py','run-adoption-mutants-js.py','prepare-adoption-mutants-handoff.py','verify-adoption-mutants-handoff.py']
manifest={'status':'FINITE_CURRENT_HANDLER_MODULE_SOURCE_AND_FULL_JS_MUTANTS','completeIssue49':False,'proofCredit':False,'productionAdopted':False,'nativeQualified':False,'performanceQualified':False,'source':{n:sha((H/n).read_bytes()) for n in names},'reportSHA256':sha((OUT/'REPORT.md').read_bytes()),'baselineNativeManifestSHA256':sha((H/'delivery-adoption-native-v1/manifest.json').read_bytes()),'historicalMutationManifestSHA256':sha((H/'delivery-mutants-v1/manifest.json').read_bytes()),'history':{n:sha(d) for n,d in history.items()},'archives':archives}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(sha((OUT/'manifest.json').read_bytes()))
