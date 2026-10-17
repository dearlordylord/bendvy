from pathlib import Path
import json,gzip,hashlib,sys

def main():
    L=Path(sys.argv[1]);d=json.loads((L/'RETENTION.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();idx={(r['actualPath'],r['sha256']):r for r in d['members']}
    for r in d['members']:
     if 'object' in r:
      p=L/r['object'];b=p.read_bytes();assert sha(b)==r['objectSHA256'];raw=gzip.decompress(b);assert len(raw)==r['bytes'] and sha(raw)==r['sha256']
     else:assert r.get('hashOnly') and r['bytes']>0
    print('objects/members PASS',len(d['members']),d['objects'],flush=True)
    def raw(path,h):
     r=idx[(path,h)];assert 'object' in r,(path,'requiredsubjectnotportable');return gzip.decompress((L/r['object']).read_bytes())
    def j(path,h):return json.loads(raw(path,h))
    checks=0;guards=0
    for rec in d['current']+d['history']+d['diagnostics']:
     p=j(rec['planPath'],rec['planSHA256'])
     for path,h in p['pins'].items():assert (path,h) in idx,(path,h)
     for root,files in p['resourceRoots'].items():
      for name,h in files.items():assert (str(Path(root)/name),h) in idx
     if 'receiptSHA256' not in rec:assert rec['status']=='UNEXECUTED';continue
     rp=str(Path(rec['actualDirectory'])/'receipt.json');r=j(rp,rec['receiptSHA256']);assert r['planSHA256']==rec['planSHA256'] and r['status']==rec['status']
     for g in r.get('guards',[]):
      q=j(g['path'],g['sha256']);assert q['unchanged'];guards+=1
      for path,h in q['actualPins'].items():assert (path,h) in idx,(path,h)
     for c in r['commands']:
      for key in ['stdout','stderr']:
       q=c[key];assert (q['path'],q['sha256']) in idx
     if rec['category'] in ['ordinary64','ordinary256','control','diagnostic-full15','diagnostic-heap']:
      cmd=r['commands'][0] if rec['category']=='diagnostic-heap' else r['commands'][-1];assert cmd['exit']==0 and cmd['failure'] is None;subject=raw(cmd['stdout']['path'],cmd['stdout']['sha256']);oracle=gzip.decompress(raw(p['oracle'],p['pins'][p['oracle']]));assert sha(oracle)==p['oracleSHA256'] and len(oracle)==p['oracleBytes'];assert subject==oracle;assert raw(cmd['stderr']['path'],cmd['stderr']['sha256'])==b'';checks+=1
     if rec['category']=='ordinary256-incomplete':assert r['status']=='INCOMPLETE' and r['commands'][-1]['failure']=='child deadline' and p['commands'][-1]['capSeconds']==5
     if rec['category']=='diagnostic-full15':assert p['diagnostic']['acceptanceCapSeconds']==5 and p['commands'][-1]['capSeconds']==15 and 'DIAGNOSTIC_ONLY' in rec['qualification']
    assert len(d['current'])==7
    assert sum(x['category']=='ordinary64' for x in d['current'])==2
    assert sum(x['category']=='control' for x in d['current'])==4
    assert sum(x['category']=='ordinary256' for x in d['current'])==1
    assert sum(x['category']=='ordinary256-incomplete' for x in d['history'])==1
    assert sum(x['category']=='diagnostic-full15' for x in d['diagnostics'])==2
    assert sum(x['category']=='diagnostic-heap' for x in d['diagnostics'])==2
    mutants=[x for x in d['history'] if x['category']=='semantic-mutant'];assert len(mutants)==2
    for rec in mutants:
     p=j(rec['planPath'],rec['planSHA256']);r=j(str(Path(rec['actualDirectory'])/'receipt.json'),rec['receiptSHA256'])
     assert r['status']=='INCOMPLETE' and not r.get('guardFailures') and all(c['exit']==0 and c['failure'] is None for c in r['commands'])
     c=r['commands'][-1];subject=raw(c['stdout']['path'],c['stdout']['sha256']);oracle=gzip.decompress(raw(p['oracle'],p['pins'][p['oracle']]));assert subject!=oracle;assert raw(c['stderr']['path'],c['stderr']['sha256'])==b''
     if len(subject)==229:
      assert len(oracle)==229 and [i for i,(a,b) in enumerate(zip(subject,oracle)) if a!=b]==[24]
      assert subject[24:25]==b'0' and oracle[24:25]==b'o' and subject.splitlines()[1]==oracle.splitlines()[1]
     else:assert len(subject)==33891616 and len(oracle)==38459780
    base='/tmp/bendvy21-query-lazy-authority-current03/'
    def member_json(name):
     hits=[r for r in d['members'] if r['actualPath']==name and not r.get('historicalGitRecovered')];assert len(hits)==1;return j(name,hits[0]['sha256'])
    pre=member_json(base+'SOURCE-PRE.json');post=member_json(base+'SOURCE-POST.json');assert pre==post and len(pre)==130
    for path,h in pre.items():assert (path,h) in idx
    results=member_json(base+'RESULTS.json');assert len(results['rows'])==8
    intended=member_json('/workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/canonical-observable-api-v1/source-final-01/intended-diagnostics.json')
    for row in results['rows']:
     streams=[]
     for key in ['stdout','stderr']:
      v=row[key];b=raw(base+v['path'],v['sha256']);assert len(b)==v['bytes'];streams.append(b)
     assert row['compilerCapSeconds']==5
     if row['name']=='positive':assert row['exit']==0 and b'ALL PROOFS CHECK' in streams[0]
     else:
      assert row['exit']==1 and row['expectedTokens']==intended[row['name'].removeprefix('negative-')]
      assert all(token.encode() in streams[0]+streams[1] for token in row['expectedTokens'])
    print('portable plan/source/tool/resource/guard joins PASS',guards,'full independent comparisons',checks,flush=True)
    print('Selected ordinary64x2, controlsx4 and Native256 PASS; JS256 INCOMPLETE. Type-before/after CPU+heap diagnostics full; reached mutantsx2 and authorityx8 checked. No final numeric acceptance.',flush=True)

if __name__ == "__main__":
    main()
