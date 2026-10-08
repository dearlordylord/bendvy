"""Read/hash-only finite same-owner JS42 and generated dependency evidence."""
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
canonical=lambda x:json.dumps(x,sort_keys=True,separators=(',',':'))
def verify():
 m=json.loads((H/'delivery-v1/manifest.json').read_text());assert sha(Path(__file__).read_bytes())==m['verifierSHA256'];assert sha((H/'delivery-v1/REPORT.md').read_bytes())==m['reportSHA256'];a=m['archive'];path=H/'delivery-v1'/a['name'];assert sha(path.read_bytes())==a['sha256']
 with tarfile.open(path) as archive:
  assert len(archive.getmembers())==len({x.name for x in archive.getmembers()})
  assert all(x.isfile() for x in archive.getmembers())
  assert {x.name for x in archive.getmembers()}==set(a['members'])
  data={x.name:archive.extractfile(x).read() for x in archive.getmembers()}
 for name,b in data.items():assert sha(b)==a['members'][name]['sha256'] and len(b)==a['members'][name]['bytes']
 def obj(name):return json.loads(data[name])
 def qualify(prefix,expected,status):
  p=obj(prefix+'/plan.json');r=obj(prefix+'/receipt.json');assert sha(data[prefix+'/plan.json'])==expected==r['planSHA256']
  assert not r.get('guardFailures',[])
  assert r['status']==status and len(p['commands'])==len(r['commands'])==2
  assert [c['seconds'] for c in p['commands']]==[30,5] and [c['exit'] for c in r['commands']]==[0,0] and all(c['failure'] is None for c in r['commands'])
  raw={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']};assert set(r['logs'])==raw
  assert {name.removeprefix(prefix+'/') for name in data if name.startswith(prefix+'/') and name.endswith(('.stdout','.stderr')) and '/execution-probes/' not in name}==raw
  for name,h in r['logs'].items():assert sha(data[prefix+'/'+name])==h
  for c in p['commands']:assert data[prefix+'/'+c['label']+'.stderr']==b''
  labels=p['executionProbeLabels'];assert labels==['guard-'+str(i)+'-ldd-'+name for i in range(5) for name in ['bend','node','python','taskset','clang']]
  assert len(labels)==r['probeCommandsExecuted']==25
  probeNames={label+suffix for label in labels for suffix in ['.json','.stdout','.stderr']}
  assert {name.removeprefix(prefix+'/execution-probes/') for name in data if name.startswith(prefix+'/execution-probes/')}==probeNames
  assert {str(Path(p['stage']).parent/'execution-probes'/name) for name in probeNames}==set(r['probePins'])
  for name,h in r['probePins'].items():assert sha(data[prefix+'/execution-probes/'+Path(name).name])==h
  for label in labels:
   probe=obj(prefix+'/execution-probes/'+label+'.json');assert probe['exit']==0 and probe['failure'] is None and probe['seconds']==5
   tool=label.rsplit('-ldd-',1)[1];assert probe['argv']==[p['tools']['taskset'],'-c',str(p['tools']['cpu']),p['tools']['ldd'],p['tools']['tools'][tool]]
   assert probe.get('exception') is None
  inv={name.removeprefix(prefix+'/stage/'):sha(b) for name,b in data.items() if name.startswith(prefix+'/stage/')};assert inv==p['inventory']
  for name,h in r['generated'].items():assert sha(data[prefix+'/'+Path(name).name])==h
  return p,r
 p,r=qualify('inspection',m['planSHA256'],'CLOCK_CODE_EMISSION_AND_FULL42_CORRECTNESS_PASS_NO_TIMING_CREDIT')
 old,previous=qualify('historical-normal',m['historicalPlanSHA256'],'INDEPENDENT_BUNDLE_FORTY_EIGHT_COMPLETE_JS_OBSERVATIONS_PASS')
 assert len(p['pins'])==1376
 review=obj('source/source-review-manifest.json');assert sha(data['source/source-review-manifest.json'])==p['sourceReviewManifestSHA256']==m['sourceReviewSHA256']
 for name,h in review['sourceFiles'].items():
  relative=Path(name).relative_to(H)
  archived='inspection/stage/'+str(relative).removeprefix('stage/') if relative.parts[0]=='stage' else 'source/'+str(relative)
  assert sha(data[archived])==h==p['pins'][name]
 for name,h in review['compilerAndClockSource'].items():
  suffix=str(name).split('/bend2/bend2/',1)[1];assert sha(data['compiler/'+suffix])==h==p['pins'][name]
 doc=p['historicalDocumentationJoin'];assert sha(data['source/historical-readiness-fe23fd7e.md'])==doc['historicalSHA256']==old['pins'][doc['originalPath']]
 expected=obj('source/common-expected.json')['comparable'];actual=obj('inspection/common-correctness-consume.stdout');assert canonical(actual['common'])==canonical(expected)
 fields=['component','resource','extraPresent','extraPayload','current','previous','locals','attempts','prefix','pendingStructural','structuralApplied','deliveries','requirements','missing','outcome']
 for schema in ['A','B']:
  assert list(actual['physical'][schema])==list(expected[schema]) and len(expected[schema])==21
  for name,row in actual['physical'][schema].items():
   projected={k:row[k] for k in fields}|{'pending':None if row['pending'] is None else row['pending']['value']}
   assert canonical(projected)==canonical(expected[schema][name])
 generated=data['inspection/inspection.mjs'];assert sha(generated)==m['generatedSHA256']
 text=generated.decode();assert 'completed$1260$(($batch$058step$1260$(_batch_0, _operation_0)), _x_2)' in text
 assert '"applications": ($batch$058stepped$1260$(_apps_0, _operation_0))' in text
 assert '"head": ($stepper$058step$1260$(_app_0, _operation_0)), "tail": ($batch$058stepped$1260$(_tail_0, _operation_0))' in text
 print('PORTABLE_FINITE_SAME_OWNER_FULL42_JS_AND_GENERATED_DEPENDENCY_PASS_NO_TIMING_CREDIT')
if __name__=='__main__':verify()
