#!/usr/bin/env python3
"""Elementary no-proof list kind/observation diagnostic; no core rewrite."""
import argparse,hashlib,json,os,pathlib,signal,subprocess,time

def run(argv,limit,cpu):
 p=subprocess.Popen(['taskset','-c',str(cpu),*argv],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);start=time.monotonic();timeout=False
 try:out=p.communicate(timeout=limit)[0]
 except subprocess.TimeoutExpired:timeout=True;os.killpg(p.pid,signal.SIGKILL);out=p.communicate()[0]
 return {'argv':argv,'limitSeconds':limit,'exit':p.returncode,'timeout':timeout,'elapsedSeconds':time.monotonic()-start,'output':out}
BUILD='''import Base
def build(count:Nat,+value:U32,values:List<Q,U32>) -> List<Q,U32>:
  match count:
    case 0n: values
    case 1n+rest: build(rest,U32.add(value,1),value <> values)
def sum(values:List<Q,U32>) -> U32:
  match values:
    case Nil{}: 0
    case Con{head,tail}: U32.add(head,sum(tail))
def main() -> IO(Unit):
  IO.print(U32.show(sum(build(8n,1,[]))))
'''
SNAPSHOT='''import Base
def snapshot_done(-A:Data,+head:A,pair:List<A> & List<&2,A>) -> List<A> & List<&2,A>:
  match pair:
    case (tail,view): (head <> tail,head <> view)
def snapshot(-A:Data,values:List<A>) -> List<A> & List<&2,A>:
  match values:
    case Nil{}: ([],[])
    case Con{head,tail}: snapshot_done(A,head,snapshot(A,tail))
def sum(values:List<&2,U32>) -> U32:
  match values:
    case Nil{}: 0
    case Con{head,tail}: U32.add(head,sum(tail))
def observed(old:List<&2,U32>,a:U32,b:U32,pair:List<U32> & List<&2,U32>) -> IO(Unit):
  match pair:
    case (_,fresh): IO.print(U32.show(a) ++ ":" ++ U32.show(b) ++ ":" ++ U32.show(sum(old)) ++ ":" ++ U32.show(sum(fresh)))
def repeated(owner:List<U32>,retained:List<&2,U32>,a:U32,b:U32) -> IO(Unit):
  observed(retained,a,b,snapshot(U32,owner))
def completed(pair:List<U32> & List<&2,U32>) -> IO(Unit):
  match pair:
    case (owner,+view): repeated(owner,view,sum(view),sum(view))
def main() -> IO(Unit):
  completed(snapshot(U32,[1,2,3]))
'''
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=10);a=p.parse_args();a.output.mkdir(exist_ok=False);receipt={'status':'INCOMPLETE','newProofs':False,'cases':{}}
 cases={'data':(BUILD.replace('Q','&2'),'36'),'affine':(BUILD.replace('Q','&1'),'36'),'snapshot':(SNAPSHOT,'6:6:6:6'),'affine-duplicate':(BUILD.replace('Q','&1')+'def duplicate(values:List<U32>) -> List<U32> & List<U32>:\n  (values,values)\n',None),'implicit-coercion':(BUILD.replace('Q','&1')+'def coerce(values:List<U32>) -> List<&2,U32>:\n  values\n',None)}
 for name,(text,expected) in cases.items():
  entry=a.output/(name+'.bend');entry.write_text(text);case={'sourceSHA256':hashlib.sha256(text.encode()).hexdigest(),'commands':[]};r=run(['bend',str(entry),'--check-only'],15,a.cpu);case['commands'].append(r)
  if expected is not None:
   if r['exit']==0:
    for cmd,limit in [(['bend',str(entry),'-o',str(entry.with_suffix('.c'))],30),(['clang','-O3',str(entry.with_suffix('.c')),'-o',str(entry.with_suffix('.bin')),'-lm','-pthread'],120),([str(entry.with_suffix('.bin'))],5)]:
     r=run(cmd,limit,a.cpu);case['commands'].append(r)
     if r['exit']!=0:break
   case['pass']=len(case['commands'])==4 and r['exit']==0 and r['output'].strip()==expected
  else:case['pass']=r['exit']==1 and not r['timeout'] and ('consumed more than once' in r['output'] if name=='affine-duplicate' else '- expected : List<&2, U32>' in r['output'] and '- observed : List<&1, U32>' in r['output'])
  receipt['cases'][name]=case
 receipt['status']='ELEMENTARY_CONTROLS_PASS' if all(c['pass'] for c in receipt['cases'].values()) else 'ELEMENTARY_CONTROLS_FAIL';(a.output/'evidence.json').write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['status'])
if __name__=='__main__':main()
