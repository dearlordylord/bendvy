"""Portable archive joins plus existing benchmark output/order/assess checks.
No measurement replay, live source read, or statistical policy change.
The output/order/statistics checks reuse scripts/reconcile-benchmark-inventory.py.
"""
from pathlib import Path
import json,hashlib,zipfile,gzip,random,statistics
E=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
d=json.loads((E/'DELIVERY.json').read_text())
for n,h in d['files'].items():assert sha((E/n).read_bytes())==h,n
m=json.loads((E/'MANIFEST.json').read_text())
with zipfile.ZipFile(E/'EVIDENCE.zip')as z:
 assert set(z.namelist())==set(m['members']) and len(z.namelist())==len(set(z.namelist()))
 for n,row in m['members'].items():
  raw=z.read(n);assert len(raw)==row['bytes'] and sha(raw)==row['sha256']
 def get(path,h=None):
  choices=m['pathHashToMember'][path]
  if h is None:assert len(choices)==1;h=next(iter(choices))
  raw=z.read(choices[h]);assert sha(raw)==h;return raw
 root=d['producerRoot'];b=root+'/regression-current-v1';gate=b+'/fresh-gate-v2';cohort=b+'/cohort2'
 p_raw=get(gate+'/plan.json');p=json.loads(p_raw);outer=json.loads(get(gate+'/receipt.json'));r=json.loads(get(cohort+'/receipt.json'))
 assert outer['planSHA256']==sha(p_raw) and outer['status']=='UNCHANGED_BENCHMARK_NO_CONFIRMED_REGRESSION'
 assert outer['commands']==[{'exit':0,'failure':None}] and not outer.get('guardFailures')
 for stream in ['stdout','stderr']:assert sha(get(gate+'/cohort.'+stream))==outer[stream+'SHA256']
 assert outer['benchmarkReceiptSHA256']==sha(get(cohort+'/receipt.json'))
 for path,h in p['pins'].items():
  if path.startswith('/workspace/'):
   if path in m['resolvers']:
    alias=m['resolvers'][path];assert alias['targetSHA256']==h and p['pins'][alias['target']]==h and alias['target']==p['nodeAliasTarget']
   else:assert sha(get(path,h))==h
 contract=json.loads(get('/workspace/formal-proofs/bendvy/benchmarks/contract.json'))
 assert r['contract']==contract==p['contract'] and contract['pairs']==20 and contract['warmups']==2 and contract['allowedSlowdown']==0
 assert r['status']=='NO_CONFIRMED_REGRESSION' and r['injectedSlowdownMs']==0 and 'candidateProvider'not in r
 assert r['baselineArchiveSHA256']==p['baselineArchiveSHA256'] and r['cpu']==11
 for role in ['baseline','candidate']:
  for name,h in r['sources'][role].items():assert sha(get(cohort+'/'+role+'/'+name))==h
 for name,h in r['artifacts'].items():assert sha(get(cohort+'/'+name))==h
 for name,h in r['currentSourceHashes'].items():assert sha(get('/workspace/formal-proofs/bendvy/'+name,h))==h
 for name,h in r['referenceHashes'].items():assert sha(get('/workspace/formal-proofs/bendvy/.references/bevy-ts/'+name))==h
 commands={c['label']:c for c in r['commands']}
 assert len(commands)==len(r['commands'])==123 and all(c['exit']==0 for c in commands.values())
 prefix=['version-Bend','version-Node','version-Clang','reference-head','reference-clean','baseline-checker','baseline-js-emit','baseline-c-emit','baseline-native-build','candidate-checker','candidate-js-emit','candidate-c-emit','candidate-native-build']
 roles=['TS','baseline-JS','baseline-Native','candidate-JS','candidate-Native']
 warmups=[f'warmup-{i}-{role}'for i in range(contract['warmups'])for role in roles]
 assert [c['label']for c in r['commands'][:23]]==prefix+warmups
 for c in r['commands']:
  limit=120 if c['label'].endswith('-native-build')else 30 if c['label'].endswith('-emit')else 5
  assert c['limitSeconds']==limit
 expected=json.loads(get(cohort+'/baseline/examples/query-composition/expected.json'))
 expected['checkpoints']=[point for point in expected['checkpoints']if point['label']!='foreign-collision-reference']
 labels=warmups+[f'pair-{i}-{role}'for i in range(contract['pairs'])for role in roles]
 assert set(commands)==set(prefix+labels)
 for label in labels:
  raw=gzip.decompress(get(cohort+'/'+label+'.stdout.gz'));assert sha(raw)==commands[label]['stdoutSHA256']
  lines=raw.decode().splitlines();assert len(lines)==contract['iterations'] and all(json.loads(line)==expected for line in lines)
 assert len(r['timings'])==contract['pairs']
 rng=random.Random(contract['seed']);orders={}
 for backend in ['JS','Native']:
  orders[backend]=[False,True]*(contract['pairs']//2);rng.shuffle(orders[backend])
 reconstructed=[];actual_order=[]
 for i,timing in enumerate(r['timings']):
  groups=[['TS']]
  for backend in ['JS','Native']:
   group=['baseline-'+backend,'candidate-'+backend];groups.append(list(reversed(group))if orders[backend][i]else group)
  rng.shuffle(groups);order=[role for group in groups for role in group]
  assert timing['pair']==i and timing['order']==order and set(timing['milliseconds'])==set(roles)
  actual_order.extend(f'pair-{i}-{role}'for role in order)
  for role in roles:assert timing['milliseconds'][role]==commands[f'pair-{i}-{role}']['elapsedMs']
  for backend in ['JS','Native']:reconstructed.append(dict(pair=i,backend=backend,baselineMs=timing['milliseconds']['baseline-'+backend],candidateMs=timing['milliseconds']['candidate-'+backend]))
 assert [c['label']for c in r['commands'][23:]]==actual_order and reconstructed==r['pairs']
 namespace={};exec(compile(get('/workspace/formal-proofs/bendvy/benchmarks/decision.py'),'<verified-existing-decision>','exec'),namespace)
 result=namespace['assess'](reconstructed,contract['pairs'],contract['alpha'])
 assert result['status']==r['status'] and result['endpoints']==r['endpoints']
 medians={role:statistics.median(t['milliseconds'][role]for t in r['timings'])for role in roles};assert medians==r['mediansMs']
 old=json.loads(get(b+'/receipt.json'));old_inner=json.loads(get(b+'/cohort/receipt.json'))
 assert old['status']=='INCOMPLETE' and old['commands']==[{'exit':1,'failure':None}] and old_inner['status']=='ERROR' and old_inner['timings']==[]
 assert 'timed out after 30 seconds'in old_inner['error']
 diag=b+'/baseline-emit-diagnostic-v1';dr=json.loads(get(diag+'/receipt.json'));dp=json.loads(get(diag+'/plan.json'))
 assert dr['planSHA256']==sha(get(diag+'/plan.json')) and len(dr['commands'])==1 and dr['commands'][0]['label']=='emit' and dr['commands'][0]['exit']==0 and dr['commands'][0]['failure']is None
 assert len(dr['guards'])==4
 for g in dr['guards']:assert json.loads(get(g['path'],g['sha256']))['unchanged']
 raw=get(dp['generated'],dr['emitArtifactSHA256']);assert len(raw)==4234989 and sha(raw)==dp['provenance']['expectedOldCSHA256']
print(json.dumps({'status':'PASS_RETAINED_UNCHANGED_STOCK28_GATE','members':len(m['members']),'pairsPerBackend':20,'fullOutputs':110,'statisticalStatus':result['status']}))
