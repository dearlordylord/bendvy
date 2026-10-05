#!/usr/bin/env python3
import pathlib,subprocess,os,signal,json,hashlib,ast
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];ART=pathlib.Path(os.environ.get('BENDVY_CACHE_REJECT_ARTIFACT','/tmp/bendvy-fivehour-cache-reject'));ART.mkdir(exist_ok=False);CPU=os.environ.get('BENDVY_CPU','5');e={'status':'INCOMPLETE','cases':[],'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120}}
guards=ROOT/'experiments/s-prep/owned-write-query/run.py';tree=ast.parse(guards.read_text());exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='run'],type_ignores=[]),str(guards),'exec'),globals())
try:
 e['sourceCommit']=run(['git','-C',ROOT,'rev-parse','HEAD']).strip();e['sources']={}
 for p in [*HERE.glob('*.py'),*HERE.glob('*.bend'),*HERE.glob('candidate-inputs/*.bend'),HERE/'source-inputs.json',guards]:
  assert p.read_bytes()==subprocess.check_output(['git','-C',str(ROOT),'show','HEAD:'+p.relative_to(ROOT).as_posix()],timeout=5);e['sources'][p.relative_to(ROOT).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
 e['runnerSHA256']=hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest();e['version']=run(['bend','version']);run(['bend','guide']);overlay=ART/'overlay';run(['python3',HERE/'materialize.py',overlay]);entry=overlay/'experiments/s-integrate/raw-reject-controls.bend'
 assert 'ALL PROOFS CHECK' in run(['taskset','-c',CPU,'bend',entry,'--check-only']);c=ART/'reject.c';js=ART/'reject.js';binary=ART/'reject'
 run(['taskset','-c',CPU,'bend',entry,'-o',c],30);run(['taskset','-c',CPU,'bend',entry,'-o',js],30);run(['taskset','-c',CPU,'clang','-O3',c,'-o',binary,'-lm','-pthread'],120)
 output=run(['taskset','-c',CPU,binary,'--threads','1','--gpu','off']);assert output==run(['taskset','-c',CPU,'node',js]);(ART/'reject-original.txt').write_text(output);e['outputSHA256']=hashlib.sha256(output.encode()).hexdigest()
 def four(n):return dict(zip('abcd',range(n,n+4)))
 records={}
 for line in output.splitlines():
  sch,step,value=line.split(':',2);records[sch,step]=value
 for sch in ['motion','health']:
  main={'coordinates':four(10),'frame':7} if sch=='motion' else {'levels':four(10),'reserve':9,'class':2};aux={'rates':four(20),'moving':True} if sch=='motion' else {'layers':four(20),'grade':3}
  assert records[sch,'factory']=='4294967295'
  expected={'namespace':7,'next':4294967295,'rows':[],'pending':[{'kind':'FlagView','id':1,'flag':{'group':8}}],'ledger':None,'mode':sch.title()+'On'}
  for step in ['before','after-reserve','after-insert']:assert json.loads(records[sch,step])==expected
  raw=records[sch,'reserve-owner'];parts=[]
  for i in range(3):
   value,end=json.JSONDecoder().raw_decode(raw);parts.append(value);raw=raw[end:];raw=raw[1:] if raw.startswith(':') else raw
  assert parts==[main,aux,{'group':9}] and raw=='';assert json.loads(records[sch,'insert-owner'])==main
 assert len(records)==12;e['cases']=[{'label':'exhausted factory reserve and foreign insert returned full raw owners and unchanged worlds','schemas':2,'backends':['NativeO3','JS'],'status':'PASS'}];e['specialization']=json.loads((overlay/'cache-specialization.json').read_text());e['status']='PASS_BOUNDED'
except Exception as error:e['error']=repr(error);raise
finally:(ART/'reject-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
