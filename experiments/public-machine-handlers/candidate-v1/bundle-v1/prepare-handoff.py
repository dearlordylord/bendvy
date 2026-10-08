"""Losslessly archive finite bundle source and JS evidence without executable children."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((H/'source-review-manifest.json').read_text())
source=[*m['source'],'source-review-manifest.json','authority-classification.json','run-source.py','run-js.py','prepare-handoff.py','verify-handoff.py','NATIVE-AND-TS-PLAN.md']
runs=['bundle-source-1791435890088394562','bundle-js-1791435891914821638']
selected={}
for name in runs:
 for f in (H/name).rglob('*'):
  if f.is_file() and f.name!='private-environment.json':selected[name+'/'+str(f.relative_to(H/name))]=f.read_bytes()
for name in ['history-unexecuted-initial-requirements','bundle-source-1791435331533148385','bundle-js-1791435332470782687','bundle-source-1791435825974960719','bundle-js-1791435825973951753']:
 for f in (H/name).rglob('*'):
  if f.is_file() and f.name!='private-environment.json':selected['history/'+name+'/'+str(f.relative_to(H/name))]=f.read_bytes()
for f in H.iterdir():
 if f.is_file() and (f.name.startswith('failed-') or 'draft-before' in f.name or 'initial-draft' in f.name or f.name.startswith('development-') or f.name.endswith('first-source-pass.bend.txt')):selected['history/'+f.name]=f.read_bytes()
out=H/'delivery-v1';assert not out.exists();out.mkdir();buffer=io.BytesIO();members={}
with tarfile.open(fileobj=buffer,mode='w') as t:
 for name,data in sorted(selected.items()):
  i=tarfile.TarInfo(name);i.size=len(data);i.mode=0o644;i.mtime=0;t.addfile(i,io.BytesIO(data));members[name]={'sha256':sha(data),'bytes':len(data)}
blob=gzip.compress(buffer.getvalue(),mtime=0);(out/'source-js.tar.gz').write_bytes(blob)
report="""# Finite arbitrary-arity single-machine handler bundle

The source-only generic bundle recursively flattens authored nested entries, deduplicates all requirements by the supplied nominal-key equality in first-occurrence order, and validates world namespace/all requirements before marker work, including inactive handlers and skipIfSame. It selects three stable phase lists, calls the unchanged handler failure kernel once, and reconstructs every selected/unselected/failed/unexecuted affine registry through separate phase zippers. Internal malformed zipper recovery retains remaining owners. Trusted authored callbacks, requirements projections and transaction inverses remain explicit; no new capture, Local or owned-event policy is selected.

The independently authored concrete application has eight differently acting registered handlers, two nominal schemas, arbitrary Type Array component/resource payloads, actual per-system Local cells, tracked registry cursors and separate namespace-validated public machine-stream readers. Forty-eight full JSON observations (24 per schema) matched the independent pre-output oracle, including overlapping/nonmatching handlers, all five matched failure positions/retries, queued next marker, inactive missing requirements/restoration, identity transitions and paired real independently constructed same-schema foreign worlds. Requirements match pinned bevy-ts resources-before-machine declaration collection: ordinary Owned,Machine; inactive Owned,Extra,Machine; complete union Owned,Machine,Extra.

Seven frozen source subjects ran under CPU8/source5 caps with 75 guard probes. Both positive outputs matched the exact typing-only banner and empty stderr. Five full single-location diagnostics were collected UNCLASSIFIED, then separately independently reviewed: wrong machine key, cross-schema requirements, duplicated affine bundle, read-to-write capability mismatch and undeclared abstract-frame escape. Original raw receipt remains unchanged. Fresh JS emit30/Node5 ran with 25 guard probes and full independent deep equality. Named postguards preserve primary failures; receipt finalization runs all source/config/raw guards before successful publication. Node environment allows only a memory-size option and rejects loader/module injection.

Earlier illustrative requirement arrays were corrected from pinned TS source before executable outputs. Original source/oracle drafts and old unexecuted plans remain lossless history. Development typing observations before the frozen cohort are transcribed tool observations, not original raw captures. Private environments/dependencies are excluded, but admitted file hashes remain in plans.

This is finite source/JS evidence for a candidate API, not production adoption, mathematical validity, Native qualification, actual new bevy-ts comparison, performance qualification or issue48/49 completion. Native partitions, actual reference observations and reached selection/order/inactive-requirement mutants remain separate gates. The existing late-key and capture questions are untouched.
"""
(out/'REPORT.md').write_text(report)
manifest={'status':'FINITE_ARBITRARY_ARITY_BUNDLE_SOURCE_AND_JS','source':{n:sha((H/n).read_bytes()) for n in source},'reportSHA256':sha((out/'REPORT.md').read_bytes()),'archive':{'name':'source-js.tar.gz','sha256':sha(blob),'members':members},'historicalRoot':str(H),'completeIssue49':False,'proofCredit':False,'performanceQualified':False}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(sha((out/'manifest.json').read_bytes()))
