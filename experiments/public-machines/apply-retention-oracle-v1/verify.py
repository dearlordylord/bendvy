"""Pure packet integrity; no compiler/backend children."""
import gzip,hashlib,json
from pathlib import Path
from model import render
root=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
basis=json.loads((root/'SOURCE-BASIS.json').read_text())
for path,digest in basis['pins'].items(): assert sha(Path(path).read_bytes())==digest,path
assert sha((root/'model.py').read_bytes())==basis['modelSHA256']
for key,entry in json.loads((root/'ORACLES.json').read_text()).items():
    raw=(root/(key+'.stdout')).read_bytes()
    assert render(key=='drop')==raw==gzip.decompress((root/(key+'.stdout.gz')).read_bytes())
    assert len(raw)==entry['bytes'] and sha(raw)==entry['sha256']
assert render(False)!=render(True)
print('PASS: current pins, complete regeneration, raw/gzip joins and distinct normal/drop models')
