#!/usr/bin/env python3
import pathlib,json,hashlib,subprocess,signal,os,argparse,shutil
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--original',type=pathlib.Path,default=pathlib.Path('/tmp/bendvy-query-paired-controls-lifecycle-v1'));a=p.parse_args();a.output.mkdir(exist_ok=False)
r={'status':'INCOMPLETE','scope':'Actual identity-family compiling order and selection mutants, unchanged40 literal oracle','cases':[],'commands':[]};sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 cmd=['taskset','-c','10',*map(str,argv)];e={'argv':cmd,'limitSeconds':limit};r['commands'].append(e);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';ch=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True,env=env)
 try:o,err=ch.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(ch.pid,signal.SIGKILL);ch.communicate();e['status']='TIMEOUT';save();raise
 (a.output/(label+'.stdout')).write_text(o);(a.output/(label+'.stderr')).write_text(err);e['returncode']=ch.returncode;save();assert ch.returncode==0,(cmd,o,err);return o
for schema in ['one','two']:
 for backend in ['JS','Native']:
  base=a.original/f'identity-{schema}-{backend}';receipt=json.loads((a.original/'evidence.json').read_text());assert receipt['status']=='ACTUAL_IDENTITY_AND_UNCHANGED_GENERIC_40_ALL_FOUR_ROLES_PASS';assert {f.name:sha(f) for f in base.glob('*.bend') if f.name not in ['owners.bend','query-lifecycle.bend']}==receipt['source29'];q=(base/'query.bend').read_text();at=q.index('def prototype_identity_');prefix,tail=q[:at],q[at:]
  for kind in ['order','selection']:
   name=f'{schema}-{backend}-{kind}';stage=a.output/name;stage.mkdir();[shutil.copyfile(f,stage/f.name) for f in base.glob('*.bend')]
   if kind=='selection':assert tail.count('selected(F,selection,flag)')==1;changed=prefix+tail.replace('selected(F,selection,flag)','True{}')
   else:
    needle='case 0n: struct_cols_finish(M,A,F,S.Handle<Schema>,capacity,depth,high,state)';assert tail.count(needle)==1
    helper='''def prototype_identity_mutant_finish(-M:Type,-A:Type,-F:Data,-O:Data,capacity:U32,depth:Nat,high:U32,state:StructColsState<M,A,F,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match state:
    case StructColsState{main,aux,live,flags,added,changed,values}: (S.Rows{main,aux,S.MetadataColumns{live,flags,added,changed},capacity,depth,high},values)
'''
    changed=prefix+helper+tail.replace(needle,needle.replace('struct_cols_finish','prototype_identity_mutant_finish'))
   (stage/'query.bend').write_text(changed);f=stage/'query-lifecycle.bend';assert 'ALL PROOFS CHECK' in run(['bend',f,'--check-only'],15,name+'-check');dest=stage/('subject.js' if backend=='JS' else 'subject.c');run(['bend',f,'-o',dest],30,name+'-emit')
   if backend=='Native':run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',stage/'native','-lm','-pthread'],120,name+'-clang')
   out=run(['node',dest] if backend=='JS' else [stage/'native','--threads','1','--gpu','off'],5,name+'-run');expected=(a.original/f'identity-{schema}-{backend}-run.stdout').read_text();assert out!=expected
   lines=out.splitlines();old=expected.splitlines();assert len(lines)==len(old)==40;assert [x.split(':',1)[0] for x in lines]==[x.split(':',1)[0] for x in old]
   label='initial-required' if kind=='order' else 'initial-present';at=next(i for i,x in enumerate(old) if x.startswith(label+':'));ns='7' if schema=='one' else '9'
   if kind=='order':assert lines[at].startswith(label+':'+ns+':3|')
   else:assert ns+':3|30:30,31,32,33|none|absent;' in lines[at]
   r['cases'].append({'name':name,'status':'DETECTED_COMPILING_RUNTIME_COUNTEREXAMPLE','source29Original':{f.name:sha(f) for f in base.glob('*.bend') if f.name not in ['owners.bend','query-lifecycle.bend']},'mutatedQuerySHA256':sha(stage/'query.bend'),'fixtureSHA256':sha(f),'witness':{'label':label,'expected':old[at],'actual':lines[at]},'checkpoints':40});save()
r['status']='ACTUAL_IDENTITY_ORDER_SELECTION_EIGHT_COMPILING_MUTANTS_DETECTED';save()
