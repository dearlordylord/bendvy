#!/usr/bin/env python3
"""Source-pinned full65 emitted-JS diagnostic; no Native or keep claim."""
import argparse,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--token-pooled',action='store_true');p.add_argument('--rotation',type=int,choices=range(7),default=0);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11});s=a.schema.lower();baseline=Path('/tmp/bendvy-js-joined-journalledger-'+s+'-pool-v3.js');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Full65 JS diagnostic against actual TS and unchanged joined JS; no qualified keep, Native claim or compiler adoption','schema':a.schema,'rotation':a.rotation,'cpu':11,'commands':[],'recipeSHA256':sha(Path(__file__))}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(label,args):
 c={'role':label,'argv':list(map(str,args)),'limitSeconds':5};r['commands'].append(c);save();code,out=supervisor.execute(c['argv'],5);f=a.output/(label+'.txt');f.write_text(out);c.update(exit=code,outputSHA256=sha(f));save();assert code==0,out[-1000:];return out
try:
 recipe=Path(str(a.candidate)+'.recipe.json');m=json.loads(recipe.read_text());cat=json.loads((HERE/'input-pins.json').read_text());pin=cat[m['inputSHA256']]
 assert m['outputSHA256']==sha(a.candidate) and m['inputSHA256']==sha(baseline) and m['schema']==s and m['recipeSHA256']==sha(HERE/'rewrite.cjs') and m['catalogSHA256']==sha(HERE/'input-pins.json')
 prior=Path(str(baseline)+'.recipe.json');assert sha(prior)==pin['poolReceiptSHA256'];pool=json.loads(prior.read_text());root=Path(pin['poolRecipeRoot']);assert pool['outputSHA256']==sha(baseline) and pool['recipeSHA256']==sha(root/'token-pool/rewrite.cjs') and pool['catalogSHA256']==sha(root/'token-pool/input-pins.json')
 pc=json.loads((root/'token-pool/input-pins.json').read_text())[pool['inputSHA256']];rowpath=Path(pc['inputPath']);rowreceipt=Path(str(rowpath)+'.recipe.json');row=json.loads(rowreceipt.read_text());assert sha(rowreceipt)==pc['rowRecipeSHA256'] and row['outputSHA256']==sha(rowpath)==pool['inputSHA256'] and row['recipeSHA256']==sha(root/'rewrite.cjs') and row['catalogSHA256']==sha(root/'input-pins.json')
 assert all(sha(Path(m['sourceRoot'])/n)==h for n,h in m['sourcePins'].items())
 r['inputs']={'baselineSHA256':sha(baseline),'candidateSHA256':sha(a.candidate),'transformReceiptSHA256':sha(recipe),'sourcePins':m['sourcePins']}
 reference=a.output/'reference.mjs';command('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',reference,'--schema',a.schema,'--batch','64'])
 order=['TS','baseline-JS','candidate-JS'];shift=a.rotation%3;order=order[shift:]+order[:shift]
 if a.rotation%2:order=order[::-1]
 paths={'TS':reference,'baseline-JS':baseline,'candidate-JS':a.candidate};r['executionOrder']=order;out={label:command(label,['node',paths[label]]) for label in order}
 ts=json.loads(out['TS']);assert ts['schema']==a.schema and ts['batch']==64 and len(ts['samples'])==64 and ts['count']==256 and ts['iterations']==64
 spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v);r['phaseMS']={'TS':ts['batchMilliseconds']}
 for label in ['baseline-JS','candidate-JS']:
  lines=out[label].splitlines();records=[x for x in lines if x.startswith('{')];clocks=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')];assert len(records)==65 and len(clocks)==1
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,a.schema,False,256,world);assert v.normalized(json.loads(line),a.schema)==world['final']
  r['phaseMS'][label]=float(clocks[0].split(':',1)[1])
 r.update(status='EMITTED_JS_FULL65_DIAGNOSTIC_PASS',fullFieldsEqual=True)
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:save()
print(json.dumps({k:r.get(k) for k in ['status','schema','phaseMS','error']}));sys.exit(0 if r['status']=='EMITTED_JS_FULL65_DIAGNOSTIC_PASS' else 1)
