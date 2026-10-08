"""Package finite development evidence without running any consumer or tools."""
from pathlib import Path
import gzip,hashlib,io,json,tarfile
H=Path(__file__).resolve().parent;R=H.parents[2];ROOT=Path('/workspace/formal-proofs/bendvy');E=H/'finite-evidence-v1';E.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
objects={};records={}
def add(p):
 p=Path(p).resolve();b=p.read_bytes();digest=sha(b);objects[digest]=b;records[str(p)]=digest;return digest
# Public draft source, historical bytes, every development raw attempt.
for p in sorted(H.rglob('*')):
 if not p.is_file() or E in p.parents or p.name in ('package-finite.py','CURRENT-REPORT.md','delivery-files.json') or p.name.startswith('ts-supplement') or p.name in ('reference-supplement.mjs','expected-ts-supplement.json'):continue
 assert 'private-environment' not in p.name
 add(p)
cohorts={}
for role,name in [('ts-failure','ts-cheap-1791435254833531539'),('ts-public','ts-cheap-1791435428607460927'),('pure-timeout','bend-cheap-1791436609609197598'),('metadata-malformed','bend-remaining-1791436786406213261'),('boundary-io','boundary-io-1791436935651351673'),('remaining-v2','bend-remaining-v2-1791437071331828055')]:
 d=R/'.artifacts'/('inspector-machine55-'+name);plan=d/'plan.json';receipt=d/'receipt.json';p=json.loads(plan.read_text());r=json.loads(receipt.read_text());assert sha(plan.read_bytes())==r['planSHA256'];raw={}
 for name,digest in r['logs'].items():assert add(d/name)==digest;raw[name]=digest
 # Record every local guard pin honestly. Public source is retained where safe;
 # compiler/resource/system/private bytes remain qualified locally, excluded.
 retained={};excluded={}
 for name,digest in p['pins'].items():
  f=Path(name)
  if f.is_file() and sha(f.read_bytes())==digest and (H in f.parents or (ROOT/'.references/bevy-ts') in f.parents or f in (R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',ROOT/'scripts/evidence_boundary.py',Path('/home/node/.bend/bend2/base.bend')) or f.parent==ROOT/'src/ecs'):
   retained[name]=add(f)
  elif digest in objects:retained[name]=digest
  else:excluded[name]=digest
 cohorts[role]={'plan':add(plan),'receipt':add(receipt),'raw':raw,'retainedPins':retained,'excludedLocalPins':excluded,'privateEnvironmentSHA256':p['environmentSHA256']}
index={'format':1,'scope':'Finite developer-source/runtime evidence only; no full55/proof/backend/performance/core adoption. No fresh checkout execution or installed resolver qualification.','records':records,'cohorts':cohorts,'objects':sorted(objects),'exclusions':'ELF/binaries/private environments/caches/installed resource tree not packaged; their exact recorded local hashes remain metadata. Original source pins not available at current paths join retained immutable objects by hash, never retroactive rerun.'}
# Deterministic content-only archive; original host paths are labels, never extract destinations.
raw=io.BytesIO()
with tarfile.open(fileobj=raw,mode='w') as t:
 for digest,b in sorted(objects.items()):
  m=tarfile.TarInfo('objects/'+digest);m.size=len(b);m.mtime=0;m.mode=0o644;t.addfile(m,io.BytesIO(b))
with (E/'objects.tar.gz').open('wb') as f:
 with gzip.GzipFile(fileobj=f,mode='wb',mtime=0,filename='') as g:g.write(raw.getvalue())
index['archiveSHA256']=sha((E/'objects.tar.gz').read_bytes());(E/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(objects),len(records),index['archiveSHA256'])
