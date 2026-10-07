"""Portable integrity verifier only; never interprets semantic receipt status."""
from pathlib import Path
import hashlib,json,sys,tarfile

def verify(directory):
 directory=Path(directory);p=json.loads((directory/'index.json').read_text());archive=directory/'objects.tar.gz'
 assert hashlib.sha256(archive.read_bytes()).hexdigest()==p['objectsArchiveSHA256']
 expected={record['object']:record for record in p['records'].values()}
 with tarfile.open(archive,'r:gz') as source:
  members=source.getmembers();assert len(members)==len(expected);assert {m.name for m in members}==set(expected)
  for member in members:
   assert member.isfile() and member.name.startswith('objects/')
   data=source.extractfile(member).read();record=expected[member.name]
   assert len(data)==record['bytes'] and hashlib.sha256(data).hexdigest()==record['sha256']
 return {'status':'PORTABLE_BYTES_VERIFIED_ONLY','recordCount':len(p['records']),'objects':len(expected),'scope':p['scope'],'hashOnlyExcluded':len(p['excludedHashOnly'])}
if __name__=='__main__':print(json.dumps(verify(sys.argv[1]),indent=2))
