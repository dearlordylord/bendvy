#!/usr/bin/env python3
"""Paired callbacks through the actual owned indexed provider, two schemas."""
import json,sys,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import command,CHECK

def test():
 evidence=[]
 with tempfile.TemporaryDirectory(prefix='controls-',dir=HERE) as tmp:
  folder=Path(tmp)
  for schema,foreign in [('Motion','Health'),('Health','Motion')]:
   for name,body,expected in [
     ('write-read',f'A.set(~A.{schema}, p, A.{schema}{{}}, 7)',f'A.Cell<A.{schema}>'),
     ('undeclared',f'A.get(~A.{foreign}, p, A.{foreign}{{}})',f'A.Cell<A.{foreign}>'),
     ('cross-schema',f'get(p, A.{foreign}{{}})',f'A.{schema}'),
     ('fabricate','(A.Cell{A.Payload{[7 : U32^2n]}, []}, "fabricated")','P'),
     ('reconstruct','rebuild(P, get(p, A.'+schema+'{}))','P'),
   ]:
    common='import Base\nimport ../owned.bend as A\n'
    if name=='reconstruct':
     common+='def rebuild(-P: Type, result: P & U32) -> P & String:\n  match result:\n    case (_, +x): (A.Cell{A.Payload{[x : U32^2n]}, []}, U32.show(x))\n'
    negative=common+f'def callback(-P: Type, get: P -> A.{schema} -> P & U32, p: P) -> P & String:\n  '+body+'\n'+f'def main() -> A.Store<A.{schema}> & String:\n  A.read(~A.{schema}, ~callback, 0, A.initial(~A.{schema}))\n'
    # write/undeclared result can require separate result conversion: preserving
    # wrong call's intended error, rather than unrelated final-result mismatch.
    if name=='write-read': negative=negative.replace('  '+body+'\n','  ('+body+', "bad")\n')
    if name in ('undeclared','cross-schema'):
     negative=negative.replace('  '+body+'\n','  finish(P, '+body+')\n').replace('def callback','def finish(-P: Type, result: P & U32) -> P & String:\n  match result:\n    case (p, x): (p, U32.show(x))\ndef callback')
    positive=f'import Base\nimport ../owned.bend as A\ndef finish(-P: Type, result: P & U32) -> P & String:\n  match result:\n    case (p, x): (p, U32.show(x))\ndef callback(-P: Type, get: P -> A.{schema} -> P & U32, p: P) -> P & String:\n  finish(P, get(p, A.{schema}{{}}))\ndef main() -> A.Store<A.{schema}> & String:\n  A.read(~A.{schema}, ~callback, 0, A.initial(~A.{schema}))\n'
    n=folder/f'{schema}-{name}.bend';p=folder/f'{schema}-{name}-positive.bend'
    n.write_text(negative);p.write_text(positive)
    good=command([CHECK,p,'--check-only']);bad=command([CHECK,n,'--check-only'],expected=1)
    assert 'ALL PROOFS CHECK' in good
    assert 'SOME PROOFS FAIL' in bad and f'- expected : {expected}' in bad,(schema,name,bad)
    if name in ('write-read','undeclared'): assert '- observed : P' in bad,bad
    if name=='cross-schema': assert f'- observed : A.{foreign}' in bad,bad
    evidence.append({'schema':schema,'control':name,'positive':'ALL PROOFS CHECK','negative':bad,'negative_source':negative,'positive_source':positive})
 (HERE/'controls.json').write_text(json.dumps(evidence,indent=2)+'\n')
 print('10 actual indexed-provider paired controls PASS')
if __name__=='__main__':test()
