"""Package existing qualification bytes only; no checker/backend/probe children."""
from pathlib import Path
import hashlib,io,json,tarfile
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
OUT=HERE/'final-evidence-v1'
def sha(data):return hashlib.sha256(data).hexdigest()
def main():
 assert not OUT.exists();OUT.mkdir()
 records={};private=set();metadata=[]
 for name in ['portable-handoff-index.json','handoff-controls-index.json']:
  path=HERE/'controls'/name;p=json.loads(path.read_text());records.update(p['records']);private.update(v['sha256'] for v in p['privateEnvironmentPins'].values());metadata.append(path)
 for directory in ['inspect54-controls-negatives-bound-2-1791409491894285321','inspect54-controls-mutant-1791408864852472176','inspect54-reader-mutant-js-1791410151574762180']:
  out=ROOT/'.artifacts'/directory;rp=out/'receipt.json';pp=out/'plan.json';p=json.loads(pp.read_text());r=json.loads(rp.read_text());assert sha(pp.read_bytes())==r['planSHA256'];paths={rp,pp,*map(Path,p['files'])}
  for name in r['logs']:paths.add(out/name)
  for field in ['generated','probePins']:
   for name,digest in r.get(field,{}).items():
    assert sha(Path(name).read_bytes())==digest;paths.add(Path(name))
  for directory in p['directories']:
   d=Path(directory)
   if d.name=='frozen-source':paths.update(d.iterdir())
  for path in paths:records[str(path)]={'sha256':sha(path.read_bytes()),'bytes':path.stat().st_size,'roles':['cohort2-exact-input-or-raw']}
 # Preserve owned historical raw failures and frozen sources without replay.
 for directory in (ROOT/'.artifacts').iterdir():
  if directory.is_dir() and (directory.name.startswith('inspect54-promotion-') or directory.name.startswith('inspect54-mutant-js-preparation-')):
   for path in directory.rglob('*'):
    if path.is_file() and 'stage' not in path.relative_to(directory).parts and 'execution-probes' not in path.relative_to(directory).parts and path.suffix not in ['.native','.js','.c']:
     records[str(path)]={'sha256':sha(path.read_bytes()),'bytes':path.stat().st_size,'roles':['historical-actual-plan-source-archive-raw-preserved']}
 for path in HERE.rglob('*'):
  if path.is_file() and OUT not in path.parents:metadata.append(path)
 for path in metadata:records[str(path)]={'sha256':sha(path.read_bytes()),'bytes':path.stat().st_size,'roles':['owned-current-source-or-metadata']}
 index={};objects={};exclusions={}
 for name,record in sorted(records.items()):
  path=Path(name);data=path.read_bytes();digest=sha(data);assert digest==record['sha256']
  reason=None
  if digest in private or path.name=='private-environment.json':reason='private environment: hash-only outside Git'
  elif data.startswith(b'\x7fELF') or path.suffix=='.native':reason='executable/tool binary: hash-only; not distributed'
  elif data.startswith(b'#!') and '/.artifacts/' not in name and not str(path).startswith(str(ROOT)):reason='external executable wrapper: hash-only; not distributed'
  if reason:exclusions[name]={**record,'reason':reason};continue
  objects[digest]=data;index[name]={**record,'object':'objects/'+digest}
 with tarfile.open(OUT/'objects.tar.gz','w:gz') as archive:
  for digest,data in sorted(objects.items()):
   item=tarfile.TarInfo('objects/'+digest);item.size=len(data);item.mode=0o644;item.mtime=0;archive.addfile(item,io.BytesIO(data))
 value={'status':'QUALIFIED_SLICE_BYTES_FINAL_REVIEW_PENDING','records':index,'excludedHashOnly':exclusions,'objectsArchiveSHA256':sha((OUT/'objects.tar.gz').read_bytes()),'scope':'Current two-schema cardinality/check TS/source/CLI/emittedJS/Native and matched six source negative controls, complete reached JS reader-consumption mutant and selected older retention/query/resource capsules. Original incomplete statuses retained. No proof/full54/performance/final-review/selected-commit acceptance.','pending':'Independent full Spec/Standards review, exact owned selected commit, root interface/integration and remaining full54 gates. Native-mutant not executed or inferred.','portability':'Absolute keys are provenance only. Verification resolves objects by digest from tar archive, no original paths; executable/tool/private-env hash-only exclusions require separate current environment requalification.'}
 (OUT/'index.json').write_text(json.dumps(value,indent=2)+'\n')
 selected={str(p.relative_to(ROOT)):sha(p.read_bytes()) for p in sorted(HERE.rglob('*')) if p.is_file() and OUT not in p.parents}
 (OUT/'selected-owned-source.json').write_text(json.dumps({'status':'SELECTED_OWNED_SOURCE_REVIEW_PENDING_NO_COMMIT','files':selected,'rule':'Only promotion-stage owned files; root separately integrates shared interfaces. Existing tracked dependencies are frozen in verified object index, never implicit untracked src.'},indent=2)+'\n')
 print(OUT);print('objects',len(objects),'records',len(index),'excluded',len(exclusions))
if __name__=='__main__':main()
