"""Finite Array projection parity/owner controls; no measurements or promotion."""
import argparse,pathlib,subprocess,hashlib,json,os,shutil,tempfile,re
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];SCHEMA=HERE.parent/'workshop/schema.bend'
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory():return {str(p.relative_to(ROOT)):sha(p) for p in sorted(list(HERE.glob('*.bend'))+[HERE/'run.py',SCHEMA])}
r={'status':'INCOMPLETE','scope':'576fullcapacity/owner/prefix/snapshot pairs and3checked bound refusals; no universal raw-helper refinement, timing/profile or live promotion','sources':inventory(),'commands':[]}
def run(label,cmd,cap,good=True):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'));(out/(label+'.stdout')).write_text(q.stdout);(out/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert (q.returncode==0)==good,(label,q.stderr);return q.stdout if good else q.stdout+q.stderr

def validate(text):
 lines=text.splitlines();assert len(lines)==579,len(lines)
 lengths=[0,1,2,9,17,33,65,129];offsets=[0,12345,4294967295]
 for i,line in enumerate(lines[:576]):
  index,old,new=line.split('|');assert int(index)==i;old=json.loads(old);new=json.loads(new);assert old==new,(i,old,new)
  cap=1<<(i%8);length=lengths[(i//8)%8];position=[0,cap//2,cap-1][(i//64)%3];base=offsets[(i//192)%3]
  snapshot=[(base+j%3)&0xffffffff for j in range(cap)];after=list(snapshot);after[position]=2147483647
  assert new==[[cap,length],snapshot,snapshot[:length],after,snapshot],(i,new)
 for line in lines[576:]:assert line.startswith('R|') and json.loads(line[2:])==[[0],[7,8,9,7]],line
 return lines
try:
 run('version',['bend','version'],5)
 schema=SCHEMA.read_text();expected_oracle='import Base\n'+schema[schema.index('def array_join('):schema.index('def fill(')];assert (HERE/'oracle.bend').read_text()==expected_oracle;r['oracle_is_exact_live_schema_projection_extract']=True
 run('check',['bend',HERE/'controls.bend','--check-only'],5)
 negative=run('negative-owner',['bend',HERE/'negative-owner.bend','--check-only'],5,False);assert 'array (consumed more than once)' in negative
 observations=[]
 for backend in ['JS','Native']:
  target=out/('controls.js' if backend=='JS' else 'controls.c');run('emit-'+backend,['bend',HERE/'controls.bend','-o',target],30)
  if backend=='Native':run('compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/'controls','-pthread','-lm'],120)
  observations.append(validate(run('run-'+backend,['node',target] if backend=='JS' else [out/'controls'],5)))
 assert observations[0]==observations[1]
 for name,replacement in [('omission','List.reverse(&2,U32,reverse)'),('reordering','value <> reverse')]:
  with tempfile.TemporaryDirectory(prefix='array-view-mutant-') as temp:
   stage=pathlib.Path(temp);shutil.copytree(HERE,stage/'probe');d=stage/'probe';original=(d/'view.bend').read_text();needle='List.reverse(&2,U32,value <> reverse)';assert original.count(needle)==1;(d/'view.bend').write_text(original.replace(needle,replacement));r.setdefault('mutants',{})[name]={'original_sha256':hashlib.sha256(original.encode()).hexdigest(),'mutant_sha256':sha(d/'view.bend'),'backends':{}}
   run(name+'-check',['bend',d/'controls.bend','--check-only'],5)
   for backend in ['JS','Native']:
    target=out/(name+('.js' if backend=='JS' else '.c'));run(name+'-emit-'+backend,['bend',d/'controls.bend','-o',target],30)
    if backend=='Native':run(name+'-compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/name,'-pthread','-lm'],120)
    actual=run(name+'-run-'+backend,['node',target] if backend=='JS' else [out/name],5)
    try:validate(actual)
    except AssertionError:r['mutants'][name]['backends'][backend]='DETECTED'
    else:raise AssertionError(name+' survived '+backend)
 assert inventory()==r['sources'];r['status']='PASS';r['pairs']=576;r['bound_refusals']=3
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
