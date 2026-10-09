"""No-child unweighted leaf CPU/sample Heap source diagnostic; no timing inference."""
from pathlib import Path
import gzip,json,hashlib,collections
HERE=Path(__file__).resolve().parent

def read_profile(directory,mode):
 manifest=json.loads((directory/'manifest.json').read_text());key=mode+'/subject.profile.json';raw=gzip.decompress((directory/(key+'.gz')).read_bytes());assert hashlib.sha256(raw).hexdigest()==manifest[key]['sha256'];return json.loads(raw)['profile']
def summarize(directory):
 cpu=read_profile(directory,'cpu');hits=collections.Counter(cpu['samples']);names=collections.Counter();lines={}
 for node in cpu['nodes']:
  frame=node['callFrame'];name=frame['functionName'];names[name]+=hits[node['id']];lines.setdefault(name,collections.Counter())[frame['lineNumber']+1]+=hits[node['id']]
 heap=read_profile(directory,'allocation');allocation=collections.Counter();stack=[heap['head']]
 while stack:
  node=stack.pop();allocation[node['callFrame']['functionName']]+=node['selfSize'];stack.extend(node.get('children',[]))
 return {'cpuSamples':len(cpu['samples']),'cpuNegativeDeltas':sum(x<0 for x in cpu['timeDeltas']),'topCPU':names.most_common(10),'topHeapSelfSize':allocation.most_common(10),'sampledHeapSelfSizeSum':sum(allocation.values()),'serializerCPUSelf':{k:v for k,v in names.items() if 'serialize' in k},'serializerHeapSelfSize':{k:v for k,v in allocation.items() if 'serialize' in k},'anonymousCPUGeneratedLines':lines.get('',{}).most_common(5)}
def main():
 result={'scope':'Same complete depth256/span16, Node100us CPU/Heap1MiB samplers and start region; preserved before only, no baseline rerun. Unweighted leaf CPU counts and sampled weights, not time/totalalloc/RSS/causal claim.','beforeStepNext':summarize(HERE.parent/'next-state-profile-evidence-v1'),'afterDirect':summarize(HERE)}
 print(json.dumps(result,indent=2))
if __name__=='__main__':main()
