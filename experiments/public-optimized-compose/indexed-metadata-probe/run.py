"""Finite scalar metadata observations/compatibility, no ECS/performance acceptance."""
import pathlib,subprocess,json,hashlib,argparse,os,shutil,tempfile

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner
from task_runner import run as _run_command

HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory():return {str(p.relative_to(ROOT)):sha(p) for p in sorted(list((ROOT/'src/ecs').glob('*.bend'))+list(HERE.glob('*.bend'))+[HERE.parent/'refusal-control.bend',HERE.parent/'row-cell-control.bend'])}
r={'scope':'Finite stamp-observation equivalence for factory metadata, raw legacy representation and unchanged consumer exhaustiveness; no universal runtime refinement, Column integration or performance acceptance','sources':inventory(),'commands':[],'status':'INCOMPLETE'}
def run(label,cmd,cap,good=True):
 env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root');q=_run_command(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=env);(out/(label+'.stdout')).write_text(q.stdout);(out/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert (q.returncode==0)==good,q.stderr;return q.stdout if good else q.stdout+q.stderr
expected_tail=[[5,9,0,13,23,29],[1,31,37,2,0,13,0,23,29],[2,0,13,0,23,29],[3,7,4,7,5,9,1,0]]
def validate(text):
 v=json.loads(text);assert len(v)==34;assert v[-4:]==expected_tail
 for i in range(0,30,2):assert v[i]==v[i+1],(i,v[i],v[i+1])
 return v
try:
 run('check',['bend',HERE/'controls.bend','--check-only'],5)
 failure=run('negative-duplicate',['bend',HERE/'negative-duplicate.bend','--check-only'],5,False);assert 'metadata (consumed more than once)' in failure
 with tempfile.TemporaryDirectory(prefix='indexed-compat-') as temp:
  stage=pathlib.Path(temp);shutil.copytree(ROOT/'src/ecs',stage/'src/ecs');d=stage/'experiments/public-optimized-compose/indexed-metadata-probe';shutil.copytree(HERE,d)
  library=(d/'compat-library.bend').read_text();r['compatibility']={'consumer_sha256':sha(HERE/'compat-consumer.bend'),'cases':[]}
  for name,new in [('old',library),('generic-added',library.replace('type Nominal','  Indexed{carrier:Carrier<C>}\ntype Nominal')),('nominal-added',library+'  IndexedNominal{owner:Carrier<Array<U32>>}\n')]:
   (d/'compat-library.bend').write_text(new);text=run('compat-'+name,['bend',d/'compat-consumer.bend','--check-only'],5,name=='old')
   if name!='old':assert ('cases for compat-library.Indexed' if name=='generic-added' else 'cases for compat-library.IndexedNominal') in text
   r['compatibility']['cases'].append({'case':name,'library_sha256':sha(d/'compat-library.bend'),'unchanged_consumer_sha256':sha(d/'compat-consumer.bend'),'pass':name=='old'})
  (d/'compat-library.bend').write_text(library)
 normal=[]
 for backend in ['JS','Native']:
  target=out/('controls.js' if backend=='JS' else 'controls.c');run('emit-'+backend,['bend',HERE/'controls.bend','-o',target],30)
  if backend=='Native':run('compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/'controls','-pthread','-lm'],120)
  normal.append(validate(run('run-'+backend,['node',target] if backend=='JS' else [out/'controls'],5)))
 assert normal[0]==normal[1]
 with tempfile.TemporaryDirectory(prefix='indexed-mutant-') as temp:
  stage=pathlib.Path(temp);shutil.copytree(ROOT/'src/ecs',stage/'src/ecs');d=stage/'experiments/public-optimized-compose';d.mkdir(parents=True)
  for name in ['refusal-control.bend','row-cell-control.bend']:shutil.copy2(HERE.parent/name,d/name)
  dest=d/'indexed-metadata-probe';shutil.copytree(HERE,dest);meta=dest/'metadata.bend';original=meta.read_text();old='Array.set(U32,changed,U32.sub(id,1),last)';assert original.count(old)==1;meta.write_text(original.replace(old,'Array.set(U32,changed,id,last)'));r['mutant']={'kind':'wrong changed-tick index aliases neighbor/wraps at bound','original_sha256':hashlib.sha256(original.encode()).hexdigest(),'mutant_sha256':sha(meta),'backends':{}}
  run('mutant-check',['bend',dest/'controls.bend','--check-only'],5)
  for backend in ['JS','Native']:
   target=out/('mutant.js' if backend=='JS' else 'mutant.c');run('mutant-emit-'+backend,['bend',dest/'controls.bend','-o',target],30)
   if backend=='Native':run('mutant-compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/'mutant','-pthread','-lm'],120)
   text=run('mutant-run-'+backend,['node',target] if backend=='JS' else [out/'mutant'],5)
   try:validate(text)
   except AssertionError:r['mutant']['backends'][backend]='DETECTED'
   else:raise AssertionError('Mutant survived '+backend)
 assert inventory()==r['sources'];r['status']='PASS';r['pairs']=15;r['raw_duplicate_records']=3;r['payload_metadata_record']=1
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
