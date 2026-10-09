from pathlib import Path
import json,gzip,hashlib,re
h=Path(__file__).resolve().parent;m=json.loads((h/'FILES.json').read_bytes());f={};ids={}
for row in m['members']:
 raw=gzip.decompress((h/row['object']).read_bytes());assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256'];assert row['path']not in f;f[row['path']]=raw;ids[row['path']]=row['sha256']
for row in m['externalIdentityOnly']:ids[row['path']]=row['sha256']
prefix=m['root']+'/';p=json.loads(f[prefix+'plan.json']);r=json.loads(f[prefix+'receipt.json']);assert ids[prefix+'plan.json']==m['planSHA256']==r['planSHA256']
assert all(ids[k]==v for k,v in p['pins'].items());assert len(p['sourceInventory'])==len(p['importClosure'])==46
assert len(p['commands'])==len(r['commands'])==1 and len(r['guards'])==4
assert r['status']=='INITIAL_LAYOUT_CAPTURED_NO_BODY_EMISSION';c=r['commands'][0];assert c['exit']==0 and c['failure']is None and c['argv']==p['commands'][0]['argv'] and c['capSeconds']==30
for k in ('stdout','stderr'):assert c[k]['published'] and ids[c[k]['path']]==c[k]['sha256'] and len(f[c[k]['path']])==c[k]['bytes']
for row in r['guards']:
 assert ids[row['path']]==row['sha256'];g=json.loads(f[row['path']]);assert g['unchanged']and all(ids[k]==v for k,v in g['actualPins'].items())
assert ids[p['generated']]==r['emitArtifactSHA256']==r['initialLayoutSHA256']=='f3b2d2eba5d6c2aa5f41d5e6a2487c46b0bff5fd06604f4b9af5fd50c6e45074'
d=json.loads(f[p['generated']]);selected=d['initial']['selected'];assert len(selected)==408
loaded=dict(d['loaded']);assert len(loaded)==47
for k in loaded:assert ids[k]==p['pins'][k]
reverse={}
for row in d['templateInstances']:
 for k in row['instances']:reverse.setdefault(k,[]).append(row['template'])
defs={row['key']:row for row in d['bookDefinitions']}
for row in d['mapping']:
 k=row['definition'];origins=reverse.get(k,[]);assert len(origins)<=1;origin=origins[0]if origins else k
 assert row.get('originTemplate')==(origins[0]if origins else None);namespace=defs[origin]['namespace'];local=origin if namespace==''else origin[len(namespace)+1:]
 assert row['status']=='mapped'and row['namespace']==namespace and row['localName']==local and loaded[row['source']]==namespace
 assert ids[row['source']]==row['sourceSHA256'];line=f[row['source']].decode().splitlines()[row['line']-1];assert re.match(r'^def '+re.escape(local)+r'(?:\W|$)',line)
summary=json.loads((h/'SUMMARY.json').read_bytes());assert summary['selected']==len(selected)
assert summary['missing']==sorted(set(d['requestedNames'])-{x['local']for x in selected})==['check_filter']
assert summary['maxBeforeArgument']==max(len(a['beforeWideFallback']['ks'])for x in selected for a in x['arguments'])==37
assert summary['maxArgument']==max(len(a['argument']['ks'])for x in selected for a in x['arguments'])==37
assert summary['maxResult']==max(len(x['result']['ks'])for x in selected)==48
assert all(a['beforeWideFallback']==a['argument']for x in selected for a in x['arguments'])
print('PASS',len(f),'lossless members/408 exact initial layouts/four guards/source-template joins; no replay')
