#!/usr/bin/env python3
"""Exact source-bound full65 rotated raw diagnostic; no qualified keep."""
import argparse,hashlib,importlib.util,json,math,os,shutil,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--program',type=Path,required=True);p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--rotation',type=int,choices=range(6),required=True);p.add_argument('--native-build',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{11})
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Sequential rotated raw full65 diagnostic, no noise qualification/keep/full matrix or product acceptance','schema':a.schema,'rotation':a.rotation,'CPU':11,'recipeSHA256':sha(Path(__file__)),'commands':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(role,argv):
 argv=list(map(str,argv));code,out=supervisor.execute(argv,5);f=a.output/(role+'.txt');f.write_text(out);r['commands'].append({'role':role,'argv':argv,'limitSeconds':5,'exit':code,'outputSHA256':sha(f)});save();assert code==0,out[-1000:];return out
try:
 consumed={str(x):sha(x) for x in [Path(__file__),ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs',ROOT/'experiments/s-integrate/measurement-bend-run.py',ROOT/'experiments/s-prep/fivehour-connected-gates/supervisor.py',ROOT/'.references/sources.json',Path(shutil.which('node'))]}
 reference=ROOT/'.references/bevy-ts';assert run('reference-head',['git','-C',reference,'rev-parse','HEAD']).strip()=='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
 assert not run('reference-clean',['git','-C',reference,'status','--porcelain','--untracked-files=all','--','packages/core/src']).strip()
 consumed.update({str(x):sha(x) for x in (reference/'packages/core/src').rglob('*') if x.is_file()});r['consumedMeasurementPins']=consumed;r['nodeVersion']=run('node-version',['node','--version']).strip()
 parent=a.program;parentReceipt=Path(str(parent)+'.recipe.json');data=parentReceipt.read_bytes();pm=json.loads(data);m=pm;consumed[str(parentReceipt)]=hashlib.sha256(data).hexdigest();consumed[str(parent)]=sha(parent)
 assert pm['status']=='PINNED_DIRECT_TUPLE_SCALAR_RECEIVERS_DERIVED' and pm['schema']==a.schema.lower() and pm['mode']=='cursor-normal' and pm['outputSHA256']==sha(parent)
 assert pm['sourceRoot']=='/tmp/bendvy-slot-host-v1' and len(pm['sourcePins'])==29
 status=ROOT/'experiments/s-prep/js-slot-host-transport/status.json';sm=json.loads(status.read_text());consumed[str(status)]=sha(status)
 assert sm['sourceClosure']=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c' and sm['full65'][a.schema.lower()+'/firststage-js']['programSHA256']==sha(parent)
 for name,h in pm['provenancePins'].items():assert sha(name)==h
 for name,h in pm['sourcePins'].items():assert sha(Path(pm['sourceRoot'])/name)==h
 r['inputs']={'programSHA256':sha(parent),'programReceiptSHA256':consumed[str(parentReceipt)],'sourceRoot':pm['sourceRoot'],'sourcePins':pm['sourcePins'],'parentProvenancePins':pm['provenancePins'],'knownEnrollmentStatusSHA256':sha(status),'sourceClosure':sm['sourceClosure']}
 paths={'TS':None,'firststage-JS':['node',parent]}
 if a.native_build:
  build=a.native_build;nb=json.loads((build/'build.json').read_text());assert nb['status']=='BUILD_PASS' and nb['schema']==a.schema and nb['sourcePins']==m['sourcePins']
  assert set(nb['artifacts'])=={'batch.bend','batch.c','batch.js','batch-native'} and sm['full65'][a.schema.lower()+'/raw-native']['programSHA256']==sha(build/'batch-native')
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
 order=['TS',*(['Native'] if a.native_build else []),'firststage-JS'];shift=a.rotation%len(order);order=order[shift:]+order[:shift]
 if a.rotation>=3:order=order[::-1]
 consumed[str(ref)]=sha(ref);consumed[str(parent)]=sha(parent);r['executionOrder']=order;outputs={role:run(role,paths[role]) for role in order};ts=json.loads(outputs['TS']);assert ts['schema']==a.schema and ts['count']==256 and ts['iterations']==64 and ts['batch']==64 and len(ts['samples'])==64
 sp=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');V=importlib.util.module_from_spec(sp);sp.loader.exec_module(V);r['phaseMS']={'TS':ts['batchMilliseconds']}
 for role in order:
  if role=='TS':continue
  lines=outputs[role].splitlines();records=[line for line in lines if line.startswith('{')];clocks=[line for line in lines if line.startswith('BATCH-MILLISECONDS:')];assert len(records)==65 and len(clocks)==1
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):V.validate(line,a.schema,False,256,world);assert V.normalized(json.loads(line),a.schema)==world['final']
  r['phaseMS'][role]=float(clocks[0].split(':',1)[1])
 assert all(isinstance(x,(int,float)) and not isinstance(x,bool) and math.isfinite(x) and x>=0 for x in r['phaseMS'].values()),'invalid elapsed value'
 for path,h in consumed.items():assert sha(path)==h,'post-run measurement input drift'
 for name,h in pm['sourcePins'].items():assert sha(Path(pm['sourceRoot'])/name)==h,'post-run source drift'
 for name,h in pm['provenancePins'].items():assert sha(name)==h,'post-run provenance drift'
 assert sha(build/'build.json')==r['native']['buildReceiptSHA256'] and all(sha(build/n)==h for n,h in nb['artifacts'].items()),'post-run native drift'
 r.update(status='SOURCE_BOUND_SLOT_HOST_BASELINE_FULL65_RAW_DIAGNOSTIC_PASS',fullFieldsEqual=True)
except Exception as e:r.update(status='FAIL',error=repr(e))
finally:save()
print(json.dumps({k:r.get(k) for k in ['status','schema','phaseMS','error']}));sys.exit(0 if r['status']=='SOURCE_BOUND_SLOT_HOST_BASELINE_FULL65_RAW_DIAGNOSTIC_PASS' else 1)
