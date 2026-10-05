#!/usr/bin/env python3
"""Mechanical C-helper arities and named caller reachability; no source-name guess."""
import argparse, collections, hashlib, json, re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--subject',type=Path,required=True);p.add_argument('--baseline',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
def inspect(path):
 text=path.read_text();heads=list(re.finditer(r'^(?:INLINE|FAR) Term (spin_\d+)\(([^\n]*)\) \{',text,re.M));cases=list(re.finditer(r'^  WL_CASE\(([^\n]*)\)',text,re.M));boundaries=sorted([(m.start(),m.group(1),'spin',m) for m in heads]+[(m.start(),m.group(1),'case',m) for m in cases]);edges={};arity={};reverse=collections.defaultdict(list)
 for i,(pos,name,kind,m) in enumerate(boundaries):
  end=boundaries[i+1][0] if i+1<len(boundaries) else len(text);body=text[pos:end];targets=sorted(set(re.findall(r'\b(spin_\d+)\(',body)))
  targets=[x for x in targets if x!=name];edges[name]=targets
  for target in targets:reverse[target].append(name)
  if kind=='spin':
   params=m.group(2).split(',');arity[name]={'totalCParameters':len(params),'valueRParameters':sum(bool(re.search(r'\br\d+\b',x)) for x in params),'locationQParameters':sum(bool(re.search(r'\bq\d+\b',x)) for x in params),'line':text.count('\n',0,pos)+1,'header':m.group(0)}
 routes=[];queue=collections.deque([['spin_75']]);seen={'spin_75'}
 while queue:
  route=queue.popleft()
  for caller in reverse[route[-1]]:
   if caller in seen:continue
   seen.add(caller);new=route+[caller]
   if caller.startswith('FID_'):routes.append(list(reversed(new)))
   elif len(new)<20:queue.append(new)
 return {'path':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'spinHelperCount':len(arity),'parameterCountDistribution':dict(sorted(collections.Counter(x['totalCParameters'] for x in arity.values()).items())),'topArityHelpers':sorted([{'name':k,**v} for k,v in arity.items()],key=lambda x:x['totalCParameters'],reverse=True)[:12],'spin75':arity['spin_75'],'spin75NamedCallerRoutes':routes,'limits':'Numeric helper identity alone is not source-function identity; routes prove static named caller reachability only.'}
r={'scope':'Generated spinning-helper ABI shapes; no timing or exact getter mapping','subject':inspect(a.subject),'baseline':inspect(a.baseline)};a.output.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'subjectSpin75':r['subject']['spin75']['totalCParameters'],'baselineSpin75':r['baseline']['spin75']['totalCParameters'],'subjectRoutes':r['subject']['spin75NamedCallerRoutes']}))
