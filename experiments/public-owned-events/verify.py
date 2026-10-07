"""No-child validation of named complete local TS reference evidence."""
import hashlib,json
from pathlib import Path
W=Path(__file__).resolve().parent
r=json.loads((W/'reference-001/receipt.json').read_text());assert r['status']=='PREFLIGHT_PASS';assert len(r['commands'])==1;command=r['commands'][0];assert command['label']=='reference' and command['exit']==0 and command['failure'] is None
for stream in ['stdout','stderr']:
 raw=(W/'reference-001'/('reference.'+stream)).read_bytes();assert hashlib.sha256(raw).hexdigest()==command[stream+'SHA256'];gold=W/('expected-001.stdout' if stream=='stdout' else 'expected.stderr');assert raw==gold.read_bytes()
observed=json.loads((W/'reference-001/reference.stdout').read_text());assert observed['developmentOnly'] and not observed['acceptance'] and not observed['completeIssue53'];rows=observed['observed'];assert len(rows)==28
for root in ['OwnedAlpha','OwnedBeta']:
 checkpoints={x['label']:x['calls'] for x in rows if x['root']==root};assert len(checkpoints)==14
 for label in ['fast-shared-payload','slow-independent']:
  read=checkpoints[label][0];assert read['values']==[{'id':1,'cells':[11,99],'nested':{'text':'publisher-mutated'}}];assert read['identity']==[{'payload':True,'cells':True,'nested':True}]
 assert checkpoints['fast-failed'][0]['values']==checkpoints['fast-retry'][0]['values']==[{'id':2,'cells':[21,22],'nested':{'text':'event-2'}}]
 assert checkpoints['slow-condition-skipped']==[] and checkpoints['slow-resume-discards'][0]['values']==[]
 assert checkpoints['default-window-trim']==[{'values':[],'lagged':True}]
print(json.dumps({'status':'OWNED_EVENTS_TS_REFERENCE_EVIDENCE_VALID','roots':2,'checkpoints':28,'acceptance':False,'completeIssue53':False}))
