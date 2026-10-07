"""Finite callback application fusion canary, preserving rejected template match."""
import pathlib,subprocess,json,hashlib,argparse,os,re
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(exist_ok=False)
def inventory():return {str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(list((ROOT/'src/ecs').glob('*.bend'))+list(HERE.glob('*.bend'))+[HERE.parent/'refusal-control.bend',HERE.parent/'row-cell-control.bend'])}
r={'scope':'Finite actual returned-owner/projection mutation comparator and generated dispatch; not universal refinement/allocation savings/performance acceptance','sources':inventory(),'commands':[],'status':'INCOMPLETE'}
def run(label,cmd,cap,good=True):
 env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root');q=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=env);(out/(label+'.stdout')).write_text(q.stdout);(out/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert (q.returncode==0)==good,q.stderr;return q.stdout+q.stderr if not good else q.stdout
try:
 failure=run('rejected-template-match',['bend',HERE/'rejected-template-match.bend','--check-only'],5,False);assert 'an annotated term (cannot infer)' in failure
 run('check',['bend',HERE/'main.bend','--check-only'],5)
 for backend in ['JS','Native']:
  target=out/('main.js' if backend=='JS' else 'main.c');run('emit-'+backend,['bend',HERE/'main.bend','-o',target],30)
  if backend=='Native':run('compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/'main','-pthread','-lm'],120)
  v=json.loads(run('run-'+backend,['node',target] if backend=='JS' else [out/'main'],5));assert v==[[3,7,4,7,5,7]]*2+[[41,43,42,43]]*2,v
 assert inventory()==r['sources'];r['status']='PASS';r['rejected_design']='Direct match on opaque template cap rejected; unchanged checker'
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
