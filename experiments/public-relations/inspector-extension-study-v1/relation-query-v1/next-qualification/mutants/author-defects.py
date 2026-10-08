"""Independent source-derived defect expectations authored before mutant outputs.
No Bend or TypeScript implementation imports. The reviewed normal source model
is the authority; mutation rules correspond exactly to the declared source seams.
"""
import copy,json,hashlib
from pathlib import Path
H=Path(__file__).resolve().parent;J=H.parents[1]
assert hashlib.sha256((J/'author-oracle-v2.py').read_bytes()).hexdigest()=='693ed45e0a29e43bb2628d8f54b4a8bf2166e2dd4870cafcb01a77b9f2d14ccc'
model=(J/'author-oracle-v2.py').read_text()
ns={'__name__':'independent_defect_model','__file__':'author-oracle-v2.py'}
exec(compile(model,'author-oracle-v2.py','exec'),ns)
normal={'schemas':[ns['schema']('Workshop',0),ns['schema']('Garden',100)],'scope':'finite relation Inspector development fixture; no full55 qualification'}
assert normal==json.loads((J/'expected-relations-v2.json').read_text())
variants={}
# Negating the single outgoing Present filter reverses only that mode predicate;
# component required membership, projection keys and other modes stay unchanged.
changed=model.replace("'with-out':target is not None", "'with-out':target is None")
assert changed!=model
vns={'__name__':'independent_defect_model','__file__':'author-oracle-v2.py'}
exec(compile(changed,'source-derived-filter-model','exec'),vns)
variants['outgoing-filter-negated']={'schemas':[vns['schema']('Workshop',0),vns['schema']('Garden',100)],'scope':normal['scope']}
# Reverse the emitted incoming Sources list wherever that relation cell is read.
value=json.loads(json.dumps(normal))  # detach shared Python row aliases into the serialized DTO tree
def reverse_cells(x):
 if isinstance(x,dict):
  for key,v in x.items():
   if key=='sources':assert isinstance(v,list);v.reverse()
   else:reverse_cells(v)
 elif isinstance(x,list):
  for v in x:reverse_cells(v)
reverse_cells(value)
for schema in value['schemas']:
 schema['retainedInitialInverse'].reverse();schema['currentInverse2'].reverse();schema['currentInverse4'].reverse()
variants['incoming-order-reversed']=value
# Family presence still performs W.valid, returning MissingEntity access.
# Optional/Required membership rejects that access (compose.selected_value).
# Skipping the OUTER public valid gate therefore yields QueryMismatch, not a row.
value=json.loads(json.dumps(normal))  # detach shared Python row aliases into the serialized DTO tree
for schema in value['schemas']:
 for phase in schema['phases']:
  for query in phase['queries']:
   for lookup in query['get'][-3:]:
    assert lookup['error']=='MissingEntity';lookup['error']='QueryMismatch'
variants['world-valid-omitted']=value
def differences(a,b,p=''):
 if type(a)!=type(b):return [{'path':p,'normal':a,'mutant':b}]
 if isinstance(a,dict):
  result=[]
  for key in sorted(a.keys()|b.keys()):
   if key not in a or key not in b:result.append({'path':p+'/'+key,'normal':a.get(key),'mutant':b.get(key)})
   else:result+=differences(a[key],b[key],p+'/'+key)
  return result
 if isinstance(a,list):
  if len(a)!=len(b):return [{'path':p,'normal':a,'mutant':b}]
  return [d for i,(x,y) in enumerate(zip(a,b)) for d in differences(x,y,p+'/'+str(i))]
 return [] if a==b else [{'path':p,'normal':a,'mutant':b}]
if __name__=='__main__':
 for name,value in variants.items():
  path=H/name/'expected-defect.json';assert not path.exists();path.write_text(json.dumps(value,indent=2)+'\n')
  witnesses=differences(normal,value);assert witnesses
  (H/name/'expected-witnesses.json').write_text(json.dumps(witnesses,indent=2)+'\n')
