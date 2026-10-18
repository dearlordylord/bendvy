from pathlib import Path
import json,gzip,hashlib,sys
p=Path(sys.argv[1])if len(sys.argv)>1 else Path(__file__).parent
sys.path.insert(0,str(p));import model
sha=lambda x:hashlib.sha256(x).hexdigest();r=json.loads((p/'GENERATION-RECEIPT.json').read_text());basis=json.loads((p/'SOURCE-BASIS.json').read_text());assert r['status']=='PASS' and r['worldReports']==[387,387]
for row in basis['sourcePins']:assert sha((p/row['copy']).read_bytes())==row['sha256']
assert sha((p/'model.py').read_bytes())==r['modelSHA256'];assert sha((p/'operation_model.py').read_bytes())==r['operationModelSHA256'];assert sha((p/'SOURCE-BASIS.json').read_bytes())==r['sourceBasisSHA256'];assert sha((p/'expected.stdout.gz').read_bytes())==r['gzipSHA256'];raw=gzip.decompress((p/'expected.stdout.gz').read_bytes());assert len(raw)==r['bytes'] and sha(raw)==r['sha256'];d=json.loads(raw)
for ns,w in enumerate(d['worlds'],1):assert w['reports']==model.world(ns)
h=hashlib.sha256();n=0
with gzip.open(p/'canonical-control/expected.stdout.gz','rb')as f:
 while chunk:=f.read(1048576):h.update(chunk);n+=len(chunk)
assert (n,h.hexdigest())==(38459780,'28595ef3734a1b4772e43d01b63806120db6c452207c31caaddd3d50cb45e3f0');assert (p/'generation.stderr').read_bytes()==b''
print('PASS independent387+387 complete metrics records, canonical38459780 bytes, boundaryGold',len(raw),sha(raw))
