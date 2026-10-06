#!/usr/bin/env python3
"""Exact source-bound full65 rotated raw diagnostic; no qualified keep."""
import argparse,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--candidate',type=Path,required=True);p.add_argument('--recipe-directory',type=Path,required=True);p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--rotation',type=int,choices=range(7),required=True);p.add_argument('--native-build',type=Path);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Prospective query-state raw full65 diagnostic; transaction query-ingress gate OPEN, no selection/qualification/adoption','schema':a.schema,'rotation':a.rotation,'CPU':11,'recipeSHA256':sha(Path(__file__)),'commands':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(role,argv):
 argv=list(map(str,argv));code,out=supervisor.execute(argv,5);f=a.output/(role+'.txt');f.write_text(out);r['commands'].append({'role':role,'argv':argv,'limitSeconds':5,'exit':code,'outputSHA256':sha(f)});save();assert code==0,out[-1000:];return out
try:
 receipt=Path(str(a.candidate)+'.recipe.json');m=json.loads(receipt.read_text());d=a.recipe_directory;catalog=d/'input-pins.json';pin=json.loads(catalog.read_text())[m['inputSHA256']];parent=Path(pin['inputPath']);pm=json.loads(Path(str(parent)+'.recipe.json').read_text())
 assert m['status']=='STRICT_DESCENDING_QUERY_STATE_REUSE_PASS' and pin['schema']==a.schema and pin['label']=='normal-'+a.schema.lower()
 assert m['outputSHA256']==sha(a.candidate) and m['inputSHA256']==sha(parent) and m['recipeSHA256']==sha(d/'rewrite.cjs') and m['catalogSHA256']==sha(catalog)
 assert m['family']==pin['family'] and len(m['family'])==6 and m['terminalCount']==5 and m['edges']==5
 assert pm['status']=='PINNED_DIRECT_TUPLE_SCALAR_RECEIVERS_DERIVED' and pm['schema']==a.schema.lower() and pm['mode']=='cursor-normal' and pm['outputSHA256']==sha(parent)
 assert pm['sourcePins']==pin['sourcePins'] and pm['sourceRoot']==pin['sourceRoot']
 for name,h in pin['files'].items():assert sha(name)==h
 for name,h in pm['provenancePins'].items():assert sha(name)==h
 assert len(pin['sourcePins'])==29
 for name,h in pin['sourcePins'].items():assert sha(Path(pin['sourceRoot'])/name)==h
 r['inputs']={'candidateSHA256':sha(a.candidate),'parentSHA256':sha(parent),'derivationReceiptSHA256':sha(receipt),'sourceRoot':pin['sourceRoot'],'sourcePins':pin['sourcePins'],'catalogSHA256':sha(catalog),'guardedRecipeSHA256':sha(d/'rewrite.cjs'),'producerPins':pin['files'],'parentProvenancePins':pm['provenancePins']}
 paths={'TS':None,'parent-JS':['node',parent],'candidate-JS':['node',a.candidate]}
 if a.native_build:
  build=a.native_build;nb=json.loads((build/'build.json').read_text());assert nb['status']=='BUILD_PASS' and nb['schema']==a.schema and nb['sourcePins']==pin['sourcePins']
  assert all(sha(build/n)==h for n,h in nb['artifacts'].items()) and sha(build/'measurement-bend.bend')==nb['measurementOutputSHA256']
  assert str(build/'build.json') in pm['provenancePins'] and pm['provenancePins'][str(build/'build.json')]==sha(build/'build.json')
  for argv,cap in [(['bend',str(build/'batch.bend'),'--check-only'],15),(['bend',str(build/'batch.bend'),'-o',str(build/'batch.c')],30),(['bend',str(build/'batch.bend'),'-o',str(build/'batch.js')],30),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(build/'batch.c'),'-o',str(build/'batch-native'),'-lm','-pthread'],120)]:
   hits=[c for c in nb['commands'] if c['argv']==argv];assert len(hits)==1 and hits[0]['limitSeconds']==cap and hits[0]['exit']==0 and not hits[0].get('timeout',False)
  assert sha('/tmp/bendvy-clang19-diagnostic/clang19')=='3e171a978d6c1decae4e6645e9bfb771cf5af21ff699ea119fdb058936b0af2d'
  r['native']={'buildReceiptSHA256':sha(build/'build.json'),'artifacts':nb['artifacts'],'same29Source':True,'flags':'Clang19 -O3 one-worker GPU-off'};paths['Native']=[build/'batch-native','--threads','1','--gpu','off']
 ref=a.output/'reference.mjs';run('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema',a.schema,'--batch','64']);paths['TS']=['node',ref]
 order=['TS',*(['Native'] if a.native_build else []),'parent-JS','candidate-JS'];shift=a.rotation%len(order);order=order[shift:]+order[:shift]
 if a.rotation%2:order=order[::-1]
 r['executionOrder']=order;outputs={role:run(role,paths[role]) for role in order};ts=json.loads(outputs['TS']);assert ts['schema']==a.schema and ts['count']==256 and ts['iterations']==64 and ts['batch']==64 and len(ts['samples'])==64
 sp=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(sp);sp.loader.exec_module(V);r['phaseMS']={'TS':ts['batchMilliseconds']}
 for role in order:
  if role=='TS':continue
  lines=outputs[role].splitlines();records=[line for line in lines if line.startswith('{')];clocks=[line for line in lines if line.startswith('BATCH-MILLISECONDS:')];assert len(records)==65 and len(clocks)==1
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,a.schema,False,256,world);assert V.normalized(json.loads(line),a.schema)==world['final']
  r['phaseMS'][role]=float(clocks[0].split(':',1)[1])
 r.update(status='SOURCE_BOUND_PARENT_CANDIDATE_FULL65_RAW_DIAGNOSTIC_PASS',fullFieldsEqual=True)
except Exception as e:r.update(status='FAIL',error=repr(e))
finally:save()
print(json.dumps({k:r.get(k) for k in ['status','schema','phaseMS','error']}));sys.exit(0 if r['status']=='SOURCE_BOUND_PARENT_CANDIDATE_FULL65_RAW_DIAGNOSTIC_PASS' else 1)
