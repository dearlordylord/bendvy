#!/usr/bin/env python3
"""Conservative static source reachability receipt; execution/call counters remain separate."""
from pathlib import Path
import argparse,re,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--entry',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();core=a.entry.resolve().parent;pending=[(a.entry.resolve(),'main')];seen=set();modules={};missing=[]
def module(path):
 if path in modules:return modules[path]
 text=path.read_text();heads=list(re.finditer(r'^(def|type) ([\w.]+)',text,re.M));blocks={h[2]:text[h.start():heads[i+1].start() if i+1<len(heads) else len(text)] for i,h in enumerate(heads)};constructors={}
 for name,b in blocks.items():
  if b.startswith('type '):
   for c in re.findall(r'^  ([\w]+)\{',b,re.M):constructors[c]=name
 aliases={alias:(path.parent/name).resolve() for name,alias in re.findall(r'^import (\./\S+\.bend) as (\w+)',text,re.M)};modules[path]=(blocks,constructors,aliases);return modules[path]
while pending:
 path,name=pending.pop();assert path.is_relative_to(core) and path.is_file();blocks,ctors,aliases=module(path);name=ctors.get(name,name)
 if (path,name) in seen:continue
 if name not in blocks:missing.append(str(path.name)+':'+name);continue
 seen.add((path,name));b=blocks[name]
 for tok in re.findall(r'(?<![\w.])([A-Za-z_][\w]*)(?![\w.])',b):
  local=ctors.get(tok,tok)
  if local in blocks:pending.append((path,local))
 for alias,target in aliases.items():
  for ref in re.findall(r'(?<![\w.])'+re.escape(alias)+r'\.([\w.]+)',b):pending.append((target,ref))
r={'scope':'Conservative lexical source closure; not dynamic reachability or universal authority proof','entry':str(a.entry),'definitions':sorted(str(path.relative_to(core))+':'+name for path,name in seen),'modulePins':{str(path.relative_to(core)):hashlib.sha256(path.read_bytes()).hexdigest() for path in modules},'unresolvedQualifiedNames':sorted(set(missing))};a.output.write_text(json.dumps(r,indent=2)+'\n')
