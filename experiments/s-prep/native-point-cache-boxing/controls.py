#!/usr/bin/env python3
"""Finite affine/nested-box controls; no ECS proof or integration acceptance."""
import argparse,hashlib,json,pathlib
from probe import run

def main():
 p=argparse.ArgumentParser();p.add_argument('--candidate',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,default=10);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
 imports=f'import Base\nimport {a.candidate.resolve()}/experiments/s-integrate/held-adapter.bend as H\nimport {a.candidate.resolve()}/experiments/s-integrate/cache.bend as CC\nimport {a.candidate.resolve()}/experiments/s-integrate/types.bend as T\n'
 positive=imports+'''type Raw is Type:
  Raw{values: Array<U32>}
def restore(-R:Type,box:H.PrototypeWorldBox<CC.Cache<R,U32>>) -> CC.Cache<R,U32>:
  H.prototype_world_unbox(CC.Cache<R,U32>,box)
def observed(view:U32,pair:Array<U32> & U32) -> U32:
  match pair:
    case (_,value): U32.add(view,value)
def observe(cache:CC.Cache<Raw,U32>) -> U32:
  match cache:
    case CC.Cache{Raw{values},view}:
      observed(view,Array.get(U32,values,0))
def main() -> IO(Unit):
  IO.print(U32.show(observe(restore(Raw,H.PrototypeWorldNested{H.PrototypeWorldNested{H.PrototypeWorldRoot{CC.Cache{Raw{[7 : U32^0n]},23}}}}))))
'''
 cases={'nested-affine-roundtrip':positive,'affine-duplicate':positive+'''def duplicate(-R:Type,box:H.PrototypeWorldBox<CC.Cache<R,U32>>) -> H.PrototypeWorldBox<CC.Cache<R,U32>> & H.PrototypeWorldBox<CC.Cache<R,U32>>:
  (box,box)
''','cross-schema-cache':positive+'''def cross_schema(box:H.PrototypeWorldBox<CC.Cache<T.Position,T.PositionView>>) -> H.PrototypeWorldBox<CC.Cache<T.Vitals,T.VitalsView>>:
  box
'''}
 receipt={'status':'INCOMPLETE','cases':{},'checkerSeconds':15,'proofDefaultSeconds':5,'newLaws':False}
 for name,source in cases.items():
  path=a.output/(name+'.bend');path.write_text(source);r=run(['bend',str(path),'--check-only'],15,a.cpu);case={'sourceSHA256':hashlib.sha256(source.encode()).hexdigest(),'commands':[r]}
  if name=='nested-affine-roundtrip':
   if r['exit']==0:
    for argv,limit in [(['bend',str(path),'-o',str(path.with_suffix('.c'))],30),(['clang','-O3',str(path.with_suffix('.c')),'-o',str(path.with_suffix('.bin')),'-lm','-pthread'],120),([str(path.with_suffix('.bin'))],5)]:
     r=run(argv,limit,a.cpu);case['commands'].append(r)
     if r['exit']!=0:break
   case['pass']=len(case['commands'])==4 and r['exit']==0 and r['output'].strip()=='30'
  else:case['pass']=r['exit']!=0 and not r['timeout'] and ('consumed more than once' in r['output'] if name=='affine-duplicate' else ('- expected : H.PrototypeWorldBox<CC.Cache<T.Vitals, T.VitalsView>>' in r['output'] and '- observed : H.PrototypeWorldBox<CC.Cache<T.Position, T.PositionView>>' in r['output']))
  receipt['cases'][name]=case
 receipt['status']='FINITE_CONTROLS_PASS' if all(c['pass'] for c in receipt['cases'].values()) else 'FINITE_CONTROLS_FAIL'
 (a.output/'controls.json').write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['status'])
if __name__=='__main__':main()
