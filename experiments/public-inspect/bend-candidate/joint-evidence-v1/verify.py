"""Verify every retained byte and original-path mapping without extracting files."""
from pathlib import Path
import hashlib,json,re,tarfile
HERE=Path(__file__).resolve().parent
index=json.loads((HERE/'index.json').read_text());archive=HERE/'objects.tar.gz'
assert hashlib.sha256(archive.read_bytes()).hexdigest()==index['archiveSHA256']
found={}
with tarfile.open(archive) as tar:
 for member in tar:
  assert member.isfile() and re.fullmatch(r'objects/[0-9a-f]{64}',member.name)
  digest=member.name.split('/')[-1];assert digest not in found
  data=tar.extractfile(member).read();assert hashlib.sha256(data).hexdigest()==digest;found[digest]=len(data)
assert found==index['objects']
for run in index['runs']:
 assert set(run['entries'].values())<=set(found)
 for path,digest in run['rawLogs'].items():assert run['entries'][path]==digest
 for path,digest in run['generated'].items():assert run['entries'][path]==digest
print(f"PASS {len(found)} exact objects, {len(index['runs'])} receipts, {sum(len(r['rawLogs']) for r in index['runs'])} raw streams")
