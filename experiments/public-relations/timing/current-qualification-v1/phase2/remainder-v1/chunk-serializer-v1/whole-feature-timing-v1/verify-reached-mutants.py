"""No-child complete retained25 negative cases; raw oracle/marker/witness verification."""
from pathlib import Path
import gzip,hashlib,json
H=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
plans=[('last-leaf-js',H/'mutant-runtime-evidence-v1/last-leaf-js',H/'mutant-runtime01/last-leaf-js-runtime-plan.json.gz',8),('moved-walk-js',H/'mutant-runtime-evidence-v1/moved-walk-js',H/'mutant-runtime01/moved-walk-js-runtime-plan.json.gz',8),('last-leaf-native',H/'last-leaf-native-evidence-v1',H/'mutant-native-runtime04/last-leaf-native-runtime-plan.json.gz',9)]
total=guards=0
for role,evidence,packed,count in plans:
 plan=json.loads(gzip.decompress(packed.read_bytes()));r=json.loads((evidence/'receipt.json').read_text())
 assert r['planSHA256']==hashlib.sha256(gzip.decompress(packed.read_bytes())).hexdigest()
 assert len(r['commands'])==count and len(r['guards'])==2+2*count and all(g['unchanged'] is True for g in r['guards']);guards+=len(r['guards'])
 assert r['status'] in ('REACHED_CURRENT_MUTANT_GATE_PASS','NATIVE_FULL9_LASTLEAF_GATE_PASS_NO_TIMING')
 for name,row in zip([c['label'] for c in plan['commands']],r['commands']):
  c=next(c for c in plan['commands'] if c['label']==name);assert row['label']==name and row['exit']==0 and row['failure'] is None and row['positiveGateRejected'] and row['completeCounterOraclePass'] is True and row['markerStatGatePass'] is True
  raw=gzip.decompress((evidence/(name+'.stdout.gz')).read_bytes());positive=gzip.decompress((H/'prepared'/Path(c['positiveOracle']).name).read_bytes());counter=gzip.decompress((H/'prepared'/Path(c['counterOracle']).name).read_bytes());assert raw==counter and hashlib.sha256(raw).hexdigest()==r['logs'][name+'.stdout'];assert sum(len(w['records']) for w in json.loads(raw)['roots'])==30
  err=evidence/(name+'.stderr');assert sha(err)==r['logs'][name+'.stderr'];markers=[json.loads(line) for line in err.read_bytes().splitlines()];assert markers[0]=={'boundary':'begin'}
  if role=='moved-walk-js':assert raw==positive and len(markers)==3;walks=[dict(nodes=0,characters=0,sum=0),c['counterWalk']]
  else:
   assert raw!=positive and len(markers)==2;original=json.loads(positive);assert original['roots'][-1]['records'][-1]['systemResult'] is None;original['roots'][-1]['records'][-1]['systemResult']=1;assert json.loads(raw)==original;walks=[c['counterWalk']]
  for marker,walk in zip(markers[1:],walks):
   marker=dict(marker);duration=marker.pop('elapsedNs');assert type(duration)is str and duration.isascii() and duration.isdecimal();assert all(type(marker[k])is int for k in ('nodes','characters','sum'));assert marker=={'boundary':'complete-trace-forced',**walk,'region':'whole-feature-setup-operations-full-trace'}
  total+=1
print(json.dumps({'status':'RETAINED25_REACHED_WHOLE_MUTANT_GATES_PASS','fullOutputs':total,'serializedGuards':guards,'requiredBlocked':['JS1024 unchangedserialization','Native movedwalk originalemitdeadline/missingpostgap'],'comparativeTiming':False}))
