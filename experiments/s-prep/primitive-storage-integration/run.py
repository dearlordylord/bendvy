#!/usr/bin/env python3
"""Actual candidate lifecycle finite controls; no benchmark or proof."""
import atexit,argparse,hashlib,json,os,pathlib,signal,subprocess,tempfile
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--candidate-root',type=pathlib.Path,default=ROOT/'experiments/fivehour-candidate');p.add_argument('--output',type=pathlib.Path,default=HERE/'evidence.json');a=p.parse_args()
CPU=os.environ.get('BENDVY_CPU','8')
def run(args,limit=5,ok=0):
 if "--check-only" in list(map(str,args)):
  limit=int(os.environ.get("BENDVY_CHECKER_SECONDS","5"));assert limit in (5,15)
 child=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:out,err=child.communicate(timeout=limit)
 except subprocess.TimeoutExpired:
  os.killpg(child.pid,signal.SIGKILL);child.communicate();raise
 if child.returncode!=ok:raise RuntimeError((args,child.returncode,out,err))
 return out+err
assert 'bend 2.0.35' in run(['bend','version']);run(['bend','guide'])
expected=(HERE/'expected.txt').read_text();receipt={'scope':'Finite actual candidate storage lifecycle; no provider authority, universal refinement or performance acceptance','commands':[],'sourceSHA256':{},'backends':{},'status':'INCOMPLETE'}
atexit.register(lambda: a.output.write_text(json.dumps(receipt,indent=2)+'\n'))
a.output.write_text(json.dumps(receipt,indent=2)+'\n')
with tempfile.TemporaryDirectory(prefix='primitive-lifecycle-') as directory:
 tmp=pathlib.Path(directory)
 for backend in ['JS','Native']:
  source=a.candidate_root/backend/'experiments/s-integrate';stage=tmp/backend;stage.mkdir()
  for f in source.glob('*.bend'):(stage/f.name).write_bytes(f.read_bytes())
  for f in ['lifecycle.bend','owners.bend','negative-clone.bend','negative-duplicate.bend','negative-cross.bend']:(stage/f).write_bytes((HERE/f).read_bytes())
  receipt['sourceSHA256'][backend]={f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in stage.glob('*.bend')}
  def command(args,limit=5):
   if "--check-only" in list(map(str,args)):limit=int(os.environ.get("BENDVY_CHECKER_SECONDS","5"))
   receipt['commands'].append({'backend':backend,'argv':list(map(str,args)),'limitSeconds':limit})
   return run(['taskset','-c',CPU,*args],limit)
  negatives=[]
  for name,want,got in [('clone','Data','Type'),('duplicate','rows','rows (consumed more than once)'),('cross','S.Row<A.Health, A.Motion, Unit>','S.Row<A.Motion, A.Health, Unit>')]:
   args=['taskset','-c',CPU,'bend',stage/f'negative-{name}.bend','--check-only']
   receipt['commands'].append({'backend':backend,'argv':list(map(str,args)),'limitSeconds':int(os.environ.get('BENDVY_CHECKER_SECONDS','5')),'expectedExit':1})
   output=run(args,5,1)
   for line in ['SOME PROOFS FAIL','Location: bad',f'- expected : {want}',f'- observed : {got}']:assert line in output,(name,line,output)
   negatives.append(name)
  def build(label):
   fixture=stage/'lifecycle.bend';assert 'ALL PROOFS CHECK' in command(['bend',fixture,'--check-only'])
   if backend=='JS':
    program=stage/(label+'.js');command(['bend',fixture,'-o',program],30);return command(['node',program])
   c=stage/(label+'.c');program=stage/label
   command(['bend',fixture,'-o',c],30);command(['clang','-O3',c,'-o',program,'-lm','-pthread'],120)
   return command([program,'--threads','1','--gpu','off'])
  original=build('original');assert original==expected,(backend,original,expected)
  storage=(stage/'storage.bend').read_text()
  # Suppress publication entirely while retaining handle/world consumption.
  start=storage.index('def mark_main(');end=storage.index('\ntype MainEffect',start+1)
  block=storage[start:end];header=block[:block.index('\n  match')]
  # The signature remains unchanged; this safe identity is a semantic omission.
  mutation=header+'\n  world\n'
  (stage/'storage.bend').write_text(storage[:start]+mutation+storage[end:])
  changed=build('omitted-mark');assert changed!=expected,'mark omission survived literal oracle'
  assert 'marked:4|40:40,41,42,43|140:140,141,142,143|absent|5:6\n' in changed
  receipt['backends'][backend]={'observations':len(expected.splitlines()),'original':'PASS','intendedTypeNegatives':negatives,'compilingOmittedMark':'REJECTED_BY_LITERAL_ORACLE','originalSHA256':hashlib.sha256(original.encode()).hexdigest(),'mutantSHA256':hashlib.sha256(changed.encode()).hexdigest()}
  (HERE/(backend.lower()+'-observed.txt')).write_text(original)
receipt['status']='FINITE_LIFECYCLE_AND_COMPILING_MARK_MUTATION_PASS'
a.output.write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['status'])
