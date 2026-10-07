#!/usr/bin/env python3
"""Build and observe #29 against pinned TS, with source-bound controls."""
import argparse, hashlib, json, os, shutil, statistics, subprocess, tempfile, time
from pathlib import Path

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command

ROOT=Path(__file__).resolve().parents[2]
HERE=Path('experiments/public-query-contract')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--timing',action='store_true');a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 receipt={'status':'INCOMPLETE','commands':[],'scope':'Workshop public count/single/get; full process timing is diagnostic only'}
 def save(): (out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def run(cmd,cwd,cap=5,expected=0,name=None):
  t=time.perf_counter();r=_run_command(cmd,cwd=cwd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,timeout=cap);elapsed=time.perf_counter()-t
  receipt['commands'].append({'command':list(map(str,cmd)),'capSeconds':cap,'exit':r.returncode,'seconds':elapsed,'stdoutSHA256':hashlib.sha256(r.stdout.encode()).hexdigest(),'stderr':r.stderr});save()
  if name:(out/name).write_text(r.stdout)
  if expected is not None and r.returncode!=expected:raise AssertionError((cmd,r.returncode,r.stderr,r.stdout))
  return r.stdout,elapsed,r.returncode
 clang=Path('/tmp/bendvy-clang19-diagnostic/clang19');os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 try:
  receipt['versions']={n:run(c,ROOT)[0].strip() for n,c in [('bend',['bend','version']),('node',['node','--version']),('clang',[str(clang),'--version'])]}
  manifest=json.loads((ROOT/'.references/sources.json').read_text())['sources'];receipt['references']={}
  for n,v in manifest.items():
   observed=run(['git','-C',str(ROOT/'.references'/n),'rev-parse','HEAD'],ROOT)[0].strip();assert observed==v['commit'];receipt['references'][n]=observed
  ref,_,_=run(['node',str(ROOT/HERE/'reference.mjs')],ROOT,name='ts.stdout.json');expected=json.loads(ref);assert len(expected)==16
  receipt['referenceSHA256']=sha(ROOT/HERE/'reference.mjs');receipt['verifierSHA256']=sha(ROOT/HERE/'verify.py')
  def validate(text):
   got=json.loads(text);assert got[:-1]==expected[:-1];assert got[-1]==dict(expected[-1],result={'ok':False,'error':'MissingEntity','entityId':1});return got
  with tempfile.TemporaryDirectory(prefix='public-query-contract-') as temp:
   stage=Path(temp)
   for d in [Path('src/ecs'),Path('examples/query-composition'),HERE]:shutil.copytree(ROOT/d,stage/d)
   receipt['sources']={str(f.relative_to(stage)):sha(f) for d in [Path('src/ecs'),Path('examples/query-composition'),HERE] for f in sorted((stage/d).glob('*.bend'))};save()
   for name,needle in [('negative-read-set','Cap.Write'),('negative-undeclared','bad~H'),('negative-cross-schema','W.Handle<Other>')]:
    text,_,exit=run(['bend',str(HERE/(name+'.bend'))],stage,expected=None,name=name+'.txt');diagnostic=text+receipt['commands'][-1]['stderr'];(out/(name+'.txt')).write_text(diagnostic);assert exit==1 and needle in diagnostic and 'Error:' in diagnostic and 'Location: bad' in diagnostic
   binaries={}
   def build(name):
    source=HERE/(name+'.bend');run(['bend',str(source)],stage,name=name+'.check.txt')
    run(['bend',str(source),'-o',str(out/(name+'.js'))],stage,30)
    run(['bend',str(source),'-o',str(out/(name+'.c'))],stage,30)
    run([str(clang),'-O3',str(out/(name+'.c')),'-o',str(out/(name+'.native')),'-pthread','-lm'],stage,120)
    return {'JS':['node',str(out/(name+'.js'))],'Native':[str(out/(name+'.native'))]}
   for name in ['main','array-controls','integrity-controls']:
    binaries[name]=build(name)
    for backend,cmd in binaries[name].items():
     text,_,_=run(cmd,stage,name=name+'-'+backend+'.stdout.json')
     if name=='main':validate(text)
     elif name=='array-controls':
      rows=json.loads(text);assert len(rows)==3
      for i,n in enumerate([0,9,17]):assert rows[i][0]['stock']=={'value':30,'owned':list(range(1,n+1))+[0]}
     else:
      rows=json.loads(text);before=json.loads((out/'main-JS.stdout.json').read_text())[3]['entities'];before[2]['recipe']={'value':22,'owned':[22,23,24]};before[4]['enabled']={};assert rows==before
   core=stage/'src/ecs/query-contract.bend';original=core.read_text();receipt['mutants']=[]
   for label,old,new in [('wrong-cardinality','MultipleEntities{count_list(~S,handles,0)}','MultipleEntities{(count_list(~S,handles,0) + 1 : U32)}'),('wrong-mismatch','case (world,False{}): Executed{world,Fail{QueryMismatch{handle_id(~S,handle)}}}','case (world,False{}): Executed{world,Fail{MissingEntity{handle_id(~S,handle)}}}')]:
    assert old in original;core.write_text(original.replace(old,new));b=build('main');detected=[]
    for backend,cmd in b.items():
     text,_,_=run(cmd,stage,name=label+'-'+backend+'.stdout.json')
     try:validate(text)
     except AssertionError:
      got=json.loads(text);normal=json.loads((out/('main-'+backend+'.stdout.json')).read_text());assert len(got)==len(normal);mismatches=[x['label'] for x,y in zip(got,normal) if x!=y];assert mismatches==(['single-multiple'] if label=='wrong-cardinality' else ['get-mismatch']);detected.append(backend)
    assert detected==['JS','Native'];receipt['mutants'].append({'name':label,'compiled':True,'detected':detected,'sourceSHA256':sha(core)});core.write_text(original)
   # Restore non-mutant executable before optional timing.
   binaries['main']=build('main')
   if a.timing:
    receipt['timings']={}
    for backend,cmd in {'TS':['node',str(ROOT/HERE/'reference.mjs')],**binaries['main']}.items():
     samples=[]
     for i in range(5):
      text,seconds,_=run(cmd,stage,name=f'timing-{backend}-{i}.json');assert json.loads(text)==expected if backend=='TS' else validate(text);samples.append(seconds)
     receipt['timings'][backend]={'seconds':samples,'medianSeconds':statistics.median(samples)}
   assert sha(core)==hashlib.sha256(original.encode()).hexdigest()
   receipt['artifacts']={f.name:sha(f) for f in out.iterdir() if f.is_file() and f.name!='receipt.json'}
   receipt.update(status='PASS',commonCheckpoints=15,approvedForeignDivergences=1,affineArrayLengths=[0,9,17],negativeControls=3,metadataAndPendingQueueControl=True);save();print(json.dumps({k:receipt[k] for k in ['status','commonCheckpoints','mutants']}))
 except Exception as e:receipt.update(status='ERROR',error=str(e));save();raise
if __name__=='__main__':main()
