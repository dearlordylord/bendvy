#!/usr/bin/env python3
"""Exact source-bound full65 rotated raw diagnostic; no qualified keep."""
import argparse,hashlib,importlib.util,json,math,os,shutil,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--candidate',type=Path,required=True);p.add_argument('--single',type=Path,required=True);p.add_argument('--selective-directory',type=Path,required=True);p.add_argument('--freeze',type=Path,required=True);p.add_argument('--recipe-directory',type=Path,required=True);p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--rotation',type=int,choices=range(12),required=True);p.add_argument('--native-build',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
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
 assert m['recipeSHA256']=='31c1cc0923fa8749f936332ed28df5875e479c9447c793a0ab3f050b4fcbc61c' and len(m['edges'])==10 and m['removedClosureSites']==10 and m['addedClosures']==0
 hot=[e for e in m['edges'] if e['position']==0];assert len(hot)==2 and sorted(len(e['laterArguments']) for e in hot)==[16,17] and all(x['kind'] in ['initializedImmutableParameter','initializedDominatingConst'] for e in hot for x in e['laterArguments'])
 assert pm['status']=='STRICT_PRIVATE_FOLD_SELECTIVE_STORE_REUSE_PASS' and pm['schema']==a.schema.lower() and pm['outputSHA256']==sha(parent)
 fd=a.selective_directory;fc=fd/'input-pins.json';fp=json.loads(fc.read_text())[pm['inputSHA256']];original=Path(fp['inputPath']);originalReceipt=Path(str(original)+'.recipe.json');originalBytes=originalReceipt.read_bytes();om=json.loads(originalBytes);consumed[str(originalReceipt)]=hashlib.sha256(originalBytes).hexdigest();consumed[str(original)]=sha(original)
 assert pm['recipeSHA256']==sha(fd/'rewrite.cjs')=='800e97559fea97f9e346d82c8d394e8f1804666a63b71b110ba8b85454bb55e0' and pm['catalogSHA256']==sha(fc)=='fe3059a7b241a8e0fe688c27b5172733863728942d213c89cb0eed6cb4847795'
 assert pm['family']==fp['family'] and len(pm['family'])==5 and pm['terminalCount']==1 and pm['edges']==4
 assert pm['transportRecipeSHA256']==sha(fd/'transport.cjs')=='3d7686c913305816c532b71f021aef524925aa7a891d9f75867004d31b5761d1'
 assert pm['stableFields']==['namespace','next','aux','capacity','depth','high','pending','mode','commands','pings'] and pm['stores']==7 and pm['transport']['stable']==pm['stableFields'] and len(pm['transport']['edges'])==4
 assert all(pm['transport']['terminal'][field]=='state.'+field for field in pm['stableFields']) and all(pm['transport']['terminal'][field] is None for field in ['columns','metadata','ledger','selected','undo','marks','total'])
 assert fp['schema']==a.schema.lower() and pm['inputSHA256']==sha(original) and om['outputSHA256']==sha(original) and om['status']=='PINNED_DIRECT_TUPLE_SCALAR_RECEIVERS_DERIVED' and om['mode']=='cursor-normal'
 singleReceipt=Path(str(a.single)+'.recipe.json');single=json.loads(singleReceipt.read_text());assert single['status']=='STRICT_POSITIONED_CONSTANT_SWAP_SCALAR_BRIDGE_DERIVED' and single['schema']==a.schema.lower() and single['inputSHA256']==sha(original) and single['outputSHA256']==sha(a.single) and single['recipeSHA256']==m['recipeSHA256'] and len(single['edges'])==9
 singleCatalogue=a.single.parent/'input-pins.json';singleRecipe=a.single.parent/'rewrite.cjs';assert sha(singleRecipe)==single['recipeSHA256'] and sha(singleCatalogue)==single['catalogSHA256']=='780665285421247815d8843d94ebc292a05a5184e0c5f0d5d548846ca6d72b6b'
 assert om['sourcePins']==pm['sourcePins']==pin['runtimeSourcePins']==m['sourcePins']==single['sourcePins'] and om['sourceRoot']==pm['sourceRoot']==pin['sourceRoot']==m['sourceRoot']==single['sourceRoot'] and len(m['sourcePins'])==29
 frozen=json.loads(a.freeze.read_text());assert frozen['status']=='ROOT_EXACT_SWAP_SELECTIVE_COHORT_FROZEN' and frozen['schema']==a.schema and frozen['paths']=={str(x):sha(x) for x in [a.candidate,receipt,parent,parentReceipt,d/'rewrite.cjs',catalog,d/'parent-joins.json',fd/'rewrite.cjs',fc,fd/'transport.cjs',singleRecipe,singleCatalogue,a.single,singleReceipt,original,originalReceipt]}
 r['freezeSHA256']=sha(a.freeze)
 for pins in [pin['provenancePins'],om['provenancePins'],fp['files']]:
  for name,h in pins.items():assert sha(name)==h
 for name,h in m['sourcePins'].items():assert sha(Path(m['sourceRoot'])/name)==h
 r['inputs']={'candidateSHA256':sha(a.candidate),'selectiveSHA256':sha(parent),'firststageSHA256':sha(original),'singlePositionedSHA256':sha(a.single),'derivationReceiptSHA256':sha(receipt),'sourceRoot':m['sourceRoot'],'sourcePins':m['sourcePins'],'catalogSHA256':sha(catalog),'guardedRecipeSHA256':sha(d/'rewrite.cjs'),'swapEdges':m['edges'],'selectiveCertificates':pm.get('certificates'),'producerPins':pin['provenancePins'],'parentProvenancePins':om['provenancePins']}
 paths={'TS':None,'firststage-JS':['node',original],'selective-JS':['node',parent],'positioned-JS':['node',a.single],'candidate-JS':['node',a.candidate]}
 if a.native_build:
  build=a.native_build;nb=json.loads((build/'build.json').read_text());assert nb['status']=='BUILD_PASS' and nb['schema']==a.schema and nb['sourcePins']==m['sourcePins']
  assert set(nb['artifacts'])=={'batch.bend','batch.c','batch.js','batch-native'}
  chain=[]
  for stage in ['row','pool','tuple']:
   q=original.parent/(a.schema.lower()+'-'+stage+'.js');consumed[str(q)]=sha(q);consumed[str(Path(str(q)+'.recipe.json'))]=sha(Path(str(q)+'.recipe.json'));qm=json.loads(Path(str(q)+'.recipe.json').read_text());assert qm['outputSHA256']==sha(q) and qm['sourcePins']==m['sourcePins'] and qm['sourceRoot']==m['sourceRoot'];chain.append(qm)
  assert chain[0]['inputSHA256']==sha(build/'batch.js') and chain[1]['inputSHA256']==chain[0]['outputSHA256'] and chain[2]['inputSHA256']==chain[1]['outputSHA256'] and chain[2]['outputSHA256']==sha(original)
  assert all(sha(build/n)==h for n,h in nb['artifacts'].items()) and sha(build/'measurement-bend.bend')==nb['measurementOutputSHA256']
  assert str(build/'build.json') in om['provenancePins'] and om['provenancePins'][str(build/'build.json')]==sha(build/'build.json')
  for argv,cap in [(['bend',str(build/'batch.bend'),'--check-only'],15),(['bend',str(build/'batch.bend'),'-o',str(build/'batch.c')],30),(['bend',str(build/'batch.bend'),'-o',str(build/'batch.js')],30),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(build/'batch.c'),'-o',str(build/'batch-native'),'-lm','-pthread'],120)]:
   hits=[c for c in nb['commands'] if c['argv']==argv];assert len(hits)==1 and hits[0]['limitSeconds']==cap and hits[0]['exit']==0 and not hits[0].get('timeout',False)
  assert sha('/tmp/bendvy-clang19-diagnostic/clang19')=='3e171a978d6c1decae4e6645e9bfb771cf5af21ff699ea119fdb058936b0af2d'
  r['native']={'buildReceiptSHA256':sha(build/'build.json'),'artifacts':nb['artifacts'],'same29Source':True,'flags':'Clang19 -O3 one-worker GPU-off'};paths['Native']=[build/'batch-native','--threads','1','--gpu','off']
 ref=a.output/'reference.mjs';run('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema',a.schema,'--batch','64']);paths['TS']=['node',ref]
 order=['TS',*(['Native'] if a.native_build else []),'firststage-JS','selective-JS','positioned-JS','candidate-JS'];shift=a.rotation%len(order);order=order[shift:]+order[:shift]
 if a.rotation>=6:order=order[::-1]
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
 assert sha(parent)==m['inputSHA256'] and sha(receipt)==r['inputs']['derivationReceiptSHA256']
 for name,h in m['sourcePins'].items():assert sha(Path(m['sourceRoot'])/name)==h,'post-run source drift'
 for pins in [pin['provenancePins'],om['provenancePins'],fp['files']]:
  for name,h in pins.items():assert sha(name)==h,'post-run provenance drift'
 assert sha(build/'build.json')==r['native']['buildReceiptSHA256'] and all(sha(build/n)==h for n,h in nb['artifacts'].items()),'post-run native drift'
 r.update(status='SOURCE_BOUND_SWAP_SELECTIVE_FULL65_RAW_DIAGNOSTIC_PASS',fullFieldsEqual=True)
except Exception as e:r.update(status='FAIL',error=repr(e))
finally:save()
print(json.dumps({k:r.get(k) for k in ['status','schema','phaseMS','error']}));sys.exit(0 if r['status']=='SOURCE_BOUND_SWAP_SELECTIVE_FULL65_RAW_DIAGNOSTIC_PASS' else 1)
