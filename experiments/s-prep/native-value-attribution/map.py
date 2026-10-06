#!/usr/bin/env python3
"""Read-only annotation of previously executed, source-pinned allocation sites."""
import hashlib,json,re,pathlib
OUT=pathlib.Path(__file__).parent
roles={'Motion':('/tmp/bendvy-flat-journal-motion-v4/batch.c','/tmp/bendvy-flat-journal-native-count-v4/analysis.json'),'Health':('/tmp/bendvy-flat-journal-health-v4/batch.c','/tmp/bendvy-joined-ledger-baseline-health-count/analysis.json')}
result={}
for schema,(c,a) in roles.items():
 text=pathlib.Path(c).read_text();analysis=json.load(open(a));sha=hashlib.sha256(text.encode()).hexdigest()
 assert analysis['sourceSHA256']==sha
 lines=text.splitlines();sites=[]
 for x in analysis['activeSites']:
  kind=x.get('staticAllocationKind','')
  if x['operation']!='heap_alloc' or not any(k in kind for k in ('TYPES_POSITION','TYPES_VITALS','CACHE_CACHE')):continue
  n=x['originalLine'];item=dict(x);item['originalContext']='\n'.join(lines[max(0,n-3):n+12]);sites.append(item)
 result[schema]={'originalCSHA256':sha,'scope':'Executed allocation counts; static direct callers are not dynamic stack attribution.','sites':sites}
(OUT/'sites.json').write_text(json.dumps(result,indent=2)+'\n')
