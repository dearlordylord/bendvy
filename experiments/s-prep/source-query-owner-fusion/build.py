#!/usr/bin/env python3
"""Build the unchanged full64 workload, source-only diagnostics (no keep)."""
import argparse,hashlib,json,pathlib,signal,subprocess,time,os
os.environ["BENDVY_CLANG19_ROOT"]="/tmp/bendvy-clang19-diagnostic/root"
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--schema',choices=['motion','health'],required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
r={'status':'INCOMPLETE','overlay':str(a.overlay.resolve()),'schema':a.schema,'checkerDiagnosticLimitSeconds':15,'proofDefaultLimitSeconds':5,'commands':[],'performanceAcceptance':False,'fullGatesComplete':False}
def command(args,limit):
 entry={'argv':list(map(str,args)),'limitSeconds':limit};r['commands'].append(entry);(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n')
 child=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:out,err=child.communicate(timeout=limit)
 except subprocess.TimeoutExpired:
  signal.signal(signal.SIGCHLD,signal.SIG_DFL);import os;os.killpg(child.pid,signal.SIGKILL);out,err=child.communicate();entry.update({'status':'TIMEOUT','out':out,'err':err});(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n');raise
 entry.update({'exit':child.returncode,'out':out,'err':err});(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n');assert child.returncode==0,entry;return out
root=HERE.parents[2];template=(root/'experiments/s-prep/js-query-live-first/evidence/native-batch.bend').read_text();template=template.replace('import ./measurement-bend.bend as M',f'import {a.overlay.resolve()}/experiments/s-integrate/measurement-bend.bend as M').replace('/tmp/bendvy-live-first-native',str(a.overlay.resolve()));template=template.replace('  motion_batch(256,64)','  '+a.schema+'_batch(256,64)');adapter='\n'.join([f'import {a.overlay.resolve()}/experiments/s-integrate/raw-boundaries.bend as RB',f'import {a.overlay.resolve()}/experiments/s-integrate/identity.bend as I','', 'def motion_fresh(count:U32) -> IO(D.Runtime<M.MotionBench,S.Handle<T.MotionSchema>> & K.System):','  M.motion_created(count,False{},RB.motion_create(M.motion_ledger,I.factory(),T.MotionOn{}))','def health_fresh(count:U32) -> IO(D.Runtime<M.HealthBench,S.Handle<T.HealthSchema>> & K.System):','  M.health_created(count,False{},RB.health_create(M.health_ledger,I.factory(),T.HealthOn{}))',''])
template=template.replace('def motion_prepared(',adapter+'\ndef motion_prepared(',1).replace('M.motion_fresh(count)','motion_fresh(count)').replace('M.health_fresh(count)','health_fresh(count)')
source=a.output/'batch.bend';source.write_text(template)
r['sourceSHA256']=hashlib.sha256(template.encode()).hexdigest();r['runtimeSources']=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert len(r['runtimeSources'])==29
assert 'ALL PROOFS CHECK' in command(['taskset','-c','8','bend',source,'--check-only'],15)
c=a.output/'batch.c';js=a.output/'batch.js';binary=a.output/'batch.native'
command(['taskset','-c','8','bend',source,'-o',c],30);command(['taskset','-c','8','/tmp/bendvy-clang19-diagnostic/clang19','-O3',c,'-o',binary,'-lm','-pthread'],120);command(['taskset','-c','8','bend',source,'-o',js],30)
for backend,args in [('Native',[binary,'--threads','1','--gpu','off']),('JS',['node',js])]:
 output=command(['taskset','-c','8',*args],5);(a.output/(backend+'.txt')).write_text(output);r[backend+'OutputSHA256']=hashlib.sha256(output.encode()).hexdigest()
r['status']='FULL64_BUILD_AND_RUNTIME_OBSERVED_NOT_ACCEPTED';r['artifacts']={n:hashlib.sha256((a.output/n).read_bytes()).hexdigest() for n in ['batch.bend','batch.c','batch.js','batch.native']};(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
