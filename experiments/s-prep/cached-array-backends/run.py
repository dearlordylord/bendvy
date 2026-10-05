#!/usr/bin/env python3
"""Finite backend source/template capability probe, no performance evidence."""
import hashlib,json,os,pathlib,re,signal,subprocess,tempfile
H=pathlib.Path(__file__).resolve().parent;os.sched_setaffinity(0,{6});report={'scope':'Finite equal-shape trusted-capacity domain; no production or proof approval','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'commands':[],'mutants':[]}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(args,limit=5):
 p=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:o,e=p.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);o,e=p.communicate();report['commands'].append({'args':list(map(str,args)),'limit':limit,'timeout':True,'output':o+e});raise
 report['commands'].append({'args':list(map(str,args)),'limit':limit,'exit':p.returncode,'output':o+e});return p.returncode,o+e
try:
 report['compiler']=run(['bend','version'])[1].strip();report['baseSHA256']=sha(pathlib.Path.home()/'.bend/bend2/base.bend')
 report['backendSourceClosures']={b:{n:sha(H/n) for n in ['fixture.bend',b+'-helpers.bend',b+'.bend']} for b in ['native','javascript']}
 build=pathlib.Path(tempfile.mkdtemp(prefix='bendvy-cached-backends-'));report['artifactRoot']=str(build)
 first='[[90, 2, 3, 4]:7, none, [30, 2, 3, 4]:7, [40, 2, 3, 4]:7]:old=[10, 2, 3, 4]:7:True'
 hole='[[10, 2, 3, 4]:7, [20, 2, 3, 4]:7, [30, 2, 3, 4]:7, [40, 2, 3, 4]:7]:old=none:True'
 rejected='[[10, 2, 3, 4]:7, none, [30, 2, 3, 4]:7, [40, 2, 3, 4]:7]:old=[90, 2, 3, 4]:7:False'
 expected='\n'.join([first,hole,rejected,rejected,rejected,'[1, 2, 99, 4]:99'])+'\n'
 def execute(folder,backend,label):
  src=folder/(backend+'.bend');assert run(['bend',src,'--check-only'])[0]==0
  out=build/(label+('.c' if backend=='native' else '.js'));assert run(['bend',src,'-o',out],30)[0]==0
  if backend=='native':
   bin=build/label;assert run(['clang','-O3',out,'-pthread','-lm','-o',bin],120)[0]==0;code,value=run([bin,'--threads','1','--gpu','off'])
  else:code,value=run(['node',out])
  assert code==0;return value,out
 report['positive']={}
 for backend in ['native','javascript']:
  observed,out=execute(H,backend,'original-'+backend);assert observed==expected
  report['positive'][backend]={'status':'FINITE_FULL_FIELD_PASS','artifactSHA256':sha(out),'output':observed}
 js=(build/'original-javascript.js').read_text();assert 'native$045helpers' not in js and 'swap_go' not in js and 'get_go' not in js
 functions=re.findall(r'function (\$javascript\$045helpers[^\n]+) \{\n(.*?)\n\}',js,re.S)
 assert functions and all('.slice(' not in body and '.concat(' not in body for _,body in functions)
 report['javascriptLowering']={'status':'FLAT_INTRINSICS_NATIVE_BRANCH_ABSENT','helpers':[{'signature':sig,'body':body} for sig,body in functions]}
 with tempfile.TemporaryDirectory(prefix='controls-',dir=H) as tmp:
  tmp=pathlib.Path(tmp)
  def files():
   for n in ['fixture.bend','native-helpers.bend','javascript-helpers.bend','native.bend','javascript.bend']:(tmp/n).write_text((H/n).read_text())
  controls={'wrong-leaf':('fixture.bend','U32.sub(id,1),Some{value})','U32.add(U32.sub(id,1),1),Some{value})',['native','javascript']),'drop-returned-owner':('fixture.bend','case (array,old): SlotResult{array,old,True{}}','case (array,_): SlotResult{array,None{},True{}}',['native','javascript']),'wrong-capacity':('native-helpers.bend','swap_go(P,array,capacity,index,value,U32.is_lt(index,U32.shr(capacity)))','swap_go(P,array,U32.add(capacity,capacity),index,value,U32.is_lt(index,U32.shr(capacity)))',['native'])}
  for name,(file,old,new,backends) in controls.items():
   files();text=(tmp/file).read_text();assert text.count(old)==1;(tmp/file).write_text(text.replace(old,new));entry={'name':name,'applicableBackends':backends,'sourceSHA256':sha(tmp/file),'results':{}}
   for backend in backends:
    value,out=execute(tmp,backend,name+'-'+backend);assert value!=expected;entry['results'][backend]={'status':'COMPILING_MUTANT_DETECTED','output':value,'artifactSHA256':sha(out)}
   if name=='wrong-capacity':entry['javascript']='INAPPLICABLE: intrinsic path does not consume cached size for tree descent'
   report['mutants'].append(entry)
  files();(tmp/'negative.bend').write_text('import Base\nimport ./fixture.bend as F\ndef bad(owner: F.Main) -> F.Main & F.Main:\n  (owner,owner)\n')
  code,out=run(['bend',tmp/'negative.bend','--check-only']);assert code==1 and 'bad' in out;report['affineNegative']={'status':'INTENDED_OWNER_DUPLICATION_REJECTION','output':out}
  (tmp/'direct.bend').write_text((H/'failed-direct-helpers.txt').read_text());code,out=run(['bend',tmp/'direct.bend','--check-only']);assert code==1;report['directFrozenBool']={'status':'CHECKER_REJECTED','sourceSHA256':sha(H/'failed-direct-helpers.txt'),'output':out}
  (tmp/'wrapper.bend').write_text((H/'failed-wrapper-helpers.txt').read_text())
  (tmp/'wrapper-entry.bend').write_text('import Base\nimport ./wrapper.bend as C\ndef show(result: Array<U32> & U32) -> String:\n  match result:\n    case (_,value): U32.show(value)\ndef main() -> IO(Unit):\n  IO.print(show(C.get(U32,False{},ALeaf{1},1,0)))\n')
  assert run(['bend',tmp/'wrapper-entry.bend','--check-only'])[0]==0
  code,out=run(['bend',tmp/'wrapper-entry.bend','-o',build/'failed-wrapper.js'],30);assert code==1 and 'open Array element type' in out
  report['wrapperFrozenBool']={'status':'CHECK_PASS_CODEGEN_REJECTED','sourceSHA256':sha(H/'failed-wrapper-helpers.txt'),'entrySource':(tmp/'wrapper-entry.bend').read_text(),'output':out}
  files();(tmp/'native-helpers.bend').write_text((H/'failed-base-go-helpers.txt').read_text());assert run(['bend',tmp/'native.bend','--check-only'])[0]==0
  code,out=run(['bend',tmp/'native.bend','-o',build/'failed-base.c'],30);assert code==1 and 'open Array element type' in out;report['directBaseGo']={'status':'CHECK_PASS_CODEGEN_REJECTED','sourceSHA256':sha(H/'failed-base-go-helpers.txt'),'output':out}
 report['status']='FINITE_EXPLICIT_OPERATION_TEMPLATE_PASS_BOOL_BASE_GO_BLOCKED'
except Exception as e:report.update(status='FAIL',error=repr(e))
report['runnerSHA256']=sha(pathlib.Path(__file__));(H/'evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(report['status']);raise SystemExit(report['status']=='FAIL')
