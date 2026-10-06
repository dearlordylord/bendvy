#!/usr/bin/env python3
"""Elementary current frozen-client seam and unsupported rank2 frozen syntax."""
import argparse,pathlib,json,hashlib,importlib.util
sp=importlib.util.spec_from_file_location('list_probe',pathlib.Path(__file__).resolve().parents[1]/'affine-journal-kind/probe.py');P=importlib.util.module_from_spec(sp);sp.loader.exec_module(P)
SOURCE='''import Base
def getter(owner:U32) -> U32:
  U32.add(owner,1)
def body(~Owner:Type,~get:Owner -> U32,owner:Owner) -> U32:
  get(owner)
def invoke(~client:@-Owner:Type -> @-get:(Owner -> U32) -> Owner -> U32,owner:U32) -> U32:
  client(U32,getter,owner)
def main() -> IO(Unit):
  IO.print(U32.show(invoke(~body,41)))
'''
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=10);a=p.parse_args();a.output.mkdir(exist_ok=False);r={'scope':'Language/checker feasibility only; no core rewrite or production authority approval','cases':{}}
 cases={'current-seam':SOURCE,'rank2-frozen-binder':SOURCE.replace('@-Owner:Type','@~Owner:Type'),'frozen-variable-call':SOURCE.replace('client(U32,getter,owner)','client(~U32,~getter,owner)'),'abstract-owner-inspection':SOURCE.replace('  get(owner)','  U32.add(owner,1)')}
 for name,s in cases.items():
  path=a.output/(name+'.bend');path.write_text(s);result=P.run(['bend',str(path),'--check-only'],15,a.cpu);c={'sourceSHA256':hashlib.sha256(s.encode()).hexdigest(),'commands':[result]}
  if name=='current-seam' and result['exit']==0:
   for argv,limit in [(['bend',str(path),'-o',str(path.with_suffix('.c'))],30),(['clang','-O3',str(path.with_suffix('.c')),'-o',str(path.with_suffix('.bin')),'-lm','-pthread'],120),([str(path.with_suffix('.bin')),'--threads','1','--gpu','off'],5)]:
    result=P.run(argv,limit,a.cpu);c['commands'].append(result)
    if result['exit']!=0:break
   c['pass']=len(c['commands'])==4 and result['exit']==0 and result['output'].strip()=='42'
  else:
   intended={'rank2-frozen-binder':['- expected : a name',"- observed : '~'"],'frozen-variable-call':['- expected : a term',"- observed : '~'"],'abstract-owner-inspection':['- expected : U32','- observed : body~Owner','Location: body']}[name]
   c['intendedDiagnostics']=intended
   c['rejected']=result['exit']==1 and not result['timeout'] and all(fragment in result['output'] for fragment in intended)
  r['cases'][name]=c
 (a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({n:c.get('pass',c.get('rejected')) for n,c in r['cases'].items()}))
if __name__=='__main__':main()
