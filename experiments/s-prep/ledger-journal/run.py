#!/usr/bin/env python3
"""Finite isolated first-Ledger-write journal proposal; no timing evidence."""
import hashlib,json,os,pathlib,signal,subprocess,tempfile
H=pathlib.Path(__file__).resolve().parent;ROOT=H.parents[2]
os.sched_setaffinity(0,{6})
report={'scope':'Concrete disjoint-storage finite prototype; generic callback equivalence explicitly falsified','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'commands':[],'mutants':[]}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(args,limit=5):
 p=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:o,e=p.communicate(timeout=limit)
 except subprocess.TimeoutExpired:
  os.killpg(p.pid,signal.SIGKILL);o,e=p.communicate();report['commands'].append({'args':list(map(str,args)),'limit':limit,'timeout':True,'output':o+e});raise
 report['commands'].append({'args':list(map(str,args)),'limit':limit,'exit':p.returncode,'stdout':o,'stderr':e});return p.returncode,o
try:
 report['compiler']=run(['bend','version'])[1].strip()
 assert run(['git','-C','/workspace/formal-proofs/bendvy/.references/bevy-ts','rev-parse','HEAD'])[1].strip()=='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
 report['sources']={p.name:sha(p) for p in H.iterdir() if p.suffix in ['.bend','.mjs']}
 code,ts=run(['node',H/'reference.mjs']);assert code==0;report['freshTS']=json.loads(ts)
 assert report['freshTS']['status']=='FINITE_FRESH_TS_PASS'
 lines=['101,303:[44, 22, 3, 4]:[303, 6, 7, 8]:[0, 1, 0]:[9]:[7]','101,303:[1, 2, 3, 4]:[5, 6, 7, 8]:[]:[]:[]','none,none:[44, 22, 3, 4]:none:[0, 1, 0]:[9]:[7]','none,none:[1, 2, 3, 4]:none:[]:[]:[]']
 expected='\n'.join([x for line in lines for x in [line,line]]+['101,303:[6, 204, 3, 4]:[5, 6, 7, 8]:[]:[]:[]','101,303:[6, 305, 3, 4]:[5, 6, 7, 8]:[]:[]:[]'])+'\n'
 build=pathlib.Path(tempfile.mkdtemp(prefix='bendvy-ledger-journal-'));report['artifactRoot']=str(build)
 def execute(source,label):
  assert run(['bend',source,'--check-only'])[0]==0
  js=build/(label+'.js');c=build/(label+'.c');native=build/label
  assert run(['bend',source,'-o',js],30)[0]==0
  assert run(['bend',source,'-o',c],30)[0]==0
  assert run(['clang','-O3',c,'-pthread','-lm','-o',native],120)[0]==0
  nc,no=run([native,'--threads','1','--gpu','off']);jc,jo=run(['node',js]);assert nc==jc==0 and no==jo
  return no,{p.name:sha(p) for p in [js,c,native]}
 observed,artifacts=execute(H/'fixture.bend','original');assert observed==expected
 report['positive']={'status':'FINITE_NATIVE_JS_PASS','output':observed,'artifacts':artifacts,'originalNewPairsEqual':4,'genericCrossDependentRestoreCounterexample':{'original':observed.splitlines()[8],'coalesced':observed.splitlines()[9]}}
 text=(H/'journal.bend').read_text()
 mutations={'initial-old-wrong':('LedgerInverse{old} <> undo,commands,pings,marks},True{}','LedgerInverse{U32.add(old,1)} <> undo,commands,pings,marks},True{}'),'drop-inverse':('LedgerInverse{old} <> undo,commands,pings,marks},True{}','undo,commands,pings,marks},True{}'),'skip-restore':('restore_ledger(world,old))','world)')}
 with tempfile.TemporaryDirectory(prefix='mutants-',dir=H) as td:
  td=pathlib.Path(td)
  for name,(before,after) in mutations.items():
   assert text.count(before)==1
   for file in ['original.bend','fixture.bend']:(td/file).write_text((H/file).read_text().replace('../../s-integrate','../../../s-integrate'))
   changed=text.replace(before,after).replace('../../s-integrate','../../../s-integrate');(td/'journal.bend').write_text(changed)
   out,arts=execute(td/'fixture.bend',name);assert out!=expected
   report['mutants'].append({'name':name,'status':'COMPILING_NATIVE_JS_MUTANT_DETECTED','journalSHA256':sha(td/'journal.bend'),'output':out,'artifacts':arts})
 report['status']='FINITE_PROTOTYPE_PASS_GENERIC_EQUIVALENCE_REJECTED'
except Exception as e:report.update(status='FAIL',error=repr(e))
report['runnerSHA256']=sha(pathlib.Path(__file__));(H/'evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(report['status'])
raise SystemExit(report['status']=='FAIL')
