"""Portable full-output reached JS controls; no child replay."""
import pathlib,json,hashlib,tarfile,io,sys
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(b):return hashlib.sha256(b).hexdigest()
def build():
 out=HERE/'portable-mutants-v1';out.mkdir(exist_ok=False);base=HERE/'portable-component-v1';index=json.loads((base/'index.json').read_text());records=dict(index['records']);objects={}
 with tarfile.open(base/'objects.tar.gz','r:gz') as t:
  for m in t.getmembers():b=t.extractfile(m).read();assert sha(b)==m.name.split('/')[1];objects[m.name]=b
 static=HERE/'portable-static-v1';static_index=json.loads((static/'index.json').read_text())
 with tarfile.open(static/'objects.tar.gz','r:gz') as t:
  for m in t.getmembers():b=t.extractfile(m).read();assert sha(b)==m.name.split('/')[1];objects[m.name]=b
 for name,r in static_index['records'].items():
  if name in records:assert records[name]==r
  records[name]=r
 files={HERE/'package-mutants.py',HERE/'js-mutant-runtime.py',static/'index.json',static/'verify.py',base/'ARCHIVED-PATH-JOINS.json',base/'pinned-reference-sources.json'};exclusions=dict(static_index['hashOnlyExclusions']);origins=[ROOT/'.artifacts/inspect54-component-order-js01',ROOT/'.artifacts/inspect54-component-conjunction-js01']
 for origin in origins:
  p=json.loads((origin/'plan.json').read_text());r=json.loads((origin/'receipt.json').read_text());assert r['status']=='COMPLETE_REACHED_FULL_COMPONENT_JS_MUTANT'
  for n,d in p['inputs'].items():
   if isinstance(d,dict):
    for relative,digest in d.items():q=pathlib.Path(n)/relative;assert sha(q.read_bytes())==digest;files.add(q)
   else:q=pathlib.Path(n);assert sha(q.read_bytes())==d;files.add(q)
  files.update(q for q in origin.rglob('*') if q.is_file())
  q=p['mutationQualification'];sp=pathlib.Path(q['plan']);source=json.loads(sp.read_text());files.update([sp,pathlib.Path(q['receipt'])])
  files.update(pathlib.Path(n) for n in q['pins'])
  for n,d in source['sourceArchive'].items():path=sp.parent/'source'/n;assert sha(path.read_bytes())==d;files.add(path)
  files.update(sp.parent/n for n in json.loads(pathlib.Path(q['receipt']).read_text())['logs'])
 for path in sorted(files):
  b=path.read_bytes();digest=sha(b)
  if '.private.' in path.name or b.startswith(b'\x7fELF') or b.startswith(b'!<arch>\n'):
   exclusions[str(path)]={'sha256':digest,'reason':'private environment' if '.private.' in path.name else 'installed executable/resource binary'};continue
  n='objects/'+digest;records[str(path)]={'sha256':digest,'bytes':len(b),'object':n};objects[n]=b
 normal_live={}
 for relative,r in index['liveSelected'].items():
  source=HERE/relative;b=source.read_bytes();assert sha(b)==r['sha256'];key='normal-current-live/'+relative;name='objects/'+sha(b);objects[name]=b;records[key]={'sha256':sha(b),'bytes':len(b),'object':name,'origin':str(source)};normal_live[relative]=key
 support={}
 for key,path in [('normal-verifier',base/'verify.py'),('normal-archive',base/'objects.tar.gz'),('static-verifier',static/'verify.py'),('static-archive',static/'objects.tar.gz')]:
  b=path.read_bytes();name='objects/'+sha(b);objects[name]=b;records['support/'+key]={'sha256':sha(b),'bytes':len(b),'object':name,'origin':str(path)};support[key]='support/'+key
 archive=out/'objects.tar.gz'
 used={r['object'] for r in records.values()}
 with tarfile.open(archive,'w:gz') as t:
  for n in sorted(used):b=objects[n];i=tarfile.TarInfo(n);i.size=len(b);i.mtime=0;i.mode=0o644;t.addfile(i,io.BytesIO(b))
 bindings={}
 for origin in origins:
  plan=json.loads((origin/'plan.json').read_text());env=pathlib.Path(plan['privateEnvironment']);b=env.read_bytes();assert sha(b)==plan['environmentSHA256']
  canonical=sha(json.dumps(json.loads(b),sort_keys=True,separators=(',',':'),ensure_ascii=True).encode());assert canonical==json.loads(pathlib.Path(plan['toolSnapshot']).read_text())['environment_sha256']
  bindings[str(env)]={'privateFileSHA256':plan['environmentSHA256'],'canonicalEnvironmentSHA256':canonical,'source':'Owned-tool snapshot canonical JSON encoding; private bytes intentionally excluded.'}
 (out/'index.json').write_text(json.dumps({'scope':'Finite normal-derived JS plus two reached complete-output JS controls; no Native/proof/general constructor truth/adoption/full54 credit. Original normal INCOMPLETE retained.','records':records,'hashOnlyExclusions':exclusions,'archiveSHA256':sha(archive.read_bytes()),'normalIndex':index,'staticIndex':static_index,'privateEnvironmentBindings':bindings,'normalLiveRecords':normal_live,'supportRecords':support,'origins':list(map(str,origins))},indent=2)+'\n');print(len(records),len(used))
if __name__=='__main__':build()
