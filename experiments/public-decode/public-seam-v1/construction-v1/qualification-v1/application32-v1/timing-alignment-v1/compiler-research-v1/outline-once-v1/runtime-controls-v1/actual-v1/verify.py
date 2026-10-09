from pathlib import Path
import gzip,hashlib,json
h=Path(__file__).resolve().parent;m=json.loads((h/'FILES.json').read_bytes());f={};ids={}
for x in m['members']:
 raw=gzip.decompress((h/x['object']).read_bytes());assert len(raw)==x['bytes'] and hashlib.sha256(raw).hexdigest()==x['sha256'];assert x['path'] not in f;f[x['path']]=raw;ids[x['path']]=x['sha256']
for x in m['externalIdentityOnly']:assert x['path'] not in ids;ids[x['path']]=x['sha256']
assert ids[m['index']]==m['indexSHA256']=='fd027f373c1e3c956c4920aa8719962bd4f22b5633c9912b6743bd05dac9698f'
index=json.loads(f[m['index']]);assert len(index['plans'])==12 and index['commands']==30
summary=json.loads((h/'SUMMARY.json').read_bytes());commands=guards=0;outputs={}
for row,stored in zip(index['plans'],summary):
 p=json.loads(f[row['plan']]);r=json.loads(f[str(Path(row['plan']).parent/'receipt.json')]);assert ids[row['plan']]==row['sha256']==r['planSHA256']
 assert r['status']=='COPIED_OUTLINE_FIXTURE_NATIVE_WHOLE_PASS' and 'error' not in r and not r.get('guardFailures')
 assert all(ids[k]==v for k,v in p['pins'].items())
 for root,inventory in p['resourceRoots'].items():assert all(ids[str(Path(root)/k)]==v for k,v in inventory.items())
 assert len(r['commands'])==len(p['commands'])==(2 if row['mode']=='baseline' else 3)
 for c,q in zip(r['commands'],p['commands']):
  assert c['argv']==q['argv'] and c['capSeconds']==q['capSeconds'] and c['exit']==0 and c['failure'] is None
  for key in ['stdout','stderr']:
   v=c[key];assert v['published'] and ids[v['path']]==v['sha256'] and len(f[v['path']])==v['bytes']
  if c['label']!='emit':assert f[c['stderr']['path']]==b''
  else:assert b'[MODULE_TYPELESS_PACKAGE_JSON] Warning:' in f[c['stderr']['path']]
  if c['label']=='consumer':assert f[c['stdout']['path']]==f[p['oracle']];outputs[row['fixture'],row['mode']]=f[c['stdout']['path']]
 assert ids[p['oracle']]==p['oracleSHA256']==r['wholeOracleSHA256'] and len(f[p['oracle']])==p['oracleBytes']
 assert ids[p['generated']]==(r['emitArtifactSHA256'] if row['mode']=='candidate' else p['baselineEvidence']['cSHA256']) and ids[p['native']]==r['buildArtifactSHA256']
 if row['mode']=='baseline':
  b=p['baselineEvidence'];assert ids[b['plan']]==b['planSHA256'] and ids[b['receipt']]==b['receiptSHA256'];old=json.loads(f[b['receipt']]);assert old['commands'][0]['exit']==0 and old['commands'][0]['failure'] is None
 assert len(r['guards'])==3*len(r['commands'])+1
 for g in r['guards']:
  assert ids[g['path']]==g['sha256'];v=json.loads(f[g['path']]);assert v['unchanged'] and all(ids[k]==sha for k,sha in v['actualPins'].items())
 assert stored=={'fixture':row['fixture'],'mode':row['mode'],'planSHA256':row['sha256'],'commands':len(r['commands']),'guards':len(r['guards']),'status':r['status'],'wholeOracleSHA256':r['wholeOracleSHA256']}
 commands+=len(r['commands']);guards+=len(r['guards'])
for name in ['ctr_at_position','fork_leaf_result_loop','fork_held_family','fork_shared_flat','fn_capture_owns','wide_record']:assert outputs[name,'baseline']==outputs[name,'candidate']
assert commands==30 and guards==102
print('PASS',len(f),'lossless members/12 cohorts/30 commands/102 guards/six whole source-authored outputs; no replay')
