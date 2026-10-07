#!/usr/bin/env python3
"""Experimental typed-state semantics gate; stdlib only, no timings."""
import argparse,hashlib,json,os,pathlib,re,shutil,subprocess,tempfile,time,runpy,gzip
import supervisor
ROOT=pathlib.Path(__file__).resolve().parents[2];HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path);p.add_argument('--preflight',action='store_true');p.add_argument('--wrong-target-only',action='store_true');p.add_argument('--cpu',default='10');args=p.parse_args()
OUT=(args.output or ROOT/'.artifacts'/('component-state-'+str(time.time_ns()))).resolve();OUT.mkdir(parents=True,exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inv(p):return {str(q.relative_to(p)):sha(q) for q in sorted(p.rglob('*')) if q.is_file()}
closure=set()
def visit(path):
 path=path.resolve()
 if path in closure:return
 assert path.is_relative_to(ROOT) and path.is_file(),path
 closure.add(path)
 for imp in re.findall(r'^import\s+(\S+)',path.read_text(),re.M):
  if imp!='Base':visit(path.parent/imp)
for f in HERE.glob('*.bend'):visit(f)
closure.update(f for f in HERE.iterdir() if f.is_file() and f.suffix in {'.py','.mjs','.md','.txt','.jsonl'})
source={str(q.relative_to(ROOT)):sha(q) for q in sorted(closure)}
STAGE=OUT/'stage';STAGE.mkdir()
for name in source:
 q=STAGE/name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,q)
