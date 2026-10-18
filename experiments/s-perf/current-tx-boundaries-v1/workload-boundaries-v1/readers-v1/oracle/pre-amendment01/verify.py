"""Portable retained Readers boundary gold/source verifier; no subject execution."""
from pathlib import Path
import gzip,json,hashlib
P=Path(__file__).parent;sha=lambda b:hashlib.sha256(b).hexdigest()
b=json.loads((P/'SOURCE-BASIS.json').read_text());r=json.loads((P/'GENERATION-RECEIPT.json').read_text())
assert sha((P/'model.py').read_bytes())==r['modelSHA256']and sha((P/'SOURCE-BASIS.json').read_bytes())==r['sourceBasisSHA256']
for pin in b['sourcePins']:assert sha((P/pin['copy']).read_bytes())==pin['sha256']
raw=(P/'expected.boundaries.json').read_bytes();packed=(P/'expected.stdout.gz').read_bytes();assert gzip.decompress(packed)==raw
assert(len(raw),sha(raw),len(packed),sha(packed))==(r['bytes'],r['sha256'],r['gzipBytes'],r['gzipSHA256'])
values=json.loads(raw);assert len(values)==277 and raw.endswith(b'\n');domain=values[:193];reader=values[193:]
assert all(x['group']=='domain'for x in domain)and all(x['group']=='reader'for x in reader)
assert [x['ordinal']for x in domain]==list(range(193))and [x['ordinal']for x in reader]==list(range(84))
assert [x['kind']for x in domain]==['Seed']+['Spawn','Update','Dispose']*64
assert all(x['cursor']is None and x['committed']and x['tx']['consistent']and x['tx']['appendTick']is None for x in values)
assert all(x['tx']['terminal']==[0,0,0]and not x['tx']['boundaries']and x['tx']['beginTick']==x['tx']['endTick']for x in reader)
assert [x['phase']for x in reader[:2]]==[0,0]and [x['iteration']for x in reader[-2:]]==[64,64]
assert all(x['tx']['returnedWorld']['namespace']==1 and x['tx']['returnedWorld']['tick']==x['tx']['endTick']for x in values)
q=b['qualifiedCanonical'];canonical=gzip.decompress((P/q['copy']).read_bytes());assert canonical==gzip.decompress((P/'canonical-control.stdout.gz').read_bytes())
assert(len(canonical),sha(canonical))==(10810200,'183936740ad2407530099198388cc87d872b121fa0681a3a7777ec42797b83ce')
print('PASS: exact currentcanonical;277finish reports grouped193domain+84reader; source/model/gold pins; no rawdiscard or invented cursor')
