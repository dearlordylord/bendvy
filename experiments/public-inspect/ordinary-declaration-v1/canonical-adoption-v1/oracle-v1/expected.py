"""Independent complete source-derived canonical leaf expectations; no runtime inputs."""
from pathlib import Path
import copy, gzip, hashlib, json, os
SOURCE_ROOT=Path('/workspace/formal-proofs/bendvy-worktrees/integration-ordinary-inspector-public')
HOME=SOURCE_ROOT/'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1'
OUT=Path(__file__).resolve().parent

def c(tag,**fields):return {'$':tag,**fields}
def leaf(value):return c('ALeaf',value=value)
def delivery(omit=False):
    # Factory starts at namespace 1. Reservation grows live to two leaves;
    # activation writes index 1, while the one-based Column writes index 0.
    stamp=c('Stamp',added=1,changed=1)
    column=c('Column',values=leaf(c('Some',value=c('Payload',values=leaf(42)))),stamps=[c('Entry',id=1,stamp=stamp)])
    world=c('World',namespace=1,nextId=2,highWater=1,live=c('ANode',left=leaf(False),right=leaf(True)),capacity=2,depth={'nat':1},store=column,resource=leaf(17),events=[],pending=[],registrations=[],nextSystemId=1,clock=1)
    return c('Delivered',factory=c('Factory',nextNamespace=2),owner=c('Frame',world=world,cursor=0),rows=[c('Row',entity=c('Handle',namespace=1,id=1),value=c('Value',access=c('Found',value=42),added=True,changed=True))],clauses=[] if omit else [c('Clause',name='Position',mode=c('Read'))],access=c('Found',value=42),previous=c('None'),undo=[],commands=[],events=[])
def model(omit=False):return c('Report',first=delivery(omit),second=delivery(omit))
FILES={'World':'world','Factory':'world','Handle':'world','Column':'column','Entry':'lifecycle','Stamp':'lifecycle','Frame':'inspector','Row':'inspector-query-projection','Value':'inspector','Found':'component','Clause':'ordinary-query-declaration','Read':'ordinary-query-declaration'}
def render(value,mutant=False):
    if type(value) is bool:return 'True{}' if value else 'False{}'
    if type(value) is int:return str(value)
    if type(value) is str:return json.dumps(value,ensure_ascii=True)
    if type(value) is list:return '['+', '.join(render(x,mutant) for x in value)+']'
    if set(value)=={'nat'}:return str(value['nat'])+'n'
    tag=value['$']
    if tag in ('Some','None','ALeaf','ANode'):name=tag
    elif tag=='Report':name=tag
    else:
        path=SOURCE_ROOT/'src/ecs'/ (FILES[tag]+'.bend') if tag in FILES else HOME.parent/('mutant-caller.bend' if mutant else 'caller.bend')
        name=os.path.relpath(path.with_suffix(''),HOME)+'.'+tag
    return name+'{'+', '.join(render(x,mutant) for k,x in value.items() if k!='$')+'}'
def write():
    basis=json.loads((HOME/'SOURCE.json').read_text())
    for inventory in basis['inventories'].values():
        for path,digest in inventory.items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==digest
    for name,omit,namespace in [('normal',False,False),('mutant',True,True),('mutant-namespace-normal',False,True)]:
        value=model(omit)
        (OUT/(name+'-expected.json')).write_text(json.dumps(value,indent=2)+'\n')
        raw=(render(value,namespace)+'\n').encode()
        (OUT/(name+'-expected.stdout')).write_bytes(raw)
        (OUT/(name+'-expected.stdout.gz')).write_bytes(gzip.compress(raw,mtime=0))
    (OUT/'SOURCE-BASIS.json').write_text(json.dumps({'sourceCommit':'f5d4165b','coreCommit':'f78d8aa3','inventories':basis['inventories'],'printerSource':{str(Path('/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts')):hashlib.sha256(Path('/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts').read_bytes()).hexdigest()},'derivation':'expected.py; no runtime or source-check output inputs'},indent=2)+'\n')
if __name__=='__main__':write()
