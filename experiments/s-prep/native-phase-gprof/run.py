#!/usr/bin/env python3
"""Phase-bounded existing GNU gprof diagnostic; never a speed metric."""
import argparse,hashlib,importlib.util,json,os,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
import supervisor
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--reference',type=Path,required=True);p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=7);a=p.parse_args()
a.output=a.output.absolute();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{a.cpu})
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r={'status':'INCOMPLETE','scope':'Existing GNU gprof phase diagnostic; instrumentation and sampling are not speed/physical allocation acceptance','schema':a.schema,'cpu':a.cpu,'sourceSHA256':sha(a.source),'referenceSHA256':sha(a.reference),'recipeSHA256':sha(Path(__file__)),'commands':[]}
def execute(argv,limit=5,output=None):
 code,text=supervisor.execute(list(map(str,argv)),limit)
 r['commands'].append({'argv':list(map(str,argv)),'limitSeconds':limit,'exit':code,'outputSHA256':hashlib.sha256(text.encode()).hexdigest()})
 if output:(a.output/output).write_text(text)
 assert code==0,text[-1200:]
 return text
try:
 source=a.source.read_text();assert 'diagnostic_profile_clocks' not in source
 old='Term io_now_run(Env e, Term* f, IoWork* w) {\n  return (Term)(io_tick() / 1000000);\n}'
 assert source.count(old)==1 and source.count('int main(int argc, char** argv) {')==1
 new='''extern void moncontrol(int);
static unsigned diagnostic_profile_clocks;
Term io_now_run(Env e, Term* f, IoWork* w) {
  unsigned n=++diagnostic_profile_clocks;
  if (n==3) { moncontrol(1); fprintf(stderr,"GPROF-PHASE:START\\n"); }
  if (n==4) { moncontrol(0); fprintf(stderr,"GPROF-PHASE:END\\n"); }
  return (Term)(io_tick() / 1000000);
}'''
 source=source.replace(old,new,1).replace('int main(int argc, char** argv) {','int main(int argc, char** argv) {\n  moncontrol(0);',1)
 derived=a.output/'phase.c';derived.write_text(source);r['derivedSHA256']=sha(derived)
 compiler=Path('/tmp/bendvy-clang19-diagnostic/clang19');assert compiler.exists()
 execute(['env','BENDVY_CLANG19_ROOT=/tmp/bendvy-clang19-diagnostic/root',compiler,'-O3','-pg',derived,'-pthread','-lm','-o',a.output/'phase.native'],120,'compile.txt')
 r['binarySHA256']=sha(a.output/'phase.native')
 ts=execute(['node',a.reference],5,'TS.raw.txt')
 # Child-only cwd/redirect; gmon.out is created only under the fresh output dir.
 launch='import os,sys;os.chdir(sys.argv[1]);fd=os.open("phase.stderr.txt",os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600);os.dup2(fd,2);os.close(fd);os.execv(sys.argv[2],sys.argv[2:])'
 native=execute([sys.executable,'-c',launch,a.output,a.output/'phase.native','--threads','1','--gpu','off'],5,'Native.raw.txt')
 marks=(a.output/'phase.stderr.txt').read_text().splitlines();assert marks==['GPROF-PHASE:START','GPROF-PHASE:END'],marks
 ref=json.loads(ts);records=[x for x in native.splitlines() if x.startswith('{')];assert len(records)==65 and len(ref['samples'])==64
 spec=importlib.util.spec_from_file_location('validator',ROOT/'experiments/s-integrate/measurement-bend-run.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 for line,world in zip(records,[ref['warmup'],*ref['samples']]):v.validate(line,a.schema,False,256,world);assert v.normalized(json.loads(line),a.schema)==world['final']
 assert sha(a.source)==r['sourceSHA256'] and (a.output/'gmon.out').exists()
 execute(['gprof','-b',a.output/'phase.native',a.output/'gmon.out'],5,'gprof.txt')
 r.update(status='PROFILE_AND_FULL65_FIELDS_PASS',allFullFieldsEqual=True,phaseClocks=[3,4],startupLimit='Profiling disabled at main body and outside clocks3/4; pre-main entry instrumentation can leave negligible startup records. Samples/call accounting are perturbed; no clock or causation acceptance.')
except Exception as e:r.update(status='FAILED',error=repr(e))
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({'status':r['status'],'error':r.get('error')}));sys.exit(0 if r['status']=='PROFILE_AND_FULL65_FIELDS_PASS' else 1)
