"""Ordinary-only indexed Column checkpoint; no prepared/capture/performance acceptance."""
import pathlib,subprocess,json,hashlib,argparse,os,shutil,tempfile
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory():return {str(p.relative_to(ROOT)):sha(p) for p in sorted(list((ROOT/'src/ecs').glob('*.bend'))+list(HERE.glob('*.bend'))+[HERE.parent/'refusal-control.bend'])}
r={'scope':'Ordinary indexed payload/stamp finite comparison; staged prepare identity/capture unavailable, no prepared, capture or performance delivery','sources':inventory(),'commands':[],'status':'INCOMPLETE'}
def run(label,cmd,cap,good=True):
 q=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'));(out/(label+'.stdout')).write_text(q.stdout);(out/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert (q.returncode==0)==good,(label,q.stderr,q.stdout);return q.stdout if good else q.stdout+q.stderr

def validate(text):
 v=json.loads(text);assert len(v)==35
 for i in range(0,30,2):assert v[i]==v[i+1],(i,v[i],v[i+1])
 assert v[30]==v[31];assert v[32]==[0]+v[31];assert v[33]==v[34]
 assert v[2][:4]==[3,7,4,7],v[2]
 return v
try:
 for module in ['column.bend','indexed-lifecycle.bend','captured-column.bend','row-column.bend','component.bend']:
  run('check-'+module,['bend',ROOT/'src/ecs'/module,'--check-only'],5)
 run('check-control',['bend',HERE/'ordinary.bend','--check-only'],5)
 negative=run('negative-owner',['bend',HERE/'negative-owner.bend','--check-only'],5,False);assert 'column (consumed more than once)' in negative
 vals=[]
 for backend in ['JS','Native']:
  target=out/('ordinary.js' if backend=='JS' else 'ordinary.c');run('emit-'+backend,['bend',HERE/'ordinary.bend','-o',target],30)
  if backend=='Native':run('compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/'ordinary','-pthread','-lm'],120)
  vals.append(validate(run('run-'+backend,['node',target] if backend=='JS' else [out/'ordinary'],5)))
 assert vals[0]==vals[1]
 # Mutate actual promoted source in isolated full closure, never shared core.
 for name,path,old,new in [
 ('wrong-index','indexed-lifecycle.bend','Array.set(U32,changed,U32.sub(id,1),last)','Array.set(U32,changed,id,last)'),
 ('owner-restoration','column.bend','Array.swap(Maybe<&1,C>,values,U32.sub(id,1),Some{owner}))','Array.swap(Maybe<&1,C>,values,U32.sub(id,1),None{}))')]:
  with tempfile.TemporaryDirectory(prefix='indexed-ordinary-mutant-') as temp:
   stage=pathlib.Path(temp);shutil.copytree(ROOT/'src/ecs',stage/'src/ecs');dest=stage/'experiments/public-optimized-compose';dest.mkdir(parents=True);shutil.copy2(HERE.parent/'refusal-control.bend',dest/'refusal-control.bend');d=dest/HERE.name;shutil.copytree(HERE,d)
   source=stage/'src/ecs'/path;text=source.read_text();assert old in text
   # First match is the added indexed helper (legacy shapes follow later).
   source.write_text(text.replace(old,new,1));r.setdefault('mutants',{})[name]={'source_sha256':sha(source),'backends':{}}
   run(name+'-check',['bend',d/'ordinary.bend','--check-only'],5)
   for backend in ['JS','Native']:
    target=out/(name+('.js' if backend=='JS' else '.c'));run(name+'-emit-'+backend,['bend',d/'ordinary.bend','-o',target],30)
    if backend=='Native':run(name+'-compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/name,'-pthread','-lm'],120)
    actual=run(name+'-run-'+backend,['node',target] if backend=='JS' else [out/name],5)
    try:validate(actual)
    except AssertionError:r['mutants'][name]['backends'][backend]='DETECTED'
    else:raise AssertionError(name+' survived '+backend)
 assert inventory()==r['sources'];r['status']='PASS';r['pairs']=15;r['stage_controls']=5
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
