#!/usr/bin/env python3
"""Finite unapproved candidate falsification, independent filter oracle."""
import itertools,json,pathlib
alphabet=[(k,s,t) for k in (1,2) for s in (1,2) for t in (1,2)]
cases=0;wrong=drop=0
for n in range(6):
 for edges in itertools.product(alphabet,repeat=n):
  oracle=[e for e in edges if e[:2]!=(1,1)];acc=[]
  for e in edges:
   if e[:2]!=(1,1):acc.insert(0,e)
  actual=acc[::-1];assert actual==oracle
  wrong+=acc!=oracle;drop+=[]!=oracle;cases+=1
inverse_cases=0
entries=[(k,t,xs) for k in (1,2) for t in (1,2) for xs in ((),(1,),(2,),(1,2),(2,1),(1,1))]
for n in range(4):
 for values in itertools.product(entries,repeat=n):
  oracle=[]
  for k,t,xs in values:
   if (k,t)==(1,1):xs=tuple(x for x in xs if x!=1)
   if xs or (k,t)!=(1,1):oracle.append((k,t,xs))
  acc=[]
  for k,t,xs in values:
   if (k,t)==(1,1):xs=tuple(x for x in xs if x!=1)
   if xs or (k,t)!=(1,1):acc.insert(0,(k,t,xs))
  assert acc[::-1]==oracle;inverse_cases+=1
result={'status':'FINITE_UNAPPROVED_FILTER_CANDIDATES_NOT_FALSIFIED','edgeCases':cases,'inverseCases':inverse_cases,'wrongOrderWitnesses':wrong,'dropSurvivorWitnesses':drop,'proof':False}
out=pathlib.Path(__file__).parent/'filter-falsification.json';out.write_text(json.dumps(result,indent=2)+'\n');print(result)
