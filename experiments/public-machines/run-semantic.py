#!/usr/bin/env python3
"""Prospective full application gate. Review before emit/Native execution."""
import argparse,base64,gzip,hashlib,importlib.util,json,os,pathlib,shutil,sys,subprocess,types
ROOT=pathlib.Path(__file__).resolve().parents[2];HERE=pathlib.Path(__file__).resolve().parent
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
tools=load('machine_tools',ROOT/'benchmarks/parity-features/tool-pins.py')
owned=load('machine_owned',HERE/'owned-exec.py')
model=load('machine_model',HERE/'full-model.py');mutations=load('machine_mutations',HERE/'mutations.py')
def sha(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def inventory():
 paths=[p for p in (ROOT/'src/ecs').rglob('*') if p.is_file()]
 paths += [p for p in HERE.iterdir() if p.is_file() and p.suffix in ('.bend','.mjs','.py','.md','.json')]
 paths += [ROOT/'.references/sources.json',ROOT/'benchmarks/parity-features/supervise.py',ROOT/'benchmarks/parity-features/tool-pins.py',ROOT/'experiments/s-prep/fivehour-connected-gates/supervisor.py']
 paths += [pathlib.Path(shutil.which('ldd')).resolve()]
 paths += [p for p in (HERE/'evidence/check-preflight-v6').iterdir() if p.is_file()]
 return {str(p):sha(p) for p in sorted(set(paths))}
def external():
 paths=[p for p in (ROOT/'.references/bevy-ts/packages/core/src').rglob('*') if p.is_file()]
 paths += [ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json']
 return {str(p):sha(p) for p in sorted(paths)}
def tree(path):return {str(p.relative_to(path)):sha(p) for p in sorted(path.rglob('*')) if p.is_file()}
def configurations(stages):
 paths={pathlib.Path('/home/node/.bend')/n for n in ['check.json','bender.json','bend.json']}
 for base in [ROOT,pathlib.Path.cwd(),*stages]:
  for directory in [base,*base.parents]:paths.update(directory/n for n in ['check.json','bender.json','bend.json'])
 return {str(p):{'present':os.path.lexists(p),'sha256':sha(p) if os.path.lexists(p) else None,'symlink':os.readlink(p) if p.is_symlink() else None,'scope':'daily update-notice cache, not checker configuration' if str(p)=='/home/node/.bend/check.json' else 'prospective configuration discovery boundary'} for p in sorted(paths)}

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=pathlib.Path,required=True);parser.add_argument('--cpu',type=int,default=7);parser.add_argument('--freeze-only',action='store_true');a=parser.parse_args()
 out=a.output.resolve();assert not out.exists(),'prospective output absence';out.mkdir();build=out/'build';build.mkdir()
 pins=inventory();ext=external();tool_logs={};probe_dir=out/'tool-probes';probe_dir.mkdir();ldd=pathlib.Path(shutil.which('ldd')).resolve()
 def supervised_ldd(argv,**kwargs):
  assert argv[0]=='ldd' and kwargs['timeout']==5 and kwargs['text'] is True
  assert kwargs['stdout']==subprocess.PIPE and kwargs['stderr']==subprocess.STDOUT
  label=f'ldd-{len(tool_logs)//2:05d}';stdout=probe_dir/(label+'.stdout');stderr=probe_dir/(label+'.stderr')
  assert sha(ldd)==pins[str(ldd)],'consumed ldd script changed before probe'
  q=owned.execute(['taskset','-c',str(a.cpu),str(ldd),*argv[1:]],5,kwargs['env'],stdout,stderr)
  for path in [stdout,stderr]:tool_logs[str(path.relative_to(out))]=sha(path)
  return subprocess.CompletedProcess(argv,q.returncode,(q.stdout+q.stderr).decode(),None)
 # Replace only the inherited module's subprocess dependency. The global
 # subprocess module and its other clients are untouched. Its exact snapshot
 # implementation still computes installed binaries/resources/resolved libs.
 tools.subprocess=types.SimpleNamespace(run=supervised_ldd,PIPE=subprocess.PIPE,STDOUT=subprocess.STDOUT)
 installed=tools.snapshot();installed['environment']['CPU']=a.cpu;installed['consumedLdd']={'resolvedPath':str(ldd),'sha256':pins[str(ldd)],'boundAs':'source pin, checked before every owned probe'}
 expected=model.expected()
 (out/'complete-expected.json').write_text(json.dumps(expected,indent=2)+'\n')
 labels=['normal',*[m[0] for m in mutations.MUTATIONS]];stages={label:out/'stages'/label for label in labels};stage_inventory={};stage_bytes={};stage_plan={}
 originals=[p for p in (ROOT/'src/ecs').rglob('*') if p.is_file()]+list(HERE.glob('*.bend'))
 base={}
 for original in sorted(originals):
  data=original.read_bytes();assert hashlib.sha256(data).hexdigest()==pins[str(original)]
  base[str(original.relative_to(ROOT))]=data
 for label in labels:
  contents=dict(base);mutation=None
  if label!='normal':
   entry=next(m for m in mutations.MUTATIONS if m[0]==label);key='experiments/public-machines/'+entry[1]
   contents[key]=mutations.apply(label,contents[key].decode()).encode()
   mutation={'file':key,'originalSha256':hashlib.sha256(base[key]).hexdigest(),'anchor':entry[2],'replacement':entry[3],'reachedCheckpoint':entry[4],'additionalTransformSourceSha256':pins[str(HERE/'mutations.py')]}
  changed={name for name in contents if contents[name]!=base[name]}
  assert changed==(set() if label=='normal' else {key}),(label,'exact singleton source mutation boundary')
  stage_bytes[label]=contents;stage_inventory[label]={name:hashlib.sha256(data).hexdigest() for name,data in sorted(contents.items())}
  stage_plan[label]={'prospectiveRoot':str(stages[label]),'prospectiveAbsence':not stages[label].exists(),'prospectiveInventory':stage_inventory[label],'intentionalChangedKeys':sorted(changed),'mutation':mutation}
  assert stage_plan[label]['prospectiveAbsence']
 # Commit every complete source inventory and transformation BEFORE writing
 # any staged source. Materialization then has to equal this prior plan.
 plan_path=out/'prospective-stage-plan.json';plan_path.write_text(json.dumps(stage_plan,indent=2)+'\n');plan_hash=sha(plan_path)
 for label in labels:
  stage=stages[label];assert not stage.exists();stage.mkdir(parents=True)
  for name,data in stage_bytes[label].items():
   target=stage/name;target.parent.mkdir(parents=True,exist_ok=True)
   with target.open('xb') as f:f.write(data)
   assert sha(target)==stage_inventory[label][name],(label,name,'written bytes differ from prior plan')
  assert tree(stage)==stage_inventory[label],(label,'materialization differs from prospective source plan')
 assert sha(plan_path)==plan_hash,'prospective plan changed during materialization'
 v6=json.loads((HERE/'evidence/check-preflight-v6/receipt.json').read_text())
 negatives={}
 for command in v6['commands']:
  label=command['label']
  if not label.startswith('negative-'):continue
  source=HERE/(label+'.bend');assert sha(source)==v6['sources'][str(source)]
  diagnostic=gzip.decompress((HERE/'evidence/check-preflight-v6'/(label+'.stdout.gz')).read_bytes())+(HERE/'evidence/check-preflight-v6'/(label+'.stderr')).read_bytes()
  assert b'expected :' in diagnostic and b'observed :' in diagnostic and b'Location:' in diagnostic
  negatives[label]={'sourceSha256':sha(source),'source':source.read_text(),'diagnosticBase64':base64.b64encode(diagnostic).decode()}
 assert len(negatives)==12
 command_plan=[{'label':'version','cap':5},{'label':'guide','cap':5},*[{'label':'head-'+n,'cap':5} for n in json.loads((ROOT/'.references/sources.json').read_text())['sources']],{'label':'reference','cap':5},*[{'label':'check-'+n,'cap':5} for n in ['typecheck','access','condition-controls','reader-controls']],*[{'label':n,'cap':5,'expectedExit':1} for n in negatives]]
 for label in labels:
  command_plan += [{'label':label+'-'+suffix,'cap':cap} for suffix,cap in [('emit-js',30),('emit-c',30),('clang',120),('js',5),('native',5)]]
 config=configurations([*stages.values(),*(stage/'experiments/public-machines' for stage in stages.values())])
 manifest={'sourcePins':pins,'externalPins':ext,'installedTools':installed,'configurationDiscovery':config,'prospectiveStagePlanSha256':plan_hash,'prospectiveStagePlan':stage_plan,'coreBendCount':len(list((ROOT/'src/ecs').rglob('*.bend'))),'stages':stage_inventory,'negativeSeams':negatives,'commands':command_plan,'mutationCheckpoints':{m[0]:m[4] for m in mutations.MUTATIONS},'expectedSha256':sha(out/'complete-expected.json')}
 manifest_path=out/'stage.json';manifest_path.write_text(json.dumps(manifest,indent=2)+'\n');manifest_hash=sha(manifest_path)
 r={'status':'FROZEN_NOT_EXECUTED','scope':'Finite comparator-only machine application; unresolved later-key retention policy; no proof/performance/full48 acceptance','sources':pins,'external':ext,'installedTools':installed,'configurationDiscovery':config,'stageManifestSha256':manifest_hash,'coreBendCount':manifest['coreBendCount'],'commands':[],'artifacts':{'stage.json':manifest_hash,'prospective-stage-plan.json':plan_hash,'complete-expected.json':sha(out/'complete-expected.json'),**tool_logs},'mutants':[]}
 def guard():
  assert inventory()==pins,'live source inventory drift';assert external()==ext,'reference inventory drift'
  assert configurations([*stages.values(),*(stage/'experiments/public-machines' for stage in stages.values())])==config,'configuration/cache presence or bytes drift'
  assert all(sha(out/name)==want for name,want in r['artifacts'].items()),'prior artifact drift before tool probes'
  tools.verify(installed);r['artifacts'].update(tool_logs)
  assert sha(manifest_path)==manifest_hash,'stage metadata drift'
  assert {k:tree(v) for k,v in stages.items()}==stage_inventory,'staged source inventory drift'
  assert all(sha(out/name)==want for name,want in r['artifacts'].items()),'artifact drift'
  present={str(p.relative_to(out)) for p in out.rglob('*') if p.is_file() and 'stages' not in p.relative_to(out).parts and p.name!='receipt.json'}
  assert present==set(r['artifacts']),'unmonitored output inventory addition'
 def retain(path):r['artifacts'][str(path.relative_to(out))]=sha(path)
 def child(label,args,cap,expected_exit=0,prospective=(),diagnostic=False):
  guard();assert all(not p.exists() for p in prospective),'prospective build artifact absence'
  stdout=out/(label+'.stdout.gz');stderr=out/(label+'.stderr');assert not stdout.exists() and not stderr.exists(),'prospective immutable log absence'
  command_record={'label':label,'command':list(map(str,args)),'capSeconds':cap,'expectedExit':expected_exit,'status':'STARTED'}
  r['commands'].append(command_record)
  capture_out=out/(label+'.capture.stdout');capture_err=out/(label+'.capture.stderr')
  try:result=owned.execute(['taskset','-c',str(a.cpu),*map(str,args)],cap,dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT=str(tools.CLANG_ROOT)),capture_out,capture_err)
  except Exception as error:
   command_record.update(status='SUPERVISION_FAILURE',exception=repr(error))
   for path in [capture_out,capture_err]:
    if path.exists():retain(path)
   with gzip.open(stdout,'wb') as f:f.write(capture_out.read_bytes() if capture_out.exists() else b'')
   stderr.write_bytes(capture_err.read_bytes() if capture_err.exists() else b'');retain(stdout);retain(stderr)
   raise
  with gzip.open(stdout,'wb') as f:f.write(result.stdout)
  stderr.write_bytes(result.stderr);retain(stdout);retain(stderr);retain(capture_out);retain(capture_err)
  command_record.update(status='TERMINAL',exit=result.returncode,directChildExit=result.direct_returncode,inconclusiveReason=result.inconclusive_reason)
  for path in prospective:
   if path.is_file():retain(path)
  guard()
  assert result.returncode==expected_exit,(label,result.returncode,(result.stdout+result.stderr).decode(errors='replace'))
  assert all(path.is_file() for path in prospective),(label,'missing produced artifact')
  return result.stdout+result.stderr if diagnostic else result.stdout
 try:
  guard()
  if a.freeze_only:return
  r['status']='INCOMPLETE'
  child('version',['bend','version'],5);child('guide',['bend','guide'],5)
  for name,known in json.loads((ROOT/'.references/sources.json').read_text())['sources'].items():assert child('head-'+name,['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5).decode().strip()==known['commit']
  actual=json.loads(child('reference',['node',HERE/'reference.mjs'],5));assert actual==json.loads((HERE/'expected.json').read_text())
  normal=stages['normal']/'experiments/public-machines'
  for name in ['typecheck','access','condition-controls','reader-controls']:child('check-'+name,['bend',normal/(name+'.bend'),'--check-only'],5)
  for name,seam in negatives.items():
   actual=child(name,['bend',normal/(name+'.bend'),'--check-only'],5,1,diagnostic=True)
   assert actual==base64.b64decode(seam['diagnosticBase64']),(name,'exact intended typed diagnostic changed')
  for label in labels:
   entry=stages[label]/'experiments/public-machines/full.bend';js=build/(label+'.js');c=build/(label+'.c');binary=build/label
   child(label+'-emit-js',['bend',entry,'-o',js],30,prospective=[js])
   child(label+'-emit-c',['bend',entry,'-o',c],30,prospective=[c])
   child(label+'-clang',[tools.WRAPPER,'-O3',c,'-o',binary,'-pthread','-lm'],120,prospective=[binary])
   for backend,command in [('js',['node',js]),('native',[binary,'--threads','1','--gpu','off'])]:
    raw=child(label+'-'+backend,command,5)
    if label=='normal':observed=model.validate(raw);path=out/(label+'-'+backend+'-complete.json');path.write_text(json.dumps(observed,indent=2)+'\n');retain(path)
    else:
     try:model.validate(raw)
     except AssertionError as error:
      # A structurally complete same-label output is required. Missing rows,
      # crashes, refusal sentinels or malformed output are not reached mutants.
      complete=model.structure(raw)
      checkpoint=manifest['mutationCheckpoints'][label]
      wanted_index=next(i for i,row in enumerate(expected['A']) if row['label']==checkpoint)
      normal_observed=model.validate(gzip.decompress((out/('normal-'+backend+'.stdout.gz')).read_bytes()))
      for schema in ['A','B']:assert complete[schema][wanted_index]!=normal_observed[schema][wanted_index],(label,schema,'designated operation did not change checkpoint')
      r['mutants'].append({'label':label,'backend':backend,'reachedCheckpoint':checkpoint,'deviation':repr(error),'policyApproved':False})
     else:raise AssertionError((label,backend,'mutation escaped full observer'))
   guard()
  r['status']='FULL24_TWO_SCHEMA_JS_NATIVE_AND_EIGHT_REACHED_MUTATIONS_PASS'
 finally:
  (out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
  print(r['status'])

if __name__=='__main__':main()
