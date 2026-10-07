#!/usr/bin/env python3
"""Freeze source; replay full pinned observations, capabilities and reached mutants."""
import argparse, gzip, hashlib, json, os, platform, shutil, subprocess, time
from pathlib import Path

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command

ROOT=Path(__file__).resolve().parents[2]
HERE=Path('experiments/public-event-readers')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=False)
 evidence=a.output/'evidence';evidence.mkdir()
 receipt={'format':1,'environment':{'machine':platform.machine(),'platform':platform.platform(),'allowedCPUs':sorted(os.sched_getaffinity(0))},'timingScope':'Whole-process full trace work including startup and serialization, 3 complete observations per backend; uncontrolled concurrent load, not qualification','limits':{'checker':5,'emit':30,'clang':120,'runtime':5},'commands':[],'results':{},'source':{}}
 def save(): (evidence/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
 def run(cmd,limit,cwd=ROOT,allow=False):
  started=time.perf_counter();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
  q=_run_command([str(x) for x in cmd],cwd=cwd,env=env,capture_output=True,text=True,timeout=limit)
  receipt['commands'].append({'argv':[str(x) for x in cmd],'limit':limit,'exit':q.returncode,'elapsedSeconds':time.perf_counter()-started,'stdoutSha256':hashlib.sha256(q.stdout.encode()).hexdigest(),'stderr':q.stderr[:2000]})
  save()
  if not allow and q.returncode: raise AssertionError(q.stderr+q.stdout)
  return q
 def retain(name,text):
  with gzip.open(evidence/(name+'.json.gz'),'wb') as f:f.write(text.encode())
  return json.loads(text)
 refs=json.loads((ROOT/'.references/sources.json').read_text())['sources']
 receipt['references']={}
 for name,entry in refs.items():
  observed=run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).stdout.strip();assert observed==entry['commit'];receipt['references'][name]=observed
 receipt['versions']={name:run(cmd,5).stdout.strip() for name,cmd in [('Bend',['bend','version']),('Node',['node','--version']),('Clang',['/tmp/bendvy-clang19-diagnostic/clang19','--version'])]}
 stage=a.output/'stage';(stage/'src').mkdir(parents=True);shutil.copytree(ROOT/'src/ecs',stage/'src/ecs');shutil.copytree(ROOT/HERE,stage/HERE,ignore=shutil.ignore_patterns('evidence','__pycache__'))
 receipt['source']={str(x.relative_to(stage)):sha(x) for d in ['src/ecs',str(HERE)] for x in sorted((stage/d).rglob('*')) if x.is_file()};save()
 reference=retain('ts',run(['node',stage/HERE/'reference.mjs'],5,cwd=stage).stdout)
 assert len(reference['checkpoints'])==18
 late_reference=retain('ts-late',run(['node',stage/HERE/'reference-late.mjs'],5,cwd=stage).stdout)
 assert len(late_reference['checkpoints'])==7
 for trial in [1,2]:
  assert retain('ts-'+str(trial),run(['node',stage/HERE/'reference.mjs'],5,cwd=stage).stdout)==reference
  assert retain('ts-late-'+str(trial),run(['node',stage/HERE/'reference-late.mjs'],5,cwd=stage).stdout)==late_reference
 expected_extension={'disposal':{'format':1,'checkpoints':[{'label':'after-disposal-and-frames','retained':[10,11],'readerCount':1},{'label':'remaining-read','read':{'reader':'slow','values':[10,11],'lagged':False}},{'label':'cleanup','retained':[],'readerCount':1}]},'registration-swap':{'format':1,'checkpoints':[{'rejected':True,'args':'swap','fail':False}]}}
 def build_run(tree,subject,label,expected,mutation=False):
  entry=tree/HERE/(subject+'.bend');run(['bend',entry,'--check-only'],5,tree)
  run(['bend',entry,'-o',tree/(label+'.js')],30,tree);run(['bend',entry,'-o',tree/(label+'.c')],30,tree)
  run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',tree/(label+'.c'),'-o',tree/(label+'.native'),'-pthread','-lm'],120,tree)
  result={}
  for backend,cmd in [('js',['node',tree/(label+'.js'),'65535']),('native',[tree/(label+'.native'),'65535'])]:
   texts=[]
   for trial in range(1 if mutation else 3):
    q=run(cmd,5,tree);actual=retain(label+'-'+backend+'-'+str(trial),q.stdout);texts.append(q.stdout)
    if mutation: assert actual!=expected, 'Compiling reached mutant survived'
    else: assert actual==expected, 'Complete output differs'
   result[backend]={'validatedOutputs':len(texts),'detectedMutation':mutation,'generatedSha256':sha(tree/(label+('.js' if backend=='js' else '.native')))}
  receipt['results'][label]=result;save()
 for subject in ['main','late-registration','disposal','registration-swap']:build_run(stage,subject,subject,reference if subject=='main' else late_reference if subject=='late-registration' else expected_extension[subject])
 diagnostics={
  'read-write':['expected : Ev.WriteAccess','observed : Ev.ReadAccess'],
  'undeclared':['ReadAccess','observed : Unit'],
  'duplicate-reader':['consumed more than once'],
  'cross-schema':['expected : E.Reader<B>','observed : E.Reader<A>']}
 # Import aliases in fixtures are E, not Ev.
 diagnostics['read-write']=['expected : E.WriteAccess','observed : E.ReadAccess']
 for name,words in diagnostics.items():
  q=run(['bend',stage/HERE/'controls'/(name+'.bend'),'--check-only'],5,stage,True);assert q.returncode==1 and all(w in q.stdout+q.stderr for w in words);(evidence/(name+'.log')).write_text(q.stdout+q.stderr)
 receipt['negativeControls']=list(diagnostics)
 run(['python3',ROOT/'experiments/query-composition/run-controls.py','--source-root',stage,'--output',a.output/'public-controls'],30)
 old=json.loads((a.output/'public-controls/receipt.json').read_text());assert all(x['passed'] for x in old['results']);receipt['priorPublicControls']=old
 for label,filename,old,new in [
  ('mutant-publication','world.bend','event_append(~E,events,published)','events'),
  ('mutant-cursor','event-runtime.bend','case Sy.Failed{world,error}: Ran{Runtime{world,namespace,batches,activate(positions,readerId,Nat.sub(tick,1n)),nextReader,tick,frameStart,boundary,capacity,dropped}','case Sy.Failed{world,error}: Ran{Runtime{world,namespace,batches,update(positions,readerId,tick,False{}),nextReader,tick,frameStart,boundary,capacity,dropped}'),
  ('mutant-retention','event-runtime.bend','hold_boundary(positions,boundary)','boundary')]:
  mutant=a.output/label;shutil.copytree(stage,mutant,ignore=shutil.ignore_patterns('*.js','*.c','*.native'));target=mutant/'src/ecs'/filename;content=target.read_text();assert content.count(old)==1;target.write_text(content.replace(old,new));receipt.setdefault('mutants',{})[label]={'file':str(target.relative_to(mutant)),'original':old,'replacement':new,'sha256':sha(target)};build_run(mutant,'main',label,reference,True)
 receipt['status']='PASS';receipt['scope']='25 complete TS-equal event checkpoints; disposal and registration swap are separate Bend extensions; finite tests, not proofs or qualified hot-path performance';save();print(json.dumps({'status':'PASS','checkpoints':25,'extensions':2,'negativeControls':4,'compilingMutants':3}))
if __name__=='__main__':main()
