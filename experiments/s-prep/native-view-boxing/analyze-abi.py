#!/usr/bin/env python3
"""Static emitted helper body/route diagnostics; no dynamic operation counts."""
import argparse,collections,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--candidate',type=Path,required=True);p.add_argument('--baseline',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
def inspect(path):
 s=path.read_text();nodes=list(re.finditer(r'^(?:INLINE|FAR) Term (spin_\d+)\(([^\n]*)\) \{|^  WL_CASE\(([^\n]*)\)',s,re.M));edges={};bodies={};heads={};lines={}
 for i,m in enumerate(nodes):
  name=m[1] or m[3];body=s[m.start():nodes[i+1].start() if i+1<len(nodes) else len(s)];edges[name]=sorted(set(re.findall(r'\b(spin_\d+)\(',body))-{name});bodies[name]=body;heads[name]=m[2];lines[name]=s.count('\n',0,m.start())+1
 root=next(x for x in edges if x.endswith('HELD_ADAPTER_MOTION_ROW_0'));todo=collections.deque([(root,[root])]);seen=set();read=[];view=[];allnodes=[]
 while todo:
  x,route=todo.popleft()
  if x in seen:continue
  seen.add(x);b=bodies[x]
  if x.startswith('spin'):
   params=heads[x].split(',');r={'name':x,'line':lines[x],'route':route,'totalCParameters':len(params),'rParameters':sum(bool(re.search(r'\br\d+\b',v))for v in params),'qParameters':sum(bool(re.search(r'\bq\d+\b',v))for v in params),'outputWords':len(re.findall(r'^  o\[\d+\]',b,re.M)),'directStaticSites':{n:len(re.findall(r'\b'+n+r'\(',b))for n in ['term_keep','ctr_take','heap_alloc','spare_free']}};allnodes.append(r)
   if not edges[x] and '_owner_' in b and 'o[' in b and not any(t in b for t in ['blk_write','heap_alloc','U32_BIN']):read.append({**r,'body':b})
   if '_view_0' in b and 'TYPES_POSITIONVIEW)' in b and 'ctr_take' in b:view.append({**r,'body':b})
  todo.extend((y,route+[y])for y in edges[x])
 return {'sourceC':str(path),'sourceSHA256':hashlib.sha256(path.read_bytes()).hexdigest(),'namedRowRoot':root,'readTransportBodies':read,'positionViewMatchBodies':view,'reachableSpinningHelpers':allnodes,'limits':'Static call routes and operation sites only. Numerical spin identities vary. Shapes plus source semantics identify read transport; no execution-frequency or runtime-cost inference.'}
a.output.write_text(json.dumps({'candidate':inspect(a.candidate),'baseline':inspect(a.baseline)},indent=2)+'\n')
