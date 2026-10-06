#!/usr/bin/env python3
"""Fresh exact-work field gate; preserve failures and timeout output, never qualify speed."""
import argparse,hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'));import supervisor
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--js',type=Path,required=True);p.add_argument('--native',type=Path,required=True);p.add_argument('--overlay',type=Path,required=True);p.add_argument('--build-record',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=7);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
sha=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Fresh full65 source fields against actually executed pinned TS; no ratio/qualification/adoption','schema':a.schema,'cpu':a.cpu,'commands':[],'recipeSHA256':sha(Path(__file__))}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(role,args):
 entry={'role':role,'argv':list(map(str,args)),'limitSeconds':5};r['commands'].append(entry);save()
 try:code,out=supervisor.execute(entry['argv'],5)
 except TimeoutError as e:entry.update(timeout=True,error=repr(e),outputLimit='Supervisor retains only the last 2000 characters in its exception; full timeout output is unavailable');save();raise
 target=a.output/(role+'.txt');target.write_text(out);entry.update(exit=code,outputSHA256=sha(target));save();assert code==0,out[-800:];return out
try:
 pins={str(x.relative_to(a.overlay)):sha(x) for x in a.overlay.rglob('*.bend')};m=json.loads((a.overlay/'overlay.json').read_text());c=json.loads((a.overlay/'cache-specialization.json').read_text());b=json.loads(a.build_record.read_text());assert len(pins)==29 and pins==m['sources']==c['runtimeClosure']==c['specializedClosure']==b['sourcePins'];assert c==m['cacheSpecialization'] and b['status']=='BUILD_PASS';assert sha(a.js)==b['artifacts'][a.js.name] and sha(a.native)==b['artifacts'][a.native.name];r.update(sourcePins=pins,buildRecordSHA256=sha(a.build_record),candidatePins={'JS':sha(a.js),'Native':sha(a.native)})
 reference=a.output/'reference.mjs';run('prepare-ts',[sys.executable,ROOT/'experiments/s-prep/fivehour-measurement/prepare-ts.py','--source',ROOT/'experiments/s-integrate/measurement-samples-reference.mjs','--output',reference,'--schema',a.schema,'--batch','64']);observed=json.loads(run('TS',['node',reference]));assert observed['schema']==a.schema and observed['count']==256 and observed['iterations']==64 and len(observed['samples'])==64
 path=ROOT/'experiments/s-integrate/measurement-bend-run.py';spec=importlib.util.spec_from_file_location('V',path);V=importlib.util.module_from_spec(spec);spec.loader.exec_module(V)
 for backend,args in [('JS',['node',a.js]),('Native',[a.native,'--threads','1','--gpu','off'])]:
  out=run(backend,args);lines=[x for x in out.splitlines() if x.startswith('{')];assert len(lines)==65
  for line,world in zip(lines,[observed['warmup'],*observed['samples']]):V.validate(line,a.schema,False,256,world);assert V.normalized(json.loads(line),a.schema)==world['final']
  r.setdefault('backends',{})[backend]={'records':65,'allFullFieldsEqual':True};save()
 r.update(status='FRESH_FULL65_FIELDS_PASS',referencePin=sha(reference),validatorPin=sha(path),allFullFieldsEqual=True)
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:save()
print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status']=='FRESH_FULL65_FIELDS_PASS' else 1)
