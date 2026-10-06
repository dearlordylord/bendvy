#!/usr/bin/env python3
"""Raw full65 observation of an exact guarded direct-Tuple JS derivation."""
import argparse,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser()
p.add_argument('--candidate',type=Path,required=True)
p.add_argument('--recipe-directory',type=Path,required=True)
p.add_argument('--schema',choices=['Motion','Health'],required=True)
p.add_argument('--rotation',type=int,choices=range(7),required=True)
p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Raw full65 diagnostic only; no qualified keep, source/compiler adoption or Native claim','schema':a.schema,'rotation':a.rotation,'CPU':11,'recipeSHA256':sha(Path(__file__)),'commands':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(role,argv):
 c={'role':role,'argv':list(map(str,argv)),'limitSeconds':5};r['commands'].append(c);save()
 code,out=supervisor.execute(c['argv'],5);f=a.output/(role+'.txt');f.write_text(out);c.update(exit=code,outputSHA256=sha(f));save();assert code==0,out[-1000:];return out
try:
 receipt=Path(str(a.candidate)+'.recipe.json');m=json.loads(receipt.read_text());d=a.recipe_directory
 constant=m['status']=='STRICT_CONSTANT_SWAP_PASS'
 state=m['status']=='STRICT_PRIVATE_CURSOR_STATE_REUSE_PASS'
 unused=m['status']=='STRICT_UNUSED_PLAIN_PRIVATE_ROW_PROJECTIONS_PASS'
 sum4=m['status']=='EXACT_CLOSED_FOUR_U32_SUM_INNER_CASTS_REMOVED'
 if sum4:
  catalog=d/'input-pins.json';pin=json.loads(catalog.read_text())[m['inputSHA256']]
  assert pin['schema']==a.schema.lower() and pin['label']==a.schema.lower() and pin['mode']=='cursor-normal'
  assert m['outputSHA256']==sha(a.candidate) and m['recipeSHA256']==sha(d/'rewrite.cjs') and m['catalogSHA256']==sha(catalog)
  assert m['helper']==pin['sumName'] and m['removedCasts']==2 and m['bound']==17179869180 and m['bound']<2**53
  baseline=Path(pin['inputPath']);assert sha(baseline)==m['inputSHA256']
  for n,h in pin['files'].items():assert sha(Path(n))==h
  parent=Path(str(baseline)+'.recipe.json');pm=json.loads(parent.read_text());assert pm['status']=='STRICT_UNUSED_PLAIN_PRIVATE_ROW_PROJECTIONS_PASS' and pm['outputSHA256']==sha(baseline)
  m['sourcePins']=pin['sourcePins'];m['sourceRoot']=pin['sourceRoot'];m['provenancePins']={**pin['files'],str(catalog):sha(catalog),str(d/'rewrite.cjs'):sha(d/'rewrite.cjs')}
  r['u32SumAdmission']={'catalogSHA256':sha(catalog),'parentReceiptSHA256':sha(parent),'removedCasts':2,'maximumExactSum':m['bound']}
 elif unused:
  catalog=d/'input-pins.json';pin=json.loads(catalog.read_text())[m['inputSHA256']]
  assert pin['schema']==a.schema.lower() and pin['label']==a.schema.lower() and pin['mode']=='cursor-normal'
  assert m['outputSHA256']==sha(a.candidate) and m['recipeSHA256']==sha(d/'rewrite.cjs') and m['catalogSHA256']==sha(catalog)
  assert len(m['removed'])==sum(pin['expectedRemoved'].values()) and m['ownerProducers']==pin['expectedProducers']
  baseline=Path(pin['inputPath']);assert sha(baseline)==m['inputSHA256']
  for n,h in pin['files'].items():assert sha(Path(n))==h
  parent=Path(str(baseline)+'.recipe.json');pm=json.loads(parent.read_text());assert pm['status']=='PINNED_DIRECT_TUPLE_SCALAR_RECEIVERS_DERIVED' and pm['mode']=='cursor-normal' and pm['schema']==a.schema.lower() and pm['outputSHA256']==sha(baseline)
  assert pin['sourceRoot']==pm['sourceRoot'] and pin['sourcePins']==pm['sourcePins']
  m['sourcePins']=pm['sourcePins'];m['sourceRoot']=pm['sourceRoot'];m['provenancePins']={**pin['files'],**pm['provenancePins'],str(catalog):sha(catalog),str(d/'rewrite.cjs'):sha(d/'rewrite.cjs')}
  r['unusedProjectionAdmission']={'catalogSHA256':sha(catalog),'parentReceiptSHA256':sha(parent),'removedReads':len(m['removed']),'ownerProducers':m['ownerProducers']}
 elif constant or state:
  catalog=d/'input-pins.json';pin=json.loads(catalog.read_text())[m['inputSHA256']]
  baseline=Path(pin['inputPath']);assert sha(baseline)==m['inputSHA256']
  assert pin['schema']==a.schema and pin['label']=='normal-'+a.schema.lower()
  if constant:assert pin['expectedSites']==9 and len(m['sites'])==9
  else:assert m['catalogSHA256']==sha(catalog) and m['family']==pin['family'] and len(m['family'])==6 and m['terminalCount']==5 and m['edges']==5
  assert m['outputSHA256']==sha(a.candidate) and m['recipeSHA256']==sha(d/'rewrite.cjs')
  if constant:assert m['sourceClosure']==pin['sourceClosure']=='bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94'
  for n,h in pin['files'].items():assert sha(Path(n))==h
  parent=Path(str(baseline)+'.recipe.json');pm=json.loads(parent.read_text());assert pm['status']=='PINNED_NESTED_DIRECT_LITERAL_SCALAR_EDGES_DERIVED' and pm['mode']=='cursor-normal' and pm['schema']==a.schema.lower() and pm['outputSHA256']==sha(baseline)
  m['sourcePins']=pm['sourcePins'];m['sourceRoot']=pm['sourceRoot'];m['provenancePins']={**pin['files'],**pm['provenancePins']}
  r['privateGeneratedAdmission']={'status':m['status'],'catalogSHA256':sha(catalog),'parentReceiptSHA256':sha(parent),'selectedSites':len(m.get('sites',[])),'runtimeSHA256':pin.get('runtimeSHA256'),'terminalCount':m.get('terminalCount')}
  m['provenancePins'].update({str(d/'rewrite.cjs'):sha(d/'rewrite.cjs'),str(catalog):sha(catalog)})
 else:
  nested=m['status']=='PINNED_NESTED_DIRECT_LITERAL_SCALAR_EDGES_DERIVED'
  assert (nested or m['status']=='PINNED_DIRECT_TUPLE_SCALAR_RECEIVERS_DERIVED') and m['schema']==a.schema.lower() and m['mode'] in ['normal','packed-paired-raw','cursor-normal']
  analysis=d.parent/'analyze.cjs' if nested else d/'analyze.cjs'
  assert m['outputSHA256']==sha(a.candidate) and m['recipeSHA256']==sha(d/'rewrite.cjs') and m['analysisSHA256']==sha(analysis) and m['catalogSHA256']==sha(d/'input-pins.json')
  pin=json.loads((d/'input-pins.json').read_text())[m['inputSHA256']];baseline=Path(pin['inputPath']);assert sha(baseline)==m['inputSHA256']
  assert pin['sourceRoot']==m['sourceRoot'] and pin['sourcePins']==m['sourcePins']
 assert len(m['sourcePins'])==29
 for n,h in m['sourcePins'].items():assert sha(Path(m['sourceRoot'])/n)==h
 for n,h in m['provenancePins'].items():assert sha(Path(n))==h
 r['inputs']={'baselineSHA256':sha(baseline),'candidateSHA256':sha(a.candidate),'actualDerivationReceiptSHA256':sha(receipt),'sourcePins':m['sourcePins'],'producerPins':m['provenancePins']}
 ref=a.output/'reference.mjs';run('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema',a.schema,'--batch','64'])
 order=['TS','baseline-JS','candidate-JS'];shift=a.rotation%3;order=order[shift:]+order[:shift]
 if a.rotation%2:order=order[::-1]
 paths={'TS':ref,'baseline-JS':baseline,'candidate-JS':a.candidate};r['executionOrder']=order;outputs={role:run(role,['node',paths[role]]) for role in order}
 ts=json.loads(outputs['TS']);assert ts['schema']==a.schema and ts['count']==256 and ts['iterations']==64 and ts['batch']==64 and len(ts['samples'])==64
 spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 r['phaseMS']={'TS':ts['batchMilliseconds']}
 for role in ['baseline-JS','candidate-JS']:
  lines=outputs[role].splitlines();records=[x for x in lines if x.startswith('{')];clocks=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')];assert len(records)==65 and len(clocks)==1
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,a.schema,False,256,world);assert v.normalized(json.loads(line),a.schema)==world['final']
  r['phaseMS'][role]=float(clocks[0].split(':',1)[1])
 r.update(status='EXACT_JS_TRANSPORT_FULL65_RAW_DIAGNOSTIC_PASS',fullFieldsEqual=True)
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:save()
print(json.dumps({k:r.get(k) for k in ['status','schema','phaseMS','error']}));sys.exit(0 if r['status']=='EXACT_JS_TRANSPORT_FULL65_RAW_DIAGNOSTIC_PASS' else 1)
