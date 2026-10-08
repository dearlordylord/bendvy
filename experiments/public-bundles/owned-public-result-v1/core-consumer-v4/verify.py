"""Portable byte/receipt verification only; no child or installed tool discovery."""
from pathlib import Path
import hashlib,json,zipfile
HERE=Path(__file__).resolve().parent
h=lambda b:hashlib.sha256(b).hexdigest()
def decoded(x):return bytes.fromhex(x['rawHex']) if set(x)=={'rawHex'} else x
m=json.loads((HERE/'FINITE-DELIVERY.json').read_text())
assert all(h((HERE/n).read_bytes())==v for n,v in m['selectedLiveFiles'].items())
with zipfile.ZipFile(HERE/'evidence-v1.zip') as z:
 assert set(z.namelist())==set(m['archiveEntries'])
 assert all(h(z.read(n))==v for n,v in m['archiveEntries'].items())
 prefix='core-consumer-v4/'
 plan=json.loads(z.read(prefix+'execution-plan.json'),object_hook=decoded)
 receipt=json.loads(z.read(prefix+'execution/receipt.json'),object_hook=decoded)
 assert h(z.read(prefix+'execution-plan.json'))==m['planSha256']==receipt['planSHA256']
 assert h(z.read(prefix+'execution/receipt.json'))==m['receiptSha256']
 assert receipt['status']=='CORE_ONLY_TWO_FAMILY_CONSUMER_SAFE_SOURCE_MATCH_NOT_PROOF_NOT_RUNTIME'
 assert len(receipt['commands'])==1 and len(receipt['toolGuardSnapshots'])==3 and len(receipt['probeCommands'])==6
 c=receipt['commands'][0];assert c['exit']==0 and c['failure'] is None and c['seconds']==5
 assert c['result']['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
 assert c['result']['stderr'] in [b'',b'bend 2.0.36 is available: run bend update\n']
 for n,v in receipt['rawLogs'].items():assert h(z.read(prefix+'execution/'+n))==v
 assert plan['snapshotReuse']['inheritedPreparationProbeCount']==2 and plan['snapshotReuse']['freshPreparationProbeCount']==0
 assert len(plan['stageFiles'])==69 and receipt['stagedInputs']==plan['stageFiles']
 import io
 with zipfile.ZipFile(io.BytesIO(z.read(prefix+'source-stage.zip'))) as stage:
  assert set(stage.namelist())==set(plan['stageFiles'])
  assert all(h(stage.read(n))==v for n,v in plan['stageFiles'].items())
print('Byte bindings and one source-only receipt verified; no proof/runtime claim.')
