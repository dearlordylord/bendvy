import hashlib,json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((HERE/'SOURCE-COMPARISON.json').read_text())
rows=manifest['files']; mapping={r['original']:r['candidate'] for r in rows}
exceptions={'registered-v1/log.bend','registered-v1/fixture.bend','generic-v1/second-schema.bend'}
for row in rows:
 old,new=Path(row['original']),Path(row['candidate'])
 assert sha(old)==row['originalSHA256'] and sha(new)==row['candidateSHA256']
 expected=old.read_text()
 for a,b in mapping.items():expected=expected.replace(a,b)
 if not any(str(new).endswith(x) for x in exceptions):assert new.read_text()==expected,new
log=(HERE/'source/declaration-read-v1/registered-v1/log.bend').read_text()
old=log[log.index('def scanned_head('):log.index('def scanned_head_by(')]
new=log[log.index('def scanned_head_by('):log.index('def partitioned(')]
for name in ['scanned_head','scan','read_result','read_counted','read_keyed','read']:
 old=re.sub(r'\b'+name+r'\(',name+'_by(',old)
old=old.replace('~at:P -> U32 -> P & U32,~body:@-H:Type -> @-read:Cap.Request<H,U32,U32> -> H -> H & O','~observe:P -> P & O').replace('~at,~body','~observe').replace('Scoped.provide(~P,~O,~observe,payload)','observe(payload)')
assert old==new,'read_by differs beyond observation substitution'
for receipt in (HERE/'source-checks').glob('*.json'):
 r=json.loads(receipt.read_text());assert r['unchangedAfter']
 for k in ['stdout','stderr']:
  f=Path(r[k]['path']);assert sha(f)==r[k]['sha256'] and f.stat().st_size==r[k]['bytes']
 assert r['exit']==(1 if 'negative' in receipt.stem else 0) and r['failure'] is None
print('PASS exact source joins, lookup transformation and source receipts')
