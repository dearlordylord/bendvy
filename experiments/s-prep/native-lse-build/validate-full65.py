#!/usr/bin/env python3
"""Finite full65 semantic observation only; emitted clocks are not measurements."""
import argparse,hashlib,importlib.util,json,os,pathlib,sys
p=argparse.ArgumentParser();p.add_argument('--cpu',type=int,required=True);p.add_argument('--kind',choices=['js','native'],required=True);p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--program',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
root=pathlib.Path('/workspace/formal-proofs/bendvy');sys.path.insert(0,str(root/'experiments/s-prep/fivehour-connected-gates'));import supervisor
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Finite full65 schema fields only; no elapsed qualification or universal refinement','schema':a.schema,'cpu':a.cpu,'commands':[],'programSHA256':sha(a.program),'kind':a.kind,'runnerSHA256':sha(pathlib.Path(__file__))}
import ctypes,platform
libc=ctypes.CDLL(None);libc.getauxval.argtypes=[ctypes.c_ulong];libc.getauxval.restype=ctypes.c_ulong
capBefore=libc.getauxval(16);assert platform.machine()=='aarch64' and capBefore&(1<<8);r['AT_HWCAPBefore']=capBefore
# Prospective full execution closure, independently verified after the checkpoints.
sourceRoot=pathlib.Path('/tmp/bendvy-slot-host-motion-id-buffer-direct-v1' if a.schema=='Motion' else '/tmp/bendvy-slot-host-concrete-owner-v3')
sourcePins=json.loads((sourceRoot/'overlay.json').read_text())['sources']
assert all(sha(sourceRoot/n)==h for n,h in sourcePins.items())
cache=json.loads((sourceRoot/'cache-specialization.json').read_text());assert cache==json.loads((sourceRoot/'overlay.json').read_text())['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==sourcePins
closure=hashlib.sha256(json.dumps(sourcePins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure==('84b808cee2c1a657569888229241dd95ae59f314025512c20159d951f4a1db2c' if a.schema=='Motion' else 'a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55')
assert cache['runtimeClosureSHA256']==cache['specializedClosureSHA256']==closure
specTools=importlib.util.spec_from_file_location('tools',pathlib.Path(__file__).parent/'tool-pins.py');tools=importlib.util.module_from_spec(specTools);specTools.loader.exec_module(tools);toolBefore=tools.snapshot()
extraFiles=[pathlib.Path(__file__),pathlib.Path(__file__).parent/'prepare-ts1024.py',pathlib.Path(__file__).parent/'tool-pins.py',root/'experiments/s-prep/fivehour-connected-gates/supervisor.py',root/'experiments/s-integrate/measurement-bend-run.py',root/'experiments/s-integrate/measurement-samples-reference.mjs',sourceRoot/'overlay.json',sourceRoot/'cache-specialization.json',*sorted((root/'.references/bevy-ts/packages/core/src').rglob('*.ts'))]
extraPins={str(f):sha(f) for f in extraFiles};r.update(sourceClosureSHA256=closure,source29=sourcePins,toolPinsBefore=toolBefore,executionClosurePinsBefore=extraPins)

def run(argv,name):
 code,out=supervisor.execute([str(x) for x in argv],5);(a.output/(name+'.txt')).write_text(out);r['commands'].append({'argv':[str(x) for x in argv],'capSeconds':5,'exit':code,'outputSHA256':sha(a.output/(name+'.txt'))});assert code==0,out[-1000:];return out
try:
 reference=a.output/'reference.mjs';source=root/'experiments/s-integrate/measurement-samples-reference.mjs'
 run([sys.executable,pathlib.Path(__file__).parent/'prepare-ts1024.py','--source',source,'--output',reference,'--schema',a.schema,'--batch','64'],'prepare')
 ts=json.loads(run(['node',reference],'ts'));native=run(['node',a.program] if a.kind=='js' else [a.program,'--threads','1','--gpu','off'],'candidate');edgeLines=[x for x in native.splitlines() if x.startswith('BENDVY_PUBLISH_EDGES ')];r['publishEdges']=json.loads(edgeLines[0].split(' ',1)[1]) if len(edgeLines)==1 else None;records=[x for x in native.splitlines() if x.startswith('{')];assert len(records)==65
 spec=importlib.util.spec_from_file_location('validator',root/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 assert ts['schema']==a.schema and ts['count']==1024 and ts['iterations']==64 and len(ts['samples'])==64
 for record,expected in zip(records,[ts['warmup'],*ts['samples']]):
  v.validate(record,a.schema,False,1024,expected);assert v.normalized(json.loads(record),a.schema)==expected['final']
 r.update(status='PASS_FULL65',allFullFieldsEqual=True,worlds=65,referenceSourceSHA256=sha(source),referenceSHA256=sha(reference),validatorSHA256=sha(root/'experiments/s-integrate/measurement-bend-run.py'))
except Exception as e:r['error']=repr(e)
assert libc.getauxval(16)==capBefore;tools.verify(toolBefore);assert all(sha(pathlib.Path(n))==h for n,h in extraPins.items());assert all(sha(sourceRoot/n)==h for n,h in sourcePins.items());assert sha(a.program)==r['programSHA256'];r.update(prospectiveExecutionBytesStableBeforeAfter=True,programBytesStableBeforeAfter=True,sourceBytesStableBeforeAfter=True)
(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r));sys.exit(0 if r['status']=='PASS_FULL65' else 1)
