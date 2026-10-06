#!/usr/bin/env python3
"""Preserve exact decoded evidence with content-addressed deduplication."""
import argparse,hashlib,io,json,tarfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--root',type=Path,action='append',required=True);a=p.parse_args()
assert not a.output.exists();a.output.parent.mkdir(parents=True,exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest();files={};blobs={};excluded={}
for root in a.root:
 assert root.is_dir(),root
 for f in sorted(root.rglob('*')):
  if not f.is_file():continue
  assert not f.is_symlink(),f
  data=f.read_bytes();h=sha(data)
  # Executable binaries are pinned but intentionally omitted. Source and logs remain.
  if f.suffix in ['.native','.out'] or data.startswith(b'\x7fELF'):
   excluded[str(f)]={'SHA256':h,'bytes':len(data),'reason':'native executable; reproducible source and command retained'};continue
  files[str(f)]={'SHA256':h,'bytes':len(data)};blobs[h]=data
manifest={'format':'sha256-deduplicated-evidence-v1','roots':list(map(str,a.root)),'files':files,'excludedBinaries':excluded}
with tarfile.open(a.output,'w:gz') as t:
 for h,b in sorted(blobs.items()):
  info=tarfile.TarInfo('blobs/'+h);info.size=len(b);info.mtime=0;t.addfile(info,io.BytesIO(b))
with tarfile.open(a.output,'r:gz') as t:
 decoded={m.name.removeprefix('blobs/'):t.extractfile(m).read() for m in t.getmembers()}
 assert set(decoded)==set(blobs)
 assert all(sha(b)==h and b==blobs[h] for h,b in decoded.items())
 assert all(len(decoded[v['SHA256']])==v['bytes'] for v in files.values())
manifest.update(archiveSHA256=sha(a.output.read_bytes()),decodedSHA256Verified=True,logicalFiles=len(files),uniqueBlobs=len(blobs))
a.output.with_suffix(a.output.suffix+'.manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({'logicalFiles':len(files),'uniqueBlobs':len(blobs),'bytes':a.output.stat().st_size,'decodedSHA256Verified':True}))
