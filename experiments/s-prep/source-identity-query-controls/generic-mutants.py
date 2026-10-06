#!/usr/bin/env python3
import pathlib,json,hashlib,subprocess,signal,os,argparse
from pins import verify
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);H=pathlib.Path(__file__).resolve().parent;files,pins,closure=verify(a.overlay);q=files['query.bend'].decode();at=q.index('def prototype_identity_');prefix,tail=q[:at],q[at:];r={'status':'INCOMPLETE','source29Original':pins,'closure':closure,'scope':'Finite reached original generic-client nonidentity returned Main/Aux omission mutants','commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 cmd=['taskset','-c','10',*map(str,argv)];e={'argv':cmd,'limitSeconds':limit};r['commands'].append(e);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';ch=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env)
 try:o,err=ch.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(ch.pid,signal.SIGKILL);ch.communicate();e['status']='TIMEOUT';save();raise
 (a.output/(label+'.stdout')).write_text(o);(a.output/(label+'.stderr')).write_text(err);e['returncode']=ch.returncode;save();assert ch.returncode==0,(cmd,o,err);return o
changed={}
needle='case (m,(a,value)): StructColsState{Array.set(Maybe<M>,main,index,Some{m}),Array.set(Maybe<A>,aux,index,a),live,flags,added,changed,value <> values}'
assert q.count(needle)==1
changed['returned-main']=q.replace(needle,needle.replace('Array.set(Maybe<M>,main,index,Some{m})','main'))
changed['returned-aux']=q.replace(needle,needle.replace('Array.set(Maybe<A>,aux,index,a)','aux'))
prefix=''
try:
 for kind,mutation in changed.items():
  for backend in ['JS','Native']:
   name=kind+'-'+backend;stage=a.output/name;stage.mkdir();[(stage/n).write_bytes(b) for n,b in files.items()];(stage/'query.bend').write_text(prefix+mutation);f=stage/'fixture.bend';f.write_bytes((H/'generic-nonidentity.bend').read_bytes());assert 'ALL PROOFS CHECK' in run(['bend',f,'--check-only'],15,name+'-check');dest=stage/('subject.js' if backend=='JS' else 'subject.c');run(['bend',f,'-o',dest],30,name+'-emit')
   if backend=='Native':run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',stage/'native','-lm','-pthread'],120,name+'-clang')
   out=run(['node',dest] if backend=='JS' else [stage/'native','--threads','1','--gpu','off'],5,name+'-run');expected=(H/'generic-nonidentity-expected.txt').read_text();actual=out.splitlines();old=expected.splitlines();assert len(actual)==len(old)==1;assert [x.split(':',1)[0] for x in actual]==[x.split(':',1)[0] for x in old];at=next(i for i,(x,y) in enumerate(zip(actual,old)) if x!=y)
   at=0;witness=kind;assert actual[0]!=old[0]
   if kind=='returned-main':assert '|none|101002@103|' in actual[0]
   else:assert '|1002@3|none|' in actual[0]
   r['cases'].append({'name':name,'status':'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE','mutantQuerySHA256':hashlib.sha256((prefix+mutation).encode()).hexdigest(),'witness':{'label':witness,'expected':old[at],'actual':actual[at]},'fullCheckpoints':1});save()
 r['status']='FOUR_GENERIC_RETURNED_MAIN_AUX_COMPILING_MUTANTS_DETECTED';save()
except BaseException as e:r['failure']=repr(e);save();raise
