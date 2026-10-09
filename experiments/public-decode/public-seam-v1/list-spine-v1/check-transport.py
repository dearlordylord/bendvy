"""Complete list-spine bijection and typed loss/order/nominal controls; no backend."""
import copy,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec)
 exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__);return module
transport=load('actual_spine_transport',HERE.parents[1]/'adoption-v1/qualification-v1/spine-report-v1/transport.py')
helper=load('actual_spine_mapping',HERE/'transport-inventory.py')
results=[]
for group,count in [('generic',15),('deferred',8)]:
 role=group+'-spine';entry=HERE/(role+'.bend');model=ROOT/'experiments/public-decode/public-seam-v1/oracle-v1'/(group+'-assembly-v1')/'expected.json';expected=json.loads(model.read_text())
 packed=helper.pack(expected,role);assert len(packed)==count and helper.unpack(packed,role)==expected
 raw=transport.render(expected,entry,True,role);assert transport.parse(raw,entry,True,role)==expected
 rejects=[]
 for label,mutate in [('missing-report',lambda x:x.pop()),('duplicate-label',lambda x:x[1].__setitem__('label',x[0]['label'])),('reordered-report',lambda x:x.reverse()),('extra-report',lambda x:x.append(x[0])),('unknown-field',lambda x:x[0].__setitem__('ignored',0))]:
  value=copy.deepcopy(packed);mutate(value)
  try:helper.unpack(value,role)
  except (AssertionError,KeyError):rejects.append(label)
  else:raise AssertionError(label)
 changed=raw.replace(b'../generic-assembly-v1/observation.PayloadView',b'../generic-assembly-v1/first-observation.PayloadView',1)
 assert changed!=raw
 try:transport.parse(changed,entry,True,role)
 except (AssertionError,KeyError,ValueError):rejects.append('cross-schema-nominal')
 else:raise AssertionError('cross-schema-nominal')
 # Semantically corrupt physical owners/stamps/local; strict complete parsing
 # preserves the change so the unchanged whole independent oracle must reject.
 value=copy.deepcopy(expected)
 snapshot=value['second']['failure']['after'] if group=='generic' else value['failure']['committed']
 snapshot['column']['slots'][0]={'$':'Some','value':{'$':'PayloadView','raw':{'$':'Number','value':987},'words':[987],'flags':[False]}}
 changed=transport.parse(transport.render(value,entry,True,role),entry,True,role)
 assert changed==value and changed!=expected
 rejects.append('complete-oracle-detects-physical-owner-corruption')
 results.append({'group':group,'reportCount':count,'unchangedModelSha256':hashlib.sha256(model.read_bytes()).hexdigest(),'rawBytes':len(raw),'rawSha256':hashlib.sha256(raw).hexdigest(),'rejections':rejects})
print(json.dumps({'status':'PASS','results':results,'backendChildren':0}))