(STAGE/'.references').symlink_to(ROOT/'.references',target_is_directory=True)
receipt={'status':'INCOMPLETE','commands':[],'sourceHashes':source,'stageHashes':dict(source),'artifactHashes':{},'timingsCollected':False,'negativeControls':{},'referenceHeads':{}}
manifest=ROOT/'.references/sources.json';receipt['manifestHash']=sha(manifest);pins=json.loads(manifest.read_text())['sources']
tool=runpy.run_path(str(HERE/'tool-pins.py'));receipt['toolSnapshot']=tool['snapshot']();receipt['toolSnapshot']['environment']['CPU']=int(args.cpu);receipt['cpu']=int(args.cpu)
fixed=[pathlib.Path('/home/node/.bend/check.json'),ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json']
receipt['fixedInputs']={str(q):sha(q) for q in fixed}
receipt['absentInputs']=[str(q) for q in [ROOT/'check.json',ROOT/'bend.json',STAGE/'check.json',STAGE/'bend.json'] if not q.exists()]
receipt['logHashes']={}
MUTANT=None;mutantExpected=None;mutantInventories={}
refs=ROOT/'.references/bevy-ts/packages/core/src';receipt['referenceSourceHashes']=inv(refs)
historical=None
if args.wrong_target_only:
 hp=HERE/'evidence-public/receipt.json.gz';data=gzip.decompress(hp.read_bytes())
 assert hashlib.sha256(data).hexdigest()=='bfe78d6aa39deee3e98eac09ca2f93f53cd66906762a2b51bfab367cb9ad6060'
 historical=json.loads(data);assert historical['status']=='PASS_FINITE_SLICE'
 suffixes={'.bend','.mjs','.txt','.jsonl','.py'}
 def subject_inventory(items):return {n:h for n,h in items.items() if pathlib.Path(n).suffix in suffixes and n!='experiments/public-component-state/run.py'}
 tested=subject_inventory(historical['sourceHashes']);assert subject_inventory(source)==tested,'historical executable/fixture/helper inventory differs'
 assert receipt['manifestHash']==historical['manifestHash']
 assert receipt['referenceSourceHashes']==historical['referenceSourceHashes']
 assert receipt['toolSnapshot']['pins']==historical['toolSnapshot']['pins'],'historical tool/library bytes differ'
 assert receipt['toolSnapshot']['environment']==historical['toolSnapshot']['environment'],'historical tool environment differs'
 assert receipt['toolSnapshot']['scope']==historical['toolSnapshot']['scope']
 def resolved_paths(snapshot):return {n:re.sub(r'0x[0-9a-fA-F]+','<ASLR-address>',text) for n,text in snapshot['resolvedLibraries'].items()}
 assert resolved_paths(receipt['toolSnapshot'])==resolved_paths(historical['toolSnapshot']),'historical resolved library paths differ'
 receipt['historicalToolComparison']='Exact all binary/library/resource pins and environment; resolved ldd records compare with only ASLR addresses normalized'
 assert all(receipt['fixedInputs'][n]==h for n,h in historical['fixedInputs'].items())
 assert all(not pathlib.Path(n).exists() for n in historical['absentInputs'])
 receipt['absentInputs']+=historical['absentInputs']
 receipt['fixedInputs'][str(hp)]=sha(hp)
 for n,h in historical['logHashes'].items():
  q=HERE/'evidence-public'/n;assert sha(q)==h,'historical log differs';receipt['fixedInputs'][str(q)]=h
 receipt['aggregateNormal']={'scope':'Historical normal81 and four reached controls plus fresh wrong-target-only control; not a fresh full cohort','receiptPath':str(hp),'receiptSHA256':hashlib.sha256(data).hexdigest(),'testedSubjectHashes':tested,'historicalHarnessHash':historical['sourceHashes']['experiments/public-component-state/run.py'],'currentHarnessHash':source['experiments/public-component-state/run.py'],'normalCommands':81,'nativeWrongTargetFromFailed86CommandsCredited':False}
def save():(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
def guards():
 tool['verify'](receipt['toolSnapshot'])
 assert all(sha(pathlib.Path(n))==h for n,h in receipt['fixedInputs'].items()),'config/package drift'
 assert all(not pathlib.Path(n).exists() for n in receipt['absentInputs']),'prospective config appeared'
 assert all(sha(OUT/n)==h for n,h in receipt['logHashes'].items()),'log drift'
 if MUTANT is not None:assert inv(MUTANT)==mutantExpected,'mutant exact inventory drift'
 for directory,expected in mutantInventories.items():assert inv(pathlib.Path(directory))==expected,'earlier mutant stage drift'
 assert all(sha(ROOT/n)==h for n,h in source.items()),'original drift'
 assert inv(STAGE)==source,'staged exact inventory drift'
 assert sha(manifest)==receipt['manifestHash'],'manifest drift'
 assert inv(refs)==receipt['referenceSourceHashes'],'reference source drift'
 for n,h in receipt['artifactHashes'].items():assert sha(OUT/n)==h,'generated artifact drift: '+n
 for n,h in receipt['referenceHeads'].items():
  head=subprocess.run(['git','-C',ROOT/'.references'/n,'rev-parse','HEAD'],capture_output=True,text=True,timeout=5);assert head.returncode==0 and head.stdout.strip()==h

def run(cmd,limit,name,exit=0):
 guards();cmd=['taskset','-c',args.cpu]+[str(x) for x in cmd]
 prospective=pathlib.Path(cmd[cmd.index('-o')+1]) if '-o' in cmd else None
 if prospective is not None:assert not prospective.exists(),'prospective artifact already exists'
 assert not (OUT/(name+'.stdout')).exists(),'prospective log already exists'
 try:
  previous=pathlib.Path.cwd();os.chdir(STAGE)
  try:code,stdout=supervisor.execute(cmd,limit,env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'))
  finally:os.chdir(previous)
 except Exception as error:
  guards();receipt['status']='INCONCLUSIVE_EXECUTION_FAILURE';receipt['commands'].append({'command':cmd,'limit':limit,'error':repr(error)});save();raise
 (OUT/(name+'.stdout')).write_text(stdout)
 receipt['logHashes'][name+'.stdout']=sha(OUT/(name+'.stdout'))
 receipt['commands'].append({'command':cmd,'limit':limit,'exit':code,'stdout':name+'.stdout','stdoutSHA256':receipt['logHashes'][name+'.stdout']});save();guards()
 assert code==exit,(name,stdout)
 return stdout
def execute():
 global MUTANT,mutantExpected
 for name,pin in pins.items():
  path=ROOT/'.references'/name;head=run(['git','-C',path,'rev-parse','HEAD'],5,'head-'+name).strip();assert head==pin['commit'];receipt['referenceHeads'][name]=head
  assert not run(['git','-C',path,'status','--porcelain','--untracked-files=no'],5,'clean-'+name).strip()
 for name,cmd in [('Bend',['bend','version']),('Node',['node','--version']),('Clang',['/tmp/bendvy-clang19-diagnostic/clang19','--version'])]:receipt[name+'Version']=run(cmd,5,'version-'+name).strip()
 frozen=STAGE/'experiments/public-component-state';main=frozen/'main.bend'
 reference=run(['node',frozen/'application-reference.mjs'],5,'application-reference');assert reference==(frozen/'application-expected.txt').read_text()
 observation=run(['node',frozen/'reference.mjs'],5,'descriptor-reference');assert observation==(frozen/'descriptor-expected.jsonl').read_text()
 run(['bend',main,'--check-only'],5,'checker')
 run(['bend',frozen/'constructors.bend','--check-only'],5,'constructors-checker')
 constructorsTS=run(['node',frozen/'constructors-reference.mjs'],5,'constructors-reference');assert constructorsTS==(frozen/'constructors-expected.txt').read_text()
 run(['bend',frozen/'foreign.bend','--check-only'],5,'foreign-checker')
 run(['bend',frozen/'access-controls.bend','--check-only'],5,'access-checker')
 accessExpected=(frozen/'access-expected.txt').read_text()
 run(['bend',frozen/'raw-boundary.bend','--check-only'],5,'raw-boundary-checker')
 rawExpected=(frozen/'raw-boundary-expected.txt').read_text()
 run(['bend',frozen/'clock-controls.bend','--check-only'],5,'clock-checker')
 clockExpected=(frozen/'clock-expected.txt').read_text()
 foreignTS=run(['node',frozen/'foreign-reference.mjs'],5,'foreign-reference');assert foreignTS==(frozen/'foreign-ts-expected.jsonl').read_text()
 receipt['coverage']={'descriptorRows':54,'applicationRows':62,'constructorRows':3,'foreignRows':6,'accessRows':5,'rawBoundaryRows':5,'clockRows':7,'schemas':2,'negativeControls':8,'stateChangedFamilies':['Phase','Mode']}
 receipt['foreignPolicy']='Existing approved Bend MissingEntity divergence; actual TS accepts colliding foreign numeric IDs'
 save()
 needles={
  'request-read':['- expected : Cap.Request<bad~H, V.Phase, A.WriteStatus<W.WorldError>>','- observed : Cap.Read<bad~H, V.Phase>','Location: bad'],
  'raw-kind':['- expected : String','- observed : U32','Location: bad'],
  'illegal-state':['- expected : V.Phase','- observed : U32','Location: bad'],
  'illegal-edge':['- expected : V.Move','- observed : V.Phase','Location: bad'],
  'undeclared-family':['- expected : Cap.Write<bad~H, S.Neighbor, S.NeighborView>','- observed : Cap.Write<bad~H, V.Phase, V.Phase>','Location: bad'],
  'duplicate-owner':['- expected : owner','- observed : owner (consumed more than once)','Location: duplicate'],
  'write-read':['- expected : Cap.Write<Compose.Frame<S.SchemaA, S.Store<S.SchemaA>, Unit, Unit>, V.Phase, V.Phase>','- observed : Cap.Read<Compose.Frame<S.SchemaA, S.Store<S.SchemaA>, Unit, Unit>, V.Phase>','Location: main'],
  'cross-schema':['- expected : W.World<S.SchemaB, S.Store<S.SchemaB>, Unit, Unit>','- observed : W.World<S.SchemaA, S.Store<S.SchemaA>, Unit, Unit>','Location: main']}
 for name,checks in needles.items():
  text=run(['bend',frozen/('negative-'+name+'.bend'),'--check-only'],5,'negative-'+name,1)
  assert 'SOME PROOFS FAIL' in text and '- message  :' not in text and all(x in text for x in checks),(name,text)
  receipt['negativeControls'][name]={'status':'INTENDED_REJECTION','needles':checks};save()
 if historical is not None:
  assert receipt['referenceHeads']==historical['referenceHeads']
  for name in ['Bend','Node','Clang']:assert receipt[name+'Version']==historical[name+'Version']
  normals={'JS':reference,'Native':reference,'foreign-JS':(frozen/'foreign-expected.txt').read_text(),'foreign-Native':(frozen/'foreign-expected.txt').read_text(),'access-JS':accessExpected,'access-Native':accessExpected,'raw-boundary-JS':rawExpected,'raw-boundary-Native':rawExpected,'clock-JS':clockExpected,'clock-Native':clockExpected,'constructors-JS':constructorsTS,'constructors-Native':constructorsTS}
  for name,expected in normals.items():assert (HERE/'evidence-public'/(name+'.stdout')).read_text()==expected,'historical normal observation differs: '+name
  receipt['aggregateNormal']['completeNormalOutputComparison']='MATCH';save()
 if args.preflight:
  receipt['status']='PASS_PREFLIGHT_ONLY';save();print(OUT);raise SystemExit(0)
 def artifact(path):receipt['artifactHashes'][str(path.relative_to(OUT))]=sha(path);save()
 clang='/tmp/bendvy-clang19-diagnostic/clang19'
 if not args.wrong_target_only:
  for suffix in ['js','c']:
   target=OUT/('main.'+suffix);run(['bend',main,'-o',target],30,'emit-'+suffix);artifact(target)
  native=OUT/'main.native';run([clang,'-O3',OUT/'main.c','-o',native,'-pthread','-lm'],120,'build-native');artifact(native)
  for backend,cmd in [('JS',['node',OUT/'main.js']),('Native',[native,'--threads','1','--gpu','off'])]:
   actual=run(cmd,5,backend);assert actual==reference,(backend,actual,reference)
  for suffix in ['js','c']:
   target=OUT/('foreign.'+suffix);run(['bend',frozen/'foreign.bend','-o',target],30,'foreign-emit-'+suffix);artifact(target)
  fn=OUT/'foreign.native';run([clang,'-O3',OUT/'foreign.c','-o',fn,'-pthread','-lm'],120,'foreign-build-native');artifact(fn)
  for backend,cmd in [('JS',['node',OUT/'foreign.js']),('Native',[fn,'--threads','1','--gpu','off'])]:
   actual=run(cmd,5,'foreign-'+backend);assert actual==(frozen/'foreign-expected.txt').read_text(),(backend,actual)
  for suffix in ['js','c']:
   target=OUT/('access.'+suffix);run(['bend',frozen/'access-controls.bend','-o',target],30,'access-emit-'+suffix);artifact(target)
  an=OUT/'access.native';run([clang,'-O3',OUT/'access.c','-o',an,'-pthread','-lm'],120,'access-build-native');artifact(an)
  for backend,cmd in [('JS',['node',OUT/'access.js']),('Native',[an,'--threads','1','--gpu','off'])]:
   actual=run(cmd,5,'access-'+backend);assert actual==accessExpected,(backend,actual)
  for suffix in ['js','c']:
   target=OUT/('raw-boundary.'+suffix);run(['bend',frozen/'raw-boundary.bend','-o',target],30,'raw-boundary-emit-'+suffix);artifact(target)
  rn=OUT/'raw-boundary.native';run([clang,'-O3',OUT/'raw-boundary.c','-o',rn,'-pthread','-lm'],120,'raw-boundary-build-native');artifact(rn)
  for backend,cmd in [('JS',['node',OUT/'raw-boundary.js']),('Native',[rn,'--threads','1','--gpu','off'])]:
   actual=run(cmd,5,'raw-boundary-'+backend);assert actual==rawExpected,(backend,actual)
  for suffix in ['js','c']:
   target=OUT/('clock.'+suffix);run(['bend',frozen/'clock-controls.bend','-o',target],30,'clock-emit-'+suffix);artifact(target)
  cn=OUT/'clock.native';run([clang,'-O3',OUT/'clock.c','-o',cn,'-pthread','-lm'],120,'clock-build-native');artifact(cn)
  for backend,cmd in [('JS',['node',OUT/'clock.js']),('Native',[cn,'--threads','1','--gpu','off'])]:
   actual=run(cmd,5,'clock-'+backend);assert actual==clockExpected,(backend,actual)
  for suffix in ['js','c']:
   target=OUT/('constructors.'+suffix);run(['bend',frozen/'constructors.bend','-o',target],30,'constructors-emit-'+suffix);artifact(target)
  cn=OUT/'constructors.native';run([clang,'-O3',OUT/'constructors.c','-o',cn,'-pthread','-lm'],120,'constructors-build-native');artifact(cn)
  for backend,cmd in [('JS',['node',OUT/'constructors.js']),('Native',[cn,'--threads','1','--gpu','off'])]:
   actual=run(cmd,5,'constructors-'+backend);assert actual==constructorsTS,(backend,actual,constructorsTS)
 variants=[
  ('error-omission','error-decoders.bend','D.Invalid{"$","\\"ready\\" | \\"windup\\" | \\"active\\"",D.Text{raw}}','D.Invalid{"$","",D.Text{raw}}','main.bend','raw-phase-invalid|raw:false|raw=sleeping|path=$|expected=|actual=sleeping'),
  ('access-coalescing','src/ecs/state.bend','case (owner,C.MissingEntity{}): (owner,StateAccessRejected{C.MissingEntity{}})','case (owner,C.MissingEntity{}): (owner,StateAccessRejected{C.ComponentAbsent{}})','access-controls.bend','foreign|ComponentAbsent'),
  ('write-status-omission','src/ecs/state.bend','case (owner,WriteRejected{error}): (owner,TypedRawWriteRejected{raw,error})','case (owner,WriteRejected{error}): (owner,TypedRawWritten{})','raw-boundary.bend','foreign|Written|transaction=MissingEntity'),
  ('move-status-omission','src/ecs/state.bend','case (owner,WriteRejected{error}): (owner,StateWriteRejected{error})','case (owner,WriteRejected{error}): (owner,StateMoved{})','clock-controls.bend','valid|Moved|transaction=CapacityExceeded'),
  ('wrong-target','src/ecs/state.bend','case True{}: move_written(~H,~Value,~WriteError,Cap.request(~H,~Value,~WriteStatus<WriteError>,~write,owner,target))','case True{}: move_written(~H,~Value,~WriteError,Cap.request(~H,~Value,~WriteStatus<WriteError>,~write,owner,expected))','main.bend','advanced|[[0,0,[11,22,33,44]],[null,null,[11,22,33,44]]]')]
 if args.wrong_target_only:variants=[v for v in variants if v[0]=='wrong-target']
 receipt['mutants']={}
 for tag,module,old,new,entry,reached in variants:
  mutantPath=OUT/tag;shutil.copytree(STAGE,mutantPath,symlinks=True)
  MUTANT=mutantPath;mutantExpected=inv(MUTANT);assert mutantExpected==source,'mutant copy differs from frozen closure'
  mp=(MUTANT/module if '/' in module else MUTANT/'experiments/public-component-state'/module);text=mp.read_text();assert text.count(old)==1;mp.write_text(text.replace(old,new));mutantExpected=inv(MUTANT)
  mutantInventories[str(MUTANT)]=dict(mutantExpected)
  receipt['mutants'][tag]={'sourceInventory':dict(mutantExpected),'anchor':old,'replacement':new,'backends':{}};save()
  mm=MUTANT/'experiments/public-component-state'/entry;run(['bend',mm,'--check-only'],5,tag+'-checker')
  for suffix in ['js','c']:
   target=OUT/(tag+'.'+suffix);run(['bend',mm,'-o',target],30,tag+'-emit-'+suffix);artifact(target)
  mn=OUT/(tag+'.native');run([clang,'-O3',OUT/(tag+'.c'),'-o',mn,'-pthread','-lm'],120,tag+'-build-native');artifact(mn)
  for backend,cmd in [('JS',['node',OUT/(tag+'.js')]),('Native',[mn,'--threads','1','--gpu','off'])]:
   actual=run(cmd,5,tag+'-'+backend);assert reached in actual,'mutant did not reach intended incorrect detail'
   if tag=='wrong-target':assert actual.count(reached)==2,'wrong-target did not reach both nominal schemas'
   assert actual!=({'main.bend':reference,'access-controls.bend':accessExpected,'raw-boundary.bend':rawExpected,'clock-controls.bend':clockExpected}[entry]),'mutant did not diverge'
   receipt['mutants'][tag]['backends'][backend]={'status':'REACHED_DIVERGENCE','checkpoint':reached}
 receipt['status']='PASS_AGGREGATED_WRONG_TARGET_CONTROL' if args.wrong_target_only else 'PASS_FINITE_SLICE';guards();save();print(OUT)
try:execute()
except Exception as error:
 if not receipt['status'].startswith('INCONCLUSIVE'):receipt['status']='FAIL'
 receipt['error']=repr(error);save();raise
