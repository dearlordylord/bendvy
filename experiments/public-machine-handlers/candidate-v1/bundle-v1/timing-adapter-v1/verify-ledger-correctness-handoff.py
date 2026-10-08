"""Portable read/hash/model-only complete IO ledger correctness; no backend execution."""
import hashlib,importlib.util,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda data:hashlib.sha256(data).hexdigest()
def module(path,name):
 spec=importlib.util.spec_from_file_location(name,path);result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
def verify():
 delivery=H/'delivery-ledger-correctness-v1';m=json.loads((delivery/'manifest.json').read_text())
 assert sha(Path(__file__).read_bytes())==m['verifierSHA256']
 assert sha((delivery/'REPORT.md').read_bytes())==m['reportSHA256']
 for relative,digest in m['prerequisite'].items():assert sha((H/relative).read_bytes())==digest
 module(H/'verify-native-inspection-handoff.py','prior_native_diagnostic').verify()
 archive=delivery/m['archive']['name'];assert sha(archive.read_bytes())==m['archive']['sha256']
 with tarfile.open(archive) as tf:
  members=tf.getmembers();assert len(members)==len({x.name for x in members}) and all(x.isfile() for x in members)
  assert {x.name for x in members}==set(m['archive']['members'])
  data={x.name:tf.extractfile(x).read() for x in members}
 for name,value in data.items():assert sha(value)==m['archive']['members'][name]['sha256'] and len(value)==m['archive']['members'][name]['bytes']
 obj=lambda name:json.loads(data[name]);p=obj('run/plan.json');r=obj('run/receipt.json')
 assert sha(data['run/plan.json'])==r['planSHA256']==m['planSHA256']=='22d346db4c109e9d71113eb86f9a502421f89ccbf1b4fa3680cdfe44c96f0986'
 assert sha(data['run/receipt.json'])==m['receiptSHA256']=='a55d1050643adcb85e5c1667c5f1077aeba027e5a902be71d9aaacef8c65b3f0'
 assert r['status']=='FULL42_SAME_OWNER_IO_LEDGER_JS_CORRECTNESS_PASS_NO_TIMING_CREDIT' and not r.get('guardFailures')
 assert r['independentValidationStatus']=='FULL42_SAME_OWNER_IO_LEDGER_CORRECTNESS_PASS_NO_TIMING_CREDIT'
 stage=Path(p['stage']);out=stage.parent;prefix=[p['tools']['taskset'],'-c','8'];generated=out/'ledger.js'
 assert p['commands']==[{'label':'ledger-emit','argv':prefix+[p['tools']['tools']['bend'],str(stage/'ledger-driver-source-v1/correctness-main.bend'),'-o',str(generated)],'seconds':30,'expected':0,'generated':str(generated)},{'label':'ledger-io-run','argv':prefix+[p['tools']['tools']['node'],str(generated)],'seconds':5,'expected':0}]
 assert len(r['commands'])==2 and all(c['exit']==0 and c['failure'] is None for c in r['commands']) and len(p['pins'])==1674
 raw={c['label']+suffix for c in p['commands'] for suffix in ['.stdout','.stderr']};assert set(r['logs'])==raw
 assert {name.removeprefix('run/') for name in data if name.startswith('run/') and name.endswith(('.stdout','.stderr')) and '/execution-probes/' not in name}==raw
 for name,digest in r['logs'].items():assert sha(data['run/'+name])==digest
 assert data['run/ledger-emit.stdout']==b'' and data['run/ledger-emit.stderr']==data['run/ledger-io-run.stderr']==b''
 assert {name.split('/')[1] for name in data if name.startswith('run/')}=={'plan.json','receipt.json','stage','execution-probes','ledger.js',*raw}
 expected=['guard-'+str(i)+'-ldd-'+tool for i in range(5) for tool in ['bend','node','python','taskset','clang']]
 assert p['executionProbeLabels']==expected and r['probeCommandsExecuted']==25
 probeNames={label+suffix for label in expected for suffix in ['.json','.stdout','.stderr']}
 assert {name.removeprefix('run/execution-probes/') for name in data if name.startswith('run/execution-probes/')}==probeNames
 assert set(r['probePins'])=={str(out/'execution-probes'/name) for name in probeNames}
 for path,digest in r['probePins'].items():assert sha(data['run/execution-probes/'+Path(path).name])==digest
 for label in expected:
  probe=obj('run/execution-probes/'+label+'.json');tool=label.rsplit('-ldd-',1)[1]
  assert probe['seconds']==5 and probe['exit']==0 and probe['failure'] is None and probe.get('exception') is None
  assert probe['argv']==[p['tools']['taskset'],'-c','8',p['tools']['ldd'],p['tools']['tools'][tool]]
 assert {name.removeprefix('run/stage/'):sha(value) for name,value in data.items() if name.startswith('run/stage/')}==p['inventory']
 assert r['generated']=={str(generated):sha(data['run/ledger.js'])} and sha(data['run/ledger.js'])==m['generatedSHA256']=='31d6af333660d7623d1aa7a20104ffb82cd66be23e950051b5bdf00385c17288'
 review=obj('source/ledger-driver-source-v1/source-review.json');assert sha(data['source/ledger-driver-source-v1/source-review.json'])==p['sourceReviewManifestSHA256']
 origins=[Path(name).parent.parent for name,digest in p['pins'].items() if name.endswith('/ledger-driver-source-v1/source-review.json') and digest==p['sourceReviewManifestSHA256']];assert len(origins)==1;origin=origins[0]
 for name,digest in review['files'].items():
  assert p['pins'][name]==digest
  path=Path(name)
  if path==origin.parent/'oracle.py':assert sha(data['source/independent-model.py'])==digest
  else:
   relative=path.relative_to(origin);assert '..' not in relative.parts
   if path.suffix=='.bend':assert sha(data['run/stage/'+str(relative)])==digest
   else:assert sha(data['source/'+str(relative)])==digest
 for relative,digest in m['selectedSource'].items():assert sha((H/relative).read_bytes())==digest==sha(data['source/'+relative])
 physical=obj('source/ledger-driver-source-v1/physical-expected-before-output.json');model=H.parent/'oracle.py'
 assert sha(model.read_bytes())==physical['modelSHA256']==sha(data['source/independent-model.py'])
 independent=module(model,'independent_bundle_model');ledger=obj('source/operations.json')
 names=[step['checkpoint'] for descriptor in ledger['scenarios'] for step in descriptor['steps'] if 'checkpoint' in step]
 assert physical['rows']=={schema:{name:independent.scenarios(1)[name] for name in names} for schema in ledger['schemas']}
 validate=module(H/'ledger-driver-source-v1/validate-correctness.py','independent_full_ledger_validator')
 complete=validate.validate(data['run/ledger-io-run.stdout'].decode());assert complete['status']==r['independentValidationStatus']
 assert len(ledger['scenarios'])==13 and sum(len(s['steps']) for s in ledger['scenarios'])==45 and len(names)==21
 delta=obj('source/ledger-telemetry-config-delta-proposal.json');assert p['historicalTelemetryCacheBoundary']==delta
 assert delta['BEND_NO_TELEMETRY']=='1' and delta['environmentSHA256']==p['environmentSHA256']
 assert delta['historicalState']['sha256']=='2701f29532eebe9f6fc5ed50c50cbfcbc33925cfe033065a86fa7bc8f9f43e5d' and delta['currentState']['sha256']=='2323ddd47baf7dd03018bcf923b6c9b4bb306f04c80bce7e21c4e5e62bc3c564'
 text=data['run/ledger.js'].decode();assert 'io_exit($main$, null);' in text and '{$: "ledger-driver.Correctness"}, 1)' in text and '$IO$pure$({$: "../stage/experiments/public-machine-handlers/candidate-v1/bundle-v1/clock-step.Timed", "batch":' in text
 assert 'history/metadata-config-failure.json' in data and 'history/loader-failure.json' in data
 assert obj('history/failed-source/receipt.json')['status']=='INCOMPLETE'
 for directory in ['driver-source-pass','main-source-pass']:
  receipt=obj('history/'+directory+'/receipt.json');assert receipt['status']=='DEVELOPMENT_LEDGER_TYPING_PASS_NO_RUNTIME_TIMING_CREDIT' and not receipt.get('guardFailures')
  for name,digest in receipt['logs'].items():assert sha(data['history/'+directory+'/'+name])==digest
 print('PORTABLE_FULL42_SAME_OWNER_IO_LEDGER_JS_CORRECTNESS_PASS_NO_TIMING_CREDIT')
if __name__=='__main__':verify()
