#!/usr/bin/env python3
import pathlib,json,hashlib,subprocess,signal,os,argparse
from pins import verify
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,default=pathlib.Path('/tmp/bendvy-private-id-query-v4'));p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);H=pathlib.Path(__file__).resolve().parent;files,pins,closure=verify(a.overlay);q=files['query.bend'].decode();h=files['held-adapter.bend'].decode();at=q.index('def prototype_cursor_restore_state');prefix,tail=q[:at],q[at:];r={'status':'INCOMPLETE','source29Original':pins,'closure':closure,'scope':'Actual private cursor query/loop compiling semantic witnesses; no proof','commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,cap,label):
 cmd=['taskset','-c','10',*map(str,argv)];env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';child=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env)
 try:o,e=child.communicate(timeout=cap)
 except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);o,e=child.communicate();(a.output/(label+'.stdout')).write_text(o);(a.output/(label+'.stderr')).write_text(e);r['commands'].append({'argv':cmd,'limitSeconds':cap,'timeout':True});save();raise
 (a.output/(label+'.stdout')).write_text(o);(a.output/(label+'.stderr')).write_text(e);r['commands'].append({'argv':cmd,'limitSeconds':cap,'returncode':child.returncode});save();assert child.returncode==0,(cmd,o,e);return o
n='Array.set(Maybe<M>,main,U32.sub(id,1),Some{owner})';assert tail.count(n)==1
m='selected(F,selection,flag)';assert tail.count(m)==1
end='struct_cols_finish(M,A,F,U32,capacity,depth,high,state)';assert tail.count(end)==1
helper='''def prototype_cursor_reverse_mutant(-M:Type,-A:Type,-F:Data,capacity:U32,depth:Nat,high:U32,state:StructColsState<M,A,F,U32>) -> S.Rows<M,A,F> & List<&2,U32>:
  match state:
    case StructColsState{main,aux,live,flags,added,changed,values}: (S.Rows{main,aux,S.MetadataColumns{live,flags,added,changed},capacity,depth,high},values)
'''
affected=h[h.index('def prototype_cursor_flatfold_motion_loop'):];assert affected.count('S.Handle{namespace,handle}')==2
cases=[('lost-owned-main','query.bend',prefix+tail.replace(n,'Array.set(Maybe<M>,main,U32.sub(id,1),None{})'),'full-shape',lambda lines:lines[0].split('|')[2]=='none'),('ignore-selection','query.bend',prefix+tail.replace(m,'True{}'),'order',lambda lines:lines[1]=='7:[1,2,3]'),('reverse-order','query.bend',prefix+helper+tail.replace(end,'prototype_cursor_reverse_mutant(M,A,F,capacity,depth,high,state)'),'order',lambda lines:lines[0]=='7:[3,2,1]'),('ignore-cursor-namespace','held-adapter.bend',h[:h.index('def prototype_cursor_flatfold_motion_loop')]+affected.replace('S.Handle{namespace,handle}','S.Handle{7,handle}'),'cursor',lambda lines:lines[2]=='1677')]
try:
 for kind,module,body,fixture,witness in cases:
  for backend in ['JS','Native']:
   label=kind+'-'+backend;stage=a.output/label;stage.mkdir();[(stage/n).write_bytes(b) for n,b in files.items()];(stage/module).write_text(body);src=stage/'fixture.bend';src.write_bytes((H/(fixture+'.bend')).read_bytes());assert 'ALL PROOFS CHECK' in run(['bend',src,'--check-only'],15,label+'-check');dest=stage/('subject.js' if backend=='JS' else 'subject.c');run(['bend',src,'-o',dest],30,label+'-emit')
   if backend=='Native':run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',stage/'native','-lm','-pthread'],120,label+'-clang')
   actual=run(['node',dest] if backend=='JS' else [stage/'native','--threads','1','--gpu','off'],5,label+'-run');expected=(H/(fixture+'-expected.txt')).read_text();lines=actual.splitlines();assert len(lines)==len(expected.splitlines()) and actual!=expected and witness(lines),(kind,actual);r['cases'].append({'name':label,'status':'DETECTED_COMPILING_INTENDED_COUNTEREXAMPLE','mutatedModule':module,'mutantSHA256':hashlib.sha256(body.encode()).hexdigest(),'fixtureSHA256':hashlib.sha256(src.read_bytes()).hexdigest(),'checkpoints':len(lines),'firstDifference':next({'index':i,'expected':x,'actual':y} for i,(x,y) in enumerate(zip(expected.splitlines(),lines)) if x!=y)});save()
 r['status']='ALL_EIGHT_PRIVATE_CURSOR_COMPILING_MUTANTS_DETECTED';save()
except BaseException as e:r['failure']=repr(e);save();raise
