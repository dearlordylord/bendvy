#!/usr/bin/env python3
"""Actual public generic query drop-returned-affine-Main counterexample."""
import argparse,pathlib,json,hashlib,shutil,subprocess,signal,os
from pins import verify
H=pathlib.Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();files,pins,closure=verify(a.overlay);a.output.mkdir(exist_ok=False)
q=files['query.bend'].decode();old='StructColsState{Array.set(Maybe<M>,main,index,Some{m}),Array.set(Maybe<A>,aux,index,a),live,flags,added,changed,value <> values}';assert q.count(old)==1;files['query.bend']=q.replace(old,old.replace('Array.set(Maybe<M>,main,index,Some{m})','main')).encode()
r={'status':'INCOMPLETE','parentClosure':closure,'actualMutated29':{'experiments/s-integrate/'+n:hashlib.sha256(b).hexdigest() for n,b in files.items()},'route':'original public Q.each, trusted nonidentity getter, opaque closed client, arbitrary affine Type Main/Aux/Ledger','commands':[],'subjects':{}}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(cmd,cap,stage,label):
 cmd=['taskset','-c','10',*map(str,cmd)];e={'argv':cmd,'limitSeconds':cap};r['commands'].append(e);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';ch=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env)
 try:o,err=ch.communicate(timeout=cap)
 except subprocess.TimeoutExpired:os.killpg(ch.pid,signal.SIGKILL);o,err=ch.communicate();e['status']='TIMEOUT';save();raise
 (stage/(label+'.stdout')).write_text(o);(stage/(label+'.stderr')).write_text(err);e['returncode']=ch.returncode;save();assert ch.returncode==0,(label,o,err);return o+err
try:
 for backend in ['JS','Native']:
  st=a.output/backend;st.mkdir();[(st/n).write_bytes(b) for n,b in files.items()];f=st/'fixture.bend';shutil.copyfile(H/'public-query-full-shape.bend',f);assert 'ALL PROOFS CHECK' in run(['bend',f,'--check-only'],15,st,'check')
  dest=st/('subject.js' if backend=='JS' else 'subject.c');run(['bend',f,'-o',dest],30,st,'emit')
  if backend=='Native':run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',st/'native','-lm','-pthread'],120,st,'clang')
  out=run(['node',dest] if backend=='JS' else [st/'native','--threads','1','--gpu','off'],5,st,'run');expected=(H/'public-query-full-shape-expected.txt').read_text();assert out!=expected
  first=out.splitlines()[0];prior=expected.splitlines()[0];assert first.split('|')[2]=='none' and prior.split('|')[2]=='1000@2';assert first.split('|')[:2]==prior.split('|')[:2] and first.split('|')[3:]==prior.split('|')[3:]
  r['subjects'][backend]={'status':'INTENDED_RUNTIME_COUNTEREXAMPLE','checkpoint':'d0-Required','expectedMain':'1000@2','observedMain':'none','otherFieldsAndHandlesUnchanged':True,'recordCount':len(out.splitlines()),'outputSHA256':hashlib.sha256(out.encode()).hexdigest()};save()
 r['status']='COMPILING_RETURNED_OWNER_MUTATION_DETECTED_BOTH_BACKENDS';save()
except BaseException as e:r['failure']=repr(e);save();raise
