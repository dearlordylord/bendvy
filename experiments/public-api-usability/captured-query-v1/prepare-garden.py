"""Reuse qualified Workshop artifacts for the other nominal schema, no rebuild."""
from pathlib import Path
import copy,gzip,hashlib,json,subprocess
W=Path(__file__).resolve().parents[3];D=Path(__file__).parent;sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();parent=Path('/tmp/bendvy73-captured-query-workshop-actual02/normal');output=Path('/tmp/bendvy73-captured-query-garden-actual01');assert not output.exists();output.mkdir();gold=D/'oracle/amendment01/garden.stdout';oracle=output/'expected.stdout.gz';oracle.write_bytes(gzip.compress(gold.read_bytes(),mtime=0));commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=W,text=True).strip();qualified={}
for role in ['js','native']:
 q=parent/role;p=json.loads((q/'plan.json').read_text());r=json.loads((q/'receipt.json').read_text());assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and r['planSHA256']==sha(q/'plan.json')and all(c['exit']==0 and c['failure']is None for c in r['commands']);assert(q/'consumer.stdout').read_bytes()==(D/'oracle/amendment01/workshop.stdout').read_bytes()and(q/'consumer.stderr').read_bytes()==b''
 for f,h in p['pins'].items():assert sha(f)==h,f
 artifact=Path(p['generated']if role=='js'else p['native']);assert sha(artifact)==(p['pins'][str(artifact)]if role=='js'else r['buildArtifactSHA256']);qualified[role]=(p,r,artifact)
for role,(p,r,artifact)in qualified.items():
 q=output/'normal'/role;q.mkdir(parents=True);pins=dict(p['pins'])
 for f in [Path(__file__),oracle,gold,artifact,*[parent/k/n for k in ['js','native']for n in ['plan.json','receipt.json','consumer.stdout','consumer.stderr']]]:pins[str(f)]=sha(f)
 command=copy.deepcopy(next(c for c in p['commands']if c['label']=='consumer'));command['argv']=['garden'if v=='workshop'else v for v in command['argv']]
 p.update(scope='Public executable captured-query App helper Garden schema; exact qualified Workshop artifacts reused, full independent Garden oracle; no performance claim',pins=pins,commands=[command],oracle=str(oracle),oracleBytes=gold.stat().st_size,oracleSHA256=sha(gold),normalOracle=str(oracle),normalOracleBytes=gold.stat().st_size,normalOracleSHA256=sha(gold),runtimeArguments=['garden'],sourceCommit=commit,producer={'plan':str(parent/role/'plan.json'),'planSHA256':sha(parent/role/'plan.json'),'receipt':str(parent/role/'receipt.json'),'receiptSHA256':sha(parent/role/'receipt.json'),'artifact':str(artifact),'artifactSHA256':sha(artifact),'scope':'Both complete Workshop roles qualified; no source/build change, only runtime nominal-schema mode'})
 for f,h in pins.items():assert sha(f)==h,f
 plan=q/'plan.json';plan.write_text(json.dumps(p,indent=2)+'\n');print(role,plan,sha(plan),flush=True)
