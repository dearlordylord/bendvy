"""No compiler/runtime child: complete preparation bindings and inherited guard checks."""
from pathlib import Path
import hashlib,json,ast
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
index=json.loads((HERE/'batch-index.json').read_text())
assert len(index['plans'])==13 and len(index['equalityPairs'])==6
for row in index['plans']:
 p=Path(row['plan']);assert sha(p)==row['sha256'];plan=json.loads(p.read_text())
 assert all(sha(p)==h for p,h in plan['pins'].items())
 assert len(plan['commands'])==1 and plan['commands'][0]['label']=='emit' and plan['commands'][0]['capSeconds']==30
 assert not Path(plan['generated']).exists() and not Path(plan['native']).exists()
 assert not (p.parent/'receipt.json').exists()
 assert plan['commands'][0]['argv'][1:3]==['-c','5']
 assert '--threads' not in plan['commands'][0]['argv']
 assert {str(p.relative_to(plan['stage'])):sha(p) for p in Path(plan['stage']).rglob('*.bend')}==plan['sourceInventory']
base=Path('/tmp/bendvy-layout-equality-v1-batch01/baseline');candidate=base.parent/'candidate'
for p in base.rglob('*'):
 if p.is_file() and p.name!='comp.ts':assert p.read_bytes()==(candidate/p.relative_to(base)).read_bytes()
original=(base/'comp.ts').read_text();new=(candidate/'comp.ts').read_text()
restored=new.replace('const LAY_IDS = new Map<Lay, number>();\n\nlet LAY_TEXT = new WeakMap<Lay, string>();','const LAY_IDS = new Map<Lay, number>();')
a=restored.index('function lay_text(');b=restored.index('\nfunction lay_c(',a)
restored=restored[:a]+'function lay_eq(a: Lay, b: Lay): boolean {\n  return a === b || JSON.stringify(a) === JSON.stringify(b);\n}\n'+restored[b:]
restored=restored.replace('function file_book(book: Bend.Book, roots: Name[], js: boolean): File {\n  LAY_TEXT = new WeakMap<Lay, string>();','function file_book(book: Bend.Book, roots: Name[], js: boolean): File {')
assert restored==original
collector=(HERE/'development.py').read_text();ast.parse(collector)
assert 'exec(compile(source' in collector and 'exec_module' not in collector
assert collector.index('actual interpreter differs before helpers')<collector.index("runner = load('task_runner'")
assert collector.index("record['commands'].append(row)")<collector.index("target=Path(row[key]['path']);write_raw")
assert "row[key]['unpublishedHex']=result[key].hex()" in collector
assert "record['qualifiesSemanticRuntime'] = False" in collector
print('13 exact plans/assets/three-delta source/interpreter/source-load/publication controls PASS; no child')
