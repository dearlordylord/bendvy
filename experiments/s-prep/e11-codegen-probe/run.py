#!/usr/bin/env python3
"""One Motion/message static fixture selection; protected runtime/invoker unchanged."""
import argparse,hashlib,importlib.util,json,os,pathlib,re,shutil,signal,subprocess,time,sys
ROOT=pathlib.Path('/workspace/formal-proofs/bendvy')
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
INPUT_MANIFEST='8e7baadb8353e746c366488f49143c61cff9daa790101be361556a3c617654f8'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def load(path,name):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def run(argv,limit,cpu):
 p=subprocess.Popen(['taskset','-c',str(cpu),*map(str,argv)],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);start=time.monotonic();timed=False
 try:out=p.communicate(timeout=limit)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(p.pid,signal.SIGKILL);out=p.communicate()[0]
 return {'argv':list(map(str,argv)),'limitSeconds':limit,'cpu':cpu,'exit':p.returncode,'timeout':timed,'elapsedSeconds':time.monotonic()-start,'output':out}
def blocks(text):return {m[1]:m[0] for m in re.finditer(r'^(?:def|type) ([\w.]+)[\s\S]*?(?=^(?:def|type) |\Z)',text,re.M)}
def main():
 p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=10);a=p.parse_args();a.output.mkdir(exist_ok=False);assert sha(a.input/'overlay.json')==INPUT_MANIFEST
 manifest=json.loads((a.input/'overlay.json').read_text());assert all(sha(a.input/n)==v for n,v in manifest['sources'].items());receipt={'status':'INCOMPLETE','scope':'One changed static Motion/message subject, unchanged ten fresh full TS reference lanes; no E11/full22 acceptance','commands':[],'inputManifestSHA256':sha(a.input/'overlay.json'),'originalSourcePins':manifest['sources'],'actual':[],'publicReference':[],'productionAcceptance':False,'fullGateAcceptance':False}
 def save():(a.output/'evidence.json').write_text(json.dumps(receipt,indent=2)+'\n')
 subject=a.output/'subject';shutil.copytree(a.input,subject);core=subject/'experiments/s-integrate';entry=core/'host-retention-controls.bend';original=entry.read_text();head=original[:original.index('def main() -> IO(Unit):')];selected=head+'def main() -> IO(Unit):\n  motion(RetMessage{})\n'
 assert selected.count('lane_name(lane)')==2 and selected.count('frames(lane)')==2
 # Change only Motion registered's two pure selector uses; Health remains untouched before slicing.
 d=blocks(selected);before=d['motion_registered'];after=before.replace('lane_name(lane)','"message"').replace('frames(lane)','message_frames()');assert before!=after and selected.count(before)==1
 selected=selected.replace(before,after,1);entry.write_text(selected)
 mapping_path=ROOT/'experiments/s-prep/fivehour-connected-gates/materialize-controls.py';mapping=load(mapping_path,'e11_fixture_mapping');runtime=set()
 def visit(path):
  name=str(path.relative_to(subject))
  if name in runtime:return
  runtime.add(name)
  for dep in re.findall(r'^import (\./\S+\.bend)',path.read_text(),re.M):visit((path.parent/dep).resolve())
 visit(core/'measurement-bend.bend');slices=mapping.slice_control_imports(core,entry,runtime)
 receipt['staticSelection']={'schema':'Motion','lane':'message','derivation':'Only Motion registered lane_name(RetMessage)→literal message and frames(RetMessage)→exact original message_frames; selected main unchanged from failed subject','fixtureBeforeSHA256':hashlib.sha256(selected.replace(after,before,1).encode()).hexdigest(),'fixtureAfterSHA256':sha(entry),'sliceRunnerSHA256':sha(mapping_path),'slices':slices,'protectedRuntimeSources':{n:sha(subject/n) for n in sorted(runtime)}}
 original_blocks=blocks(original);derived_blocks=blocks(entry.read_text());assert derived_blocks['message_frames']==original_blocks['message_frames'];assert 'lane_name' not in derived_blocks and 'frames' not in derived_blocks
 invoker=next(core/pathlib.Path(n).name for n,v in slices.items() if v['originalSource']=='experiments/s-integrate/host-batch-invoker.bend');old_inv=blocks((a.input/'experiments/s-integrate/host-batch-invoker.bend').read_text());new_inv=blocks(invoker.read_text());assert all(new_inv[n]==old_inv[n] for n in new_inv)
 assert 'D.tick(Batch<H.MotionHost()>,W.Handle<T.MotionSchema>,motion_presence,motion_invoke,motion_barrier,motion_transition,motion_frame' in new_inv['motion_tick']
 assert all(sha(subject/n)==manifest['sources'][n] for n in runtime)
 receipt['protectedInvokerBinding']={'source':str(invoker.relative_to(subject)),'sourceSHA256':sha(invoker),'retainedDefinitionSHA256':{n:hashlib.sha256(t.encode()).hexdigest() for n,t in new_inv.items()},'allRetainedBodiesByteIdentical':True,'actualDispatcherBindingUnchanged':True};save()
 reference=ROOT/'experiments/s-integrate-trace/reference-retention.mjs';receipt['referenceSourceSHA256']=sha(reference)
 for schema in ('Motion','Health'):
  for lane in ('message','removed','despawned','unheld','marks'):
   r=run(['node',reference,schema,lane],5,a.cpu);receipt['commands'].append(r);save()
   if r['exit']!=0:receipt['status']='REFERENCE_BLOCKED';save();return
   observed=json.loads(r['output']);assert observed['status']=='PASS';receipt['publicReference'].append(observed);r['output']='(Full JSON retained in publicReference)';save()
 for argv,limit in [(['bend',entry,'--check-only'],15),(['bend',entry,'-o',a.output/'subject.c'],30),(['clang','-std=c11','-O3',a.output/'subject.c','-lpthread','-lm','-o',a.output/'subject-native'],120),(['bend',entry,'-o',a.output/'subject.js'],30)]:
  r=run(argv,limit,a.cpu);receipt['commands'].append(r);save()
  if r['exit']!=0:receipt['status']='BUILD_BLOCKED';save();print(receipt['status']);return
 runner=load(ROOT/'experiments/s-integrate/host-retention-run.py','e11_original_compare');ref=next(x for x in receipt['publicReference'] if x['schema']=='Motion' and x['lane']=='message')
 for backend,argv in [('Native',[a.output/'subject-native','0','0','--threads','1','--gpu','off']),('JavaScript',['node',a.output/'subject.js','0','0'])]:
  r=run(argv,5,a.cpu);receipt['commands'].append(r);save()
  if r['exit']!=0:receipt['status']='RUNTIME_BLOCKED';save();return
  out=a.output/(backend+'.txt');out.write_text(r['output']);result=runner.compare_joined(r['output'],ref);result['backend']=backend;receipt['actual'].append(result);r['output']='(Full output retained in '+out.name+')';save()
 receipt['status']='ONE_STATIC_MOTION_MESSAGE_BOTH_BACKENDS_PASS';assert all(sha(a.input/n)==v for n,v in manifest['sources'].items());save();print(receipt['status'])
if __name__=='__main__':main()
