#!/usr/bin/env python3
import json,pathlib,collections,sys
root=pathlib.Path(sys.argv[1]);result={}
for file in sorted(root.glob('*-alloc.json')):
 p=json.loads(file.read_text())['profile'];counts=collections.Counter()
 def walk(n):
  f=n['callFrame'];counts[(f['functionName'],f['url'],f['lineNumber']+1)]+=n['selfSize']
  for c in n['children']:walk(c)
 walk(p['head']);result[file.name]={'estimatedSampledBytes':sum(counts.values()),'topSelfBytes':[{'function':k[0],'url':k[1],'line':k[2],'bytes':v} for k,v in counts.most_common(25)]}
for file in sorted(root.glob('*-cpu.json')):
 p=json.loads(file.read_text())['profile'];nodes={n['id']:n for n in p['nodes']};counts=collections.Counter()
 for id,t in zip(p.get('samples',[]),p.get('timeDeltas',[])):
  f=nodes[id]['callFrame'];counts[(f['functionName'],f['url'],f['lineNumber']+1)]+=t
 result[file.name]={'samples':len(p.get('samples',[])),'topSelfSampleMicroseconds':[{'function':k[0],'url':k[1],'line':k[2],'microseconds':v} for k,v in counts.most_common(25)]}
(root/'analysis.json').write_text(json.dumps(result,indent=2)+'\n')
for name,row in result.items():
 print(name,row.get('estimatedSampledBytes',row.get('samples')))
 for item in list(row.values())[-1][:10]:print(item['function'],item.get('bytes',item.get('microseconds')))
