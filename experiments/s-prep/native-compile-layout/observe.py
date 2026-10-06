#!/usr/bin/env python3
"""Truthful same-C native-only TS/O3/Os rotated full65 observation, not qualification."""
import argparse,pathlib,json,hashlib,os,sys,importlib.util
ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--rotation',type=int,choices=range(3),required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{10});sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
overlay=pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-v1');original=pathlib.Path('/tmp/bendvy-joined-flatjournal-ledger-'+a.schema.lower()+'-build-v1');derived=pathlib.Path('/tmp/bendvy-native-layout-'+a.schema.lower()+'-Os-v1');r={'status':'INCOMPLETE','scope':'Native-only rotated actual TS/O3/Os full65 raw descriptive observation; host noise not qualified, no keep/adoption/canonical allowance reset','CPU':10,'schema':a.schema,'rotation':a.rotation,'recipeSHA256':sha(pathlib.Path(__file__)),'commands':[],'inputs':{},'performanceAcceptance':False}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(role,argv):
 argv=list(map(str,argv));record={'role':role,'argv':argv,'limitSeconds':5};r['commands'].append(record);save()
 try:code,out=supervisor.execute(argv,5)
 except Exception as e:record.update(error=repr(e),fullTimeoutOutputUnavailable=True);save();raise
 path=a.output/(role+'.txt');path.write_text(out);record.update(exit=code,outputSHA256=sha(path));save();assert code==0,out[-1000:];return out
try:
 pins={str(p.relative_to(overlay)):sha(p) for p in overlay.rglob('*.bend')};m=json.loads((overlay/'overlay.json').read_text());cache=json.loads((overlay/'cache-specialization.json').read_text());b=json.loads((original/'build.json').read_text());d=json.loads((derived/'build.json').read_text());assert len(pins)==29 and pins==m['sources']==cache['runtimeClosure']==cache['specializedClosure']==b['sourcePins']==d['sourcePins'];assert m['cacheSpecialization']==cache
 digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert digest==cache['runtimeClosureSHA256']==d['sourceClosureSHA256']=='8cb83bc7467ca8e9b0192b8dadd89d3c143262d37e812079342289be1c0f6e26';assert b['status']=='BUILD_PASS' and d['status']=='SAME_C_LAYOUT_BUILD_PASS';assert d['flag']=='-Os' and d['schema']==a.schema
 assert all(sha(original/name)==value for name,value in b['artifacts'].items());assert sha(original/'batch.c')==sha(derived/'batch.c')==d['sameC']['SHA256']==d['sameC']['copiedSHA256'];assert str(original/'batch.c')==d['sameC']['path'];assert sha(original/'batch-native')==d['baselineBinary']['SHA256'];assert sha(original/'build.json')==d['baselineBuildReceiptSHA256'];assert sha(derived/'batch-native')==d['candidateBinarySHA256'];assert sha('/tmp/bendvy-clang19-diagnostic/clang19')==d['clangWrapperSHA256'];assert d['compileLimitSeconds']==120 and d['runtimePolicy']=={'workers':1,'GPU':'off','limitSeconds':5}
 r['inputs']={'sourcePins':pins,'sourceClosureSHA256':digest,'overlaySHA256':sha(overlay/'overlay.json'),'cacheReceiptSHA256':sha(overlay/'cache-specialization.json'),'O3':{'buildStatus':b['status'],'buildReceiptSHA256':sha(original/'build.json'),'CSHA256':sha(original/'batch.c'),'binarySHA256':sha(original/'batch-native')},'Os':{'buildStatus':d['status'],'buildReceiptSHA256':sha(derived/'build.json'),'CSHA256':sha(derived/'batch.c'),'binarySHA256':sha(derived/'batch-native'),'clangVersion':d['clangVersion'],'clangWrapperSHA256':d['clangWrapperSHA256']}}
 ref=a.output/'reference.mjs';source=ROOT/'experiments/s-integrate/measurement-samples-reference.mjs';run('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',source,'--output',ref,'--schema',a.schema,'--batch','64']);r['reference']={'sourceSHA256':sha(source),'derivedSHA256':sha(ref)}
 commands={'TS':['node',ref],'O3':[original/'batch-native','--threads','1','--gpu','off'],'Os':[derived/'batch-native','--threads','1','--gpu','off']};order=['TS','O3','Os'];order=order[a.rotation:]+order[:a.rotation];r['executionOrder']=order;outputs={role:run(role,commands[role]) for role in order}
 ts=json.loads(outputs['TS']);assert ts['schema']==a.schema and ts['batch']==64 and ts['count']==256 and ts['iterations']==64 and len(ts['samples'])==64
 vf=ROOT/'experiments/s-integrate/measurement-bend-run.py';spec=importlib.util.spec_from_file_location('validator',vf);v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v);r['phaseMS']={'TS':ts['batchMilliseconds']}
 for role in ('O3','Os'):
  lines=outputs[role].splitlines();records=[x for x in lines if x.startswith('{')];clocks=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')];assert len(records)==65 and len(clocks)==1
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,a.schema,False,256,world);assert v.normalized(json.loads(line),a.schema)==world['final']
  r['phaseMS'][role]=float(clocks[0].split(':',1)[1])
 r.update(status='NATIVE_ONLY_ROTATED_TS_O3_OS_ALL_FULL65_PASS',fullFieldsEqual=True,validationRecipeSHA256=sha(vf),ratios={role:r['phaseMS'][role]/r['phaseMS']['TS'] for role in ('O3','Os')})
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
