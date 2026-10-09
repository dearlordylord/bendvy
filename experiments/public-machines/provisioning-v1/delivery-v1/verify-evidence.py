"""No-child complete archived subject/result/progressive boundary verification."""
from pathlib import Path
import gzip,hashlib,json,types
HERE=Path(__file__).resolve().parent
EVIDENCE=HERE/'evidence-v2'
index=json.loads((EVIDENCE/'INDEX.json').read_text())
def sha(data):return hashlib.sha256(data).hexdigest()
def read(member):
 data=gzip.decompress((EVIDENCE/member).read_bytes());meta=index['members'][member]
 assert len(data)==meta['bytes'] and sha(data)==meta['sha256'];return data
def source(path):return read(index['sourceObjects'][path])
assert {p.name for p in EVIDENCE.iterdir()}=={'INDEX.json',*index['members']}
for member in index['members']:read(member)
checked=0;guards=0
for key,subject in index['cohorts'].items():
 files=subject['files'];original=Path(subject['originalDirectory'])
 def raw(name):return read(files[name])
 plan=json.loads(raw('plan.json'));receipt=json.loads(raw('receipt.json'))
 assert sha(raw('plan.json'))==subject['planSHA256']==index['prepared']['plans'][key]['sha256']
 assert receipt['status']=='DEVELOPMENT_PASS' and not receipt.get('error') and not receipt.get('guardFailures')
 assert receipt['planSHA256']==subject['planSHA256']
 assert len(receipt['commands'])==len(plan['commands'])
 for path,member in index['sourceObjects'].items():
  if path in plan['pins']:assert sha(read(member))==plan['pins'][path]
 parserpath=str(HERE/'transport-v1/transport.py');parser=types.ModuleType('frozen_parser');parser.__file__=parserpath
 exec(compile(source(parserpath),parserpath,'exec'),parser.__dict__)
 pins=dict(plan['pins']);pins[str(original/'plan.json')]=subject['planSHA256'];expectedlabels=[]
 def guard(label):
  global guards
  name=label+'.guard.json';g=json.loads(raw(name));expectedlabels.append(name)
  assert g['label']==label and g['unchanged'] is True
  assert g['actualPins']==pins and g['actualResources']==plan['resourceInventory'];guards+=1
 for command,row in zip(plan['commands'],receipt['commands']):
  label=command['label'];assert row['label']==label and row['argv']==command['argv'] and row['capSeconds']==command['capSeconds']
  assert row['exit']==0 and row['failure'] is None
  assert command['argv'][:3]==[plan['tools']['taskset'],'-c','5']
  assert command['capSeconds']=={'emit':30,'build':120,'consumer':5}[label]
  if label=='consumer' and key.endswith('-native'):assert command['argv'][-4:]==['--threads','1','--gpu','off']
  guard(label+'-pre');guard(label+'-acquired')
  for stream in ['stdout','stderr']:
   capture=row[stream];body=raw(label+'.'+stream)
   assert capture['path']==str(original/(label+'.'+stream)) and capture['sha256']==sha(body) and capture['bytes']==len(body)
   pins[capture['path']]=sha(body)
  if label in ('emit','build'):
   artifact=Path(plan['generated'] if label=='emit' else plan['native']);pins[str(artifact)]=sha(raw(artifact.name))
  else:
   assert raw('consumer.stderr')==b''
   stdout=raw('consumer.stdout');assert stdout==source(plan['stdoutOracle']) and sha(stdout)==plan['stdoutOracleSHA256']
   expected=source(plan['oracle']);assert sha(expected)==plan['expectedSHA256']==receipt['wholeOracleSHA256']
   actual=parser.Transport(plan['entrypoint']).normalize(stdout.decode());parser.TERM.strict_equal(actual,json.loads(expected))
   if plan.get('baselineJSON'):
    baseline=source(plan['baselineJSON']);baselinewire=source(plan['baselineStdout'])
    assert sha(baseline)==plan['baselineSHA256']==receipt['normalBaselineRejectedSHA256']
    assert sha(baselinewire)==plan['baselineStdoutSHA256'] and stdout!=baselinewire and actual!=json.loads(baseline)
  guard(label+'-post')
 guard('final')
 assert len(receipt['guards'])==len(expectedlabels)
 for item,name in zip(receipt['guards'],expectedlabels):assert item['path']==str(original/name) and item['sha256']==sha(raw(name))
 checked+=1
print(f'PASS {checked} complete cohorts, {guards} exact progressive guards, {len(index["members"])} lossless members; no child or performance claim')
