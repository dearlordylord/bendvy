from pathlib import Path
import json,gzip,hashlib,re
h=Path(__file__).resolve().parent;m=json.loads((h/'FILES.json').read_bytes());f={};ids={}
for row in m['members']:
 raw=gzip.decompress((h/row['object']).read_bytes());assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256'];assert row['path']not in f;f[row['path']]=raw;ids[row['path']]=row['sha256']
for row in m['externalIdentityOnly']:ids[row['path']]=row['sha256']
prefix=m['root']+'/';p=json.loads(f[prefix+'plan.json']);r=json.loads(f[prefix+'receipt.json']);assert ids[prefix+'plan.json']==m['planSHA256']==r['planSHA256']
assert all(ids[k]==v for k,v in p['pins'].items());assert len(p['sourceInventory'])==len(p['importClosure'])==46
assert len(p['commands'])==len(r['commands'])==1 and len(r['guards'])==4
assert r['status']=='INCOMPLETE' and 'Owned child failed: emit' in r['error']
c=r['commands'][0];assert c['exit']==1 and c['failure']is None and c['argv']==p['commands'][0]['argv'] and c['capSeconds']==30
for k in ('stdout','stderr'):assert c[k]['published'] and ids[c[k]['path']]==c[k]['sha256'] and len(f[c[k]['path']])==c[k]['bytes']
for row in r['guards']:
 assert ids[row['path']]==row['sha256'];g=json.loads(f[row['path']]);assert g['unchanged']and all(ids[k]==v for k,v in g['actualPins'].items())
assert p['generated']not in f and p['native']not in f
assert ids[p['costArtifact']]==r['costArtifactSHA256']
d=json.loads(f[p['costArtifact']]);observed=d['observed'];rows=observed['rows'];assert len(rows)==3158
assert d['compilerCompleted']is False and 'cooperative lowering cutoff' in d['primaryError']
assert observed['cutoffStack']==['runtime-declarations:inspect_fiveAlias~0'] and observed['active']==[]
loaded=dict(d['loaded']);assert len(loaded)==47
for k in loaded:assert ids[k]==p['pins'][k]
reverse={}
for row in d['templateInstances']:
 for k in row['instances']:reverse.setdefault(k,[]).append(row['template'])
defs={row['key']:row for row in d['bookDefinitions']}
assert {row['definition']for row in d['mapping']}=={row['key']for row in rows}
for row in d['mapping']:
 k=row['definition']
 if k=='':assert row=={'definition':'','status':'not-declared'};continue
 origins=reverse.get(k,[]);assert len(origins)<=1;origin=origins[0]if origins else k
 assert row.get('originTemplate')==(origins[0]if origins else None);namespace=defs[origin]['namespace'];local=origin if namespace==''else origin[len(namespace)+1:]
 assert row['status']=='mapped'and row['namespace']==namespace and row['localName']==local and loaded[row['source']]==namespace
 assert ids[row['source']]==row['sourceSHA256'];line=f[row['source']].decode().splitlines()[row['line']-1];assert re.match(r'^def '+re.escape(local)+r'(?:\W|$)',line)
for row in rows:
 assert row['entries']==row['completed']+row['aborted']
 for k,v in row.items():
  if k!='key':assert isinstance(v,(int,float))and v>=0
analysis=json.loads((h/'ANALYSIS.json').read_bytes());timed=[x for x in rows if x['entries']];closed=[x for x in timed if x['aborted']==0];den=sum(x['userUsInclusive']+x['systemUsInclusive']for x in closed)
assert len(timed)==analysis['timedRoots']==2890 and len(closed)==analysis['completedRoots']==2889 and den==analysis['completedRootCPUus']==23072493
assert analysis['completedRootWallNs']==sum(x['wallNsInclusive']for x in closed)
assert analysis['unfinished']==[x for x in timed if x['aborted']]
assert analysis['totalCounters']=={k:sum(x[k]for x in rows)for k in ('bodyCalls','valTo','cacheHits','cacheMisses','lines','chars')}
mappings={x['definition']:x for x in d['mapping']}
for section,rank in [('topCompleted',sorted(closed,key=lambda x:x['userUsInclusive']+x['systemUsInclusive'],reverse=True)[:12]),('top_valTo',sorted(rows,key=lambda x:x['valTo'],reverse=True)[:8]),('top_chars',sorted(rows,key=lambda x:x['chars'],reverse=True)[:8])]:
 for stored,row in zip(analysis[section],rank):
  assert stored['row']==row and stored['source']==mappings[row['key']]
  if section=='topCompleted':assert stored['shareOfCompletedInstrumentedRootCPU']==(row['userUsInclusive']+row['systemUsInclusive'])/den
print('PASS',len(f),'lossless members/full cost3158rows/four guards/exact source-template joins/partial instrumented interval analysis; no replay')
