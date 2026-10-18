from pathlib import Path
import json,gzip,hashlib,sys
p=Path(sys.argv[1])if len(sys.argv)>1 else Path(__file__).parent
sha=lambda x:hashlib.sha256(x).hexdigest();b=json.loads((p/'PILOT-ORACLE-BASIS.json').read_text());s=json.loads((p/'SOURCE-BASIS.json').read_text());assert b['status']=='PASS';assert sha((p/'SOURCE-BASIS.json').read_bytes())==b['sourceBasisSHA256']
for n,h in b['modelPins'].items():assert sha((p/n).read_bytes())==h
for r in s['sourcePins']:assert sha((p/r['copy']).read_bytes())==r['sha256']
for role,r in b['oracles'].items():
 f=p/(role+'-expected.stdout.gz');assert sha(f.read_bytes())==r['gzipSHA256'];h=hashlib.sha256();count=0
 with gzip.open(f,'rb')as stream:
  while chunk:=stream.read(1048576):h.update(chunk);count+=len(chunk)
 assert(count,h.hexdigest())==(r['bytes'],r['sha256'])
fixtures=json.loads(gzip.decompress((p/'observer-fixtures.json.gz').read_bytes()));assert fixtures[0]['tuple']==fixtures[1]['tuple'];assert len(fixtures)==2
for w in fixtures:
 assert len(w['records'])==965 and len(w['tuple'])==3608414 and w['fold']==1350975224 and len(w['rawActorMap'])==256;assert w['counts']=={'callbacks':193,'publications':129,'boundaries':256,'phases':385}
h=hashlib.sha256();count=0
with gzip.open(p/'canonical-control/expected.stdout.gz','rb')as stream:
 while chunk:=stream.read(1048576):h.update(chunk);count+=len(chunk)
assert (count,h.hexdigest())==(38400832,'a20f7dccdf2efd66b44cb4dde507b0f7256ea493c1d3d5935d12f97db0ef5a95')
fold=0
for v in fixtures[0]['tuple']:fold=(fold*33+v)%2**32
assert fold==1350975224
assert (p/'generation.stderr').read_bytes()==b'';print('PASS Health64 full canonical control and complete2world common/Bend/TS gold identities; no subject replay')
