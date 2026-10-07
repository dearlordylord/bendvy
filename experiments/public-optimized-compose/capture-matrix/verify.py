#!/usr/bin/env python3
"""Finite exact old-seek/new-capture equivalence; no performance measurements."""
import argparse,hashlib,json,os,pathlib,re,shutil,subprocess,tempfile,time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner
from task_runner import run as _run_command

ROOT=pathlib.Path(__file__).resolve().parents[3];HERE=pathlib.Path(__file__).resolve().parent
parser=argparse.ArgumentParser();parser.add_argument('--output',type=pathlib.Path);args=parser.parse_args();OUT=(args.output or ROOT/'.artifacts'/('capture-matrix-'+str(time.time_ns()))).resolve();OUT.mkdir(parents=True,exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def closure(entries):
 found=set();pending=list(entries)
 while pending:
  p=pending.pop().resolve()
  if p in found:continue
  found.add(p)
  for token in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
   if token=='Base':continue
   assert token.endswith('.bend'),token
   pending.append((p.parent/token).resolve())
 return found
sources=closure([HERE/'main.bend',HERE/'smoke.bend'])|{HERE/'verify.py'}
receipt={'status':'INCOMPLETE','sourceHashes':{str(p.relative_to(ROOT)):sha(p) for p in sorted(sources)},'commands':[],'cases':{},'scope':{'targets':[0,5],'fuel':[0,8],'phases':['Inspect','ChoiceFF','ChoiceFT','ChoiceTF','ChoiceTT'],'remainingKinds':3,'historyKinds':3,'incoming':'None','restore':'None,dirty=False'}}
env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root')
def save():(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
def run(cmd,limit,name):
 p=_run_command([str(x) for x in cmd],env=env,text=True,capture_output=True,timeout=limit)
 (OUT/(name+'.stdout')).write_text(p.stdout);(OUT/(name+'.stderr')).write_text(p.stderr);receipt['commands'].append({'command':[str(x) for x in cmd],'limit':limit,'exit':p.returncode,'stdout':name+'.stdout','stderr':name+'.stderr'});save();assert p.returncode==0,(name,p.stdout,p.stderr);return p.stdout
with tempfile.TemporaryDirectory(prefix='capture-matrix-') as td:
 td=pathlib.Path(td)
 for p in sources:
  dest=td/p.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
 for tool,cmd in [('Bend',['bend','version']),('Node',['node','--version']),('Clang',['/tmp/bendvy-clang19-diagnostic/clang19','--version'])]:run(cmd,5,'version-'+tool)
 # First inspect the bounded smoke before executing the widened matrix.
 for name,expectedCount,start in [('smoke',6,270),('main',2430,0)]:
  entry=td/HERE.relative_to(ROOT)/(name+'.bend');run(['bend',entry,'--check-only'],5,name+'-checker')
  run(['bend',entry,'-o',td/(name+'.js')],30,name+'-emit-js');run(['bend',entry,'-o',td/(name+'.c')],30,name+'-emit-c');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',td/(name+'.c'),'-o',td/(name+'.native'),'-pthread','-lm'],120,name+'-build')
  transcripts={}
  for backend,cmd in [('JS',['node',td/(name+'.js')]),('Native',[td/(name+'.native')])]:
   lines=run(cmd,5,name+'-'+backend).splitlines();assert len(lines)==expectedCount,(name,backend,len(lines));transcripts[backend]=lines
   for offset,line in enumerate(lines):
    index,old,new=line.split('|');assert int(index)==start+offset,(index,offset)
    assert old==new,{'firstMismatch':int(index),'backend':backend,'old':old,'new':new}
    assert 'RECOVERY_FAILED' not in old,(index,old)
    assert 'UNEXPECTED_INDEXED_REPRESENTATION' not in old,(index,old)
   receipt['cases'][name+'-'+backend]=len(lines);save()
  assert transcripts['JS']==transcripts['Native'],'Backend mismatch'
assert all(sha(ROOT/n)==h for n,h in receipt['sourceHashes'].items()),'Reachable source drift during run'
assert {str(p.relative_to(ROOT)) for p in closure([HERE/'main.bend',HERE/'smoke.bend'])|{HERE/'verify.py'}}==set(receipt['sourceHashes']),'Reachable source inventory drift'
receipt['status']='PASS';receipt['sourceGuard']='PASS';save();print(json.dumps({'status':'PASS','cases':receipt['cases'],'output':str(OUT)}))
