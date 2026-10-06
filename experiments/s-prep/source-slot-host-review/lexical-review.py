#!/usr/bin/env python3
"""Conservative lexical declaration closure, deliberately not dynamic reachability."""
import argparse,pathlib,re,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--entry',type=pathlib.Path,required=True);p.add_argument('--schema',choices=['motion','health'],required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();core=a.entry.resolve().parent;parsed={};seen=set();pending=[(a.entry.resolve(),'main')];missing=set();sha=lambda b:hashlib.sha256(b).hexdigest()
def parse(path):
 if path in parsed:return parsed[path]
 raw=path.read_text();starts=list(re.finditer(r'^(def|type) ([\w]+)',raw,re.M));decls={m[2]:raw[m.start():starts[i+1].start() if i+1<len(starts) else len(raw)] for i,m in enumerate(starts)};constructors={c:name for name,b in decls.items() if b.startswith('type ') for c in re.findall(r'^  (\w+)\{',b,re.M)};aliases={k:(path.parent/v).resolve() for v,k in re.findall(r'^import (\./\S+\.bend) as (\w+)',raw,re.M)};parsed[path]=(decls,constructors,aliases);return parsed[path]
while pending:
 path,name=pending.pop();assert path.is_relative_to(core);decls,ctors,aliases=parse(path);name=ctors.get(name,name)
 if (path,name) in seen:continue
 if name not in decls:missing.add(path.name+':'+name);continue
 seen.add((path,name));body=re.sub(r'"(?:\\.|[^"\\])*"','""',decls[name]);body=re.sub(r'(?m)^\s*//.*$','',body)
 for token in re.findall(r'(?<![\w.])\w+(?![\w.])',body):
  ref=ctors.get(token,token)
  if ref in decls:pending.append((path,ref))
 for alias,target in aliases.items():
  for ref in re.findall(r'(?<![\w.])'+re.escape(alias)+r'\.(\w+)',body):pending.append((target,ref))
defs=sorted(path.name+':'+name for path,name in seen);private=[d for d in defs if ':prototype_slot_host_' in d];modules=('systems.bend','audited-invoker.bend','structural-invoker.bend','host.bend');old=[d for d in defs if d.split(':')[0] in modules and re.match(a.schema+'_',d.split(':')[1])];assert not old,old;required=['host.bend:prototype_slot_host_'+a.schema+'_'+s for s in ('dispatch','tick','invoke','barrier','reserve','transition','frame')]+['systems.bend:prototype_slot_host_'+a.schema+'_'+s for s in ('a','b','seed','seed_beta')];assert all(x in defs for x in required),[x for x in required if x not in defs];assert not missing,missing
r={'status':'CONSERVATIVE_PRIVATE_HOST_LEXICAL_ROUTE_PASS','scope':'All syntactic branches, constructors and frozen refs; not actual execution counts or universal proof','schema':a.schema,'entrySHA256':sha(a.entry.read_bytes()),'definitions':defs,'privateDefinitions':private,'oldConcreteFamilies':old,'requiredPaths':required,'unresolvedQualifiedNames':sorted(missing),'modulePins':{path.name:sha(path.read_bytes()) for path in parsed}};a.output.write_text(json.dumps(r,indent=2)+'\n')
