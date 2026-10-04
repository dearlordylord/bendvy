#!/usr/bin/env python3
"""Actual same-registry E2 provisioning; each checker/runtime invocation <=5s."""
import pathlib,re,sys,hashlib,json,tempfile,shutil
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import command,paired

def build(source,folder):
 name=source.stem;c=folder/(name+".c");native=folder/(name+"-native");js=folder/(name+".js")
 checked=command([HERE.parent/"t01"/"bend-check",source,"--check-only"]);assert "ALL PROOFS CHECK" in checked
 command(["bend",source,"-o",c],timeout=30)
 command(["clang","-std=c11","-O0",c,"-lpthread","-lm","-o",native],timeout=120)
 command(["bend",source,"-o",js],timeout=30)
 print("built "+str(source),flush=True)
 return native,js

def closure(p,files):
 if p.name in files:return
 files[p.name]=p
 for v in re.findall(r'^import (\./\S+\.bend)',p.read_text(),re.M):closure((p.parent/v).resolve(),files)
files={};closure(HERE/'host-preflight-controls.bend',files)
report={'native_optimization':'-O0 correctness-only; no performance acceptance','scope':'actual D.tick canonical E2; original registry/capture owners lent to fresh worlds then returned; full original owner observations','hashes':{n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in files.items()},'original':None,'mutants':{}}
with tempfile.TemporaryDirectory(prefix='host-preflight-') as d:
 for label in ['original','preflight_bypass']:
  folder=pathlib.Path(d)/label;folder.mkdir()
  for n,p in files.items():shutil.copyfile(p,folder/n)
  if label!='original':
   p=folder/'dispatcher.bend';s=p.read_text();old='case requirements state: IO.pure(Dispatched<W,H>,Dispatched{state,MissingRuntimeRequirements{requirements}})';new='case requirements Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}: tick_frame(W,H,presence,invoke,barrier,transition,frame,nodes,registry,audit,style,escaped,observations,nextMode,frame(world,readers,R.frame(clock)))';assert s.count(old)==1;s=s.replace(old,new);p.write_text(s)
  pieces=[]
  for schema in ['motion','health']:
   source=folder/('host-preflight-'+schema+'.bend')
   source.write_text((folder/'host-preflight-controls.bend').read_text().split('def main()')[0]+f'def main() -> IO(Unit): {schema}_start(F.{schema}_initial(C.Returned{{}}))\n')
   pieces.append(paired(build(source,folder)))
  out='\n'.join(pieces);lines=out.splitlines()
  actual=[x for x in lines if x.startswith('PREFLIGHT-INVOKE:')]
  results=[x for x in lines if x.startswith('PREFLIGHT-RESULT:')]
  comparisons=[x for x in lines if x.startswith('PREFLIGHT-ORIGINAL:')]
  if label=='original':
   assert actual==[],actual
   assert len(results)==4 and len(comparisons)==4,(results,comparisons)
   for schema in ['motion','health']:
    for missing,kind,name in [('missing-ledger','ResourceRequired',schema.title()+'Ledger'),('missing-audit','ServiceRequired','Audit')]:
     prefix=f'PREFLIGHT-RESULT:{schema}:{missing}:';found=[x[len(prefix):] for x in results if x.startswith(prefix)];assert len(found)==1
     assert json.loads(found[0])=={'kind':'MissingRuntimeRequirements','requirements':[{'kind':kind,'name':name}]},found
   assert all(x.endswith(':True') for x in comparisons),comparisons
   # Complete strings include physical logs, all captures, ECS owners/metadata.
   before=[x[len('PREFLIGHT-BEFORE:'):] for x in lines if x.startswith('PREFLIGHT-BEFORE:')]
   after=[x[len('PREFLIGHT-AFTER:'):] for x in lines if x.startswith('PREFLIGHT-AFTER:')]
   assert before==after and len(before)==4
   report['original']={'native_js_equal':True,'actual_invocations':actual,'actual_results':results,'complete_original_preserved':True,'output':out}
  else:
   assert actual, 'mutant must reach actual invoker'
   assert out!=report['original']['output']
   report['mutants'][label]={'compiling_native_js':True,'actual_invocations':actual,'intended_difference':'requirements bypass invokes actual A and changes original captures','output':out}
(HERE/'host-preflight-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
print('HOST PREFLIGHT ACTUAL ORIGINAL + COMPILING MUTANT PASS')
