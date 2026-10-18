"""Portable source/fixture/fullstream verifier; no backend or model regeneration."""
from pathlib import Path
import gzip,json,hashlib
from common_model import tuple_records,fold
P=Path(__file__).parent;sha=lambda v:hashlib.sha256(v).hexdigest()
b=json.loads((P/'SOURCE-BASIS.json').read_text());r=json.loads((P/'PILOT-ORACLE-BASIS.json').read_text())
assert sha((P/'SOURCE-BASIS.json').read_bytes())==r['sourceBasisSHA256']
for pin in b['sourcePins']:assert sha((P/pin['copy']).read_bytes())==pin['sha256']
for n,h in r['modelPins'].items():assert sha((P/n).read_bytes())==h
q=b['qualifiedCanonical'];packed=(P/q['copy']).read_bytes();assert sha(packed)==q['gzipSHA256'];raw=gzip.decompress(packed)
assert(len(raw),sha(raw))==(10810200,'183936740ad2407530099198388cc87d872b121fa0681a3a7777ec42797b83ce')
assert raw==gzip.decompress((P/'canonical-control.stdout.gz').read_bytes())
worlds=json.loads(gzip.decompress((P/'observer-fixtures.json.gz').read_bytes()))
for f,s in zip(worlds,r['worlds']):
 assert len(f['records'])==280 and len(f['rawActorMap'])==128
 cells=tuple_records(f['records']);assert cells==f['tuple']and fold(cells)==f['fold']==s['fold']
 kinds=[v['kind']for v in f['records']];assert kinds.count('Read')==84 and kinds.count('Stage')==194 and kinds[0]=='SeedActors'and kinds[-1]=='Final'
 assert [v['actor']for v in f['rawActorMap']]==list(range(1,129))
 assert [(v['index'],v['generation'])for v in f['rawActorMap'][64:]]==[(65,i)for i in range(64)]
 assert all(v['namespace']==f['namespace']for v in f['rawActorMap'])
 raw=gzip.decompress((P/f"canonical-ns{f['namespace']}.stdout.gz").read_bytes());assert(len(raw),sha(raw))==(s['canonical']['bytes'],s['canonical']['sha256'])
assert worlds[0]['tuple']==worlds[1]['tuple']
for f in worlds:
 for record in f['records']:
  if record['kind']=='Read':assert list(record['ping'])==['values','lagged'] and list(record['removed'])==list(record['despawned'])==['values']
for role,out in r['oracles'].items():
 packed=(P/f'{role}-expected.stdout.gz').read_bytes();raw=gzip.decompress(packed)
 assert(len(raw),sha(raw),len(packed),sha(packed))==(out['bytes'],out['sha256'],out['gzipBytes'],out['gzipSHA256'])
 assert raw==(P/f'{role}-expected.stdout').read_bytes()
 for label in [b'WARMUP',b'SAMPLE']:
  segment=raw.split(label+b'\nFORCE:',1)[1];assert segment.index(b'\nTUPLE:')<segment.index(b'\nACTORS:')
 assert b'FOREIGN'not in raw
print('PASS: current independent canonical, both namespace role streams,280 full actual API records and lossless scalar tuples; source/model pins; no backend or private TS cursor claim')
