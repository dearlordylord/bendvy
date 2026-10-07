"""Verify exact portable observer capsules; this is not semantic/performance acceptance."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent
for directory in [HERE.parent/'projection-opt',HERE]:
 folder=directory/'capsules';index=json.loads((folder/'index.json').read_text());archive=folder/index['archive']
 assert archive.stat().st_size==index['bytes']
 assert hashlib.sha256(archive.read_bytes()).hexdigest()==index['archiveSHA256']
 with tarfile.open(archive,'r:gz') as tar:
  entries=tar.getmembers();assert all(m.isfile() for m in entries)
  assert len({m.name for m in entries})==len(entries)
  blobs={m.name:tar.extractfile(m).read() for m in entries}
 assert {n:hashlib.sha256(b).hexdigest() for n,b in blobs.items()}==index['archiveMembers']
 assert len(blobs)==index['uniqueBlobs'] and len(index['members'])==index['logicalMemberCount']
 for logical,h in index['members'].items():
  assert 'blobs/'+h in blobs
  live=directory/logical
  if live.is_file():assert hashlib.sha256(live.read_bytes()).hexdigest()==h
 assert all(n not in index['members'] for n in index['excludedNativeAndGitMetadata'])
 receipts=0
 for logical,h in index['members'].items():
  if not logical.endswith('/receipt.json'):continue
  receipt=json.loads(blobs['blobs/'+h]);parent=str(Path(logical).parent)
  if receipt.get('status','').startswith('COMPLETE_'):
   for group in ['logs','raw_logs']:
    for name,digest in receipt.get(group,{}).items():assert index['members'][parent+'/'+name]==digest
   for mode,run in receipt.get('runs',{}).items():
    assert run['validated_records']==600
    assert index['members'][parent+'/'+mode+'.profile.json']==run['profile_sha256']
   for name,digest in receipt.get('targets',{}).items():
    if name.endswith('.native'):assert index['excludedNativeAndGitMetadata'][parent+'/'+name]['SHA256']==digest
    else:assert index['members'][parent+'/'+name]==digest
   receipts+=1
 print('PASS',directory.name,len(index['members']),'members',receipts,'complete receipts, exact logs/profiles/generated bindings; excluded binaries hash-only')
