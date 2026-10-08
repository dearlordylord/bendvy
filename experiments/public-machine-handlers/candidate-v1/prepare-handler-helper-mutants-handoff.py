"""Archive current-module source diagnostics and actual full JS mutants; no children."""
import gzip
import hashlib
import io
import json
import tarfile
from pathlib import Path
H = Path(__file__).resolve().parent
OUT = H / 'delivery-handler-helper-mutants-js-v1'
OUT.mkdir(exist_ok=True)
sha = lambda data: hashlib.sha256(data).hexdigest()
archives = {}
for label, run, probes, count in [('source','handler-helper-mutants-source-1791426965182904874',35,3),('js','handler-helper-mutants-js-1791427335326091287',65,6)]:
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
history={}
for label, path in [('unexecuted-rebase775.json','handler-helper-mutant-rebase-1791425771483118124/manifest.json'),('unexecuted-rootscbc.json','handler-helper-native-mutant-roots-1791426008302206058/manifest.json'),('source-lock-refusal.json','handler-helper-mutant-source-lock-refusal.json')]:
    history[label]=(H/'development'/path).read_bytes()
for name,data in history.items():(OUT/name).write_bytes(data)
report="""# #49 staged package helpers: full JS semantic mutants

Three actual controlled defects on the two-helper closure passed source5 typing (exact58 stdout/emptystderr,35 guards), then fresh emit30/fullNode5 each (six subjects65 guards). Each variant matches all24 strings,96 complete physical checkpoints and12 four-line refusal cases against unchanged independent models, with actual normal differences/prefixes/Local/cursor/two-schema witnesses reached. No previous runtime kills transfer.

Lost retry and premature publication retain historical one-line handler defects, imports rebased only. Whole-marker rollback retains finite actual Data inverse and full marker defect, preserving real Local/registry owners. No universal Type cloning, capture policy, stream/later-key or general event policy choices. Generic world/condition helpers and sole provider imports are staged; root alone owns adoption.

Source-only first775 mapping omitted baseline oracle (a14 typing stage lacks JS support); unexecuted manifest/partitioncbc retained. Fresh3909 mapping includes original byte-joined baseline oracle before source/runtime. Prior source lock refusal started zero children and is retained as transcribed observation, not original stderr. No cap raises or baseline/TS replay.

Archives preserve complete source/raw/generatedJS/tool/config/probe/model/consumer joins, exclude private environments/installed dependencies. Source typing is not mathematical proof. Native changed-closure groups and paired root regression remain required; no performance/adoption/issueclosure claim. Finite metadata equivalence is not erased predicate/owner typeidentity.
"""
(OUT/'REPORT.md').write_text(report)
names=['prepare-handler-helper-mutant-sources.py','run-handler-helper-mutants-source.py','run-handler-helper-mutants-js.py','prepare-handler-helper-mutants-handoff.py','verify-handler-helper-mutants-handoff.py']
manifest={'status':'FINITE_CURRENT_HANDLER_MODULE_SOURCE_AND_FULL_JS_MUTANTS','completeIssue49':False,'proofCredit':False,'productionAdopted':False,'nativeQualified':False,'performanceQualified':False,'source':{n:sha((H/n).read_bytes()) for n in names},'reportSHA256':sha((OUT/'REPORT.md').read_bytes()),'baselineNativeManifestSHA256':sha((H/'delivery-handler-helper-native-v1/manifest.json').read_bytes()),'historicalMutationManifestSHA256':sha((H/'delivery-mutants-v1/manifest.json').read_bytes()),'history':{n:sha(d) for n,d in history.items()},'archives':archives}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(sha((OUT/'manifest.json').read_bytes()))
