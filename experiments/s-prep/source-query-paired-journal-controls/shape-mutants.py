#!/usr/bin/env python3
import pathlib,json,hashlib,subprocess,signal,os,argparse
from pins import verify
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--kinds',nargs='+',choices=['restore-omission','missing-main','dead-main','high-water']);a=p.parse_args();a.output.mkdir(exist_ok=False);H=pathlib.Path(__file__).resolve().parent;files,pins,closure=verify(a.overlay);q=files['query.bend'].decode();at=q.index('def prototype_identity_');prefix,tail=q[:at],q[at:];r={'status':'INCOMPLETE','source29Original':pins,'closure':closure,'scope':'Finite actual identity-family full-shape ownership/dead/missing/high-water mutants','commands':[],'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 cmd=['taskset','-c','10',*map(str,argv)];e={'argv':cmd,'limitSeconds':limit};r['commands'].append(e);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';ch=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env)
 try:o,err=ch.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(ch.pid,signal.SIGKILL);ch.communicate();e['status']='TIMEOUT';save();raise
 (a.output/(label+'.stdout')).write_text(o);(a.output/(label+'.stderr')).write_text(err);e['returncode']=ch.returncode;save();assert ch.returncode==0,(cmd,o,err);return o
changed={}
if 'prototype_identity_array_restore' in tail:
 needle='(Array.set(Maybe<M>,array,index,Some{owner}),True{})';assert tail.count(needle)==1;changed['restore-omission']=tail.replace(needle,'(array,True{})')
 needle='case Tuple{array,None{}}: (array,False{})';assert tail.count(needle)==1;changed['missing-main']=tail.replace(needle,needle.replace('False{}','True{}'))
else:
 needle='StructColsState{Array.set(Maybe<M>,main,U32.sub(id,1),Some{owner}),aux,live,flags,added,changed,S.Handle{namespace,id} <> values}';assert tail.count(needle)==1;changed['restore-omission']=tail.replace(needle,needle.replace('Array.set(Maybe<M>,main,U32.sub(id,1),Some{owner})','main'))
 needle='case Tuple{main,None{}}: StructColsState{main,aux,live,flags,added,changed,values}';assert tail.count(needle)==1;changed['missing-main']=tail.replace(needle,needle.replace('changed,values','changed,S.Handle{namespace,id} <> values'))
needle='case Tuple{live,False{}}: StructColsState{main,aux,live,flags,added,changed,values}';assert tail.count(needle)==1
replacement='case Tuple{live,False{}}: prototype_identity_struct_idx_metadata(~Schema,~M,~A,~F,id,namespace,selection,main,aux,values,live,added,changed,True{},Array.get(Maybe<&2,F>,flags,U32.sub(id,1)))';changed['dead-main']=tail.replace(needle,replacement)
needle='U32.to_nat(high),1,capacity,depth,high,selection,namespace,StructColsState';assert tail.count(needle)==1;changed['high-water']=tail.replace(needle,needle.replace('U32.to_nat(high)','U32.to_nat(capacity)')).replace('S.MetadataColumns{live,flags,added,changed},capacity,depth,+high','S.MetadataColumns{live,flags,added,changed},+capacity,depth,+high')
try:
 for kind,mutation in changed.items():
  if a.kinds and kind not in a.kinds:continue
  for backend in ['JS','Native']:
   name=kind+'-'+backend;stage=a.output/name;stage.mkdir();[(stage/n).write_bytes(b) for n,b in files.items()];(stage/'query.bend').write_text(prefix+mutation);f=stage/'fixture.bend';f.write_bytes((H/'full-shape.bend').read_bytes());assert 'ALL PROOFS CHECK' in run(['bend',f,'--check-only'],15,name+'-check');dest=stage/('subject.js' if backend=='JS' else 'subject.c');run(['bend',f,'-o',dest],30,name+'-emit')
   if backend=='Native':run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',stage/'native','-lm','-pthread'],120,name+'-clang')
   out=run(['node',dest] if backend=='JS' else [stage/'native','--threads','1','--gpu','off'],5,name+'-run');expected=(H/'full-shape-expected.txt').read_text();actual=out.splitlines();old=expected.splitlines();assert len(actual)==len(old)==20;assert [x.split(':',1)[0] for x in actual]==[x.split(':',1)[0] for x in old];at=next(i for i,(x,y) in enumerate(zip(actual,old)) if x!=y)
   # Separate exact causal witness clauses, not merely output inequality.
   witness='d0-Required' if kind=='restore-omission' else 'd2-Required' if kind in ['missing-main','dead-main'] else 'd2-Optional';at=next(i for i,x in enumerate(old) if x.startswith(witness+':'));assert actual[at]!=old[at]
   if kind=='restore-omission':assert '|none|' in actual[at]
   if kind=='missing-main':assert '|7:1;7:2;end' in actual[at]
   if kind=='dead-main':assert '|7:1;7:3;end' in actual[at]
   if kind=='high-water':assert '|7:1;7:4;end' in actual[at]
   r['cases'].append({'name':name,'status':'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE','mutantQuerySHA256':hashlib.sha256((prefix+mutation).encode()).hexdigest(),'witness':{'label':witness,'expected':old[at],'actual':actual[at]},'fullCheckpoints':20});save()
 r['status']='ALL_REQUESTED_ACTUAL_FULL_SHAPE_COMPILING_MUTANTS_DETECTED';save()
except BaseException as e:r['failure']=repr(e);save();raise
