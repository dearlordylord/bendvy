"""Portable Native description full9 evidence packaging only; no child processes."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent;P=H/'mutant-native-v1/1791444378688579450';OUT=H/'mutant-native-evidence-v1'
OUT.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
files={};paths={};objects={};excluded={}
def add(path,key=None):
 raw=path.read_bytes();digest=sha(raw)
 if path.name=='private-environment.json' or raw.startswith(b'\x7fELF'):
  excluded[str(path)]={'sha256':digest,'bytes':len(raw),'reason':'Private environment or executable; hash identity only'};return
 key=key or 'external/'+digest+'/'+path.name;files[key]=digest;paths[str(path)]=key;objects[digest]=raw
for p in P.rglob('*'):
 if p.is_file():add(p,'cohort/'+str(p.relative_to(P)))
plan=json.loads((P/'plan.json').read_text());unavailable={}
for dirname,cohort in [('js-cohort',H/'mutant-js-v1/1791444019044852828'),('normal-cohort',H/'native-v1/1791442794012838906')]:
 for p in cohort.rglob('*'):
  if p.is_file():add(p,dirname+'/'+str(p.relative_to(cohort)))
for n,h in {**plan['pins'],**plan['toolSnapshot']['pins']}.items():
 p=Path(n)
 if p.is_file() and sha(p.read_bytes())==h:add(p)
 else:unavailable[n+'@'+h]='Historical identity unavailable; independent frozen stage retained separately'
for p in [H/'mutant-native-package.py',H/'mutant-native-verify.py',H/'MUTANT-NATIVE-RESULT.md',H/'mutant-native-runner.py',H/'MUTANT-PROPOSAL.json',H/'mutant-js-verify.py',H/'mutant-js-evidence-v1/index.json',H/'mutant-js-evidence-v1/objects.tar.gz',H/'evidence-v1/index.json',H/'evidence-v1/objects.tar.gz']:
 add(p,'delivery/'+str(p.relative_to(H)))
with tarfile.open(OUT/'objects.tar.gz','w:gz') as archive:
 for h,raw in sorted(objects.items()):
  info=tarfile.TarInfo(h);info.size=len(raw);info.mtime=0;archive.addfile(info,io.BytesIO(raw))
index={'scope':'Actual two reached Native complete9 defects and current JS/source/normal TSJSNative prerequisites; no proof/performance/full56','archiveSHA256':sha((OUT/'objects.tar.gz').read_bytes()),'files':files,'pathKeys':paths,'objects':{h:len(b) for h,b in objects.items()},'excluded':excluded,'historicalUnavailable':unavailable,'installedToolScope':'Ordinary installed ELF/resource/loader identities and actual raw owned probes retained in plan/receipts; executable/private bytes excluded'}
(OUT/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(files),len(objects),len(excluded),len(unavailable))
