import pathlib,json,collections,re
out=pathlib.Path('.artifacts/storage30-get-warm-timeline');receipt=json.loads((out/'receipt.json').read_text());summary={'scope':'Single exploratory dense pair, not acceptance','roles':{}}
def category(name):
 for c in ['optimized-compose','component','column','schema','compose']:
  if '$047'+c+'$058' in name or '/'+c+'.' in name or ('$'+c+'$058') in name:return c
 if name=='(garbage collector)':return 'gc'
 if name.startswith('array_'):return 'array-runtime'
 return 'other'
for role,r in receipt['roles'].items():
 p=json.loads((out/(role+'.cpuprofile')).read_text());nodes={n['id']:n for n in p['nodes']};aggregate=collections.Counter();phases={'cold':collections.Counter(),'warm':collections.Counter()};hot=collections.Counter();t=p['startTime'];times=r['audit']['iterationTimes']
 for sid,dt in zip(p['samples'],p['timeDeltas']):
  t+=dt;n=nodes[sid]['callFrame']['functionName'];c=category(n);aggregate[c]+=dt;hot[n]+=dt
  if times[0]['start']<=t<=times[0]['end']:phases['cold'][c]+=dt
  elif any(x['start']<=t<=x['end'] for x in times[1:]):phases['warm'][c]+=dt
 summary['roles'][role]={'firstIterationMicroseconds':times[0]['end']-times[0]['start'],'remaining19TotalMicroseconds':sum(x['end']-x['start'] for x in times[1:]),'aggregateSelfMicroseconds':dict(aggregate),'sampledPhases':{k:dict(v) for k,v in phases.items()},'hotFunctions':hot.most_common(20),'samples':len(p['samples'])}
(out/'summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
