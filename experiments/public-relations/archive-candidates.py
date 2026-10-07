#!/usr/bin/env python3
"""Preserve raw local stages; archive every candidate file and verify decoding."""
import pathlib,tarfile,json,hashlib
H=pathlib.Path(__file__).resolve().parent;out=H/'candidate-archives';out.mkdir(exist_ok=True)
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
index=[]
for base in [H/'production-candidate',*[H/f'production-candidate-v{i}' for i in range(2,6)]]:
 if not base.exists():continue
 files=[p for p in sorted(base.rglob('*')) if p.is_file() and '__pycache__' not in p.parts]
 expected={str(p.relative_to(H)):sha(p) for p in files};archive=out/(base.name+'.tar.gz');assert not archive.exists()
 with tarfile.open(archive,'w:gz',compresslevel=9) as t:
  for p in files:t.add(p,arcname=str(p.relative_to(H)),recursive=False)
 with tarfile.open(archive,'r:gz') as t:
  decoded={m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers() if m.isfile()}
 assert decoded==expected
 index.append({'archive':archive.name,'sha256':sha(archive),'bytes':archive.stat().st_size,'decodedFiles':expected,'rawLocalFilesPreserved':True})
(out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(sum(x['bytes'] for x in index),'bytes',len(index),'verified archives')
