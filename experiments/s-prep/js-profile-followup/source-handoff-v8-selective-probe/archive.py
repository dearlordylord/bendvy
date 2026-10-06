#!/usr/bin/env python3
"""Archive only compact graph/refusal receipts, never source/tool/binary copies."""
from pathlib import Path
import json,hashlib,tarfile,io
H=Path(__file__).resolve().parent;root=Path('/tmp/bendvy-v8-selective-feasibility-final');out=H/'evidence';out.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();members={}
with tarfile.open(out/'evidence.tar.gz','w:gz') as archive:
 for p in sorted(root.iterdir()):
  if p.suffix not in ['.json','.txt']:continue
  data=p.read_bytes();info=tarfile.TarInfo(p.name);info.size=len(data);info.mtime=0;archive.addfile(info,io.BytesIO(data));members[p.name]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}
with tarfile.open(out/'evidence.tar.gz','r:gz') as archive:
 assert len(archive.getmembers())==len(members)
 for p in archive.getmembers():assert hashlib.sha256(archive.extractfile(p).read()).hexdigest()==members[p.name]['sha256']
(out/'manifest.json').write_text(json.dumps({'status':'DECODED_SMALL_REFUSAL_ARCHIVE_VERIFIED','archiveSHA256':sha(out/'evidence.tar.gz'),'members':members},indent=2)+'\n')
(H/'status.json').write_text(json.dumps({'status':'UNCHANGED_GUARD_REFUSAL_NEW_IMPLEMENTATION_DEFERRED','receiptPath':str(root/'evidence.json'),'receiptSHA256':sha(root/'evidence.json'),'sourceClosure':'4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235','inputPinsSHA256':sha(H/'pins.json'),'ownedRecipePins':{p.name:sha(p) for p in H.iterdir() if p.suffix in ['.cjs','.py']},'archiveManifestSHA256':sha(out/'manifest.json'),'noCandidateImplemented':True,'newSemanticAndPerformanceGates':'OPEN; not exercised or transferred','normal742Artifacts':'UNMODIFIED'},indent=2)+'\n')
print(json.dumps({'status':'ARCHIVED','members':len(members),'bytes':(out/'evidence.tar.gz').stat().st_size}))
