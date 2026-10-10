"""Unweighted CPU samples and sampled heap bytes; no region/cause inference."""
import collections,json

def analyze(cpu,heap,source_url):
 nodes={n['id']:n for n in cpu['nodes']};parent={c:n['id'] for n in cpu['nodes'] for c in n.get('children',[])}
 counts=collections.Counter(cpu['samples']);inclusive=collections.Counter()
 for node,count in counts.items():
  seen=set()
  while node in nodes:
   if node in seen:raise ValueError('CPU parent cycle')
   seen.add(node);inclusive[node]+=count;node=parent.get(node)
 def ranked(values,table):return [{'countOrSampledBytes':count,'frame':table[node]['callFrame'],'nodeId':node} for node,count in values.most_common(30)]
 hn={};hp={}
 def visit(n,parent=None):
  if n['id'] in hn:raise ValueError('Heap duplicate node')
  hn[n['id']]=n;hp[n['id']]=parent
  for c in n.get('children',[]):visit(c,n['id'])
 visit(heap['head']);hs=collections.Counter();hi=collections.Counter()
 for sample in heap['samples']:
  node=sample['nodeId'];size=sample['size']
  if node not in hn or type(size)is not int or size<0:raise ValueError('Invalid heap sample')
  hs[node]+=size
  while node is not None:hi[node]+=size;node=hp[node]
 generated=sum(c for n,c in counts.items() if nodes[n]['callFrame']['url']==source_url)
 return dict(scope='Whole Node process only; unweighted CPU sample counts and sampled heap bytes, not measured IO-region CPU, total allocation, RSS, causal attribution or speedup',
  cpu=dict(samples=len(cpu['samples']),generatedArtifactLeafSamples=generated,otherLeafSamples=len(cpu['samples'])-generated,selfTop30=ranked(counts,nodes),inclusiveTop30=ranked(inclusive,nodes)),
  heap=dict(samples=len(heap['samples']),sampledBytes=sum(hs.values()),selfTop30=ranked(hs,hn),inclusiveTop30=ranked(hi,hn)),
  conclusion='The short single process contains substantial Node startup samples. Generated evaluator/ECS/observation frames coexist; sample counts alone cannot isolate serialization versus ECS or explain the paired elapsed ratio. No optimization or workload subtraction is selected.')
