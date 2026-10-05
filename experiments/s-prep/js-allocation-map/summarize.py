#!/usr/bin/env python3
"""Source-constructor counts only; neither materialized allocation bytes nor timing."""
import argparse,collections,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--sites',type=Path,required=True);p.add_argument('--profile',type=Path,required=True);a=p.parse_args();meta=json.loads(a.sites.read_text());sites=meta['sites'];raw=(a.profile/'JS.raw.txt').read_text();reports=[x for x in raw.splitlines() if x.startswith('ALLOCATION-COUNTS:')];assert len(reports)==1;counts=json.loads(reports[0].split(':',1)[1]);assert len(counts)==len(sites);e=json.loads((a.profile/'evidence.json').read_text());assert e['allFullFieldsEqual']
def decode(s):return re.sub(r'\$(\d{3})',lambda m:chr(int(m[1])),s).strip('$')
mods=collections.Counter();kinds=collections.Counter();funcs=collections.Counter()
for site,n in zip(sites,counts):
 f=decode(site['function']);mod=f.split('s-integrate/')[-1].split(':')[0] if 's-integrate/' in f else 'measurement' if f.startswith('measurement-bend:') else 'base/runtime';mods[mod]+=n;kinds[site['kind'].split('s-integrate/')[-1]]+=n;funcs[f.split('s-integrate/')[-1]]+=n
r={'scope':meta['scope'],'pointCallbacks':8*64*256,'totalConstructorExecutions':sum(counts),'perPointCallback':sum(counts)/(8*64*256),'modules':dict(mods.most_common()),'kinds':dict(kinds.most_common()),'functions':dict(funcs.most_common()),'siteMapSHA256':hashlib.sha256(a.sites.read_bytes()).hexdigest(),'sites':[{**s,'decodedFunction':decode(s['function']),'count':n} for s,n in zip(sites,counts) if n]};(a.profile/'allocation-summary.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({k:r[k] for k in ['totalConstructorExecutions','perPointCallback','modules']}))
