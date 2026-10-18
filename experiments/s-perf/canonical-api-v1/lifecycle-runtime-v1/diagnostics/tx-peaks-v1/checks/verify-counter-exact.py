"""Post-run exact countermodel comparison; the derived wrong gold was not presealed."""
from pathlib import Path
import hashlib,json
L=Path(__file__).resolve().parent.parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
normal=L/'oracle/motion64.stats.json';value=json.loads(normal.read_bytes());wrong={'samples':[dict(row,undo=row['undo']+1) for row in value['samples']]};expected=(json.dumps(wrong,separators=(',',':'))+'\n').encode();normalSource=L/'subject/tx-metrics.bend';mutantSource=L/'counter-mutant/tx-metrics.bend';assert mutantSource.read_bytes()==normalSource.read_bytes().replace(b'Nat.show(undo)',b'Nat.show(1n+undo)')
rows=[]
for role in ['js','native']:
 q=Path('/tmp/bendvy21-lifecycle-tx-peaks-counter-mutant-actual01')/role;p=json.loads((q/'plan.json').read_text());r=json.loads((q/'receipt.json').read_text());actual=Path(p['metricArtifact']['path']);raw=actual.read_bytes();assert json.loads(raw)==wrong and raw==expected and len(wrong['samples'])==130;assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS';control=r['commands'][-1];assert control['exit']==1 and control['failure'] is None;rows.append({'role':role,'actualPath':str(actual),'actualSHA256':sha(actual),'actualBytes':len(raw),'planSHA256':sha(q/'plan.json'),'receiptSHA256':sha(q/'receipt.json')})
print(json.dumps({'status':'EXACT_COUNTER_MATCH','provenance':'Post-run comparison derived from presealed normal finite model and prefrozen one-line reporter mutation. No retroactive claim that wrong gold was presealed.','normalOracle':str(normal),'normalOracleSHA256':sha(normal),'normalSourceSHA256':sha(normalSource),'mutantSourceSHA256':sha(mutantSource),'expectedWrongSHA256':hashlib.sha256(expected).hexdigest(),'samples':130,'onlyFieldChange':'undo + 1; kind/commands/events and order unchanged','actual':rows,'checkerSHA256':sha(Path(__file__))},indent=2))
