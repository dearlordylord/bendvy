"""Read-only provenance guard, executed before evaluator imports or Node."""
import hashlib,json,re,subprocess,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
REFERENCE=Path('/workspace/formal-proofs/bendvy/.references/bevy-ts')
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def git(root,*args):return subprocess.check_output(['git','-C',str(root),*args],timeout=5)
def verify_reference(root,pin):
 assert git(root,'rev-parse','HEAD').decode().strip()==pin,'Reference HEAD mismatch'
 pending=[root/'packages/core/src/index.ts'];seen={}
 while pending:
  source=pending.pop();assert not source.is_symlink(),'Reference symlink rejected'
  source=source.resolve();assert source.is_relative_to(root.resolve()),'Reference path escape'
  relative=source.relative_to(root.resolve()).as_posix()
  if relative in seen:continue
  data=source.read_bytes();assert data==git(root,'show',pin+':'+relative),'Reference blob mismatch: '+relative
  seen[relative]=hashlib.sha256(data).hexdigest()
  for spec in re.findall(r'(?:\bfrom\s*|\bimport\s*\(\s*|^\s*import\s*)["\']([^"\']+)["\']',data.decode(),re.M):
   assert spec.startswith('.') and Path(spec).suffix=='.ts','Unpinned reference dependency'
   pending.append(source.parent/spec)
 return dict(sorted(seen.items()))
def verify(overlay):
 assert sha(HERE/'provenance-pins.json')=='405c0667ef57d89c452432d62cefd251acd5c133fc9c2fe64c7f469e363c3833','Frozen provenance pins mismatch'
 pins=json.loads((HERE/'provenance-pins.json').read_text())
 for n,digest in pins['checkoutSources'].items():
  source=ROOT/n;assert sha(source)==digest,'Protected checkout hash mismatch: '+n
  assert source.read_bytes()==git(ROOT,'show','HEAD:'+n),'Protected source differs from tracked HEAD: '+n
 for n,digest in pins['recipeSources'].items():assert sha(HERE/n)==digest,'Recipe mismatch: '+n
 pin=json.loads((ROOT/'.references/sources.json').read_text())['sources']['bevy-ts']['commit']
 closure=verify_reference(REFERENCE,pin)
 manifest=json.loads((overlay/'overlay.json').read_text());expected=dict(pins['baseSources'])
 expected['experiments/s-integrate/measurement-bend.bend']=pins['preparedReceipt']['derivedMeasurementSHA256']
 expected.update({'experiments/s-integrate/held.bend':pins['recipeSources']['held.bend'],'experiments/s-integrate/held-adapter.bend':pins['recipeSources']['adapter.bend']})
 assert manifest['sources']==expected,'Derived overlay source recipe mismatch'
 for n,digest in expected.items():assert sha(overlay/n)==digest,'Derived source mismatch: '+n
 receipt=json.loads((overlay/'integration-prepare.json').read_text());assert receipt==pins['preparedReceipt'],'Prepare receipt mismatch'
 assert sha(overlay/'measurement-adapter.diff')==receipt['adapterDiffSHA256'],'Adapter diff mismatch'
 return {'referenceCommit':pin,'referenceClosureSHA256':closure,'pinsSHA256':sha(HERE/'provenance-pins.json'),'protectedSources':len(pins['checkoutSources']),'derivedSources':len(expected)}
