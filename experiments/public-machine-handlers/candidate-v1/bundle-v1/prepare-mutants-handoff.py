"""Archive source-feasible and actually reached complete bundle JS variants without replay."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;sha=lambda b:hashlib.sha256(b).hexdigest()
source=['mutations-v1/manifest.json','mutations-v1/PLAN.md','run-mutant-source.py','run-mutant-js.py','consumer-mutant.mjs','prepare-mutants-handoff.py','verify-mutants-handoff.py']
models=json.loads((H/'mutations-v1/manifest.json').read_text())
for variant,r in models['variants'].items():source.extend('mutations-v1/'+variant+'/'+n for n in [r['changedFile'],'source.patch','oracle.py','expected.json'])
runs=['bundle-mutant-source-1791437789551147879','bundle-mutant-JS-1791438058480149128'];data={}
for run in runs:
 for f in (H/run).rglob('*'):
  if f.is_file() and f.name!='private-environment.json':data[run+'/'+str(f.relative_to(H/run))]=f.read_bytes()
data['history/run-mutant-js-metadata-before-source-receipt-shape.py.txt']=(H/'run-mutant-js-metadata-before-source-receipt-shape.py.txt').read_bytes()
out=H/'delivery-mutants-js-v1';assert not out.exists();out.mkdir();b=io.BytesIO();members={}
with tarfile.open(fileobj=b,mode='w') as t:
 for name,raw in sorted(data.items()):
  i=tarfile.TarInfo(name);i.size=len(raw);i.mode=0o644;i.mtime=0;t.addfile(i,io.BytesIO(raw));members[name]={'sha256':sha(raw),'bytes':len(raw)}
raw=gzip.compress(b.getvalue(),mtime=0);(out/'source-js.tar.gz').write_bytes(raw)
report="""# Three reached typed bundle composition controls: finite source/JS

The candidate baseline retains independently checked source/JS48/Native48 and actual TS42 with six explicitly Bend-specific observations. Three new source-backed composition defects were independently modeled before executable outputs: exit predicates compare target rather than old state; each selected phase executes in reverse order while returned phase owners reverse back before the original zipper; inactive Extra is omitted from authored requirements while actual Owned/Machine and extra:read access stay declared. No scalar counter or arbitrary Type clone substitutes for real owners. The reverse control preserves entry identity/order after reconstruction, isolating execution order from owner corruption.

All three actual main roots instantiated both nominal schemas and passed exact check-only typing58/empty-stderr (three source5 subjects/35 guards). Fresh three JS emit30/Node5 pairs then produced complete48 records each, including all physical payloads, registry cursors, Local owners, phase/publication/retry effects and paired foreign source/target worlds. Strict deep equality matched each independent variant model, and both schema witnesses differed from the qualified normal oracle: boot_Play_applied for wrong exit and reversed order, inactive_missing for omitted inactive requirements. Full raw is printed before refusal assertions. This establishes reached executable controls, not mathematical proofs or universal mutation coverage.

Source receipt61aa and runtime receipt310f remain immutable; ordinary stage/source/config/environment/tool/generated/raw joins and all105/195-per-cohort probe JSON/stdout/stderr members are retained. Source-receipt metadata preparation initially assumed a generated field, refused before children and was corrected to actual empty source-artifact shape; original wrapper is retained. Private environments/dependency trees are excluded and original hashes preserved. No baseline/source replay or cap raise was performed.

Native composition variants and current-root module/import relocation remain separate pending qualifications; earlier prepared candidate Native plans are deliberately unexecuted to avoid duplicate work before direct relocated controls. Root alone selects production adoption after API review, fresh current closure and unchanged regression gate. This evidence does not adopt the bundle, select late-key/capture/owned-event policy, establish performance/universal proof or close issue48/49.
"""
(out/'REPORT.md').write_text(report)
m={'status':'FINITE_THREE_REACHED_BUNDLE_JS_VARIANTS','source':{n:sha((H/n).read_bytes()) for n in source},'reportSHA256':sha((out/'REPORT.md').read_bytes()),'archive':{'name':'source-js.tar.gz','sha256':sha(raw),'members':members},'historicalRoot':str(H),'baselineManifestSHA256':sha((H/'delivery-v1/manifest.json').read_bytes()),'completeIssue49':False,'proofCredit':False,'performanceQualified':False}
(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(sha((out/'manifest.json').read_bytes()))
