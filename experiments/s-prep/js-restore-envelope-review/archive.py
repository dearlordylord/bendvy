#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,tarfile
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r=json.loads((a.input/'evidence.json').read_text());assert r['status']=='INDEPENDENT_BOTH65_HELPER130_TX576_EXCEPTION31_GUARDS32_AND_SIX_MUTANTS_PASS';s=json.loads((a.input/'structural.json').read_text());assert s['status']=='INDEPENDENT_CONSTRUCTOR_LOCAL_MAIN_ALL17_RHS_LATE_LEDGER_FRESH_FOLD_NOESCAPE_PASS';assert json.loads((a.input/'chain-review.json').read_text())['status']=='INDEPENDENT_TEN_EXACT_PRIOR_CHAIN_JOINS_CURRENT_RECIPES_CATALOGS_SOURCE_PASS';assert all(c['exit']==0 for c in r['commands']);entries={}
for f in a.input.rglob('*'):
 if f.is_file() and f.suffix in ['.json','.txt','.mjs']:entries[str(f.relative_to(a.input))]=f
for schema in ['motion','health']:
 assert sha(a.input/(schema+'.js'))==r['freeze'][schema+'.js'];entries[schema+'.js']=a.input/(schema+'.js')
 route=json.loads((a.input/('exceptions/'+schema+'-candidate.js.route.json')).read_text());assert route['candidate'] and route['inputCandidate'] and route['selectedReturned']=='__restore_envelope_4';program=a.input/'exceptions'/(schema+'-candidate.js');text=program.read_text();assert 'function __restore_envelope_4(' in text and '__returnedCount++' in text and '__returnedCount,1' in text
 entries['exceptions/'+schema+'-candidate.js']=program
 # Preserve wrong-route receipt history explicitly; no passing claim is transferred.
for label,d in [('wrong-route-v1',Path('/tmp/bendvy-restore-envelope-exceptions')),('wrong-route-v2',Path('/tmp/bendvy-restore-envelope-exceptions-v2')),('first-early-ledger-failed',Path('/tmp/bendvy-restore-envelope-mutants'))]:
 if d.exists():
  for f in d.rglob('*'):
   if f.is_file() and (f.suffix in ['.json','.txt'] or f.name in ['motion-candidate.js','health-candidate.js']):entries['history/'+label+'/'+str(f.relative_to(d))]=f
entries['freeze.json']=Path('/tmp/bendvy-restore-envelope-frozen-v1/freeze.json');out=H/'review-evidence.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,f in sorted(entries.items()):t.add(f,arcname=n,recursive=False)
pins={n:sha(f) for n,f in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers()}==pins
(H/'manifest.json').write_text(json.dumps({'status':'INDEPENDENT_FOUR_ENVELOPE_FINITE_REVIEW_PASS','scope':r['scope'],'archiveSHA256':sha(out),'decodedSHA256Verified':True,'freeze':r['freeze'],'reviewHelperPins':{p.name:sha(p) for p in (H/'recipe').iterdir() if p.is_file()},'members':pins},indent=2)+'\n');print(len(pins),out.stat().st_size)
