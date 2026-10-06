#!/usr/bin/env python3
"""Aggregate V8 sampled allocation attribution; never call this exact accounting."""
import argparse,collections,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('profile',type=Path);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
profile=json.loads(a.profile.read_text());functions=collections.Counter();modules=collections.Counter();nodes=[]
def decode(s):return re.sub(r'\$(\d{3})',lambda m:chr(int(m[1])),s).strip('$')
def visit(n):
    frame=n['callFrame'];name=decode(frame['functionName']);size=n['selfSize']
    if size:
        functions[name]+=size
        module=name.split('s-integrate/')[-1].split(':')[0] if 's-integrate/' in name else 'measurement' if name.startswith('measurement-bend:') else 'runtime/profiler'
        modules[module]+=size
        nodes.append({'function':name,'url':frame['url'],'line':frame['lineNumber']+1,'sampledSelfBytes':size,'nodeId':n['id']})
    for child in n.get('children',[]):visit(child)
visit(profile['head'])
r={'scope':'V8 sampled allocation attribution; collected objects included; inlined allocation can be attributed to caller. Not exact heap accounting or timing acceptance.',
   'profileSHA256':hashlib.sha256(a.profile.read_bytes()).hexdigest(),'samples':len(profile['samples']),
   'sampledSelfBytes':sum(functions.values()),'modules':dict(modules.most_common()),
   'functions':[{'function':k,'sampledSelfBytes':v} for k,v in functions.most_common()],
   'topNodes':sorted(nodes,key=lambda x:x['sampledSelfBytes'],reverse=True)[:30]}
a.output.write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps({k:r[k] for k in ['samples','sampledSelfBytes','modules']}))
