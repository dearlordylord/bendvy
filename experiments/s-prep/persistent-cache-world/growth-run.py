#!/usr/bin/env python3
import pathlib,subprocess,os,signal,json,hashlib,shutil,re,ast
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];ART=pathlib.Path(os.environ.get('BENDVY_GROWTH_ARTIFACT','/tmp/bendvy-persistent-cache-growth'));ART.mkdir(exist_ok=False);CPU=os.environ.get('BENDVY_CPU','5');e={'status':'INCOMPLETE','cases':[],'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120}}
guards=ROOT/'experiments/s-prep/owned-write-query/run.py';tree=ast.parse(guards.read_text());exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='run'],type_ignores=[]),str(guards),'exec'),globals())
runner=HERE/'run.py';tree=ast.parse(runner.read_text());exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in ['assigned_cutoff','assert_build_allowed','deadline_controls']],type_ignores=[]),str(runner),'exec'),globals())
try:
 cutoff=assigned_cutoff(os.environ.get('BENDVY_BUILD_CUTOFF_UTC'));e['assignedCutoff']=cutoff.isoformat() if cutoff else None;e['deadlineControls']=deadline_controls();e['sourceCommit']=run(['git','-C',ROOT,'rev-parse','HEAD']).strip();e['runnerSHA256']=hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest();e['rawRoot']=str(ART)
 e['sourceHashes']={}
 for p in [*HERE.glob('*.bend'),runner,pathlib.Path(__file__),guards]:
  assert p.read_bytes()==subprocess.check_output(['git','-C',str(ROOT),'show','HEAD:'+p.relative_to(ROOT).as_posix()],timeout=5);e['sourceHashes'][p.relative_to(ROOT).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
 run(['bend','version']);run(['bend','guide']);overlay=ART/'overlay';run(['python3',ROOT/'experiments/s-perf/overlay.py',overlay]);pkg=overlay/'experiments/s-integrate'
 for p in HERE.glob('*.bend'):shutil.copy2(p,pkg/p.name)
 payload=subprocess.check_output(['git','-C',str(ROOT),'show','56b72f6:experiments/s-integrate/payload.bend'],timeout=5);assert (pkg/'payload.bend').read_bytes()==payload;(pkg/'uncached-payload.bend').write_bytes(payload)
 for p in [pathlib.Path('/home/node/.bend/bin/bend'),pathlib.Path('/home/node/.bend/bend2/base.bend')]:e['sourceHashes'][str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
 def build(label):
  assert_build_allowed(cutoff);entry=pkg/'growth.bend';assert 'ALL PROOFS CHECK' in run(['taskset','-c',CPU,'bend',entry,'--check-only']);c=ART/(label+'.c');js=ART/(label+'.js');binary=ART/label
  run(['taskset','-c',CPU,'bend',entry,'-o',c],30);run(['taskset','-c',CPU,'bend',entry,'-o',js],30);run(['taskset','-c',CPU,'clang','-O3',c,'-o',binary,'-lm','-pthread'],120)
  a=run(['taskset','-c',CPU,binary,'--threads','1','--gpu','off']);b=run(['taskset','-c',CPU,'node',js]);assert a==b;(ART/(label+'.txt')).write_text(a);return a
 def four(n):return dict(zip('abcd',range(n,n+4)))
 def expected(sch,step):
  def row(i,n,aux,flag,added,changed):
   main=None if n is None else ({'coordinates':four(n),'frame':7} if sch=='motion' else {'levels':four(n),'reserve':9,'class':2})
   a={'rates':four(aux),'moving':True} if sch=='motion' else {'layers':four(aux),'grade':3}
   return {'id':i,'main':main,'aux':a,'flag':None if flag is None else {'group':flag},'added':added,'changed':changed}
  rows=[row(1,10,110,8,4,4),row(2,None,120,None,0,0),row(8,80,180,None,4,4)] if step=='grown' else [row(1,100,110,8,4,5),row(2,20,120,None,5,5),row(8,80,180,None,4,4)]
  if step=='edited':rows=[row(1,None,110,8,0,0),row(8,80,180,9,4,4)]
  pending=[{'kind':'RemoveMainView','id':1},{'kind':'FlagView','id':8,'flag':{'group':9}},{'kind':'DespawnView','id':2}] if step=='staged' else []
  return {'namespace':7,'next':9,'rows':rows,'pending':pending,'ledger':None,'mode':sch.title()+'On'}
 def observe(out):
  records={}
  for line in out.splitlines():
   if ':cached:' in line or ':raw:' in line:
    sch,step,kind,value=line.split(':',3);records[sch,step,kind]=json.loads(value)
  assert len(records)==16
  for sch in ['motion','health']:
   for step in ['grown','replaced','staged','edited']:assert records[sch,step,'raw']==records[sch,step,'cached']==expected(sch,step)
   for suffix in ['zero:missing','out:missing','foreign-point:missing','foreign-queue:missing:123','shape:8:3:8']:assert sch+':'+suffix in out.splitlines()
   for step,changes in [('seed','A1;C1;A8;C8;'),('replace','C1;A2;C2;'),('edit','R1;R2;D2;')]:assert sch+':'+step+':changes:'+changes in out.splitlines()
 original=build('growth-original');observe(original);e['cases'].append({'label':'generic growth replacement removal deferred FIFO bounds foreign','status':'PASS','schemas':2,'fullWorldCheckpoints':8,'backends':['NativeO3','JS']});e['originalOutputSHA256']=hashlib.sha256(original.encode()).hexdigest()
 source=(pkg/'storage.bend').read_text();needle='ANode{m,slots_empty(M,d)}';assert source.count(needle)==1;(pkg/'storage.bend').write_text(source.replace(needle,'ANode{slots_empty(M,d),m}'));mutant=build('growth-wrong-association')
 try:observe(mutant)
 except AssertionError:pass
 else:raise AssertionError('Growth association mutant survived')
 e['cases'].append({'label':'growth-wrong-association','status':'DETECTED','compilingBothBackends':True});e['status']='PASS_BOUNDED'
except Exception as error:e['error']=repr(error);raise
finally:(ART/'growth-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
