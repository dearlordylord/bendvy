"""Offline source/model reproduction only; never reads a backend output."""
from pathlib import Path
import gzip,hashlib,json,sys,types
ROOT=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
for label in ['app-a','app-b']:
    b=ROOT/label;f=json.loads((b/'SOURCE-FREEZE.json').read_text());basis=json.loads((b/'SOURCE-BASIS.json').read_text())
    for p,h in {**f['sourcePins'],**f['toolPins'],**basis['modelPins']}.items():assert sha(p)==h,p
    assert sha(b/'SOURCE-FREEZE.json')==basis['freeze']['sha256']
    assert sha(b/'SOURCE-CHECK.json')==basis['sourceCheck']['sha256']
    raw=(b/'expected.stdout').read_bytes();assert raw==gzip.decompress((b/'expected.stdout.gz').read_bytes())
    assert len(raw)==basis['expected']['bytes'] and hashlib.sha256(raw).hexdigest()==basis['expected']['sha256']
    prior_base=sys.modules.get('base_model')
    if label=='app-a':
        current_base=types.ModuleType('base_model');sys.modules['base_model']=current_base
        exec((b/'base_model.py').read_bytes(),current_base.__dict__)
    current={'__name__':'retained_current_model'};exec((b/'model.py').read_bytes(),current)
    assert current['render']()==raw
    if label=='app-a':current['selftest']()
    if prior_base is None:sys.modules.pop('base_model',None)
    else:sys.modules['base_model']=prior_base
    oldcode=gzip.decompress((b/'historical-model.py.gz').read_bytes()).decode()
    previous=sys.modules.get('base_model')
    if label=='app-a':
        mod=types.ModuleType('base_model');sys.modules['base_model']=mod
        exec(gzip.decompress((b/'historical-base_model.py.gz').read_bytes()),mod.__dict__)
    ns={'__name__':'retained_independent_model'};exec(oldcode,ns)
    assert ns['render']()==gzip.decompress((b/'historical-expected.stdout.gz').read_bytes())
    if previous is None:sys.modules.pop('base_model',None)
    else:sys.modules['base_model']=previous
    if label=='app-a':
        assert raw.count(b'|live=leaf:False|')==1
        assert raw.count(b'|live=node(node(leaf:False,leaf:False),node(leaf:False,leaf:True))|')==1
        assert raw.count(b'|live=node(node(leaf:False,leaf:True),node(leaf:False,leaf:False))|')==21
    else:
        current={'__name__':'current_independent_model'};exec((b/'model.py').read_text(),current);s=current['State']();assert '|live=leaf:False|' in s.world()
        s.reserved=True
        assert '|live=node(node(node(leaf:False,leaf:False),node(leaf:False,leaf:False)),node(node(leaf:False,leaf:True),node(leaf:True,leaf:True)))|' in s.world()
        s.flushed=True
        assert '|live=node(node(node(leaf:False,leaf:True),node(leaf:True,leaf:True)),node(node(leaf:False,leaf:False),node(leaf:False,leaf:False)))|' in s.world()
        assert 'inverses=3' in s.world()
    print(label,len(raw),hashlib.sha256(raw).hexdigest(),'PASS')
