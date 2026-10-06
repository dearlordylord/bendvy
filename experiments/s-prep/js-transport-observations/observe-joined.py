#!/usr/bin/env python3
"""Raw full65 observation of an exact guarded direct-Tuple JS derivation."""
import argparse,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser()
p.add_argument('--candidate',type=Path,required=True)
p.add_argument('--native-build',type=Path,required=True)
p.add_argument('--native-receipt',type=Path,required=True)
p.add_argument('--recipe-directory',type=Path,required=True)
p.add_argument('--schema',choices=['Motion','Health'],required=True)
p.add_argument('--rotation',type=int,choices=range(7),required=True)
p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Joined exact-source full65 Dense diagnostic; no qualified keep, workload matrix, source/compiler adoption or complete acceptance','schema':a.schema,'rotation':a.rotation,'CPU':11,'recipeSHA256':sha(Path(__file__)),'commands':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(role,argv):
 c={'role':role,'argv':list(map(str,argv)),'limitSeconds':5};r['commands'].append(c);save()
 code,out=supervisor.execute(c['argv'],5);f=a.output/(role+'.txt');f.write_text(out);c.update(exit=code,outputSHA256=sha(f));save();assert code==0,out[-1000:];return out
try:
 receipt=Path(str(a.candidate)+'.recipe.json');m=json.loads(receipt.read_text());d=a.recipe_directory
 constant=m['status']=='STRICT_CONSTANT_SWAP_PASS'
 state=m['status']=='STRICT_PRIVATE_CURSOR_STATE_REUSE_PASS'
 unused=m['status']=='STRICT_UNUSED_PLAIN_PRIVATE_ROW_PROJECTIONS_PASS'
 if unused:
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
 build=a.native_build;nb=json.loads(a.native_receipt.read_text());assert nb['status']=='BUILD_PASS' and nb['schema']==a.schema and nb['sourcePins']==m['sourcePins']
 assert str(a.native_receipt) in m['provenancePins'] and m['provenancePins'][str(a.native_receipt)]==sha(a.native_receipt)
 assert {n:sha(build/n) for n in ['batch.bend','batch.c','batch-native','batch.js']}==nb['artifacts']
 assert sha(build/'measurement-bend.bend')==nb['measurementOutputSHA256']
 for argv,cap in [(['bend',str(build/'batch.bend'),'--check-only'],15),(['bend',str(build/'batch.bend'),'-o',str(build/'batch.c')],30),(['bend',str(build/'batch.bend'),'-o',str(build/'batch.js')],30),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(build/'batch.c'),'-o',str(build/'batch-native'),'-lm','-pthread'],120)]:
  hits=[c for c in nb['commands'] if c['argv']==argv];assert len(hits)==1 and hits[0]['limitSeconds']==cap and hits[0]['exit']==0 and not hits[0].get('timeout',False)
 assert sha(Path('/tmp/bendvy-clang19-diagnostic/clang19'))=='3e171a978d6c1decae4e6645e9bfb771cf5af21ff699ea119fdb058936b0af2d'
 r['joinedNative']={'actualReceiptPath':str(a.native_receipt),'actualReceiptSHA256':sha(a.native_receipt),'artifacts':nb['artifacts'],'measurementOutputSHA256':nb['measurementOutputSHA256'],'same29SourceAsDerivedJS':True,'workerCount':1,'GPU':'off'}
 ref=a.output/'reference.mjs';run('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema',a.schema,'--batch','64'])
 order=['TS','Native','candidate-JS'];shift=a.rotation%3;order=order[shift:]+order[:shift]
 if a.rotation%2:order=order[::-1]
 paths={'TS':['node',ref],'Native':[build/'batch-native','--threads','1','--gpu','off'],'candidate-JS':['node',a.candidate]};r['executionOrder']=order;outputs={role:run(role,paths[role]) for role in order}
 ts=json.loads(outputs['TS']);assert ts['schema']==a.schema and ts['count']==256 and ts['iterations']==64 and ts['batch']==64 and len(ts['samples'])==64
 spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 r['phaseMS']={'TS':ts['batchMilliseconds']}
 for role in ['Native','candidate-JS']:
  lines=outputs[role].splitlines();records=[x for x in lines if x.startswith('{')];clocks=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')];assert len(records)==65 and len(clocks)==1
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,a.schema,False,256,world);assert v.normalized(json.loads(line),a.schema)==world['final']
  r['phaseMS'][role]=float(clocks[0].split(':',1)[1])
 r.update(status='EXACT_JOINED_SOURCE_FULL65_RAW_DIAGNOSTIC_PASS',fullFieldsEqual=True)
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:save()
print(json.dumps({k:r.get(k) for k in ['status','schema','phaseMS','error']}));sys.exit(0 if r['status']=='EXACT_JOINED_SOURCE_FULL65_RAW_DIAGNOSTIC_PASS' else 1)
