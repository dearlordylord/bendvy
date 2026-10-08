"""Portable no-child verification of matched finite source authority checks."""
from pathlib import Path
import hashlib,json,tarfile,runpy
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
with tarfile.open(H/'evidence.tar.gz') as t:
 members=t.getmembers();assert len({m.name for m in members})==len(members) and all(m.isfile() for m in members);raw={m.name:t.extractfile(m).read() for m in members}
assert raw['index.json']==(H/'index.json').read_bytes();i=json.loads(raw['index.json']);rows={r['name']:r for r in i['records']};assert len(rows)==len(i['records']) and set(raw)=={'index.json'}|{'objects/'+r['SHA256'] for r in rows.values()}
f={}
for n,row in rows.items():
 b=raw['objects/'+row['SHA256']];assert sha(b)==row['SHA256'] and len(b)==row['bytes'];f[n]=b
prefix='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/'
def path(n):return 'worktree/'+n[len(prefix):] if n.startswith(prefix) else 'external/'+n.lstrip('/')
def obj(n):return json.loads(f[n])
a=i['actual'];p=obj(a+'/plan.json');r=obj(a+'/receipt.json');c=obj(a+'/classification.json')
assert sha(f[a+'/plan.json'])=='4b0a1767e031031be1750610706e41a86da807853195cbd21725f05a8efee43d'==r['planSHA256']
assert sha(f[a+'/receipt.json'])=='fe853365a796765e1298e392e857f74a9e517d112eac88dee1d2249b1526ae3b'==c['receiptSHA256']
assert sha(f[a+'/classification.json'])=='4024267bc53aa9d654096040e1aa9189345f69354252b08906ba1b255bf9a7ff'
assert r['status']==c['originalReceiptStatusUnchanged']=='DEVELOPMENT_FOUR_POSITIVES_AND_FOUR_UNCLASSIFIED_NEGATIVES_COLLECTED' and r.get('guardFailures',[])==[]
plans=[p]+[json.loads(b) for n,b in f.items() if n.endswith('/plan.json') and 'pins' in json.loads(b)]
private={q['privateEnvironment']:q['environmentSHA256'] for q in plans if 'privateEnvironment' in q};installed={}
for q in plans:installed.update(q.get('tools',{}).get('pins',{}))
for n,d in p['pins'].items():
 if path(n) in f:assert sha(f[path(n)])==d
 else:assert i['excluded'][n]['SHA256']==d
for n,row in i['excluded'].items():
 if n in private:assert row['SHA256']==private[n] and row['reason']=='private environment metadata only'
 elif n=='/home/node/.npmrc':assert row['reason']=='private participating configuration identity only' and p['configuration'][n]['SHA256']==row['SHA256']
 else:assert row['reason']=='installed ELF identity only' and installed[n]==row['SHA256']
assert len(p['commands'])==len(r['commands'])==len(c['rows'])==8
labels=['positive-'+n for n in ('inspector-frame','cross-schema','opaque-world','write-through-owner')]+['negative-'+n for n in ('inspector-frame','cross-schema','opaque-world','write-through-owner')]
assert [x['label'] for x in p['commands']]==labels and set(r['logs'])=={label+s for label in labels for s in ('.stdout','.stderr')}
for n,d in r['logs'].items():assert sha(f[a+'/'+n])==d
for pc,rc,cl in zip(p['commands'],r['commands'],c['rows']):
 assert all(pc[k]==rc[k] for k in ('label','argv','seconds','role')) and pc['seconds']==5 and pc['argv'][-1]=='--check-only' and pc['argv'][1:3]==['-c','5']
 assert rc['failure'] is None and rc['label']==cl['label'] and rc['exit']==cl['exit']==(0 if pc['role']=='positive' else 1)
 assert sha(f[path(cl['source'])])==p['pins'][cl['source']]==cl['sourceSHA256']
 assert sha(f[a+'/'+rc['label']+'.stdout'])==cl['stdoutSHA256'] and sha(f[a+'/'+rc['label']+'.stderr'])==cl['stderrSHA256']
 if pc['role']=='positive':assert f[a+'/'+rc['label']+'.stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and f[a+'/'+rc['label']+'.stderr']==b''
 else:assert rc['status']=='RAW_UNCLASSIFIED_REQUIRES_INDEPENDENT_DIAGNOSTIC_REVIEW' and f[a+'/'+rc['label']+'.stdout']==b''
for n in p['consumedClosure']:assert sha(f[path(n)])==p['pins'][n]
root=H
while not (root/'experiments').is_dir():root=root.parent
selected=json.loads((H/'delivery-files.json').read_text())
for row in selected['files']:assert sha((root/row['path']).read_bytes())==row['SHA256']
for pc in p['commands']:
 source=pc['argv'][-2];assert source.startswith(prefix) and sha((root/source[len(prefix):]).read_bytes())==p['pins'][source]==sha(f[path(source)])
for source in (prefix+str((H.parent/'collector.py').relative_to(root)),prefix+str((H.parent/'collector-proposal.json').relative_to(root)),prefix+str((H.parent/'source-proposal.json').relative_to(root))):assert sha((root/source[len(prefix):]).read_bytes())==p['pins'][source]==sha(f[path(source)])
normal=H.parents[1]/'finite-js-evidence-v1';assert sha((normal/'delivery-files.json').read_bytes())=='c378dda1c3ff33f6a2b5bdc85f5ee41c9113b152b2884f629a72ae1f1e037612';runpy.run_path(str(normal/'verify.py'),run_name='__main__')
print('PASS: four matched legal/source refusals independently classified; no runtime kill/proof/When claim')
