#!/usr/bin/env python3
"""Summarize executed source sites; static labels are not dynamic call stacks."""
import argparse, bisect, collections, hashlib, json, re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--sites',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
original=a.source.read_text(); lines=[]; original_lines=[]
for n,line in enumerate(original.splitlines(),1):
 m=re.fullmatch(r'  BLK_ALLOC\((\w+), (.*?)\)',line)
 if m:
  name,words=m.groups();expanded=[f'  u64 {name} = heap_alloc(e, {words});','  if (err_seen(e.mem)) {',f'    return term_buf(0, {name});','  }']
 else:expanded=[line]
 lines.extend(expanded);original_lines.extend([n]*len(expanded))
text='\n'.join(lines)+'\n'
contexts=list(re.finditer(r'^(?:INLINE|OUTLINE|FAR|static)\s+[^;\n]*?\b(\w+)\([^;\n]*\)\s*\{|^\s*WL_CASE\(([^)]+)\)',text,re.M)); positions=[m.start() for m in contexts]
line_starts=[0]+[m.end() for m in re.finditer('\n',text)]
parents=collections.defaultdict(set)
for m in re.finditer(r'\b(spin_\d+)\(',text):
 line=text[text.rfind('\n',0,m.start())+1:m.start()]
 if re.match(r'\s*(?:INLINE|FAR)\b',line):continue
 ci=bisect.bisect_right(positions,m.start())-1
 if ci>=0:parents[m.group(1)].add(contexts[ci].group(1) or contexts[ci].group(2))
active=[];bykind=collections.Counter();byowner=collections.Counter();rfcowners=collections.Counter()
for site in json.loads(a.sites.read_text()):
 if not(site['entries'] or site['rfcCreated']):continue
 line=site.get('expandedSourceLine',site.get('derivedLine'));site['originalLine']=original_lines[line-1]
 if site['operation']=='heap_alloc':
  pos=line_starts[line-1];ci=bisect.bisect_right(positions,pos)-1;end=positions[ci+1] if ci+1<len(positions) else len(text)
  m=re.search(r'\bu64\s+(\w+)\s*=',lines[line-1]);kind='unclassified'
  if site['owner']=='rfc_wrap':kind='RFC redirect cell'
  elif site['owner'].startswith('blk_'):kind='Array/Buffer block'
  elif m:
   var=m.group(1);targets=set(re.findall(r'\bterm_(ctr|clo)\((\w+),\s*'+re.escape(var)+r'\)',text[pos:end]))
   if len(targets)==1:
    tag,label=next(iter(targets));kind=('Constructor:' if tag=='ctr' else 'Closure:')+label
   elif targets:kind='ambiguous:'+repr(sorted(targets))
  site['staticAllocationKind']=kind;bykind[kind]+=site['entries'];byowner[site['owner']]+=site['entries']
 rfcowners[site['owner']]+=site['rfcCreated']
 site['staticDirectCallers']=sorted(parents.get(site['owner'],[]));active.append(site)
result={'sourceSHA256':hashlib.sha256(a.source.read_bytes()).hexdigest(),'labelScope':'Exact direct source callsites. Constructor/closure labels are unique static uses of allocated local; direct caller edges are static, not stack/time attribution.','activeSiteCount':len(active),'heapByStaticAllocationKind':dict(bykind.most_common()),'heapByOwner':dict(byowner.most_common()),'rfcByOriginOwner':dict(rfcowners.most_common()),'activeSites':active}
a.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='activeSites'},indent=2))
