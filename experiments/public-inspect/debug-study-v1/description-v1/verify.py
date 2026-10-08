"""No-child portable full9 development evidence verifier."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent;E=H/'evidence-v1';sha=lambda b:hashlib.sha256(b).hexdigest();i=json.loads((E/'index.json').read_text())
assert sha((E/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(E/'objects.tar.gz') as tar:
 assert len(tar.getnames())==len(set(tar.getnames())) and set(tar.getnames())==set(i['objects'])
 assert all(m.isfile() for m in tar.getmembers())
 obj={m.name:tar.extractfile(m).read() for m in tar.getmembers()}
assert all(sha(b)==h and len(b)==i['objects'][h] for h,b in obj.items())
assert set(i['files'].values())<=set(obj)
def raw(k):return obj[i['files'][k]]
def data(k):return json.loads(raw(k))
receipts={}
for key in i['files']:
 if not key.startswith('preflight/') or not key.endswith('/receipt.json'):continue
 base=key.removesuffix('receipt.json');r=data(key);p=data(base+'plan.json');assert r['planSHA256']==sha(raw(base+'plan.json'))
 assert set(r['logs'])=={c['label']+'.'+s for c in r['commands'] if c['exit'] is not None for s in ['stdout','stderr']}
 assert all(sha(raw(base+n))==h for n,h in r['logs'].items())
 assert {k.removeprefix(base+'stage/') for k in i['files'] if k.startswith(base+'stage/')}==set(p['inventory'])
 assert all(sha(raw(base+'stage/'+n))==h for n,h in p['inventory'].items())
 for n,h in p['pins'].items():
  if n in i['pathKeys'] and i['files'][i['pathKeys'][n]]==h:assert sha(raw(i['pathKeys'][n]))==h
  else:assert n+'@'+h in i['historicalUnavailable'] or (n in i['excluded'] and i['excluded'][n]['sha256']==h)
 for n,h in r.get('generated',{}).items():assert sha(raw(i['pathKeys'][n]))==h
 receipts[base.split('/')[1]]=r
assert all(receipts[n]['status']=='INCOMPLETE' for n in ['1791439616802018042','1791439998687644243','1791440398044598012','1791441572162016340'])
b='preflight/1791440813082986928/';r=receipts['1791440813082986928'];assert r['status']=='DEVELOPMENT_REFERENCE_FULL9_PASS_NOT_DELIVERY'
assert sha(raw(b+'plan.json'))=='2ee2dce254e940d8521afc4842f026a9b3a350c0586abf03447b0eb31ebb6e97'
assert r.get('guardFailures',[])==[]
assert len(r['commands'])==1 and r['commands'][0]['label']=='reference' and r['commands'][0]['seconds']==5
assert all(r['commands'][0][k]==data(b+'plan.json')['commands'][0][k] for k in ['label','argv','seconds'])
assert  r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None and raw(b+'reference.stderr')==b''
rows=[json.loads(line) for line in raw(b+'reference.stdout').splitlines()];oracle=data('delivery/ORACLE.json')['cases'];assert len(rows)==9 and [x['scoped'] for x in rows]==oracle and all(x['before']==x['after'] for x in rows)
b='preflight/1791441880404529800/';r=receipts['1791441880404529800'];p=data(b+'plan.json')
assert r['status']=='DEVELOPMENT_DESCRIPTION_FULL9_PASS_NOT_DELIVERY_NOT_FORMAT_PUBLICATION'
assert sha(raw(b+'plan.json'))=='a1a5af87ea5aba1dda8706f3ee392480f3e9a4f70462ee058d40f969373e05fd'
assert r.get('guardFailures',[])==[]
assert len(r['commands'])==len(p['commands'])==2
assert all(all(c[k]==p['commands'][j][k] for k in p['commands'][j]) for j,c in enumerate(r['commands']))
assert [(c['label'],c['seconds'],c['exit'],c['failure']) for c in r['commands']]==[('emit',30,0,None),('candidate',5,0,None)]
assert raw(b+'candidate.stdout')==raw('delivery/EXPECTED.stdout') and raw(b+'candidate.stderr')==b''
assert raw(b+'emit.stderr') in [b'',b'bend 2.0.36 is available: run bend update\n'] and raw(b+'emit.stdout')==b''
assert p['referenceReuse']['receiptSHA256']==sha(raw('preflight/1791440813082986928/receipt.json'))
assert p['referenceReuse']['planSHA256']==sha(raw('preflight/1791440813082986928/plan.json'))
assert [json.loads(x) for x in raw(b+'candidate.stdout').splitlines()]==oracle
assert raw('preflight/1791441572162016340/candidate.stdout')==raw('delivery/EXPECTED.stdout')+b'\n'
print('PASS portable development TS9+JS9 scoped indexes/lints and immutable histories:',len(i['files']),'records',len(obj),'objects')
