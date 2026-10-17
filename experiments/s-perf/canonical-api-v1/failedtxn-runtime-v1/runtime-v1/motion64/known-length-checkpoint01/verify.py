from pathlib import Path
import json,gzip,hashlib,sys
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
 if rec['category'] in ['ordinary64','control','diagnostic-full15']:
  cmd=r['commands'][-1];assert cmd['exit']==0 and cmd['failure'] is None;subject=raw(cmd['stdout']['path'],cmd['stdout']['sha256']);oracle=gzip.decompress(raw(p['oracle'],p['pins'][p['oracle']]));assert sha(oracle)==p['oracleSHA256'] and len(oracle)==p['oracleBytes'];assert subject==oracle;assert raw(cmd['stderr']['path'],cmd['stderr']['sha256'])==b'';checks+=1
 if rec['category']=='ordinary256-incomplete':assert r['status']=='INCOMPLETE' and r['commands'][-1]['failure']=='child deadline' and p['commands'][-1]['capSeconds']==5
 if rec['category']=='diagnostic-full15':assert p['diagnostic']['acceptanceCapSeconds']==5 and p['commands'][-1]['capSeconds']==15 and 'DIAGNOSTIC_ONLY' in rec['qualification']
assert len(d['current'])==4 and sum(x['category']=='ordinary256-incomplete' for x in d['history'])==2 and sum(x['category']=='diagnostic-full15' for x in d['diagnostics'])==2
print('portable plan/source/tool/resource/guard joins PASS',guards,'full independent comparisons',checks)
print('ordinary64/control4PASS; ordinary2562INCOMPLETE; fuller15diagnostic2FULL only; no5squalification')
