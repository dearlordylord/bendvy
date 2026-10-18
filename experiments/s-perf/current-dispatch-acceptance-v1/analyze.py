"""Verify completed normal/counter streams; report concrete reached differences."""
from pathlib import Path
import hashlib,json
D=Path(__file__).parent;sha=lambda b:hashlib.sha256(b).hexdigest();normal=(D/'oracle/expected.stdout').read_bytes();counter=(D/'oracle/counter.inverse.stdout').read_bytes();assert normal!=counter
cases=[]
for kind,parent in [('normal','/tmp/bendvy21-current-dispatch-acceptance-actual02/normal'),('inverse','/tmp/bendvy21-current-dispatch-controls-actual01')]:
 for role in ['js','native']:
  q=Path(parent)/role;p=json.loads((q/'plan.json').read_text());r=json.loads((q/'receipt.json').read_text());actual=(q/'consumer.stdout').read_bytes();expected=normal if kind=='normal'else counter
  assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and actual==expected and(q/'consumer.stderr').read_bytes()==b''
  assert r['planSHA256']==sha((q/'plan.json').read_bytes())and all(g['unchanged']for g in [json.loads(Path(x['path']).read_text())for x in r['guards']])
  cases.append({'kind':kind,'role':role,'directory':str(q),'bytes':len(actual),'sha256':sha(actual),'normalOracleRejected':actual!=normal if kind=='inverse'else False,'counterOracleMatched':actual==counter if kind=='inverse'else False})
source=Path('/tmp/bendvy21-current-dispatch-controls-actual01/source');r=json.loads((source/'receipt.json').read_text());assert r['status']=='COMPLETE_SOURCE_CONTROL_PASS';assert[x['exit']for x in r['commands']]==[0,1,1,1]
def failure_main(raw):
 line=next(x for x in raw.decode().splitlines()if x.startswith('failure:'));return line.split('|store={main={',1)[1].split('};aux={',1)[0]
witness={'normalFailureMain':failure_main(normal),'inverseFailureMain':failure_main(counter),'explanation':'Oldest-first inverses leave intermediate +10 Position arrays and intermediate changed stamps after failure. The ordinary App callback is reached; same-owner retry and repeat consume that corrupted state. Unrelated owners/capture/identity remain fully included in both independently sealed streams.'}
result={'scope':'Bounded current ordinary dispatch source/authority/rollback-order evidence; no full22 aggregate or performance qualification','cases':cases,'sourceExpectedExits':[0,1,1,1],'witness':witness};print(json.dumps(result,indent=2))
