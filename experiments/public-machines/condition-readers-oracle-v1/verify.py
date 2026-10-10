"""Pure current-source/hash and complete independent model checks; no child."""
import gzip,hashlib,json
from pathlib import Path
import model
p=Path(__file__).resolve().parent
basis=json.loads((p/'SOURCE-BASIS.json').read_text())
for name,h in basis['sourcePins'].items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==h,name
assert hashlib.sha256((p/'model.py').read_bytes()).hexdigest()==basis['modelSHA256']
expected=json.loads((p/'ORACLES.json').read_text())['normal']
b=model.render()
assert b==(p/'normal.stdout').read_bytes()==gzip.decompress(Path(expected['stdout']).read_bytes())
assert len(b)==expected['bytes'] and hashlib.sha256(b).hexdigest()==expected['sha256']
print('PASS',len(b),len(basis['sourcePins']))
