"""Retained qualification verification only: never execute backend or measurements."""
from pathlib import Path
import hashlib,json,zipfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((H/'MANIFEST.json').read_bytes());data={}
with zipfile.ZipFile(H/'EVIDENCE.zip') as z:
 assert len(z.namelist())==len(set(z.namelist()))==len(m['members'])
 assert set(z.namelist())=={e['member'] for e in m['members']}
 for e in m['members']:
  b=z.read(e['member']);assert sha(b)==e['sha256'] and len(b)==e['bytes'];assert e['source'] not in data;data[e['source']]=b
read=lambda p:data[p];js=lambda p:json.loads(read(p))
base=next(k[:-len('/RESULT.json')] for k in data if k.endswith('/paired-v1/RESULT.json'))
result=js(base+'/RESULT.json');v=base+'/binding-repair-v2';q=base+'/qualification-only-v1'
def check(root,planfile,prefix,complete):
 p=js(planfile);r=js(root+'/receipt.json');assert sha(read(planfile))==r['planSHA256']
 assert [c['label'] for c in r['commands']]==[c['label'] for c in p['commands']][:4]
 assert [c['capSeconds'] for c in r['commands']]==[5,5,120,5]
 for k,h in p['pins'].items():assert (h if 'sha256:'+h in data else sha(read(k)) if k in data else m['externalPins'][k])==h
 for c,w in zip(r['commands'],p['commands']):
  assert c['argv']==w['argv'] and c['capSeconds']==w['capSeconds'] and c['exit']==0 and c['failure'] is None
  for s in ['stdout','stderr']:
   raw=read(root+'/'+c['label']+'.'+s);assert raw==bytes.fromhex(c[s]['rawHex']) and sha(raw)==c[s]['sha256'] and len(raw)==c[s]['bytes']
 for c in r['probes']:
  assert c['exit']==0 and c['failure'] is None
  for s in ['stdout','stderr']:assert read(root+'/'+c['label']+'.'+s)==bytes.fromhex(c[s]['rawHex'])
 labels=['initial-pre','initial-acquired']+[c['label']+'-'+phase for c in r['commands'] for phase in ['pre','acquired','post']]+['final']
 assert len(r['guards'])==len(labels)==15
 previous={};generated={};pins=dict(p['pins']);pins[planfile]=r['planSHA256']
 for row,label in zip(r['guards'],labels):
  assert row['path']==root+'/'+label+'.guard.json' and sha(read(row['path']))==row['sha256'];g=js(row['path'])
  assert g['label']==label and g['unchanged'] is True and g['actualPins']==pins and g['stagePins']==p['stagePins'] and g['namespace']==p['namespace']
  assert previous.items()<=g['rawPins'].items() and generated.items()<=g['generated'].items()
  for name,h in g['rawPins'].items():assert sha(read(root+'/'+name))==h
  for name,h in g['generated'].items():assert sha(read(root+'/'+name))==h==r['generated'][name]
  previous=g['rawPins'];generated=g['generated']
 assert generated==r['generated']
 assert set(previous)=={c['label']+'.'+s for c in r['commands']+r['probes'] for s in ['stdout','stderr']}
 for role in ['TS','JS','Native']:
  lab=prefix+role;c=next(c for c in r['commands'] if c['label']==lab);out=read(root+'/'+lab+'.stdout');metrics=json.loads(read(root+'/'+lab+'.stderr'))
  assert sha(out)==('9aea2ef9b3157f12f7c6da92513a3887cdf4b152b39324a005bfb4374fee6fd3' if role=='TS' else '4473bc5dbab2005bc4ae7d9cdce86ead92f498f488cfc728840e6f7e786af1ca')
  assert set(metrics)==({'simulationNs','transportNs'} if role=='Native' else {'simulationNs','transportNs','bytes'})
  for k in ['simulationNs','transportNs']:assert isinstance(metrics[k],str) and metrics[k].isascii() and metrics[k].isdigit()
  if role!='Native':assert type(metrics['bytes']) is int and metrics['bytes']==len(out)
 if complete:
  assert r['status']=='REACHED_TIMING_SEQUENCE_CONTROLS_PASS_NOT_MEASUREMENT' and r.get('error') is None
  assert set(r['cases'])=={prefix+role for role in ['TS','JS','Native']}
  assert all(c['reachedControlMatch'] for c in r['cases'].values())
 else:assert r['status']=='INCOMPLETE' and r['error']=='ValueError: expected output must match its admitted pin'
 return r
old=check(q+'/actual01',q+'/plan.json','qualification-baseline-',False)
new=check(v+'/candidate-actual01',v+'/candidate-plan.json','qualification-candidate-',True)
assert sha(read(v+'/candidate-actual01/receipt.json'))==result['candidateReceiptSHA256']
b=js(v+'/BASELINE-REVALIDATION.json');assert b['status']=='RETAINED_BASELINE_FULL_TIMER_REVALIDATION_PASS_NOT_FRESH_RUN'
assert sha(read(v+'/BASELINE-REVALIDATION.json'))==result['baselineRevalidationSHA256']
assert b['originalReceiptSHA256']==sha(read(q+'/actual01/receipt.json')) and b['originalPlanSHA256']==sha(read(q+'/plan.json'))
assert b['repairedPlanSHA256']==sha(read(v+'/candidate-plan.json.proposal01'))
assert set(b['cases'])=={'TS','JS','Native'}
for role,case in b['cases'].items():
 assert case['fullOutputAndClockMatch'] is True
 for stream in ['stdout','stderr']:assert case[stream+'SHA256']==sha(read(q+'/actual01/qualification-baseline-'+role+'.'+stream))
assert b['baselineNativeSHA256']==sha(read(q+'/actual01/baseline.native'))
assert result['comparisonsRun']==result['profilesRun']==0 and result['baselineRerun'] is False and result['productionAdoption'] is False
assert result['candidateGenerated']==new['generated']
print(json.dumps({'status':'PASS_RETAINED_TIMER_QUALIFICATION_ONLY','members':len(data),'freshCandidateCommands':4,'baselineFreshRerun':False,'comparisons':0,'profiles':0}))
