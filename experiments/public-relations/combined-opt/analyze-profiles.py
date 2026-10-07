from pathlib import Path
import json,re,hashlib,collections
D=Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();out={}
for role in ['baseline','candidate']:
 root=D/'profile-results'/role;receipt=json.loads((root/'receipt.json').read_text());assert receipt['status']=='COMPLETE_CPU_ALLOCATION_DIAGNOSTICS_PASS_NO_VERDICT';rows={}
 for backend in ['JS','TS']:
  heap=root/(backend+'-heap.profile.json');cpu=root/(backend+'-cpu.profile.json');source=(root/(backend+'-heap.mjs')).read_text().splitlines();enclosing=[];current=''
  for line in source:
   m=re.match(r'function (\S+)\(',line)
   if m:current=m[1]
   enclosing.append(current)
  sizes=collections.Counter();closures=0
  def walk(n):
   nonlocal_dummy=None
   frame=n['callFrame'];name=frame['functionName'];line=frame['lineNumber'];owner=enclosing[line] if 0<=line<len(enclosing) and frame['url'].endswith(backend+'-heap.mjs') else '';key=name or ('anonymous@'+owner);sizes[key]+=n.get('selfSize',0)
   for c in n.get('children',[]):walk(c)
  walk(json.loads(heap.read_text())['head']);p=json.loads(cpu.read_text());nodes={n['id']:n for n in p['nodes']};gc=sum(delta for node,delta in zip(p.get('samples',[]),p.get('timeDeltas',[])) if nodes[node]['callFrame']['functionName']=='(garbage collector)')
  project={k:v for k,v in sizes.items() if 'project_cells' in k};rows[backend]={'heapSampledSelfBytes':sum(sizes.values()),'projectCellsSampledSelfBytes':sum(project.values()),'projectCellsAnonymousSelfBytes':sum(v for k,v in project.items() if k.startswith('anonymous@')),'projectCellsBuckets':project,'cpuSampledDurationMs':(p['endTime']-p['startTime'])/1000,'gcCpuSampleMs':gc/1000,'heapSHA256':sha(heap),'cpuSHA256':sha(cpu),'validatedRecordsEach':receipt['runs'][backend+'-heap']['validated_records']}
 out[role]={'receiptSHA256':sha(root/'receipt.json'),'roles':rows}
(D/'profile-analysis.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
