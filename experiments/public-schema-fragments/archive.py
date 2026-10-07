#!/usr/bin/env python3
"""Archive and verify every retained execution, including terminal failures."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent/'evidence'
sha=lambda b:hashlib.sha256(b).hexdigest()
index=[]
for directory in sorted(HERE.iterdir()):
 if not directory.is_dir():continue
 archive=HERE/(directory.name+'.tar.gz')
 files={str(p.relative_to(HERE)):sha(p.read_bytes()) for p in sorted(directory.rglob('*')) if p.is_file()}
 with tarfile.open(archive,'w:gz') as out:
  for name in files:out.add(HERE/name,arcname=name,recursive=False)
 with tarfile.open(archive,'r:gz') as inp:
  assert {m.name for m in inp.getmembers() if m.isfile()}==set(files)
  for name,digest in files.items():assert sha(inp.extractfile(name).read())==digest
 receipt=json.loads((directory/'receipt.json').read_text())
 index.append({'archive':archive.name,'sha256':sha(archive.read_bytes()),'status':receipt['status'],'decodedFiles':files})
(HERE/'archive-index.json').write_text(json.dumps(index,indent=2)+'\n')
