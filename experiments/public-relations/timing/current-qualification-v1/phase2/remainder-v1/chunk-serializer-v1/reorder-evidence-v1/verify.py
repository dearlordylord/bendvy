"""Reconcile finite archived current-root reorder evidence without live files or children."""
from pathlib import Path
import hashlib,io,json,tarfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
i=json.loads((H/'index.json').read_text());assert sha((H/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(H/'objects.tar.gz') as a:o={m.name:a.extractfile(m).read() for m in a.getmembers()}
assert set(o)==set(i['objects'])
for s,b in o.items():assert sha(b)==s and len(b)==i['objects'][s]
raw=lambda k:o[i['files'][k]]
read=lambda k:json.loads(raw(k))
by_path=lambda p:raw(i['pathKeys'][p])
proposal=read('authored/reorder-runtime-proposal.json')
archive_key=next(k for k in i['files'] if k.endswith('/'+proposal['historicalArchive']))
archive_bytes=raw(archive_key);assert sha(archive_bytes)==proposal['historicalArchiveSHA256']
with tarfile.open(fileobj=io.BytesIO(archive_bytes)) as a:historical={m.name:a.extractfile(m).read() for m in a.getmembers() if m.isfile()}
assert sha(historical[proposal['receiptMember']])==proposal['receiptSHA256']
hr=json.loads(historical[proposal['receiptMember']]);assert hr['status']=='FINITE_REGISTERED_HIERARCHY_REORDER_PASS'
assert not any(n.endswith('.py') for n in historical)
for role in ('js','native'):
 plan=read(role+'/plan.json')
 for c in plan['commands']:
  if 'normalOracle' not in c:continue
  assert by_path(c['normalOracle'])==historical['reorder-1791361321007561029/command-19.txt']
  original=next(x for x in hr['results'] if x['case']==c['case'] and x['backend']=='js')
  assert json.loads(by_path(c['witnessOracle']))==original['witnesses']
root_join=read('authored/reorder-current-root-closure.json')
for role in ('js','native'):
 plan=read(role+'/plan.json')
 for row in root_join['files']:
  path=str(Path(root_join['root'])/row['path']);assert sha(by_path(path))==row['currentRootSHA256']
  staged=str(Path(plan['stage'])/'normal'/row['path']);assert sha(by_path(staged))==row['currentRootSHA256']
roles=('js','native','cheap-positive','cheap-negatives')
for role in roles:
 p=read(role+'/plan.json');r=read(role+'/receipt.json')
 assert r['planSHA256']==sha(raw(role+'/plan.json'))
 for name,s in p['pins'].items():
  if role=='cheap-positive' and name.endswith('/reorder-cheap.py'):
   assert sha(raw('historical-qualified/reorder-cheap-dc1391.py'))==s
  elif name in i['pathKeys']:assert sha(by_path(name))==s
 for name,s in r['logs'].items():assert sha(raw(role+'/'+name))==s
 for name,s in r.get('probePins',{}).items():assert sha(by_path(name))==s
 if role in ('js','native'):
  count=8 if role=='js' else 12;probes=68 if role=='js' else 125
  assert r['status']=='CURRENT_REGISTERED_REORDER_'+role.upper()+'_FULL52_THREE_MUTANTS_PASS_NO_TIMING'
  assert len(p['commands'])==len(r['commands'])==count and r['probeCommandsExecuted']==probes
  assert all(c['exit']==0 and c['failure'] is None and c['status']=='QUALIFIED' for c in r['commands'])
  prep=read(role+'/prepare-receipt.json');assert prep['status']=='OWNED_TOOL_PREPARATION_PASS' and prep['probeCommandsExecuted']==(4 if role=='js' else 5)
  for name,s in prep['probePins'].items():assert sha(by_path(name))==s
  assert [x['witnessCount'] for x in r['results']]==[0,46,42,38]
  for c in p['commands']:
   if 'normalOracle' not in c:continue
   expected=by_path(c['normalOracle']).decode().splitlines();actual=raw(role+'/'+c['label']+'.stdout').decode().splitlines()
   assert len(expected)==len(actual)==56
   witnesses=[{'checkpoint':n,'expected':a,'actual':b} for n,(a,b) in enumerate(zip(expected,actual)) if a!=b]
   assert witnesses==json.loads(by_path(c['witnessOracle']))
   assert raw(role+'/'+c['label']+'.stderr')==b''
# Preserve the first positive's original INCOMPLETE verdict while classifying
# exactly the independently archived historical full result plus pinned notice.
p=read('cheap-positive/plan.json');r=read('cheap-positive/receipt.json')
assert r['status']=='INCOMPLETE' and len(r['commands'])==0
notice=raw('authored/pinned-notice.stderr');assert len(notice)==42
actual=raw('cheap-positive/reorder-owned.stdout');assert len(actual)==100 and actual==by_path(p['commands'][0]['expectedMerged'])+notice
assert raw('cheap-positive/reorder-owned.stderr')==b''
p=read('cheap-negatives/plan.json');r=read('cheap-negatives/receipt.json')
assert r['status']=='REMAINING_THREE_REORDER_NEGATIVES_EXACT_DIAGNOSTICS_NOT_RUNTIME_OR_PROOF'
assert len(r['commands'])==3
for c in r['commands']:assert c['exit']==1
for c in p['commands']:
 expected=by_path(c['expectedMerged']);assert sha(expected)==c['expectedMergedSHA256']
 assert raw('cheap-negatives/'+c['label']+'.stdout') in (expected,expected+notice)
 assert raw('cheap-negatives/'+c['label']+'.stderr')==b''
# All archived owned receipts' guard and raw entries remain hash joined.
for k in i['files']:
 if not k.endswith('receipt.json'):continue
 r=read(k)
 for path,s in r.get('probePins',{}).items():assert sha(by_path(path))==s
 prefix=k.rsplit('/',1)[0]
 for name,s in r.get('logs',{}).items():
  candidate=prefix+'/'+name
  if candidate in i['files']:assert sha(raw(candidate))==s
print('PASS: archived current-root JS/Native full52 normal+3 exact reached mutants; retained source-negative/history/raw/probe joins. No rerun, proof, performance, adoption or full42.')
