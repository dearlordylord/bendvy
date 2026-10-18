"""Finite source-model checks, not compiling mutants or universal proofs."""
import json,copy
from pilot_oracle import expected,score,row,MASK
from health_model import report
from health_shared import rows
cells,fold,final,audits,cumulative=expected();cases=[];running=0
for t,a in enumerate(audits):
 delta=[]
 for n in ['all','present','absent']:
  s=a['scans'][n];rs=s['included'];d=sum(i*(2-1) for i,_ in enumerate(rs,1))&MASK
  raw=score(rs,2);logical=(raw-d)&MASK
  assert logical==s['score'] and (logical+d)&MASK==raw
  assert (raw-(d+1))&MASK!=logical
  delta.append(d)
 weighted=sum(w*d for w,d in zip([1,3,5],delta))&MASK;running=(running+weighted)&MASK
 raw_cumulative=(a['cumulative']+running)&MASK
 assert (raw_cumulative-running)&MASK==a['cumulative']
 assert (raw_cumulative-(running+1))&MASK!=a['cumulative']
 present=a['scans']['present']['included'];absent=a['scans']['absent']['included'];full=a['scans']['all']['rows']
 assert sorted(r['rawId']for r in present+absent)==[r['rawId']for r in full]
 assert all(r['aux']is not None for r in present)and all(r['aux']is None for r in absent)
 assert score(list(reversed(full)))!=score(full)
 assert weighted!=sum(w*d for w,d in zip([1,5,3],delta))
_,sample=report(namespace=2);assert sample.cumulative==(cumulative+running)&MASK
for i in [0,5,len(cells)//2,len(cells)-1]:
 changed=cells.copy();changed[i]^=1;assert changed!=cells # full-tuple rejection independent of unchanged fold
health=[]
for key in ['reserve','class']:
 changed=copy.deepcopy(final['rows'][0]);changed['main'][key]+=1;assert row(changed)!=row(final['rows'][0]);health.append(key)
for owner,field,index in [('main','levels',3),('aux','layers',2)]:
 changed=copy.deepcopy(final['rows'][0]);changed[owner][field][index]+=1;assert row(changed)!=row(final['rows'][0]);health.append(field+'-nonfirst')
changed=copy.deepcopy(final['rows'][0]);changed['aux']['grade']+=1;assert row(changed)!=row(final['rows'][0]);health.append('grade')
print(json.dumps({'status':'PASS','finiteAudits':64,'healthFields':health,'controls':['wrongnamespace/delta','inverse','wrongweight','cumulativedelta','orderedrows','partition','fulltuple-not-fold'],'scope':'Model-only finite sensitivity, no subject execution'}))
