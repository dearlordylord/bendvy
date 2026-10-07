"""Metadata-only lossless selection; does not execute a tool or backend."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
OUT=HERE/'delivery-driver-native-v1'
RUNS={
 'driver-binder-failure':'driver-v2-cheap-1791404376478958885',
 'driver-js':'driver-v2-cheap-1791404921410873785',
 'literal-native-timeout':'full-native-1791403923601058173',
 'driver-native-timeout':'full-driver-v2-native-1791405024263814664',
 'schema-a-c':'schema-a-c-diagnostic-1791405265516436542',
 'split-native':'split-native-1791405647419008300',
}
sha=lambda b:hashlib.sha256(b).hexdigest()
OUT.mkdir(exist_ok=True)
records={}
for label,name in RUNS.items():
 root=HERE/'development'/name;members={};buf=io.BytesIO()
 with tarfile.open(fileobj=buf,mode='w') as archive:
  for p in sorted(root.rglob('*')):
   if not p.is_file() or p.is_symlink():continue
   rel=p.relative_to(root)
   if 'stage' in rel.parts:
    if p.suffix!='.bend':continue
   elif p.name=='private-environment.json' or p.name.endswith('-native'):continue
   elif p.suffix not in {'.json','.stdout','.stderr','.c','.mjs'}:continue
   data=p.read_bytes();member=tarfile.TarInfo(str(rel));member.size=len(data);member.mtime=0;member.mode=0o644
   archive.addfile(member,io.BytesIO(data));members[str(rel)]={'sha256':sha(data),'bytes':len(data)}
 blob=gzip.compress(buf.getvalue(),mtime=0)
 filename=label+'.tar.gz';(OUT/filename).write_bytes(blob)
 records[label]={'historicalDirectory':str(root),'archive':filename,'sha256':sha(blob),'members':members}
source_names=['full-driver-v2.bend','full-driver-v2-consumer.mjs','full-native-schema-a.bend','full-native-schema-b.bend','DRIVER-V2-REVIEW.md','run-full-driver-v2-cheap.py','run-schema-a-c-diagnostic.py','run-split-native.py','run-full-native-v2.py','prepare-driver-native-handoff.py','verify-driver-native-handoff.py']
source={n:sha((HERE/n).read_bytes()) for n in source_names}
report='''# Registered handler driver and Native evidence

This is a follow-on to selected source/full-JS commit 62b28c86499d16fc70d8e15be682314803856770. The current runtime descriptor driver passes complete independent full96/12 JS output. Two separately compiled nominal schema IO roots each pass all48 checkpoints and6 refusal observations; their concatenated raw stdout equals all96 checkpoints and12 refusals byte for byte against unchanged full-expected.json. Source callbacks, physical observables, actual registered handler execution and affine component/resource/Local paths remain the selected implementation.

The runtime driver uses two actual closed refusal-template instantiations repeated under12 labels. Observable owner metadata is identical; original erased owner/predicate type identity is not established. Actual TS full96/12 evidence is reused from the previously selected reference-v3 run, not rerun here. A's C emission is reused by exact byte hash from its earlier admitted source5/emit30 diagnostic; B is source5/emit30/clang120/run5. The split cohort has6 successful subjects and65 execution probes. No cap raises, timing claims or core adoption.

Both previous combined-root C emission30 timeouts and the driver source binder failure remain losslessly archived. Timeouts are inconclusive. The original literal JS source's one-terminal-LF normalization has its explicit semantic join in delivery-js-v1; current runtime-driver source/JS emission is independently qualified. Historical absolute paths and plan bytes are retained without rewriting.

Archives contain full source closures, raw logs, original plans/receipts/probe evidence and full generated C/JS bytes. Native binaries and private environment maps are omitted; their historical hashes remain in receipts/plans. This is auditable historical evidence, not an offline replay capsule or resolver-independent production qualification. The historical driver-cheap plan retains an obsolete unused initial reference.mjs pin; none of its commands invokes that adapter. Actual TS provenance is the earlier guarded selected reference-v3 receipt. No failed adapter is selected as a semantic reference. Remaining #49 acceptance: executable foreign/affine authority controls and reached compiling whole-marker-rollback, premature-publication and lost-retry mutants. #50 capture policy is not inferred. CompleteIssue49 and performanceQualified remain false.
'''
(OUT/'REPORT.md').write_text(report)
manifest={'status':'SELECTED_DRIVER_FULL96_JS_AND_SPLIT_NATIVE_EVIDENCE','completeIssue49':False,'performanceQualified':False,'priorSourceCommit':'62b28c86499d16fc70d8e15be682314803856770','source':source,'oracleSHA256':sha((HERE/'full-expected.json').read_bytes()),'archives':records,'reportSHA256':sha((OUT/'REPORT.md').read_bytes()),'scope':'Complete96/12 finite observable qualification; two actual refusal instantiations repeated under12 labels, not original predicate/owner TYPE identity.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({'manifestSHA256':sha((OUT/'manifest.json').read_bytes()),'compressedBytes':sum((OUT/r['archive']).stat().st_size for r in records.values()),'archives':len(records)}))
