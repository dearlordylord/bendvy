"""Portable evidence verification; no backend, tool child, or proof claim."""
from pathlib import Path
import hashlib,json,zipfile,io
HERE=Path(__file__).resolve().parent;h=lambda b:hashlib.sha256(b).hexdigest()
def decoded(x):return bytes.fromhex(x['rawHex']) if set(x)=={'rawHex'} else x
m=json.loads((HERE/'FINITE-DELIVERY.json').read_text());assert all(h((HERE/n).read_bytes())==v for n,v in m['selectedLiveFiles'].items())
with zipfile.ZipFile(HERE/'evidence-v1.zip') as z:
 assert len(z.namelist())==len(m['archiveEntries']) and set(z.namelist())==set(m['archiveEntries'])
 assert all(h(z.read(n))==v for n,v in m['archiveEntries'].items())
 p='core-runtime-v1/';plan=json.loads(z.read(p+'execution-plan.json'),object_hook=decoded);receipt=json.loads(z.read(p+'execution/receipt.json'),object_hook=decoded)
 assert h(z.read(p+'execution-plan.json'))==m['planSha256']==receipt['planSHA256'] and h(z.read(p+'execution/receipt.json'))==m['receiptSha256']
 assert receipt['status']=='CORE_ONLY_BOOTSTRAP_SPAWN_INSERT_RESTORE_RETURN_JS_NATIVE_PASS_NOT_PROOF_NOT_PERFORMANCE'
 assert [c['seconds'] for c in receipt['commands']]==[5,30,5,30,120,5]
 assert [c['exit'] for c in receipt['commands']]==[1,0,0,0,0,0] and all(c['failure'] is None for c in receipt['commands'])
 assert len(receipt['toolGuardSnapshots'])==13 and len(receipt['probeCommands'])==52 and len(plan['preparationProbeResults'])==4
 assert receipt['commands'][0]['result']['stdout']==z.read(p+'expected-source.stdout')
 assert receipt['commands'][0]['result']['stderr'] in [z.read(p+'expected-source.stderr'),z.read(p+'expected-source.stderr')+b'bend 2.0.36 is available: run bend update\n']
 for i in [2,5]:assert receipt['commands'][i]['result']['stdout']==z.read(p+'expected.stdout') and not receipt['commands'][i]['result']['stderr']
 for n,v in receipt['rawLogs'].items():assert h(z.read(p+'execution/'+n))==v
 for n,v in receipt['generated'].items():
  if n in m['hashOnlyExcludedBinaries']:assert m['hashOnlyExcludedBinaries'][n]['sha256']==v
  else:assert h(z.read(p+'execution/'+n))==v
 assert len(plan['stageFiles'])==70 and receipt['stagedInputs']==plan['stageFiles']
 with zipfile.ZipFile(io.BytesIO(z.read(p+'source-stage.zip'))) as stage:
  assert len(stage.namelist())==70 and set(stage.namelist())==set(plan['stageFiles'])
  assert all(h(stage.read(n))==v for n,v in plan['stageFiles'].items())
 for n,v in plan['files'].items():
  if '/core-runtime-v1/' in n:
   relative=n.split('/core-runtime-v1/',1)[1]
   if p+relative in z.namelist():assert h(z.read(p+relative))==v
print('Exact source/evidence bindings and six finite subjects verified; no proof/performance claim.')
