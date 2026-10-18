"""Portable retained source/gold checks; no subject or model generation."""
from pathlib import Path
import gzip,json,hashlib
P=Path(__file__).parent;sha=lambda b:hashlib.sha256(b).hexdigest()
r=json.loads((P/'GENERATION-RECEIPT.json').read_text());b=json.loads((P/'SOURCE-BASIS.json').read_text())
assert sha((P/'model.py').read_bytes())==r['modelSHA256']
assert sha((P/'SOURCE-BASIS.json').read_bytes())==r['sourceBasisSHA256']
for x in b['sourcePins']:assert sha((P/x['copy']).read_bytes())==x['sha256']
raw=(P/'expected.boundaries.json').read_bytes();packed=(P/'expected.stdout.gz').read_bytes();assert gzip.decompress(packed)==raw
assert(len(raw),sha(raw),len(packed),sha(packed))==(r['bytes'],r['sha256'],r['gzipBytes'],r['gzipSHA256'])
values=json.loads(raw);assert len(values)==4226 and raw.endswith(b'\n')
counts={}
for s in values:
 counts[s['kind']]=counts.get(s['kind'],0)+1;t=s['observation']['tx'];assert t['consistent']and t['appendTick']is None
 assert t['namespace']==t['returnedWorld']['namespace']and t['endTick']==t['returnedWorld']['tick']
 if s['action']=='unselect':assert s['committed']is None and t['boundaries']==[]and t['terminal']==[0,0,0]
 else:assert s['committed']is True
assert counts=={'main-seed':1,'foreign-seed':1,'Select':4096,'Reserve':64,'Dispose':64}
for start,n in [(2,4096),(4098,64),(4162,64)]:assert [s['ordinal']for s in values[start:start+n]]==list(range(n))
canonical=gzip.decompress((P/'canonical-control.stdout.gz').read_bytes());assert canonical==gzip.decompress((P/b['qualifiedCanonical']['copy']).read_bytes())
assert(len(canonical),sha(canonical))==(3848488,'ff435edc418dbded9b6e76106da002fbe1058f919879f065fb6281c4f58cca05')
print('PASS: independent original LC2 control; 4226 exact grouped samples; empty raw-unselect null outcomes; source/model/gold pins')
