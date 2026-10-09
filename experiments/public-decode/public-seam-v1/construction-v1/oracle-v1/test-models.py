"""No runtime: complete source-model structural/detachment controls."""
import copy,importlib.util,json
from pathlib import Path
H=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('independent',H/'expected.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
for name,fn in [('initial',m.initial),('custom',m.custom),('request',m.request),('raw-resource',m.raw_resource),('materialization',m.materialization)]:
 value=fn();assert value==json.loads((H/(name+'-expected.json')).read_text())
 other=copy.deepcopy(value['second']);value['first'].clear();assert value['second']==other,'nominal schema models alias'
assert m.initial()['first']['constructed']['owner']['raw']==m.CANON
assert m.initial()['first']['constructed']['recovered']['raw']==m.VALID
mats=m.materialization()['first'];assert mats['spawn']['barrier']['column']['slots'][1]['value']['original']==m.VALID
assert mats['failure']['instance']['recoveries'][0]['packets'][0]['owner']['value']['words']==[71,72]
assert mats['lateMissing']['barrier']['mail']['errors']==[m.c('MissingEntity')]
assert m.raw_resource()['first']['abort']['after']['resource']==m.owner(m.number(100))
print('complete models, two-schema detachment, original-owner and rollback controls PASS; no backend')
