#!/usr/bin/env python3
"""Exact source-bound full65 rotated raw diagnostic; no qualified keep."""
import argparse,hashlib,importlib.util,json,math,os,shutil,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--candidate',type=Path,required=True);p.add_argument('--legacy',type=Path,required=True);p.add_argument('--freeze',type=Path,required=True);p.add_argument('--recipe-directory',type=Path,required=True);p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--rotation',type=int,choices=range(10),required=True);p.add_argument('--native-build',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Sequential rotated raw full65 diagnostic, no noise qualification/keep/full matrix or product acceptance','schema':a.schema,'rotation':a.rotation,'CPU':11,'recipeSHA256':sha(Path(__file__)),'commands':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(role,argv):
 argv=list(map(str,argv));code,out=supervisor.execute(argv,5);f=a.output/(role+'.txt');f.write_text(out);r['commands'].append({'role':role,'argv':argv,'limitSeconds':5,'exit':code,'outputSHA256':sha(f)});save();assert code==0,out[-1000:];return out
try:
 consumed={str(x):sha(x) for x in [Path(__file__),ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs',ROOT/'experiments/s-integrate/measurement-bend-run.py',ROOT/'experiments/s-prep/fivehour-connected-gates/supervisor.py',ROOT/'.references/sources.json',Path(shutil.which('node'))]}
 reference=ROOT/'.references/bevy-ts';assert run('reference-head',['git','-C',reference,'rev-parse','HEAD']).strip()=='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
 assert not run('reference-clean',['git','-C',reference,'status','--porcelain','--untracked-files=all','--','packages/core/src']).strip()
 consumed.update({str(x):sha(x) for x in (reference/'packages/core/src').rglob('*') if x.is_file()});r['consumedMeasurementPins']=consumed;r['nodeVersion']=run('node-version',['node','--version']).strip()
 receipt=Path(str(a.candidate)+'.recipe.json');m=json.loads(receipt.read_text());d=a.recipe_directory;catalog=d/'input-pins.json';pin=json.loads(catalog.read_text())[m['inputSHA256']];parent=Path(pin['inputPath']);parentReceipt=Path(str(parent)+'.recipe.json');parentReceiptBytes=parentReceipt.read_bytes();pm=json.loads(parentReceiptBytes);consumed[str(parentReceipt)]=hashlib.sha256(parentReceiptBytes).hexdigest()
 assert m['status']=='STRICT_POSITIONED_CONSTANT_SWAP_SCALAR_BRIDGE_DERIVED' and pin['schema']==a.schema.lower() and pin['label']==a.schema.lower()
 assert m['outputSHA256']==sha(a.candidate) and m['inputSHA256']==sha(parent) and m['recipeSHA256']==sha(d/'rewrite.cjs') and m['catalogSHA256']==sha(catalog)
 assert len(m['edges'])==9 and m['derivedReceivers']==8 and m['removedClosureSites']==9 and m['addedClosures']==0
 hot=[e for e in m['edges'] if e['position']==0];assert len(hot)==1 and len(hot[0]['laterArguments'])==16 and all(e['position']>0 and not e['laterArguments'] for e in m['edges'] if e not in hot)
 assert all(x['kind'] in ['initializedImmutableParameter','initializedDominatingConst'] for x in hot[0]['laterArguments'])
 legacyReceipt=Path(str(a.legacy)+'.recipe.json');lm=json.loads(legacyReceipt.read_text());ld=d/'legacy'
 assert lm['outputSHA256']==sha(a.legacy) and lm['inputSHA256']==sha(parent) and lm['recipeSHA256']==sha(ld/'rewrite.cjs') and lm['catalogSHA256']==sha(ld/'input-pins.json')
 lp=json.loads((ld/'input-pins.json').read_text())[lm['inputSHA256']];assert lp['schema']==pin['schema'] and lp['label']==pin['label'] and lp['sourceRoot']==m['sourceRoot'] and lp['runtimeSourcePins']==m['sourcePins'] and lp['provenancePins']==pin['provenancePins']
 assert lm['scope']=='Pinned generated-JS constant Array.swap direct-call product split; no general optimizer/refinement/qualification' and lm['parserVersion']==m['parserVersion']
 assert lm['sourcePins']==m['sourcePins'] and len(lm['edges'])==8 and lm['removedClosureSites']==8 and all(not e.get('laterArguments') for e in lm['edges'])
 frozen=json.loads(a.freeze.read_text());assert frozen['status']=='ROOT_EXACT_SWAP_COHORT_FROZEN' and frozen['schema']==a.schema and frozen['paths']=={str(x):sha(x) for x in [a.candidate,receipt,a.legacy,legacyReceipt,d/'rewrite.cjs',catalog,ld/'rewrite.cjs',ld/'input-pins.json']}
 r['freezeSHA256']=sha(a.freeze)
 assert pm['status']=='PINNED_DIRECT_TUPLE_SCALAR_RECEIVERS_DERIVED' and pm['schema']==a.schema.lower() and pm['mode']=='cursor-normal' and pm['outputSHA256']==sha(parent)
 assert pm['sourcePins']==pin['runtimeSourcePins']==m['sourcePins'] and pm['sourceRoot']==pin['sourceRoot']==m['sourceRoot']
 for name,h in pin['provenancePins'].items():assert sha(name)==h
 for name,h in pm['provenancePins'].items():assert sha(name)==h
 assert len(m['sourcePins'])==29
 for name,h in m['sourcePins'].items():assert sha(Path(m['sourceRoot'])/name)==h
 r['inputs']={'candidateSHA256':sha(a.candidate),'parentSHA256':sha(parent),'derivationReceiptSHA256':sha(receipt),'sourceRoot':m['sourceRoot'],'sourcePins':m['sourcePins'],'catalogSHA256':sha(catalog),'guardedRecipeSHA256':sha(d/'rewrite.cjs'),'swapEdges':m['edges'],'legacySHA256':sha(a.legacy),'legacyReceiptSHA256':sha(legacyReceipt),'producerPins':pin['provenancePins'],'parentProvenancePins':pm['provenancePins']}
 paths={'TS':None,'parent-JS':['node',parent],'candidate-JS':['node',a.candidate],'legacy-JS':['node',a.legacy]}
 if a.native_build:
  build=a.native_build;nb=json.loads((build/'build.json').read_text());assert nb['status']=='BUILD_PASS' and nb['schema']==a.schema and nb['sourcePins']==m['sourcePins']
  assert set(nb['artifacts'])=={'batch.bend','batch.c','batch.js','batch-native'}
  chain=[]
  for stage in ['row','pool','tuple']:
   q=parent.parent/(a.schema.lower()+'-'+stage+'.js');consumed[str(q)]=sha(q);consumed[str(Path(str(q)+'.recipe.json'))]=sha(Path(str(q)+'.recipe.json'));qm=json.loads(Path(str(q)+'.recipe.json').read_text());assert qm['outputSHA256']==sha(q) and qm['sourcePins']==m['sourcePins'] and qm['sourceRoot']==m['sourceRoot'];chain.append(qm)
  assert chain[0]['inputSHA256']==sha(build/'batch.js') and chain[1]['inputSHA256']==chain[0]['outputSHA256'] and chain[2]['inputSHA256']==chain[1]['outputSHA256'] and chain[2]['outputSHA256']==sha(parent)
  assert all(sha(build/n)==h for n,h in nb['artifacts'].items()) and sha(build/'measurement-bend.bend')==nb['measurementOutputSHA256']
  assert str(build/'build.json') in pm['provenancePins'] and pm['provenancePins'][str(build/'build.json')]==sha(build/'build.json')
  for argv,cap in [(['bend',str(build/'batch.bend'),'--check-only'],15),(['bend',str(build/'batch.bend'),'-o',str(build/'batch.c')],30),(['bend',str(build/'batch.bend'),'-o',str(build/'batch.js')],30),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(build/'batch.c'),'-o',str(build/'batch-native'),'-lm','-pthread'],120)]:
   hits=[c for c in nb['commands'] if c['argv']==argv];assert len(hits)==1 and hits[0]['limitSeconds']==cap and hits[0]['exit']==0 and not hits[0].get('timeout',False)
  assert sha('/tmp/bendvy-clang19-diagnostic/clang19')=='3e171a978d6c1decae4e6645e9bfb771cf5af21ff699ea119fdb058936b0af2d'
  r['native']={'buildReceiptSHA256':sha(build/'build.json'),'artifacts':nb['artifacts'],'same29Source':True,'flags':'Clang19 -O3 one-worker GPU-off'};paths['Native']=[build/'batch-native','--threads','1','--gpu','off']
 ref=a.output/'reference.mjs';run('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema',a.schema,'--batch','64']);paths['TS']=['node',ref]
 order=['TS',*(['Native'] if a.native_build else []),'parent-JS','legacy-JS','candidate-JS'];shift=a.rotation%len(order);order=order[shift:]+order[:shift]
 if a.rotation>=5:order=order[::-1]
 consumed[str(ref)]=sha(ref);consumed[str(parent)]=sha(parent);r['executionOrder']=order;outputs={role:run(role,paths[role]) for role in order};ts=json.loads(outputs['TS']);assert ts['schema']==a.schema and ts['count']==256 and ts['iterations']==64 and ts['batch']==64 and len(ts['samples'])==64
 sp=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(sp);sp.loader.exec_module(V);r['phaseMS']={'TS':ts['batchMilliseconds']}
 for role in order:
  if role=='TS':continue
  lines=outputs[role].splitlines();records=[line for line in lines if line.startswith('{')];clocks=[line for line in lines if line.startswith('BATCH-MILLISECONDS:')];assert len(records)==65 and len(clocks)==1
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,a.schema,False,256,world);assert V.normalized(json.loads(line),a.schema)==world['final']
  r['phaseMS'][role]=float(clocks[0].split(':',1)[1])
 assert all(isinstance(x,(int,float)) and not isinstance(x,bool) and math.isfinite(x) and x>=0 for x in r['phaseMS'].values()),'invalid elapsed value'
 for path,h in consumed.items():assert sha(path)==h,'post-run measurement input drift'
 assert sha(a.freeze)==r['freezeSHA256'],'post-run freeze receipt drift'
 for path,h in frozen['paths'].items():assert sha(path)==h,'post-run freeze drift'
 assert sha(parent)==m['inputSHA256'] and sha(receipt)==r['inputs']['derivationReceiptSHA256'] and sha(legacyReceipt)==r['inputs']['legacyReceiptSHA256']
 for name,h in m['sourcePins'].items():assert sha(Path(m['sourceRoot'])/name)==h,'post-run source drift'
 for pins in [pin['provenancePins'],pm['provenancePins']]:
  for name,h in pins.items():assert sha(name)==h,'post-run provenance drift'
 assert sha(build/'build.json')==r['native']['buildReceiptSHA256'] and all(sha(build/n)==h for n,h in nb['artifacts'].items()),'post-run native drift'
 r.update(status='SOURCE_BOUND_PARENT_CANDIDATE_FULL65_RAW_DIAGNOSTIC_PASS',fullFieldsEqual=True)
except Exception as e:r.update(status='FAIL',error=repr(e))
finally:save()
print(json.dumps({k:r.get(k) for k in ['status','schema','phaseMS','error']}));sys.exit(0 if r['status']=='SOURCE_BOUND_PARENT_CANDIDATE_FULL65_RAW_DIAGNOSTIC_PASS' else 1)
