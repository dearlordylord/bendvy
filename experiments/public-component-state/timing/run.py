#!/usr/bin/env python3
"""Standalone guarded #47 application preflight/semantics/paired observations."""
import argparse,hashlib,json,os,pathlib,random,statistics,time,runpy
import stage

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

HERE=pathlib.Path(__file__).resolve().parent;ROOT=stage.ROOT

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def fnv(data):
 value=2166136261
 for b in data:value=((value^b)*16777619)&4294967295
 return value

def telemetry(cpu):
 result={'loadavg':pathlib.Path('/proc/loadavg').read_text().strip(),'cpuStat':next(s for s in pathlib.Path('/proc/stat').read_text().splitlines() if s.startswith(f'cpu{cpu} '))}
 for name,path in [('pressure','/proc/pressure/cpu'),('frequency',f'/sys/devices/system/cpu/cpu{cpu}/cpufreq/scaling_cur_freq')]:
  p=pathlib.Path(path)
  if p.exists():result[name]=p.read_text().strip()
 return result

class Harness:
 def __init__(self,args):
  self.args=args;self.staged=json.loads((args.stage/'stage.json').read_text());self.tree=args.stage/'stage';assert not args.output.exists(),'output must be fresh';args.output.mkdir(parents=True)
  self.tools=runpy.run_path(str(HERE/'tool-pins.py'));pins=self.tools['snapshot']();pins['environment']['CPU']=args.cpu
  fixed=[pathlib.Path('/home/node/.bend/check.json'),ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json',ROOT/'benchmarks/contract.json']
  self.receipt={'status':'INCOMPLETE','stageReceiptSHA256':digest(args.stage/'stage.json'),'installedTools':pins,'fixedInputs':{str(p):digest(p) for p in fixed},'absentInputs':[str(p) for p in [ROOT/'check.json',ROOT/'bend.json',self.tree/'check.json',self.tree/'bend.json'] if not p.exists()],'commands':[],'artifactHashes':{},'logHashes':{},'referenceHeads':{},'cpu':args.cpu,'sourceScope':'Actual full62-row public component-state lifecycle; no baseline/criterion amendment','timingMode':args.timing,'telemetry':{'initial':telemetry(args.cpu)}}
  self.guard();self.save()
 def save(self):(self.args.output/'receipt.json').write_text(json.dumps(self.receipt,indent=2)+'\n')
 def guard(self):
  assert digest(self.args.stage/'stage.json')==self.receipt['stageReceiptSHA256']
  assert stage.sources()==self.staged['sourceHashes'],'live source drift'
  assert stage.inventory(self.tree)==self.staged['stageInventory'],'stage exact inventory drift'
  assert (self.tree/'.references').is_symlink() and (self.tree/'.references').resolve()==ROOT/'.references','reference link drift'
  assert stage.inventory(ROOT/'.references/bevy-ts/packages/core/src')==self.staged['referenceSourceHashes'],'reference inventory drift'
  assert digest(ROOT/'.references/sources.json')==self.staged['manifestHash']
  self.tools['verify'](self.receipt['installedTools'])
  for n,h in self.receipt['referenceHeads'].items():
   checked=task_runner.execute_completed(['git','-C',str(ROOT/'.references'/n),'rev-parse','HEAD'],5,dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'));assert checked.returncode==0 and checked.stdout.decode().strip()==h,'reference HEAD drift'
  for n,h in self.receipt['fixedInputs'].items():assert digest(pathlib.Path(n))==h,'config/package drift'
  assert all(not pathlib.Path(n).exists() for n in self.receipt['absentInputs']),'prospective config appeared'
  for group in ['artifactHashes','logHashes']:
   for n,h in self.receipt[group].items():assert digest(self.args.output/n)==h,group+' drift'
 def run(self,label,command,cap,good=True):
  self.guard();command=['taskset','-c',str(self.args.cpu),*map(str,command)]
  for suffix in ['.stdout','.stderr']:assert not (self.args.output/(label+suffix)).exists(),'prospective log exists'
  if '-o' in command:assert not pathlib.Path(command[command.index('-o')+1]).exists(),'prospective generated output exists'
  before=time.perf_counter_ns()
  try:result=task_runner.execute_completed(command,cap,dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'))
  except Exception as error:
   self.receipt['commands'].append({'label':label,'command':command,'capSeconds':cap,'error':repr(error),'wholeProcessNs':time.perf_counter_ns()-before});self.save();self.guard();raise
  processNs=time.perf_counter_ns()-before
  for suffix,data in [('.stdout',result.stdout),('.stderr',result.stderr)]:
   p=self.args.output/(label+suffix);p.write_bytes(data);self.receipt['logHashes'][p.name]=digest(p)
  self.receipt['commands'].append({'label':label,'command':command,'capSeconds':cap,'exit':result.returncode,'wholeProcessNs':processNs});self.save();self.guard();assert (result.returncode==0)==good,(label,result.stderr)
  return result
 def pin(self,p):self.receipt['artifactHashes'][str(p.relative_to(self.args.output))]=digest(p);self.save()
 def refs(self):
  manifest=json.loads((ROOT/'.references/sources.json').read_text())['sources']
  for n,pin in manifest.items():
   actual=self.run('head-'+n,['git','-C',ROOT/'.references'/n,'rev-parse','HEAD'],5).stdout.decode().strip();assert actual==pin['commit'];self.receipt['referenceHeads'][n]=actual
   assert not self.run('clean-'+n,['git','-C',ROOT/'.references'/n,'status','--porcelain','--untracked-files=no'],5).stdout.strip()
  for n,cmd in [('Bend',['bend','version']),('Node',['node','--version']),('Clang',['/tmp/bendvy-clang19-diagnostic/clang19','--version'])]:self.receipt[n+'Version']=self.run('version-'+n,cmd,5).stdout.decode().strip()
  self.save()
 def commands(self,n):
  base=self.tree/'experiments/public-component-state/timing';return {'TS':['node',base/f'state-{n}.mjs'],'JS':['node',self.args.output/f'state-{n}.js'],'Native':[self.args.output/f'state-{n}.native','--threads','1','--gpu','off']}
 def build(self,n):
  base=self.tree/'experiments/public-component-state/timing';entry=base/f'state-{n}.bend'
  result=self.run(f'state-{n}-foreign-checker',['bend',entry,'--check-only'],5,False)
  diagnostics=result.stderr.decode()+result.stdout.decode();assert 'defs rely on unsafe or foreign code' in diagnostics and ('capture' in diagnostics or 'begin' in diagnostics),'checker failed outside intended foreign timer seam'
  for suffix in ['js','c']:
   p=self.args.output/f'state-{n}.{suffix}';self.run(f'state-{n}-emit-{suffix}',['bend',entry,'-o',p],30);self.pin(p)
  native=self.args.output/f'state-{n}.native';self.run(f'state-{n}-build',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',self.args.output/f'state-{n}.c','-o',native,'-pthread','-lm'],120);self.pin(native)
 def sample(self,n,backend,label):
  result=self.run(label,self.commands(n)[backend],5);expected=(self.tree/'experiments/public-component-state/application-expected.txt').read_bytes()*n
  assert result.stdout==expected,(label,'complete62-row lifecycle mismatch')
  region=json.loads(result.stderr);assert region['bytes']==len(expected) and region['digest']==fnv(expected) and int(region['elapsedNs'])>=0,'timer metadata mismatch'
  return region

def main():
 p=argparse.ArgumentParser();p.add_argument('--stage',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,required=True);p.add_argument('--preflight',action='store_true');p.add_argument('--timing',action='store_true');p.add_argument('--semantic-receipt',type=pathlib.Path);p.add_argument('--quiet-window');a=p.parse_args();a.stage=a.stage.resolve();a.output=a.output.resolve();assert a.cpu in os.sched_getaffinity(0);assert not(a.preflight and a.timing)
 h=Harness(a)
 try:
  h.refs();expected=(h.tree/'experiments/public-component-state/application-expected.txt').read_bytes();assert len(expected.splitlines())==62;actual=h.run('actual-original-TS',['node',h.tree/'experiments/public-component-state/application-reference.mjs'],5).stdout;assert actual==expected
  checked=h.run('pure-driver-checker',['bend',h.tree/'experiments/public-component-state/driver.bend','--check-only'],5)
  assert b'ALL PROOFS CHECK' in checked.stdout+checked.stderr
  # Callable TS fresh repetition is exercised before any Native build/timing admission.
  for n in [1,2,4]:h.sample(n,'TS',f'state-{n}-TS-preflight')
  if a.preflight:h.receipt['status']='PASS_PREFLIGHT_TS_ONLY_NO_NATIVE_NO_TIMING';h.guard();h.save();print(a.output);return
  if a.timing:
   assert a.semantic_receipt and a.quiet_window,'reviewed semantic receipt and integrator quiet-window context required'
   semantic=json.loads(a.semantic_receipt.read_text());assert semantic['status']=='PASS_COMPLETE_APPLICATION_EQUIVALENCE' and semantic['stageReceiptSHA256']==h.receipt['stageReceiptSHA256']
   assert semantic['installedTools']['pins']==h.receipt['installedTools']['pins'],'semantic consumed tool/library bytes differ'
   assert {k:v for k,v in semantic['installedTools']['environment'].items() if k!='CPU'}=={k:v for k,v in h.receipt['installedTools']['environment'].items() if k!='CPU'},'semantic tool environment differs'
   assert all(h.receipt['fixedInputs'].get(n)==v for n,v in semantic['fixedInputs'].items()),'semantic configs differ'
   h.receipt['fixedInputs'][str(a.semantic_receipt.resolve())]=digest(a.semantic_receipt)
   h.receipt['quietWindowContext']=a.quiet_window
  for n in [1,2,4]:
   h.build(n)
   for backend in ['JS','Native']:h.sample(n,backend,f'state-{n}-{backend}-semantic')
  if not a.timing:h.receipt['status']='PASS_COMPLETE_APPLICATION_EQUIVALENCE';h.guard();h.save();print(a.output);return
  contract=json.loads((ROOT/'benchmarks/contract.json').read_text());assert contract['pairs']==20 and contract['pairs']%2==0
  generator=random.Random(contract['seed']);h.receipt.update(protocol={'pairs':contract['pairs'],'warmups':contract['warmups'],'seed':contract['seed'],'scales':[1,2,4],'scope':'Observations only; no per-feature alpha/tolerance/baseline/acceptance verdict'},observations=[],summary=[]);h.save()
  for n in [1,2,4]:
   for backend in ['TS','JS','Native']:
    for warm in range(contract['warmups']):h.sample(n,backend,f'state-{n}-{backend}-warmup{warm}')
   for backend in ['JS','Native']:
    orders=[['TS',backend]]*10+[[backend,'TS']]*10;generator.shuffle(orders);ratios=[]
    for i,order in enumerate(orders):
     before=telemetry(a.cpu);values={role:h.sample(n,role,f'state-{n}-{backend}-pair{i}-{role}') for role in order};assert int(values['TS']['elapsedNs'])>0
     ratio=int(values[backend]['elapsedNs'])/int(values['TS']['elapsedNs']);ratios.append(ratio);h.receipt['observations'].append({'lifecycles':n,'backend':backend,'pair':i,'order':order,'before':before,'after':telemetry(a.cpu),'regions':values,'ratio':ratio});h.save()
    h.receipt['summary'].append({'lifecycles':n,'backend':backend,'medianPairedRatio':statistics.median(ratios),'allPairedRatios':ratios,'minimum':min(ratios),'maximum':max(ratios)})
  h.receipt['status']='COMPLETE_APPLICATION_TIMING_OBSERVATIONS_NO_VERDICT';h.guard();h.save();print(a.output)
 except Exception as error:
  h.receipt.update(status='INCONCLUSIVE' if isinstance(error,TimeoutError) else 'FAIL',error=repr(error));h.save();raise
if __name__=='__main__':main()
