"""Prove source-only label amendment changes exactly128goldleaf fields."""
from pathlib import Path
import json,hashlib
P=Path(__file__).parent;sha=lambda b:hashlib.sha256(b).hexdigest()
a=json.loads((P/'SOURCE-AMENDMENT.json').read_text());oldraw=(P/'pre-amendment01/expected.boundaries.json').read_bytes();newraw=(P/'expected.boundaries.json').read_bytes()
assert(len(oldraw),sha(oldraw))==(a['priorGold']['bytes'],a['priorGold']['sha256'])
old=json.loads(oldraw);new=json.loads(newraw);changes=[]
def compare(x,y,path):
 assert type(x)is type(y)
 if isinstance(x,dict):
  assert list(x)==list(y)
  for k in x:compare(x[k],y[k],path+[k])
 elif isinstance(x,list):
  assert len(x)==len(y)
  for i,(l,r)in enumerate(zip(x,y)):compare(l,r,path+[i])
 elif x!=y:changes.append({'path':path,'old':x,'new':y})
compare(old,new,[])
expected=[[3*(i+1),'tx','boundaries',j,'site']for i in range(64)for j in range(2)]
assert [c['path']for c in changes]==expected and len(changes)==128
for c in changes:assert a['replacements'][c['old']]==c['new']
for evidence in a['sourceEvidence']:
 text=(P/evidence['path']).read_text()
 if 'calls'in evidence:
  for token in evidence['calls']:assert token+'('in text
 else:assert '"'+evidence['site']+'"'in text
r=json.loads((P/'GENERATION-RECEIPT.json').read_text());assert r['amendmentSHA256']==sha((P/'SOURCE-AMENDMENT.json').read_bytes())
checks={'status':'PASS','classification':a['classification'],'priorGoldSHA256':sha(oldraw),'successorGoldBytes':len(newraw),'successorGoldSHA256':sha(newraw),'changedLeafFields':len(changes),'onlyDisposeSiteLabels':True,'allOther277SampleFieldsUnchanged':True,'sourceAmendmentSHA256':sha((P/'SOURCE-AMENDMENT.json').read_bytes()),'changes':changes}
(P/'AMENDMENT-CHECKS.json').write_text(json.dumps(checks,indent=2)+'\n');print(json.dumps({k:v for k,v in checks.items()if k!='changes'},sort_keys=True))
