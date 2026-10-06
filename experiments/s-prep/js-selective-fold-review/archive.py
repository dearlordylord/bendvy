#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,tarfile
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();e=json.loads((a.input/'evidence.json').read_text());assert e['status']=='INDEPENDENT_BOTH65_HELPER130_TX576_AND32_GUARD_REFUSALS_PASS';assert json.loads((a.input/'chain-review.json').read_text())['status']=='INDEPENDENT_TEN_EXACT_PRIOR_CHAIN_JOINS_CURRENT_RECIPES_CATALOGS_SOURCE_PASS';assert json.loads((a.input/'structural.json').read_text())['status']=='INDEPENDENT_ALL17_RHS_EXACT_ORDER_SEVEN_STORES_ORIGINALS_AND_FOUR_MUTATION_REFUSALS_PASS'
for c in e['commands']:
 assert c['exit']==0
cat=json.loads((H/'recipe/input-pins.json').read_text());w=json.loads((a.input/'helper-witness/evidence.json').read_text());assert len(w['cases'])==4
for c in w['cases']:
 expected=e['freeze'][c['schema']+'.js'] if c['role']=='candidate' else next(k for k,v in cat.items() if v['label']==c['schema']);assert c['programSHA']==expected
for schema in ['motion','health']:
 assert sha(a.input/(schema+'.js'))==e['freeze'][schema+'.js'];g=json.loads((a.input/(schema+'-guards/evidence.json')).read_text());t=json.loads((a.input/(schema+'-guards/transport-evidence.json')).read_text());assert len(g['refusals'])==12 and len(t['flowRefusals'])==4
entries={}
for f in a.input.rglob('*'):
 if f.is_file() and f.suffix in ['.json','.txt','.mjs']:entries[str(f.relative_to(a.input))]=f
for schema in ['motion','health']:entries[schema+'.js']=a.input/(schema+'.js')
entries['freeze.json']=Path('/tmp/bendvy-followup-selective-frozen-v1/freeze.json')
out=H/'review-evidence.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,f in sorted(entries.items()):t.add(f,arcname=n,recursive=False)
pins={n:sha(f) for n,f in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers()}==pins
(H/'manifest.json').write_text(json.dumps({'status':'INDEPENDENT_SELECTIVE_FOLD_FINITE_REVIEW_PASS','scope':e['scope'],'archiveSHA256':sha(out),'decodedSHA256Verified':True,'freeze':e['freeze'],'recipeCopies':{p.name:sha(p) for p in (H/'recipe').iterdir() if p.is_file()},'members':pins},indent=2)+'\n');print(len(pins),out.stat().st_size)
