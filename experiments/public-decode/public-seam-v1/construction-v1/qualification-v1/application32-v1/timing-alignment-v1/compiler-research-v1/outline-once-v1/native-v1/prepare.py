"""Metadata-only artifact continuation of exact successful outlined C; no child."""
from pathlib import Path
import json,hashlib,types
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
ACTUAL=Path('/tmp/bendvy-inspect54-outline-once01')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 old=json.loads((ACTUAL/'plan.json').read_text());receipt=json.loads((ACTUAL/'receipt.json').read_text())
 assert receipt['commands'][0]['exit']==0 and receipt['commands'][0]['failure'] is None
 assert receipt['status']=='INSTRUMENTED_C_EMISSION_WITH_COST_CAPTURED'
 assert sha(ACTUAL/'reference.c')==receipt['emitArtifactSHA256']=='1213c7de4cf2dbf8ba7437ee65cf4b949f44f3fb4966ddfdba7a870908856a33'
 assert sha(ACTUAL/'cost.json')==receipt['costArtifactSHA256'] and receipt['costSummary']['compilerCompleted']
 pins=dict(old['pins']);assert {p:sha(p) for p in pins}==pins
 for row in receipt['guards']:
  assert sha(row['path'])==row['sha256'] and json.loads(Path(row['path']).read_text())['unchanged'];pins[row['path']]=row['sha256']
 for p in ACTUAL.iterdir():
  if p.is_file():pins[str(p)]=sha(p)
 for p in HERE.iterdir():
  if p.is_file() and p.name not in ('plan.json','PREPARED.json'):pins[str(p.resolve())]=sha(p)
 out=Path('/tmp/bendvy-inspect54-outline-native01');out.mkdir()
 tools=old['tools'];binary=out/'inspector.native';plan=dict(old)
 plan.update(scope='Artifact-only outlined copied-compiler fullInspector Native whole finite oracle; no compiler adoption/performance/#54 closure',pins=pins,cwd=str(HERE),generated=str(ACTUAL/'reference.c'),native=str(binary),commands=[{'label':'build','argv':[tools['taskset'],'-c','5',tools['clangWrapper'],'-O3',str(ACTUAL/'reference.c'),'-o',str(binary),'-pthread','-lm'],'capSeconds':120},{'label':'consumer','argv':[tools['taskset'],'-c','5',str(binary),'--threads','1','--gpu','off'],'capSeconds':5}],postConsumer='Exact full independent5077477-byte oracle and empty stderr; no emit',priorC={'plan':str(ACTUAL/'plan.json'),'planSHA256':sha(ACTUAL/'plan.json'),'receipt':str(ACTUAL/'receipt.json'),'receiptSHA256':sha(ACTUAL/'receipt.json'),'Csha256':sha(ACTUAL/'reference.c'),'Cbytes':(ACTUAL/'reference.c').stat().st_size,'cost':str(ACTUAL/'cost.json'),'costSHA256':sha(ACTUAL/'cost.json')})
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');(HERE/'plan.json').write_bytes(path.read_bytes())
 index={'status':'FROZEN_UNADMITTED_NO_CHILD','plan':str(path),'sha256':sha(path),'launchArgv':[tools['python'],str(HERE/'development.py'),str(path),sha(path)],'stages':['artifact-onlybuild120','wholeconsumer5'],'priorC':plan['priorC']};(HERE/'PREPARED.json').write_text(json.dumps(index,indent=2)+'\n');print(json.dumps(index))
if __name__=='__main__':main()
