"""Archive qualified Native24+24 and literal-plan nochild union without backend replay."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;sha=lambda b:hashlib.sha256(b).hexdigest()
runs=['bundle-native-A-diagnostic-1791436391764146836','bundle-native-A-1791436662137826392','bundle-native-B-1791436663174091849','bundle-native-B-1791436965507308248','bundle-native48-reconciliation-1791437158552482846']
source=['native-a.bend','native-b.bend','run-native-a-diagnostic.py','run-native-followup.py','run-native-b-runtime.py','reconcile-native48.py','prepare-native-handoff.py','verify-native-handoff.py']
data={}
for run in runs:
 for f in (H/run).rglob('*'):
  if f.is_file() and f.name not in ['private-environment.json','bundle-A','bundle-B']:data[run+'/'+str(f.relative_to(H/run))]=f.read_bytes()
for run in ['bundle-native-A-1791436599701040533','bundle-native-B-1791436601174117730']:
 for f in (H/run).rglob('*'):
  if f.is_file() and f.name!='private-environment.json':data['history/'+run+'/'+str(f.relative_to(H/run))]=f.read_bytes()
out=H/'delivery-native-v1';assert not out.exists();out.mkdir();b=io.BytesIO();members={}
with tarfile.open(fileobj=b,mode='w') as t:
 for name,raw in sorted(data.items()):
  i=tarfile.TarInfo(name);i.size=len(raw);i.mode=0o644;i.mtime=0;t.addfile(i,io.BytesIO(raw));members[name]={'sha256':sha(raw),'bytes':len(raw)}
raw=gzip.compress(b.getvalue(),mtime=0);(out/'native.tar.gz').write_bytes(raw)
report="""# Finite typed handler bundle: actual Native48

The unchanged qualified candidate source/independent oracle emitted separate A/B roots retaining all24 cases per nominal schema, including complete paired independently constructed foreign worlds. Both source/C-emission diagnostics passed with source5/emit30 caps. Each exact generated C artifact was reused without emission replay for private approved Clang19 compile120/run5, runtime thread1/GPUoff. All24 complete JSON observations per schema matched the pre-output independent oracle with canonical type-sensitive comparison. A separate admitted read/hash/model-only reconciler pinned the literal independently reviewed plans, all75-per-cohort probe JSON/stdout/stderr members, complete immutable stage/raw membership, config/input/C/binary hashes and raw outputs; its full48 union matched the independently recomputed application model.

Four backend cohorts had two subjects/25 guard probes each: A source/C, A compile/run, B source/C, B compile/run. No caps were raised and no benchmark or backend replay was performed for packaging. Earlier unexecuted A/B runtime plans with Python bool/number equality were preserved; the corrected canonical comparison was independently reviewed before actual execution. Named postguards and final receipt boundary preserve primary failure and require all postchecks before PASS. The per-schema physical output is grouped A24 thenB24; no observer/key/field was dropped.

This extends the committed finite source/JS bundle capsule (49256d86, source/JS manifestd5e2e797). Private environments, native binaries and dependency trees are excluded, while original admitted hashes and raw qualifications remain. The portable verifier checks archived source/C/raw/receipt/model joins, not a fresh compiler or execution. Actual new TS comparison and reached bundle selection/order/inactive-requirement mutants remain separate requirements. No production adoption, universal proof, performance or issue48/49 closure is granted by this evidence.
"""
(out/'REPORT.md').write_text(report)
m={'status':'FINITE_TYPED_BUNDLE_NATIVE_FORTY_EIGHT','source':{n:sha((H/n).read_bytes()) for n in source},'reportSHA256':sha((out/'REPORT.md').read_bytes()),'archive':{'name':'native.tar.gz','sha256':sha(raw),'members':members},'historicalRoot':str(H),'baselineManifestSHA256':sha((H/'delivery-v1/manifest.json').read_bytes()),'completeIssue49':False,'proofCredit':False,'performanceQualified':False}
(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(sha((out/'manifest.json').read_bytes()))
