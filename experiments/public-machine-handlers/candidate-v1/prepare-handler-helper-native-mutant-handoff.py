"""Archive one actual Native mutation group; no executable children."""
import argparse
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
p=argparse.ArgumentParser();p.add_argument('variant',choices=['whole-marker-rollback','lost-retry','premature-publication']);p.add_argument('--run',required=True);args=p.parse_args();v=args.variant
root=Path(args.run).resolve();assert root.is_relative_to(H/'development');r=json.loads((root/'receipt.json').read_text());plan=json.loads((root/'plan.json').read_text());assert r['status']=='STAGED_HANDLER_HELPERS_ONE_MUTANT_NATIVE_FULL96_AND12_UNION_PASS'
assert r['planSHA256']==sha((root/'plan.json').read_bytes()) and r['probeCommandsExecuted']==plan['expectedProbeCount']
assert len(r['commands'])==len(plan['commands']) and all(c['exit']==0 and c['failure'] is None for c in r['commands'])
selected={str(p.relative_to(root)):p.read_bytes() for p in root.rglob('*') if p.is_file() and p.name!='private-environment.json' and p.suffix in ['.json','.py','.bend','.mjs','.c','.stdout','.stderr']}
OUT=H/('delivery-handler-helper-native-mutant-'+v+'-v1');OUT.mkdir(exist_ok=True);members={};buffer=io.BytesIO()
with tarfile.open(fileobj=buffer,mode='w') as t:
    for n,data in sorted(selected.items()):
        info=tarfile.TarInfo(n);info.size=len(data);info.mode=0o644;info.mtime=0;t.addfile(info,io.BytesIO(data));members[n]={'sha256':sha(data),'bytes':len(data)}
blob=gzip.compress(buffer.getvalue(),mtime=0);(OUT/'native.tar.gz').write_bytes(blob)
report=f'''# #49 staged two-helper closure: actual Native {v} semantic mutant

Current source closure freshly checked/emitted/compiled/ran in {len(plan['nominalRoots'])} original successful partition roots. Each source5 is typing only; emit30/allocated private Clang120/run5, CPU8/thread1/GPUoff and {plan['expectedProbeCount']} ordinary owned guards passed. Complete per-root actual observations equal unchanged independent model subsets; concatenation equals all24 strings/full96 physical checkpoints and12 four-line refusals. Earlier historical timeout roots are not retried, prior C or kills are not transferred. Source and full JS actual qualification on this same staged two-helper closure remain pinned.

The controlled defect is historical source with import relocation only; actual registry/Local owners and full pipeline are retained. Whole-marker's finite Data inverse is fixture-only, not universal Type clone. The internal handler event helper remains trusted and chooses no new public #53 policy. Refusal metadata equivalence does not claim erased predicate/owner type identity.

Lossless source/C/raw/stage/configuration/probe receipts are archived. Private environment maps, binaries and installed dependencies are excluded; binary hashes are historical, not portable replay promises. This capsule qualifies only {v}; other variant receipts remain separate. Paired regression and two-helper root adoption are still pending. No mathematical proof, timing, new laws, adoption or #49 closure is claimed.
'''
(OUT/'REPORT.md').write_text(report)
names=['run-handler-helper-mutants-native.py','prepare-handler-helper-native-mutant-roots.py','prepare-handler-helper-native-mutant-handoff.py','verify-handler-helper-native-mutant-handoff.py']
m={'status':'FINITE_CURRENT_CORE_ONE_NATIVE_MUTANT','variant':v,'completeIssue49':False,'proofCredit':False,'productionAdopted':False,'performanceQualified':False,'source':{n:sha((H/n).read_bytes()) for n in names},'reportSHA256':sha((OUT/'REPORT.md').read_bytes()),'archive':{'name':'native.tar.gz','sha256':sha(blob),'historicalDirectory':str(root),'members':members},'jsReceiptSHA256':plan['sourceAndJSQualification']['sha256'],'jsCapsuleManifestSHA256':sha((H/'delivery-handler-helper-mutants-js-v1/manifest.json').read_bytes())}
(OUT/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(sha((OUT/'manifest.json').read_bytes()))
