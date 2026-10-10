"""Pure current source/whole expectation integrity, no backend processes."""
import gzip,hashlib,json
from pathlib import Path
from model import render
root=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
basis=json.loads((root/'SOURCE-BASIS.json').read_text())
for path,digest in basis['sourcePins'].items():assert sha(Path(path).read_bytes())==digest,path
assert sha((root/'model.py').read_bytes())==basis['modelSHA256']
entry=json.loads((root/'ORACLES.json').read_text())['a-normal']
raw=(root/'normal.stdout').read_bytes()
assert raw==render()==gzip.decompress((root/'normal.stdout.gz').read_bytes())
assert len(raw)==entry['bytes'] and sha(raw)==entry['sha256']
print('PASS: all current input hashes, full regeneration and raw/gzip equality')
