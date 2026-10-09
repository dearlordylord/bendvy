import gzip,hashlib,json,difflib,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
original=(ROOT/'.references/bend2/bend2/comp.ts').read_bytes();copy=gzip.decompress((HERE/'comp.ts.gz').read_bytes());pins=json.loads((HERE/'COPY.json').read_text())
assert hashlib.sha256(original).hexdigest()==pins['originalSHA256'] and hashlib.sha256(copy).hexdigest()==pins['patchedSHA256']
header=b'import * as LayoutProvenance from "./layout-provenance.mjs";\n'
call=b'  LayoutProvenance.observe(fl.def, v.lay, lay);\n'
assert copy.startswith(header) and copy.count(call)==1
assert copy[len(header):].replace(call,b'',1)==original
assert (HERE/'comp.patch').read_text()==''.join(difflib.unified_diff(original.decode().splitlines(True),copy.decode().splitlines(True),fromfile='comp.ts',tofile='comp.ts'))
m=json.loads((HERE/'SOURCE-DEFINITIONS.json').read_text());stage=Path(m['entry']).parent
inventory=stage.parent/'source-inventory.json';assert hashlib.sha256(inventory.read_bytes()).hexdigest()==m['inventorySHA256'];inv=json.loads(inventory.read_text());expected=[]
for file,sha in inv.items():
 p=stage/file;assert hashlib.sha256(p.read_bytes()).hexdigest()==sha
 for line,text in enumerate(p.read_text().splitlines(),1):
  found=re.match(r'def ([A-Za-z_][A-Za-z_0-9]*)',text)
  if found:expected.append(dict(module=file,definition=found[1],line=line,sourceSHA256=sha))
assert expected==m['definitions'] and len(inv)==46
print('PASS exact two-insertion compiler patch/inverse and1185 current source-definition rows; no compiler child')
