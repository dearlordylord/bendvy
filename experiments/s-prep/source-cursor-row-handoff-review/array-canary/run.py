from pathlib import Path
import subprocess,os,signal,json,hashlib
H=Path(__file__).resolve().parent;O=Path('/tmp/bendvy-handoff-array-runtime-canary-v1');O.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Installed generic Array constructor/runtime finite canary only, no source query equivalence/proof/foreign interop claim','CPU':9,'commands':[]};save=lambda:(O/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(args,cap,label):
 args=list(map(str,args));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';p=subprocess.Popen(['taskset','-c','9',*args],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env)
 try:s=p.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);s=p.communicate()[0];raise
 f=O/(label+'.txt');f.write_text(s);r['commands'].append({'argv':args,'cap':cap,'exit':p.returncode,'outputSHA256':sha(f)});save();return p.returncode,s
for name in ['balanced','ragged']:
 src=H/(name+'.bend');r.setdefault('sourcePins',{})[name]=sha(src)
 for args,cap,label in [(['bend',src,'--check-only'],15,name+'-check'),(['bend',src,'-o',O/(name+'.js')],30,name+'-js-emit'),(['bend',src,'-o',O/(name+'.c')],30,name+'-c-emit'),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',O/(name+'.c'),'-o',O/(name+'-native'),'-lm','-pthread'],120,name+'-clang')]:
  code,s=run(args,cap,label);assert code==0,s[-1000:]
 for backend,args in [('js',['node',O/(name+'.js')]),('native',[O/(name+'-native'),'--threads','1','--gpu','off'])]:
  code,s=run(args,5,name+'-'+backend+'-run');assert 'BEFORE' in s
  if name=='balanced':assert code==0 and 'SIZE=4' in s and 'OLD=3' in s
  else:assert code!=0 and 'SIZE='not in s and 'OLD='not in s
r['status']='BOTH_BACKENDS_BALANCED_ARRAY_SIZE_SWAP_PASS_RAGGED_CONSTRUCTOR_FAILSTOP_BEFORE_SIZE';save();print(r['status'])
