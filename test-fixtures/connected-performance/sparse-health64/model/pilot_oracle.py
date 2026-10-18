"""Independent Sparse B1 complete correspondence; never reads subject output."""
import copy,gzip,hashlib,json
from pathlib import Path
from health_model import report
from health_shared import rows
MASK=2**32-1
natural=lambda n:[*map(ord,str(n)),0]
sized=lambda xs,f:natural(len(xs))+[v for x in xs for v in f(x)]
def row(r):return natural(r['rawId'])+[2,*r['main']['levels'],r['main']['reserve'],r['main']['class']]+([1] if r['aux'] is None else [2,*r['aux']['layers'],r['aux']['grade']])+([1] if r['flag'] is None else [2,r['flag']['group']])
def score(rs,namespace=1):
 def value(r):return namespace+r['rawId']+sum(r['main']['levels'])+r['main']['reserve']+r['main']['class']+(0 if r['aux'] is None else 1+sum(r['aux']['layers'])+r['aux']['grade'])+(0 if r['flag'] is None else 1+r['flag']['group'])
 return (sum(i*value(r) for i,r in enumerate(rs,1))+len(rs)+1)&MASK

def expected(count=64,iterations=64):
 audits=[];cumulative=0
 for t in range(iterations):
  full=rows(t+1,count);sets=[full,[r for r in full if r['aux'] is not None],[r for r in full if r['aux'] is None]]
  scans=[{'rows':copy.deepcopy(full),'included':copy.deepcopy(rs),'score':score(rs)} for rs in sets]
  weighted=sum(k*s['score'] for k,s in zip([1,3,5],scans))&MASK
  values=[4*j+6+t for j in range(0,count,8)];readsum=sum(values)&MASK;cumulative=(cumulative+readsum+weighted)&MASK
  audits.append({'values':values,'readsum':readsum,'updated':len(values),'scans':dict(zip(['all','present','absent'],scans),weighted=weighted),'cumulative':cumulative})
 final={'rows':rows(iterations,count),'ledger':{'totals':[len(rows(0,count))*iterations,101,102,103],'epoch':4}}
 def scan(s):return sized(s['rows'],row)+sized(s['included'],row)+[s['score']]
 def audit(a):return sized(a['values'],lambda x:[x])+[a['readsum']]+natural(a['updated'])+sum((scan(a['scans'][n]) for n in ['all','present','absent']),[])+[a['scans']['weighted'],a['cumulative']]
 cells=sized(final['rows'],row)+[*final['ledger']['totals'],4]+sized(audits,audit)+sized(audits,lambda _:[0])+[cumulative]
 fold=0
 for v in cells:fold=(fold*33+v)&MASK
 return cells,fold,final,audits,cumulative
if __name__=='__main__':
 here=Path(__file__).parent;cells,fold,final,audits,cumulative=expected();sha=lambda x:hashlib.sha256(x).hexdigest();compact=lambda x:json.dumps(x,separators=(',',':'))
 ns1,world=report();assert ns1==gzip.decompress((here/'canonical-ns1.stdout.gz').read_bytes());assert cumulative==world.cumulative
 full=dict(final=final,audits=audits,statuses=[{'ok':True} for _ in audits],worksum=cumulative,ids=list(range(1,65)),finalSha256=sha(compact(final).encode()),oracleSha256=sha(compact(final).encode()),fullFieldsCompared=8,samples={'first':final['rows'][0],'last':final['rows'][-1]})
 bend=[];ts=[]
 for label,ns in [('WARMUP',1),('SAMPLE',2)]:
  raw,physical=report(namespace=ns);assert b'UNSUPPORTED'not in raw and raw.count(b'Column{values=')==15
  for phase in [b'seedPending=',b'seedApplied=',b'registered=',b'final=',b'afterLogicalRead=']:assert raw.split(phase,1)[1].split(b'\n',1)[0].count(b'Column{values=')==3
  assert [r['main']['levels']for r in final['rows']]==[physical.columns[0].values[i-1]for i in physical.row_entities()]
  (here/f'canonical-ns{ns}.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
  bend.append(f'{label}\nFORCE:{fold}\nTUPLE:{json.dumps(cells)}\nCANONICAL-BEGIN\n'.encode()+raw+b'CANONICAL-END\n')
  ts.append(f'{label}\nFORCE:{fold}\nTUPLE:{compact(cells)}\nFULL:{compact(full)}\n'.encode())
 fixture={'tuple':cells,'fold':fold,'final':final,'audits':audits,'cumulative':cumulative};assert (compact(fixture)+'\n').encode()==(here/'expected-common.json').read_bytes()
 basis={'scope':'SparseHealth64 B1 method feasibility only; asymmetric original query strategies retained','tupleValues':len(cells),'fold':fold,'namespaceCorrespondence':'Delta=sum rank*(actualIncludedNamespace-1) mod2^32; logicalScore=rawScore-Delta, inverse rawScore=logicalScore+Delta. Weighted delta weights1/3/5. Each cumulative subtracts prior weighted deltas. Raw namespaces/scores retained canonical.','snapshotCorrespondence':'TS original optional full snapshot reused for common Scan.rows; original present/absent actual filtered results retained. No intervening writes; Bend still3fresh fullqueries+postfilters. Not identical internal query work.','oracles':{}}
 for role,chunks in [('bend',bend),('ts',ts)]:
  raw=b''.join(chunks);p=here/f'{role}-expected.stdout.gz'
  if role=='ts':assert raw==gzip.decompress(p.read_bytes())
  else:p.write_bytes(gzip.compress(raw,mtime=0))
  basis['oracles'][role]={'path':str(p.resolve()),'bytes':len(raw),'sha256':sha(raw),'gzipSHA256':sha(p.read_bytes())}
 (here/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(basis,indent=2)+'\n');print(json.dumps({k:basis[k] for k in ['tupleValues','fold','oracles']}))
