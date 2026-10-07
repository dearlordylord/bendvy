from pathlib import Path
import json,hashlib,tarfile
R=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for dirname in ['projection-opt','combined-opt']:
 D=R/'experiments/public-relations'/dirname;out=D/'capsules';out.mkdir(exist_ok=True);archive=out/'evidence.tar.gz';assert not archive.exists();members={};files={};excluded={}
 for p in sorted(D.rglob('*')):
  if not p.is_file() or any(k in p.parts for k in ['capsules','__pycache__']):continue
  name=str(p.relative_to(D));head=p.open('rb').read(4)
  if head==b'\x7fELF':excluded[name]={'SHA256':sha(p),'bytes':p.stat().st_size,'reason':'Native binary; exact hash retained, generated C/tool/build/run receipts retained'};continue
  if '/.git/' in name:excluded[name]={'SHA256':sha(p),'bytes':p.stat().st_size,'reason':'Reference Git metadata; hash-only'};continue
  h=sha(p);members[name]=h;files.setdefault(h,p)
 with tarfile.open(archive,'w:gz',compresslevel=1) as tar:
  for h,p in sorted(files.items()):tar.add(p,arcname='blobs/'+h,recursive=False)
 with tarfile.open(archive) as tar:
  decoded={m.name:hashlib.sha256(tar.extractfile(m).read()).hexdigest() for m in tar if m.isfile()}
 assert decoded=={'blobs/'+h:h for h in files};assert all(sha(D/n)==h for n,h in members.items());index={'format':'CONTENT_ADDRESSED_LOSSLESS_V1','archive':archive.name,'archiveSHA256':sha(archive),'bytes':archive.stat().st_size,'logicalMemberCount':len(members),'uniqueBlobs':len(files),'members':members,'archiveMembers':decoded,'excludedNativeAndGitMetadata':excluded,'scope':'Lossless selected source/stage/receipt/rawlog/profile/generated JS/C. Native ELF bytes excluded with exact hashes; installed tools/libraries and external reference Git metadata remain hash-only prerequisites. Historical failed attempts retained. No new execution/timing acceptance.'};(out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(dirname,len(members),len(files),archive.stat().st_size,len(excluded))
