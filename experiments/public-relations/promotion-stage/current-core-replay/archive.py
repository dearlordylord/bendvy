"""Lossless capsule retention; no executable gate or source acceptance."""
import hashlib,json,pathlib,tarfile
D=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
roots=[D/'evidence',D/'guarded-v2']
files=sorted(p for root in roots for p in root.rglob('*') if p.is_file() and '__pycache__' not in p.parts)
files += [D/'query.py',D/'lifetime.py',D/'README.md',pathlib.Path(__file__).resolve()]
files=sorted(set(files));members={str(p.relative_to(D)):sha(p) for p in files}
out=D/'capsules';out.mkdir(exist_ok=True);archive=out/'current-replay.tar.gz';assert not archive.exists()
with tarfile.open(archive,'w:gz',compresslevel=9) as tar:
 for p in files:tar.add(p,arcname=str(p.relative_to(D)),recursive=False)
with tarfile.open(archive) as tar:
 observed={m.name:hashlib.sha256(tar.extractfile(m).read()).hexdigest() for m in tar if m.isfile()}
assert observed==members
assert all(sha(D/k)==v for k,v in members.items())
(out/'index.json').write_text(json.dumps({'archive':'current-replay.tar.gz','archiveSHA256':sha(archive),'bytes':archive.stat().st_size,'members':members,'scope':'Exact frozen wrappers, preflights and execution artifacts; history remains labeled, no new execution'},indent=2)+'\n')
print(len(members),archive.stat().st_size)
