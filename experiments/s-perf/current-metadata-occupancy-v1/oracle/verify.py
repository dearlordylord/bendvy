"""Portable wholetrace/source verification and per-column complete-state peak checks."""
from pathlib import Path
import json,gzip,hashlib
P=Path(__file__).parent;sha=lambda b:hashlib.sha256(b).hexdigest()
b=json.loads((P/'SOURCE-BASIS.json').read_text());r=json.loads((P/'GENERATION-RECEIPT.json').read_text())
assert sha((P/'model.py').read_bytes())==r['modelSHA256']and sha((P/'SOURCE-BASIS.json').read_bytes())==r['sourceBasisSHA256']
for pin in b['sourcePins']:assert sha((P/pin['copy']).read_bytes())==pin['sha256']
raw=(P/'expected.stats.json').read_bytes();packed=(P/'expected.stats.json.gz').read_bytes();assert gzip.decompress(packed)==raw and not raw.endswith(b'\n')
assert(len(raw),sha(raw),len(packed),sha(packed))==(r['bytes'],r['sha256'],r['gzipBytes'],r['gzipSHA256'])
v=json.loads(raw);assert list(v)==['main','aux','flag']and [len(x)for x in v.values()]==[321,23,22]
for name,samples in v.items():
 assert samples[0]=={'site':'empty','snapshot':{'kind':'indexed','values':[1,0],'metadata':{'added':[1,0,0],'changed':[1,0,0],'capacity':1,'depth':0,'exceptional':[0,0,0,0],'populated':0}}}
 for s in samples:
  x=s['snapshot'];assert list(x)==['kind','values','metadata']and x['kind']=='indexed';m=x['metadata'];assert list(m)==['added','changed','capacity','depth','exceptional','populated']
  assert x['values'][0]>0 and x['values'][1]==x['values'][0]-1
  for a in [m['added'],m['changed']]:assert a[0]==m['capacity']==2**m['depth']and a[1]==a[0]-1 and 0<=a[2]<=a[0]
  assert m['exceptional']==[0,0,0,0]and m['populated']==m['added'][2]==m['changed'][2]
  assert s['site']in ['empty','mark','clear_stamp'] # restore is absent in actual commits-only story
 # Independently recompute each flattened field maximum from complete snapshots.
 for field,maximum in r['perColumnCompleteStatePeaks'][name]['fieldMaxima'].items():
  def get(sample):
   value=sample['snapshot']
   for part in field.split('.'):value=value[int(part)]if isinstance(value,list)else value[part]
   return value
  values=[get(s)for s in samples];assert max(values)==maximum
  witness=r['perColumnCompleteStatePeaks'][name]['firstWitnessSample'][field];assert values[witness]==maximum and witness==values.index(maximum)
 assert max(s['snapshot']['metadata']['populated']for s in samples)=={'main':65,'aux':22,'flag':21}[name]
for i in range(64):
 cycle=v['main'][65+4*i:69+4*i];assert [s['site']for s in cycle]==['mark','mark','mark','clear_stamp']
 assert [s['snapshot']['metadata']['populated']for s in cycle]==[65,65,64,64]
 assert cycle[2]['snapshot']==cycle[3]['snapshot']
for n in ['aux','flag']:assert all(s['site']=='mark'for s in v[n][1:])
q=b['qualifiedCanonical'];canonical=gzip.decompress((P/q['copy']).read_bytes());assert canonical==gzip.decompress((P/'canonical-control.stdout.gz').read_bytes())
assert(len(canonical),sha(canonical))==(10810200,'183936740ad2407530099198388cc87d872b121fa0681a3a7777ec42797b83ce')
print('PASS: originalfullcanonical; ordered321/23/22 complete-state snapshots; wholecompactJSON; independent per-column fieldmaxima+witnesses; no Worldaggregate/bytes/unique-node/temporary claim')
