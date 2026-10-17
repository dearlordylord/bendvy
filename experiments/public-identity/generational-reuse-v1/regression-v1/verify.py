"""Offline joins for the existing unchanged Workshop #28 gate; no replay."""
from pathlib import Path
import ast
import gzip
import hashlib
import json
import random
import statistics
import zipfile
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
d=json.loads((HERE/'DELIVERY.json').read_text())
for name,digest in d['files'].items():assert sha((HERE/name).read_bytes())==digest,name
m=json.loads((HERE/'MANIFEST.json').read_text())
with zipfile.ZipFile(HERE/'EVIDENCE.zip')as z:
 assert len(z.namelist())==len(set(z.namelist())) and set(z.namelist())==set(m['members'])
 for name,row in m['members'].items():
  raw=z.read(name);assert len(raw)==row['bytes'] and sha(raw)==row['sha256']
 def get(path,h=None):
  choices=m['pathHashToMember'][path]
  if h is None:assert len(choices)==1,path;h=next(iter(choices))
  raw=z.read(choices[h]);assert sha(raw)==h;return raw
 def pinned(path,h):
  if path in m['externalInstalledELFIdentities']:
   assert m['externalInstalledELFIdentities'][path]['sha256']==h
  else:assert sha(get(path,h))==h
 root=d['producerRoot'];gate=d['run'];cohort=gate+'/cohort'
 plan_raw=get(gate+'/plan.json');p=json.loads(plan_raw);outer=json.loads(get(gate+'/receipt.json'));r=json.loads(get(cohort+'/receipt.json'))
 assert sha(plan_raw)==outer['planSHA256']=='05cff6c89e0392f7f97ae2dc8d491ae85e7559fcce71321b785e361fbfc24bc3'
 assert outer['status']=='UNCHANGED_BENCHMARK_NO_CONFIRMED_REGRESSION' and outer['commands']==[{'exit':0,'failure':None}]
 assert not outer.get('guardFailures')
 for stream in ('stdout','stderr'):assert sha(get(gate+'/cohort.'+stream))==outer[stream+'SHA256']
 assert get(gate+'/cohort.stderr')==b'' and outer['benchmarkReceiptSHA256']==sha(get(cohort+'/receipt.json'))
 for path,h in p['pins'].items():pinned(path,h)
 for path,resolver in m['resolvers'].items():
  assert p['pins'].get(path,resolver['sha256'])==resolver['sha256']
 assert m['resolvers'][p['nodeAlias']]['target']==p['nodeAliasTarget']
 review=json.loads(get('/tmp/bendvy38-combined-launch-review.json'))
 assert review['verdict']=='CONDITIONAL_LAUNCH_PASS' and not review['findings']
 assert review['benchmarkPlanSHA256']==sha(plan_raw)
 admission=json.loads(get('/tmp/bendvy38-cpu11-admission01.json'))
 assert admission['cpu']==11 and 11 in admission['allowed'] and admission['busyFraction']==0.0
 successor=p['provenance']['documentationPinSuccessor'];prior_raw=get(successor['predecessorPlan'],successor['predecessorSHA256']);prior=json.loads(prior_raw)
 assert successor['executed'] is False
 differences={path for path,h in prior['pins'].items()if p['pins'].get(path)!=h}
 assert differences==set(successor['changedOnlyDocumentationPins'])
 assert len(differences)==2
 for path,change in successor['changedOnlyDocumentationPins'].items():
  assert prior['pins'][path]==change['before'] and p['pins'][path]==change['after']
  assert sha(get(path,change['before']))==change['before'] and sha(get(path,change['after']))==change['after']
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
 assert len(expected['checkpoints'])==22
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

 adapter={};exec(compile(get(root+'/benchmarks/generational_fixture.py'),'<retained exact fixture adapter>','exec'),adapter)
 adaptation=r['candidateFixtureAdaptation'];assert not adaptation['providerFilesTransformed'] and adaptation['baselineCommit']==contract['baselineCommit']
 changes=[]
 for name,digest in adapter['WORKLOAD_SHA256'].items():
  original=get(cohort+'/baseline/examples/query-composition/'+name)
  assert sha(original)==digest
  candidate=get(cohort+'/candidate/examples/query-composition/'+name)
  text=original.decode()
  for before,after in adapter['REPLACEMENTS'].get(name,()):
   assert text.count(before)==1;text=text.replace(before,after)
  assert text.encode()==candidate
  if name in adapter['REPLACEMENTS']:
   changes.append({'path':'examples/query-composition/'+name,'beforeSHA256':sha(original),'afterSHA256':sha(candidate),'replacements':len(adapter['REPLACEMENTS'][name])})
 changes.sort(key=lambda row:list(adapter['REPLACEMENTS']).index(Path(row['path']).name))
 assert changes==adaptation['files']
 assert len(changes)==4 and sum(row['replacements']for row in changes)==5
 print(json.dumps({'status':'PASS_RETAINED_UNCHANGED_STOCK28_GATE','archiveMembers':len(m['members']),'externalInstalledELFIdentities':len(m['externalInstalledELFIdentities']),'executedPlanPins':len(p['pins']),'commands':123,'completeOutputs':110,'applicationsPerOutput':contract['iterations'],'pairsPerBackend':contract['pairs'],'statisticalStatus':result['status'],'fixtureChanges':4,'fixtureReplacements':5,'documentationOnlyPlanSuccessor':2,'backendReplay':False},indent=2))
