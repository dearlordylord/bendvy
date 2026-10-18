from pathlib import Path
import hashlib,json,gzip,sys
p=Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).parent
sha=lambda x:hashlib.sha256(x).hexdigest();plan=json.loads((p/'GENERATION-PLAN.json').read_text());r=json.loads((p/'GENERATION-RECEIPT.json').read_text());assert r['status']=='PASS' and r['planSHA256']==sha((p/'GENERATION-PLAN.json').read_bytes());assert sha((p/'model.py').read_bytes())=='5d4ef8b23e823a665e3dcc7b9f161f1e962dc448e1978df7c96a66d4e661c537';assert [c['count']for c in r['commands']]==[64,256,1024]
for c in r['commands']:
 d=p/('health1024' if c['count']==1024 else 'controls'+str(c['count']));assert c['exit']==0 and (d/'generation.stderr').read_bytes()==b'';g=d/'expected.stdout.gz';assert sha(g.read_bytes())==c['gzipSHA256'];h=hashlib.sha256();n=0
 with gzip.open(g,'rb') as f:
  while chunk:=f.read(1048576):h.update(chunk);n+=len(chunk)
 assert (n,h.hexdigest())==(c['bytes'],c['sha256'])
 if c['count']in [64,256]:assert c['referenceByteEqual'] is True
b=json.loads((p/'health1024/SOURCE-BASIS.json').read_text());assert b['runtimeArguments']==['1024','64'] and b['generationReceiptSHA256']==sha((p/'GENERATION-RECEIPT.json').read_bytes());assert (b['expectedBytes'],b['expectedSHA256'])==(444047554,'a97b57c6d4df37ecc96e2afe11eeb49770ef8530582046013bd75481afe22f75');print('PASS independent64/256 reproduction receipts and all3 complete retained gzip streams;1024',b['expectedBytes'],b['expectedSHA256'])
