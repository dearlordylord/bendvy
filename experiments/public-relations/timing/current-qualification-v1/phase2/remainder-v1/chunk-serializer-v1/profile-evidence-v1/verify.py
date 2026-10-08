"""No-child reconciliation of finite matched sampled diagnostics and retained failures."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent;sha=lambda b:hashlib.sha256(b).hexdigest();i=json.loads((H/'index.json').read_text());assert sha((H/'objects.tar.gz').read_bytes())==i['archiveSHA256']
with tarfile.open(H/'objects.tar.gz') as t:o={m.name:t.extractfile(m).read() for m in t.getmembers()}
assert set(o)==set(i['objects'])
for s,b in o.items():assert sha(b)==s and len(b)==i['objects'][s]
raw=lambda n:o[i['files'][n]];read=lambda n:json.loads(raw(n));expected=read('oracle/depth16.json');case=next(c for c in read('oracle/manifest.json')['cases'] if c['input']==['depth','256','16','0']);assert sha(raw('oracle/depth16.json'))==case['sha256'];assert sum(len(x['records']) for x in expected['roots'])==30
pending=[expected];nodes=chars=total=0
while pending:
 v=pending.pop();nodes=(nodes+1)&0xffffffff
 if v is None:total+=1
 elif isinstance(v,bool):total+=5 if v else 4
 elif isinstance(v,int):total+=2+v
 elif isinstance(v,str):total+=3;chars+=len(v);total+=sum(map(ord,v))
 elif isinstance(v,list):total+=6;pending.extend(reversed(v))
 else:
  total+=7
  for k,x in reversed(list(v.items())):pending.extend([x,k])
 total&=0xffffffff;chars&=0xffffffff
boundaries=[{'boundary':'begin'},{'boundary':'complete-trace-forced','nodes':nodes,'characters':chars,'sum':total}]
for role,labels,status,probeCount in [('original-partial',['original-cpu','original-allocation'],'INCOMPLETE',16),('remaining-cpu',['candidate-cpu'],'REMAINING_CANDIDATE_CPU_FULL30_PROFILE_PASS_NO_VERDICT',12),('coarse-allocation',['original-allocation','candidate-allocation'],'MATCHED_DEPTH16_COARSE_ALLOCATION_DIAGNOSTICS_PASS_NO_VERDICT',20)]:
 p=read(role+'/plan.json');r=read(role+'/receipt.json');assert r['planSHA256']==sha(raw(role+'/plan.json')) and r['status']==status and r['probeCommandsExecuted']==probeCount
 for label in labels:assert read(role+'/'+label+'.stdout')==expected;assert [json.loads(x) for x in raw(role+'/'+label+'.stderr').splitlines()]==boundaries
 for n,s in r['profiles'].items():
  alias='original-partial/' if role=='remaining-cpu' else role+'/'
  assert sha(raw(alias+Path(n).name))==s,'receipt recorded profile artifact mismatch'
 recorded=[p['command']] if role=='remaining-cpu' else [c for c in p['commands'] if any(x['label']==c['label'] and x['status']=='FULL30_PROFILE_OUTPUT_PASS' for x in r['commands'])]
 assert set(r['profiles'])=={c['profile'] for c in recorded}
 for n,s in r['logs'].items():assert sha(raw(role+'/'+n))==s
 for n,s in r['probePins'].items():assert sha(raw(role+'/execution-probes/'+Path(n).name))==s
 if role!='remaining-cpu':
  prep=read(role+'/prepare-receipt.json');assert prep['status']=='OWNED_TOOL_PREPARATION_PASS' and prep['probeCommandsExecuted']==4
  for n,s in prep['probePins'].items():assert sha(raw(role+'/prepare-probes/'+Path(n).name))==s
assert read('original-partial/receipt.json')['commands']==[{'label':'original-cpu','status':'FULL30_PROFILE_OUTPUT_PASS'},{'label':'original-allocation','status':'INCOMPLETE'}]
assert 'original-partial/original-allocation.profile.json' not in i['files']
analysis=read('authored/profile-analysis.json')
for role in ['original','candidate']:
 c=read('original-partial/'+role+'-cpu.profile.json');a=read('coarse-allocation/'+role+'-allocation.profile.json');assert c['zeroExits']==a['zeroExits']==1 and c['invocations']==a['invocations']==1 and c['mode']=='cpu' and a['mode']=='allocation';assert c['profile']['nodes'] and c['profile']['samples'] and a['profile']['head'] and a['profile']['samples'];r=analysis['roles'][role];assert r['cpuProfileSHA256']==sha(raw('original-partial/'+role+'-cpu.profile.json')) and r['allocationProfileSHA256']==sha(raw('coarse-allocation/'+role+'-allocation.profile.json'));assert r['CPUtotalSamples']==len(c['profile']['samples']) and sum(r['CPUbyLexicalDeclarationGroup'].values())==r['CPUtotalSamples'];stack=[a['profile']['head']];size=0
 while stack:n=stack.pop();size+=n['selfSize'];stack.extend(n['children'])
 assert size==r['allocationReportedSelfSizeSum']==sum(r['allocationByLexicalDeclarationGroup'].values())
 if role=='candidate':assert next(iter(read('remaining-cpu/receipt.json')['profiles'].values()))==r['cpuProfileSHA256']
 else:assert next(iter(read('original-partial/receipt.json')['profiles'].values()))==r['cpuProfileSHA256']
assert read('failed-newline/prepare-receipt.json')['probeCommandsExecuted']==0;assert read('wrapping-preflight/receipt.json')['childrenExecuted']==0
print('PASS: finite full30 CPU/coarseHeap profiles/audits/raw/oracle/probes; failed16KiB allocation retained. Evidence only, no timing/RSS/totalallocation/cause/Native qualification.')
