#!/usr/bin/env python3
"""Pinned independent authored finite fixtures and intended negative controls."""
import pathlib,json,hashlib,subprocess,signal,os,argparse,shutil
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--overlay',type=pathlib.Path,default=pathlib.Path('/tmp/bendvy-query-paired-journal-v1'));p.add_argument('--fixture',type=pathlib.Path,required=True);p.add_argument('--expected',type=pathlib.Path);p.add_argument('--negative',action='store_true');a=p.parse_args();a.output.mkdir(exist_ok=False)
from pins import verify
_,verified_pins,closure=verify(a.overlay)
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest();files=list((a.overlay/'experiments/s-integrate').glob('*.bend'));pins={'experiments/s-integrate/'+f.name:sha(f) for f in files};manifest=json.loads((a.overlay/'overlay.json').read_text());assert len(files)==29 and manifest['sources']==pins
r={'status':'INCOMPLETE','scope':'Authored finite owned full-shape identity fixture or intended type negative; no universal proof','source29':pins,'inputManifest':manifest,'closure':closure,'fixtureSHA256':sha(a.fixture),'commands':[],'subjects':{}}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 cmd=['taskset','-c','10',*map(str,argv)];e={'argv':cmd,'limitSeconds':limit};r['commands'].append(e);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';ch=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env)
 try:o,err=ch.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(ch.pid,signal.SIGKILL);ch.communicate();e['status']='TIMEOUT';save();raise
 (a.output/(label+'.stdout')).write_text(o);(a.output/(label+'.stderr')).write_text(err);e['returncode']=ch.returncode;save();return ch.returncode,o+err
try:
 for backend in (['Check'] if a.negative else ['JS','Native']):
  stage=a.output/backend;stage.mkdir();[shutil.copyfile(f,stage/f.name) for f in files];f=stage/'fixture.bend';shutil.copyfile(a.fixture,f);rc,text=run(['bend',f,'--check-only'],15,backend+'-check')
  if a.negative:assert rc==1 and 'SOME PROOFS FAIL' in text and 'Location: bad' in text;text=text;r['subjects'][backend]={'status':'INTENDED_TYPE_REJECTION','diagnostic':text};continue
  assert rc==0 and 'ALL PROOFS CHECK' in text
  dest=stage/('subject.js' if backend=='JS' else 'subject.c');rc,text=run(['bend',f,'-o',dest],30,backend+'-emit');assert rc==0
  if backend=='Native':rc,text=run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',stage/'native','-lm','-pthread'],120,backend+'-clang');assert rc==0
  rc,text=run(['node',dest] if backend=='JS' else [stage/'native','--threads','1','--gpu','off'],5,backend+'-run');assert rc==0;expected=a.expected.read_text();assert text==expected,(text,expected);r['subjects'][backend]={'status':'PASS','checkpoints':len(expected.splitlines()),'outputSHA256':hashlib.sha256(text.encode()).hexdigest()};save()
 r['status']='INTENDED_TYPE_REJECTION_PASS' if a.negative else 'FINITE_AUTHORED_LITERAL_FULL_FIELDS_BOTH_BACKENDS_PASS';save()
except BaseException as e:r['failure']=repr(e);save();raise
