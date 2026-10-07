"""Restore exact authored oracle bytes from the capsule; do not regenerate expectations."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent
sha=lambda data:hashlib.sha256(data).hexdigest()
def main():
 directory=HERE/'evidence-v1';index=json.loads((directory/'index.json').read_text());assert sha((directory/'objects.tar.gz').read_bytes())==index['archiveSHA256'];wanted={key:digest for key,digest in index['files'].items() if key.startswith('oracle/')};objects={}
 with tarfile.open(directory/'objects.tar.gz','r:gz') as archive:
  for member in archive:
   if member.name in wanted.values():
    assert member.isfile();data=archive.extractfile(member).read();assert sha(data)==member.name;objects[member.name]=data
 manifest=json.loads(objects[wanted['oracle/manifest.json']]);assert sha((HERE/'oracle.py').read_bytes())==manifest['oracleSourceSha256']
 for case in manifest['cases']:
  name=case['expected'];data=objects[wanted['oracle/'+name]];assert sha(data)==case['sha256'];target=HERE/'expected'/name
  if target.exists():assert target.read_bytes()==data,'refusing to overwrite different oracle bytes'
  else:target.parent.mkdir(exist_ok=True);target.write_bytes(data)
 print('Restored three exact hash-bound original full30 oracle files; no consumer execution')
if __name__=='__main__':main()
