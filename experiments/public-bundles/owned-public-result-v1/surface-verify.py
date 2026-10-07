from pathlib import Path
import hashlib,json,runpy,zipfile
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
m=json.loads((HERE/'surface-delivery.json').read_text())
for name,want in m['selectedLiveFiles'].items():assert sha((HERE/name).read_bytes())==want,name
assert sha((HERE/'surface-evidence-v1.zip').read_bytes())==m['archiveSHA256']
with zipfile.ZipFile(HERE/'surface-evidence-v1.zip') as z:
 assert set(z.namelist())==set(m['archiveEntries'])
 for name,want in m['archiveEntries'].items():assert sha(z.read(name))==want,name
 assert not any('environment' in Path(n).name or Path(n).suffix=='.native' for n in z.namelist())
 r=json.loads(z.read('history/surface-backend-001/receipt.json'));plan=json.loads(z.read('history/surface-backend-plan-001.json'))
 assert r['status']=='FULL_BUNDLE_SURFACE_BACKENDS_FINITE_PASS'
 for command in r['commands']:
  assert command['exit']==0 and command['failure'] is None
  assert command['result']['exit']==command['exit'] and command['result']['failure']==command['failure']
  for stream in ['stdout','stderr']:
   assert bytes.fromhex(command['result'][stream]['rawHex'])==z.read('history/surface-backend-001/'+command['label']+'.'+stream)
 assert len(r['commands'])==5 and len(r['probeCommands'])==44 and len(r['toolGuardSnapshots'])==11
 assert len(plan['preparationProbeResults'])==4
 assert sha(z.read('history/surface-backend-plan-001.json'))==m['backendPlanSHA256']
 assert sha(z.read('history/surface-backend-001/receipt.json'))==m['backendReceiptSHA256']
 for name,want in r['rawLogs'].items():assert sha(z.read('history/surface-backend-001/'+name))==want,name
 for name,want in r['generated'].items():
  if not name.endswith('.native'):assert sha(z.read('history/surface-backend-001/'+name))==want,name
 assert set(r['fullPhysicalRows'].values())=={20}
 ts=z.read('history/surface-development-006/actual-TS-public-surface.stdout');cli=z.read('history/surface-development-006/complete-owned-surface.stdout')
 assert ts==(HERE/'surface-expected-reference.stdout').read_bytes()
 assert cli==(HERE/'surface-expected.stdout').read_bytes()
 assert len(json.loads(ts))==10
 actual={'CLI-in-processJSIO':cli}
 for backend in ['JS','Native']:
  actual[('standalone-JS' if backend=='JS' else backend)]=z.read('history/surface-backend-001/surface-'+backend+'-full20.stdout')
  assert actual[('standalone-JS' if backend=='JS' else backend)]==(HERE/'surface-expected.stdout').read_bytes()
  assert len(actual[('standalone-JS' if backend=='JS' else backend)].splitlines())==20
 join=runpy.run_path(str(HERE/'surface-public-join.py'))['compare']
 expected={name:join(stdout.decode(),ts.decode()) for name,stdout in actual.items()}
 assert expected==json.loads(z.read('history/surface-backend-001/declared-public-join.json'))
 assert all(len(d['publicCheckpoints'])==20 for d in expected.values())
 source=json.loads(z.read('history/surface-source-005/receipt.json'))
 assert source['status']=='PREFLIGHT_PASS' and source['commands'][0]['exit']==1
 assert z.read('history/surface-source-005/canonical-surface-IO-effect-boundary.stderr')==(HERE/'surface-expected-check.stderr').read_bytes()
 consumer=json.loads(z.read('history/surface-development-006/receipt.json'))
 assert consumer['status']=='PREFLIGHT_PASS' and len(consumer['commands'])==2
 for path,entry in m['consumedSourceObjects'].items():assert sha(z.read(entry['archive']))==entry['sha256'],path
assert m['baselineEvidenceArchiveSHA256']==json.loads((HERE/'bounded-delivery.json').read_text())['archiveSHA256']
runpy.run_path(str(HERE/'bounded-verify.py'))
print('FULL_SURFACE_HASH_ORACLE_LEDGER_PASS: no child executed; 5 backend subjects / 48 probes / 20 physical rows / 20 public projections per backend')
