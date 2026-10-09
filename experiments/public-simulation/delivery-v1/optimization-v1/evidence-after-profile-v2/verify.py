"""No-child lossless whole-output profile packet verification."""
import gzip,hashlib,json
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def verify():
 m=json.loads((H/'MANIFEST.json').read_bytes());raw={}
 for x in m['members']:
  p=H/x['archive'];assert p.is_file() and not p.is_symlink();b=p.read_bytes();assert sha(b)==x['archiveSHA256'];b=gzip.decompress(b);assert len(b)==x['bytes'] and sha(b)==x['sha256'];raw[x['source']]=b
 assert {str(p.relative_to(H))for p in(H/'archive').iterdir()}=={x['archive']for x in m['members']}
 pp='/tmp/bendvy63-named-loop-after-profile-plan-v2.json';assert sha(raw[pp])==m['planSHA256']=='7777067c82ace897e4a3159009111111370f8d8032d7912c6cb5877c88807e3f'
 p=json.loads(raw[pp]);root=p['outputRoot'];r=json.loads(raw[root+'/receipt.json']);assert r['planSHA256']==m['planSHA256'] and not r.get('error') and not r.get('guardFailures');assert len(r['commands'])==2 and len(r['guards'])==9 and len(r['probes'])==48
 for wanted,actual in zip(p['commands'],r['commands']):
  assert wanted['argv']==actual['argv'] and wanted['label']==actual['label'] and actual['capSeconds']==5 and actual['exit']==0 and actual['failure']is None
  for stream in ['stdout','stderr']:
   b=raw[root+'/'+actual['label']+'.'+stream];v=actual[stream];assert sha(b)==v['sha256'] and b.hex()==v['rawHex'] and len(b)==v['bytes']
  assert raw[root+'/'+actual['label']+'.stdout']==raw['/tmp/bendvy63-named-loop-qualification-v1/JS-run.stdout'] and raw[root+'/'+actual['label']+'.stderr']==b''
 for v in r['guards']:
  b=raw[v['path']];assert sha(b)==v['sha256'];g=json.loads(b);assert g['unchanged']is True
  assert all(g['actualPins'][k]==v for k,v in p['pins'].items())
  for k,v in g['stagePins'].items():assert sha(raw[p['stageRoot']+'/'+k])==v
  for k,v in g['rawPins'].items():assert sha(raw[root+'/'+k])==v
 for k,v in r['generated'].items():assert sha(raw[root+'/'+k])==v
 for k,v in p['pins'].items():
  if k in raw:assert sha(raw[k])==v
 cpu=json.loads(raw[root+'/simulation.cpuprofile']);heap=json.loads(raw[root+'/simulation.heapprofile']);assert type(cpu)is dict and cpu['nodes'] and len(cpu['samples'])==len(cpu['timeDeltas']);assert type(heap)is dict and type(heap['head'])is dict and type(heap['samples'])is list
 analysis=json.loads((H/'PROFILE-ANALYSIS.json').read_bytes());assert analysis['cpuSamples']==len(cpu['samples']) and analysis['cpuSampleWeightUs']==sum(cpu['timeDeltas']) and analysis['cpuSpanUs']==cpu['endTime']-cpu['startTime'];assert analysis['heapSamples']==len(heap['samples']) and analysis['heapEstimatedSampleBytes']==sum(v['size']for v in heap['samples'])
 for name,digest in analysis['profileFiles'].items():assert sha(raw[root+'/'+name])==digest
 print(json.dumps(dict(members=len(raw),commands=2,guards=9,probes=48,wholeOutputAndProfiles='PASS',newChildren=0,performanceVerdict=False)))
if __name__=='__main__':verify()
