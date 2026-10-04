#!/usr/bin/env python3
"""Finite Type traversal expressibility, originals and compiling controls."""
import hashlib,json,pathlib,subprocess,tempfile,os,signal
H=pathlib.Path(__file__).resolve().parent;os.sched_setaffinity(0,{6});source=H/'expressibility.bend'
report={'cpu':[6],'scope':'finite structural ownership prototype, no candidate ECS implementation or laws','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'commands':[],'controls':[]}
def run(args,limit=5):
 p=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:o,e=p.communicate(timeout=limit)
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);o,e=p.communicate();report['commands'].append({'args':list(map(str,args)),'limit':limit,'timeout':True,'output':o+e});raise
 report['commands'].append({'args':list(map(str,args)),'limit':limit,'exit':p.returncode,'output':o+e});return p.returncode,o+e
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
run(['bend','version']);run(['bend','guide']);report['sourceSHA256']=sha(source)
with tempfile.TemporaryDirectory(prefix='prep22-expressibility-') as tmp:
 tmp=pathlib.Path(tmp)
 def build(p,name):
  code,out=run(['bend',p,'--check-only']);assert code==0 and 'ALL PROOFS CHECK' in out
  js=tmp/(name+'.js');c=tmp/(name+'.c');native=tmp/name
  assert run(['bend',p,'-o',js],30)[0]==0
  assert run(['bend',p,'-o',c],30)[0]==0
  assert run(['clang','-O3',c,'-pthread','-lm','-o',native],120)[0]==0
  nc,no=run([native,'--threads','1','--gpu','off']);jc,jo=run(['node',js]);assert nc==jc==0 and no==jo
  return no
 original=build(source,'original');expected='[1, 10]:True\n[1, 222, 4, 882]:True\n[1, 222, 4, 882]:True\n[]:True\n[]:False\n[1, 10]:True\n[]:False\n[]:False\n[]:False\n[]:False\n';assert original==expected
 text=source.read_text()
 changes={'reversed':('List.append(&2,U32,lv,rv)','List.append(&2,U32,rv,lv)'), 'wrong-leaf':('walk(~M,~A,~mg,~ag,~use,rest,id,lm,la,lo)','walk(~M,~A,~mg,~ag,~use,rest,id,rm,ra,lo)'), 'stale-count':('Node{3,Node{1','Node{2,Node{1'), 'early-reservation':('Node{3,Node{1,Leaf{True{}},Leaf{False{}}}','Node{4,Node{2,Leaf{True{}},Leaf{True{}}}')}
 # Wrong leaf must preserve both affine owners, so swap sibling ownership in the other call too.
 for name,(old,new) in changes.items():
  changed=text.replace(old,new);assert changed!=text
  if name=='wrong-leaf':changed=changed.replace('offset(rest)),rm,ra,ro)','offset(rest)),lm,la,ro)')
  p=tmp/(name+'.bend');p.write_text(changed);out=build(p,name);assert out!=original
  report['controls'].append({'name':name,'sourceSHA256':sha(p),'status':'COMPILING_MUTANT_DETECTED','firstDifference':next(({'line':i+1,'original':a,'mutant':b} for i,(a,b) in enumerate(zip(original.splitlines(),out.splitlines())) if a!=b),None)})
 for name,bad in {'duplicate':'(p,(p,0))','raw-access':'main_get(p)','reconstruct':'(Main{0,0},(u,0))','write-through-read':'(main_set(p),(u,0))','cross-owner':'(u,(p,0))'}.items():
  p=tmp/(name+'.bend');p.write_text(text+'\ndef bad(~P: Type,~U: Type,p: P,u: U) -> P & (U & U32):\n  '+bad+'\n')
  code,out=run(['bend',p,'--check-only']);assert code==1 and 'Location: bad' in out and 'SOME PROOFS FAIL' in out
  report['controls'].append({'name':name,'sourceSHA256':sha(p),'status':'INTENDED_TYPE_REJECTION','diagnostic':out})
 p=tmp/'cross-schema.bend';p.write_text(text+'\ndef bad(p: Handle<Schema>) -> Handle<Unit>:\n  p\n')
 code,out=run(['bend',p,'--check-only']);assert code==1 and 'Location: bad' in out and 'SOME PROOFS FAIL' in out
 report['controls'].append({'name':'cross-schema','sourceSHA256':sha(p),'status':'INTENDED_TYPE_REJECTION','diagnostic':out})
report['status']='PASS_FINITE_PROTOTYPE';report['runnerSHA256']=sha(pathlib.Path(__file__));(H/'expressibility-evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(report['status'])
