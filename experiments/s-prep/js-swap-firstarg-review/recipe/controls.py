#!/usr/bin/env python3
"""Fresh pinned emitted-code controls; no elapsed comparison or source gate transfer."""
from pathlib import Path
import argparse,json,hashlib,sys,os,importlib.util
ROOT=Path('/workspace/formal-proofs/bendvy');H=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));from supervisor import execute
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','cpu':9,'commands':[],'controllers':[],'scope':'Fresh actual source-bound 576 records with original independent/suppressed oracles; generated-only causal probe'}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(args,label):
 code,out=execute(list(map(str,args)),5);f=a.output/(label+'.txt');f.write_text(out);r['commands'].append({'argv':list(map(str,args)),'cap':5,'exit':code,'outputSHA':sha(f)});save();assert code==0,out[-1000:];return out
cat=json.loads((H/'input-pins.json').read_text());sets={}
def load(n,p):
 sp=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(sp);sp.loader.exec_module(m);return m
I=load('independent',ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py');S=load('suppression',ROOT/'experiments/s-prep/fivehour-connected-gates/suppressed-owner.py')
try:
 for digest,pin in cat.items():
  if pin['label'] in ['motion','health']:continue
  label=pin['label'];inp=Path(pin['inputPath']);out=a.output/(label+'.js');assert sha(inp)==digest
  run(['node','--expose-internals',H/'rewrite.cjs',inp,out],label+'-derive');observed=a.output/(label+'-coverage.js');coverage=a.output/(label+'-coverage.json');run(['node','--expose-internals',H/'coverage.cjs',out,observed,coverage],label+'-coverage-derive');before=run(['node',inp],label+'-parent');after=run(['node',observed],label+'-candidate');route=json.loads(coverage.read_text());assert route=={'ingress':18,'take':6,'returned':4};assert before==after
  stored=Path('/tmp/bendvy-private-id-query-descending-tx-controls-v1')/(label+'-js-run.stdout');assert after==stored.read_text()
  recs=[json.loads(x) for x in after.splitlines()];assert len(recs)==72;sets[label]=recs;r['controllers'].append({'label':label,'inputSHA':digest,'candidateSHA':sha(out),'records':72,'actualRouteCounts':route,'observedSHA':sha(observed)});save()
 baseline=None
 for suppressed in [False,True]:
  getters=[]
  for getter in ['cached','raw']:
   combined=[]
   for scenario in range(9):
    for lane in ['motion','health']:combined.extend(sets[('suppressed-' if suppressed else '')+getter+'-'+lane][scenario*8:scenario*8+8])
   if suppressed:assert combined==S.expected_noop(baseline) and combined!=baseline
   else:I.independent(combined);assert not I.differences(combined);baseline=combined
   getters.append(combined)
  assert getters[0]==getters[1]
 r.update(status='FRESH_576_CURRENT_TX_SUPPRESSION_AND_PROTECTED_ORACLES_PASS',records=576,oraclePins={str(p):sha(p) for p in [ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py',ROOT/'experiments/s-prep/fivehour-connected-gates/suppressed-owner.py']})
except Exception as e:r.update(status='FAILED',error=repr(e))
save();print(json.dumps({'status':r['status'],'error':r.get('error'),'records':sum(x['records'] for x in r['controllers'])}));sys.exit(0 if r['status'].endswith('_PASS') else 1)
