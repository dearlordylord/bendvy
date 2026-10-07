"""Select lossless historical controls evidence without execution or private maps."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;OUT=H/'delivery-controls-v1';OUT.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
runs={'computed-match-failure':'foreign-authority-source-1791406441952311812','positive-source':'control-source-cheap-1791407861883379025','foreign-js':'foreign-consumer-cheap-1791408106680526278','negative-diagnostics':'authority-negative-cheap-1791408299657331622'}
archives={}
for label,name in runs.items():
 root=H/'development'/name;buffer=io.BytesIO();members={}
 with tarfile.open(fileobj=buffer,mode='w') as tar:
  for path in sorted(root.rglob('*')):
   if not path.is_file() or path.is_symlink():continue
   rel=path.relative_to(root)
   if 'stage' in rel.parts:
    if path.suffix!='.bend':continue
   elif path.name=='private-environment.json':continue
   elif path.suffix not in ['.json','.stdout','.stderr','.mjs']:continue
   data=path.read_bytes();info=tarfile.TarInfo(str(rel));info.size=len(data);info.mode=0o644;info.mtime=0;tar.addfile(info,io.BytesIO(data));members[str(rel)]={'sha256':sha(data),'bytes':len(data)}
 blob=gzip.compress(buffer.getvalue(),mtime=0);filename=label+'.tar.gz';(OUT/filename).write_bytes(blob);archives[label]={'historicalDirectory':str(root.resolve()),'archive':filename,'sha256':sha(blob),'members':members}
names=['full-foreign-controls.bend','full-foreign-consumer.mjs','full-foreign-oracle.py','full-foreign-expected.json','full-authority-positive.bend','full-negative-owner-duplicate.bend','full-negative-cross-schema.bend','full-negative-write-through-read.bend','full-negative-undeclared-next.bend','authority-diagnostic-classification-v1.json','run-controls-source-cheap.py','run-foreign-consumer-cheap.py','run-authority-negatives-cheap.py','prepare-controls-handoff.py','verify-controls-handoff.py']
source={name:sha((H/name).read_bytes()) for name in names}
report='''# Registered handler foreign and authority controls

This selection follows complete96/12 JS/Native source evidence commit1190bbee64eeb467861f43a6ec42f0db0b1f0d91. Actual SchemaA and SchemaB foreign registry controls use one sequential Factory per application, namespaces1/2 and matching numeric SysID1/name/access declarations. Complete target World before/after, complete source World, both registry metadata/cursors and returned Invocation match an independent seven-row oracle in both nominal schemas. Separate actual zero Local.Cell owners remain unchanged; the callback does not run. Actual Sys.run_tracked returns RegistrationRejected. No surrogate counter or alternate world is substituted.

Matching positive authority siblings source-check successfully. Four source negatives reach the intended errors: affine H.Owners consumed twice, SchemaA Registry required as SchemaB, ValueRead supplied to ValueWrite and extraction of an undeclared second field from one-field ReadOnly. Original collector status remains UNCLASSIFIED; separate immutable classification binds exact error bytes and matched positive definitions. Exit1 alone is not proof/acceptance or a semantic mutant kill.

The first guarded foreign source check failed on a computed tuple scrutinee inside match. Its exact original source closure/plan/raw/probes are preserved. The repair uses parameter-scrutinee helper functions; complete oracle remains unchanged. Subsequent source and foreign JS/negative cohorts are bounded development checks with frozen source/Base/executables/environment, deliberately no ordinary resolver probe replay. Foreign emitter/consumer reuses exact successful positive source closure and raw receipt. Final resolver-qualified acceptance remains required.

Archives retain original plans/receipts/full source closures/complete generated JS and raw outputs. Private environment maps/dependency trees are omitted; hashes/paths remain historical. This is auditable historical evidence, not offline replay or production qualification. No new policy/law/proof/runtime capture contract, timing/core adoption or completeIssue49 claim. Three reached compiling semantic mutants and final qualification remain.
'''
(OUT/'REPORT.md').write_text(report)
m={'status':'PREPARED_SELECTED_DEVELOPMENT_FOREIGN_AND_CLASSIFIED_AUTHORITY_EVIDENCE','completeIssue49':False,'acceptanceQualified':False,'performanceQualified':False,'proofCredit':False,'source':source,'archives':archives,'reportSHA256':sha((OUT/'REPORT.md').read_bytes())}
(OUT/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(json.dumps({'manifestSHA256':sha((OUT/'manifest.json').read_bytes()),'compressedBytes':sum((OUT/r['archive']).stat().st_size for r in archives.values())}))
