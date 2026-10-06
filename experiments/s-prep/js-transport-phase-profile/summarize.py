#!/usr/bin/env python3
"""Execution-bracket CPU samples; GC trace attribution is approximate."""
import argparse,collections,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);a=p.parse_args();e=json.loads((a.directory/'evidence.json').read_text());result={}
for role in ['JS','TS']:
 d=json.loads((a.directory/(role+'.cpuprofile')).read_text());nodes={n['id']:n for n in d['nodes']};start,end=e['marks'][role];lo,hi=start['micro'],end['micro'];assert d['startTime']<=lo<hi<=d['endTime'];now=d['startTime'];counts=collections.Counter()
 for ident,dt in zip(d['samples'],d['timeDeltas']):
  old=now;now+=dt;overlap=max(0,min(now,hi)-max(old,lo));counts[ident]+=overlap
 total=sum(counts.values());assert total>0
 def name(n):
  text=nodes[n]['callFrame']['functionName'];return re.sub(r'\$(\d{3})',lambda m:chr(int(m[1])),text).strip('$')
 top=[{'function':name(i),'milliseconds':v/1000,'selfPercent':100*v/total,'file':nodes[i]['callFrame']['url'],'line':nodes[i]['callFrame']['lineNumber']+1} for i,v in counts.most_common(18)]
 gc=[]
 for line in (a.directory/(role+'.raw.txt')).read_text().splitlines():
  m=re.match(r'\[.*?\]\s+(\d+) ms: (.*)',line)
  if m and start['uptimeMS']<=int(m[1])<=end['uptimeMS']:
   fields=dict(re.findall(r'(\w+)=([^ ]+)',m[2]));gc.append({'atMS':int(m[1]),'pauseMS':float(fields['pause']),'allocatedSincePreviousGC':int(fields.get('allocated',0)),'gc':fields['gc']})
 result[role]={'profileBracketMS':(hi-lo)/1000,'sampledOverlapMS':total/1000,'gcSelfPercent':100*sum(v for i,v in counts.items() if name(i)=='(garbage collector)')/total,'topSelf':top,'approximateGC':{'events':len(gc),'pauseMS':sum(x['pauseMS'] for x in gc),'allocatedSincePriorEventsBytes':sum(x['allocatedSincePreviousGC'] for x in gc),'limits':'GC event timestamps have millisecond resolution; allocation intervals can straddle bracket boundaries; profiler perturbs execution.'}}
(a.directory/'summary.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))

if e.get('gcTracing') is False:
 for role in result:
  result[role]['approximateGC']={'status':'UNAVAILABLE_GC_TRACING_DISABLED','limits':'CPU GC self samples remain available; no event count, pause or allocation traffic estimate was collected.'}
 (a.directory/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
