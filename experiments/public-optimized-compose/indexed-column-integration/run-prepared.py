"""Finite indexed prepared/capture owner evidence; no timing or Workshop opt-in."""
import pathlib,subprocess,json,hashlib,argparse,os,shutil,tempfile,re
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory():return {str(p.relative_to(ROOT)):sha(p) for p in sorted(list((ROOT/'src/ecs').glob('*.bend'))+list(HERE.glob('*.bend'))+[HERE.parent/'refusal-control.bend'])}
r={'scope':'60 finite old/new prepared/capture cases with full payload/stamps; no universal refinement, Workshop opt-in or performance acceptance','sources':inventory(),'commands':[],'status':'INCOMPLETE'}
def run(label,cmd,cap,good=True):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'));(out/(label+'.stdout')).write_text(q.stdout);(out/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert (q.returncode==0)==good,(label,q.stderr,q.stdout);return q.stdout if good else q.stdout+q.stderr

def validate(text):
 v=json.loads(text);assert len(v)==120
 for i in range(0,120,2):assert v[i]==v[i+1],(i,v[i],v[i+1])
 # Found projection mutates actual stored owner; full physical cells observed.
 assert v[2][:4]==[3,7,4,7],v[2]
 return v
try:
 for module in ['column.bend','indexed-lifecycle.bend','captured-column.bend','row-column.bend','component.bend','restored-row.bend']:
  run('check-'+module,['bend',ROOT/'src/ecs'/module,'--check-only'],5)
 run('check-control',['bend',HERE/'prepared.bend','--check-only'],5)
 negative=run('negative-owner',['bend',HERE/'negative-owner.bend','--check-only'],5,False);assert 'column (consumed more than once)' in negative
 vals=[]
 for backend in ['JS','Native']:
  target=out/('prepared.js' if backend=='JS' else 'prepared.c');run('emit-'+backend,['bend',HERE/'prepared.bend','-o',target],30)
  if backend=='Native':run('compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/'prepared','-pthread','-lm'],120)
  vals.append(validate(run('run-'+backend,['node',target] if backend=='JS' else [out/'prepared'],5)))
 assert vals[0]==vals[1]
 for name,path,old,new in [
 ('wrong-index','indexed-lifecycle.bend','Array.set(U32,changed,U32.sub(id,1),last)','Array.set(U32,changed,id,last)'),
 ('current-recovery','column.bend','indexed_wrap(~S,~C,recover_selected_rows(S,C,remaining,recover_past(~S,~C,past,Array.set(Maybe<&1,C>,values,U32.sub(current,1),owner))),metadata)','indexed_wrap(~S,~C,recover_selected_rows(S,C,remaining,recover_past(~S,~C,past,Array.set(Maybe<&1,C>,values,U32.sub(current,1),None{}))),metadata)'),
 ('capture-restoration','captured-column.bend','Col.indexed_wrap(~S,~C,Array.set(Maybe<&1,C>,values,U32.sub(id,1),owner),metadata)','Col.indexed_wrap(~S,~C,Array.set(Maybe<&1,C>,values,U32.sub(id,1),None{}),metadata)')]:
  with tempfile.TemporaryDirectory(prefix='indexed-prepared-mutant-') as temp:
   stage=pathlib.Path(temp);shutil.copytree(ROOT/'src/ecs',stage/'src/ecs');dest=stage/'experiments/public-optimized-compose';dest.mkdir(parents=True);shutil.copy2(HERE.parent/'refusal-control.bend',dest/'refusal-control.bend');d=dest/HERE.name;shutil.copytree(HERE,d)
   source=stage/'src/ecs'/path;text=source.read_text();assert text.count(old)==1,(name,text.count(old));source.write_text(text.replace(old,new,1));r.setdefault('mutants',{})[name]={'source_sha256':sha(source),'backends':{}}
   run(name+'-check',['bend',d/'prepared.bend','--check-only'],5)
   for backend in ['JS','Native']:
    target=out/(name+('.js' if backend=='JS' else '.c'));run(name+'-emit-'+backend,['bend',d/'prepared.bend','-o',target],30)
    if backend=='Native':run(name+'-compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/name,'-pthread','-lm'],120)
    actual=run(name+'-run-'+backend,['node',target] if backend=='JS' else [out/name],5)
    try:validate(actual)
    except AssertionError:r['mutants'][name]['backends'][backend]='DETECTED'
    else:raise AssertionError(name+' survived '+backend)
 assert inventory()==r['sources'];r['status']='PASS';r['pairs']=60
 native=out/'prepared.c';r['native_control_source_sha256']=sha(native);r['native_control_WL_RESW']=int(re.search(r'#define WL_RESW (\d+)',native.read_text())[1])
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
