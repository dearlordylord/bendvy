#!/usr/bin/env python3
"""One rotated diagnostic observation; no canonical packet or qualified keep."""
import argparse,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser()
for role in ['baseline','candidate']:
 p.add_argument('--'+role+'-overlay',type=Path,required=True);p.add_argument('--'+role+'-build',type=Path,required=True)
p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--rotation',type=int,choices=range(7),required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=11)
a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Source-bound rotated full65 diagnostic observation; not noise qualification, canonical execution, keep or product acceptance','schema':a.schema,'rotation':a.rotation,'cpu':a.cpu,'recipeSHA256':sha(Path(__file__)),'commands':[],'inputs':{}}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(role,argv):
 c={'role':role,'argv':list(map(str,argv)),'limitSeconds':5};r['commands'].append(c);save()
 try:code,out=supervisor.execute(c['argv'],5)
 except Exception as e:c.update(error=repr(e),fullTimeoutOutputUnavailable=True);save();raise
 dest=a.output/(role+'.txt');dest.write_text(out);c.update(exit=code,outputSHA256=sha(dest));save();assert code==0,out[-1000:];return out
try:
 binaries={}
 for role in ['baseline','candidate']:
  overlay=getattr(a,role+'_overlay');build=getattr(a,role+'_build');m=json.loads((overlay/'overlay.json').read_text());cache=json.loads((overlay/'cache-specialization.json').read_text());b=json.loads((build/'build.json').read_text())
  pins={str(f.relative_to(overlay)):sha(f) for f in overlay.rglob('*.bend')};assert pins==m['sources']==cache['runtimeClosure']==cache['specializedClosure']==b['sourcePins'];assert len(pins)>=29 and b['status']=='BUILD_PASS';assert m['cacheSpecialization']==cache
  digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert digest==cache['runtimeClosureSHA256']
  artifacts={n:sha(build/n) for n in ['batch.bend','batch.c','batch-native','batch.js']};assert all(h==b['artifacts'][n] for n,h in artifacts.items())
  r['inputs'][role]={'sourceClosureSHA256':digest,'sourcePins':pins,'manifestSHA256':sha(overlay/'overlay.json'),'buildReceiptSHA256':sha(build/'build.json'),'artifacts':artifacts}
  binaries[role+'-Native']=[build/'batch-native','--threads','1','--gpu','off'];binaries[role+'-JS']=['node',build/'batch.js']
 ref=a.output/'reference.mjs';run('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',ref,'--schema',a.schema,'--batch','64']);r['referenceSHA256']=sha(ref);binaries['TS']=['node',ref]
 order=['TS','baseline-Native','candidate-Native','baseline-JS','candidate-JS'];shift=a.rotation%len(order);order=order[shift:]+order[:shift]
 if a.rotation%2:order=order[::-1]
 r['executionOrder']=order;outputs={role:run(role,binaries[role]) for role in order}
 ts=json.loads(outputs['TS']);assert ts['schema']==a.schema and ts['batch']==64 and ts['count']==256 and ts['iterations']==64 and len(ts['samples'])==64
 spec=importlib.util.spec_from_file_location('V',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 r['phaseMS']={'TS':ts['batchMilliseconds']}
 for role,out in outputs.items():
  if role=='TS':continue
  lines=out.splitlines();records=[x for x in lines if x.startswith('{')];clocks=[x for x in lines if x.startswith('BATCH-MILLISECONDS:')];assert len(records)==65 and len(clocks)==1
  for line,world in zip(records,[ts['warmup'],*ts['samples']]):v.validate(line,a.schema,False,256,world);assert v.normalized(json.loads(line),a.schema)==world['final']
  r['phaseMS'][role]=float(clocks[0].split(':',1)[1])
 r.update(status='ROTATED_DIAGNOSTIC_ALL_FULL65_WORLDS_PASS',fullFieldsEqual=True,validationRecipeSHA256=sha(ROOT/'experiments/s-integrate/measurement-bend-run.py'))
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:save()
print(json.dumps({k:r.get(k) for k in ['status','schema','rotation','phaseMS','error']}));sys.exit(0 if r['status']=='ROTATED_DIAGNOSTIC_ALL_FULL65_WORLDS_PASS' else 1)
