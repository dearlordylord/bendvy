"""Portable full9 reached JS mutation evidence, no children."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent;E=H/'mutant-js-evidence-v1';sha=lambda b:hashlib.sha256(b).hexdigest();i=json.loads((E/'index.json').read_text())
assert sha((E/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(E/'objects.tar.gz') as tar:
 assert len(tar.getnames())==len(set(tar.getnames())) and set(tar.getnames())==set(i['objects']) and all(m.isfile() for m in tar.getmembers())
 obj={m.name:tar.extractfile(m).read() for m in tar.getmembers()}
assert all(sha(b)==h and len(b)==i['objects'][h] for h,b in obj.items()) and set(i['files'].values())<=set(obj)
def raw(k):return obj[i['files'][k]]
def path(n):return raw(i['pathKeys'][n])
def data(k):return json.loads(raw(k))
p=data('cohort/plan.json');r=data('cohort/receipt.json')
assert sha(raw('cohort/plan.json'))==r['planSHA256']=='a902ea8f5e709de446e036880b9cc1cbe64a91a71cbf929361f61f952e0f487c'
assert sha(raw('cohort/receipt.json'))=='7dc53116f4ed80cfbe7482307892e8bade1c3fe7b4332ef2cb5d67c13fce6bb6'
assert r['status']=='MUTANTS_JS_REACHED_FULL9_NOT_NATIVE_NOT_PROOF_NOT_DELIVERY' and r.get('guardFailures',[])==[]
assert [(c['label'],c['seconds'],c['exit'],c['failure']) for c in r['commands']]==[('emit-omit-with-index',30,0,None),('run-omit-with-index',5,0,None),('emit-dedup-next-queuers',30,0,None),('run-dedup-next-queuers',5,0,None)]
assert all(all(c[k]==p['commands'][j][k] for k in p['commands'][j]) for j,c in enumerate(r['commands']))
assert set(r['logs'])=={c['label']+'.'+s for c in p['commands'] for s in ['stdout','stderr']}
assert all(sha(raw('cohort/'+n))==h for n,h in r['logs'].items())
assert {k.removeprefix('cohort/stage/'):h for k,h in i['files'].items() if k.startswith('cohort/stage/')}==p['inventory']
for n,h in p['pins'].items():
 if n in i['pathKeys']:assert sha(path(n))==h
 else:assert (n in i['excluded'] and i['excluded'][n]['sha256']==h) or n+'@'+h in i['historicalUnavailable']
assert all(sha(path(n))==h for n,h in r['generated'].items())
proposal=data('delivery/MUTANT-PROPOSAL.json');assert sha(raw('delivery/MUTANT-PROPOSAL.json'))=='ce1fff11d518a5ea031acbb6ccda64e2386d4e5262d3e9122a08fb075531a032' and p['mutations']==proposal
sourcep=json.loads(path(p['sourceCohort']['plan']));sourcer=json.loads(path(p['sourceCohort']['receipt']));sr=str(Path(p['sourceCohort']['receipt']).parent)
assert sha(path(p['sourceCohort']['plan']))==sourcer['planSHA256']=='ee3cbc31897583f74f158fb665c39c6576d239d2487f84190116e2c035a969f4'
assert sha(path(p['sourceCohort']['receipt']))=='aca9f58f7eb0210fff526d5473fb27d061cda39be3f3c94eeb2789b99b456ad1'
assert sourcer['status']=='MUTANT_SOURCE_SHAPES_TYPECHECKED_NOT_REACHED_NOT_PROOF_NOT_DELIVERY' and sourcer.get('guardFailures',[])==[]
assert {str(Path(n).relative_to(sourcep['stage'])):i['files'][key] for n,key in i['pathKeys'].items() if n.startswith(sourcep['stage']+'/')}==sourcep['inventory']
assert all(sha(path(str(Path(sourcep['stage'])/n)))==h for n,h in sourcep['inventory'].items())
for n,h in sourcep['pins'].items():
 if n in i['pathKeys']:assert sha(path(n))==h
 else:assert (n in i['excluded'] and i['excluded'][n]['sha256']==h) or n+'@'+h in i['historicalUnavailable']
assert [(c['label'],c['seconds'],c['exit'],c['failure']) for c in sourcer['commands']]==[('omit-with-index',5,0,None),('dedup-next-queuers',5,0,None)]
assert all(all(c[k]==sourcep['commands'][j][k] for k in sourcep['commands'][j]) for j,c in enumerate(sourcer['commands']))
assert set(sourcer['logs'])=={c['label']+'.'+s for c in sourcep['commands'] for s in ['stdout','stderr']}
assert all(sha(path(sr+'/'+n))==h for n,h in sourcer['logs'].items())
for c in sourcep['commands']:
 assert path(sr+'/'+c['label']+'.stdout')==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
 assert path(sr+'/'+c['label']+'.stderr') in [b'',b'bend 2.0.36 is available: run bend update\n']
normalp=json.loads(path(sourcep['normalJSPlan']));normalr=json.loads(path(sourcep['normalJSReceipt']));normalstage=normalp['stage']
assert sha(path(sourcep['normalJSPlan']))=='a1a5af87ea5aba1dda8706f3ee392480f3e9a4f70462ee058d40f969373e05fd' and normalr['planSHA256']==sha(path(sourcep['normalJSPlan']))
assert normalr['status']=='DEVELOPMENT_DESCRIPTION_FULL9_PASS_NOT_DELIVERY_NOT_FORMAT_PUBLICATION' and normalr.get('guardFailures',[])==[]
assert [(c['label'],c['seconds'],c['exit'],c['failure']) for c in normalr['commands']]==[('emit',30,0,None),('candidate',5,0,None)]
assert all(all(c[k]==normalp['commands'][j][k] for k in normalp['commands'][j]) for j,c in enumerate(normalr['commands']))
normal=json.loads(path(normalstage+'/study/ORACLE.json'))['cases']
assert sha(path(sourcep['normalJSReceipt']))=='906d1e0b5f38062eea372a0acfd0f5bd1df3f9d5bc5c635d9d26d63c86ce6e67'
normalroot=str(Path(sourcep['normalJSReceipt']).parent)
assert set(normalr['logs'])=={'emit.stdout','emit.stderr','candidate.stdout','candidate.stderr'}
assert all(sha(path(normalroot+'/'+n))==h for n,h in normalr['logs'].items())
assert path(normalroot+'/candidate.stdout')==path(normalstage+'/study/EXPECTED.stdout') and path(normalroot+'/candidate.stderr')==b''
assert [json.loads(line) for line in path(normalroot+'/candidate.stdout').splitlines()]==normal
assert all(sha(path(n))==h for n,h in normalr['generated'].items())
assert {str(Path(n).relative_to(normalstage)):i['files'][key] for n,key in i['pathKeys'].items() if n.startswith(normalstage+'/')}==normalp['inventory']
tr=normalp['referenceReuse'];tsr=json.loads(path(tr['receipt']));tsp=json.loads(path(tr['plan']));tsroot=str(Path(tr['receipt']).parent)
assert sha(path(tr['plan']))==tr['planSHA256']=='2ee2dce254e940d8521afc4842f026a9b3a350c0586abf03447b0eb31ebb6e97'
assert sha(path(tr['receipt']))==tr['receiptSHA256']=='8b396cdbd105f4f02fea1002c0ad0b5ec196e7fc0c0de9dce4eed31e4c8b3ef1'
assert tsr['status']=='DEVELOPMENT_REFERENCE_FULL9_PASS_NOT_DELIVERY' and tsr.get('guardFailures',[])==[]
assert [(c['label'],c['seconds'],c['exit'],c['failure']) for c in tsr['commands']]==[('reference',5,0,None)]
assert all(tsr['commands'][0][k]==tsp['commands'][0][k] for k in tsp['commands'][0])
assert set(tsr['logs'])=={'reference.stdout','reference.stderr'} and all(sha(path(tsroot+'/'+n))==h for n,h in tsr['logs'].items())
assert path(tsroot+'/reference.stderr')==b''
tsrows=[json.loads(line) for line in path(tsroot+'/reference.stdout').splitlines()];assert len(tsrows)==9 and [row['scoped'] for row in tsrows]==normal and all(row['before']==row['after'] for row in tsrows)
for m in proposal['mutants']:
 for name,h in normalp['inventory'].items():
  original=path(normalstage+'/'+name);sourcen=str(Path(sourcep['stage'])/m['name']/name);runtime='cohort/stage/'+m['name']+'/'+name
  assert sha(original)==h
  if name=='study/'+m['source']:
   assert sha(original)==m['sourceSHA256'] and original.decode().count(m['old'])==1
   assert path(sourcen)==original.decode().replace(m['old'],m['new']).encode() and raw(runtime)==path(sourcen)
  else:
   assert path(sourcen)==original
   if name!='study/EXPECTED.stdout':assert raw(runtime)==original
 rows=[json.loads(x) for x in raw('cohort/run-'+m['name']+'.stdout').splitlines()]
 assert len(rows)==9 and rows==m['expectedFull9'] and [j for j,(a,b) in enumerate(zip(rows,normal)) if a!=b]==m['changedCaseIndices']
 assert raw('cohort/run-'+m['name']+'.stdout')==raw('cohort/stage/'+m['name']+'/study/EXPECTED.stdout') and raw('cohort/run-'+m['name']+'.stderr')==b''
 assert raw('cohort/emit-'+m['name']+'.stdout')==b'' and raw('cohort/emit-'+m['name']+'.stderr') in [b'',b'bend 2.0.36 is available: run bend update\n']
print('PASS portable full9 source shapes and reached JS defects; no Native/proof/full56:',len(i['files']),len(obj))
