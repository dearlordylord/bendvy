from pathlib import Path
import tarfile,json,hashlib
H=Path(__file__).resolve().parent;O=Path('/tmp/bendvy-swap-firstarg-independent-v1');F=Path('/tmp/bendvy-swap-firstarg-frozen-v1');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r=json.load(open(O/'evidence.json'));assert r['status']=='INDEPENDENT_BOTH65_NINE_EDGES_TX576_HELPER130_TWO_ORDER_29_REFUSALS_FOUR_MUTANTS_PASS';assert all(x['exit']==0 for x in r['commands']);entries={str(p.relative_to(O)):p for p in O.rglob('*') if p.is_file() and p.suffix in ['.json','.txt','.js','.mjs']};entries.update({'freeze/'+str(p.relative_to(F)):p for p in F.rglob('*') if p.is_file()})
for n in ['scope','scope-v2']:
 d=Path('/tmp/bendvy-swap-firstarg-'+n)
 if d.exists():entries.update({'history/'+n+'/'+str(p.relative_to(d)):p for p in d.rglob('*') if p.is_file() and p.suffix in ['.json','.txt','.js','.cjs']})
for schema in ['motion','health']:
 for role in ['legacy','added']:
  p=Path(f'/tmp/bendvy-swap-firstarg-{schema}-{role}-count/evidence.json');entries['producer-counts/'+schema+'-'+role+'.json']=p
out=H/'review-evidence.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,p in sorted(entries.items()):t.add(p,arcname=n,recursive=False)
pins={n:sha(p) for n,p in entries.items()}
with tarfile.open(out) as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest() for m in t.getmembers()}==pins
(H/'manifest.json').write_text(json.dumps({'status':'INDEPENDENT_EXACT_POSITIONED_SWAP_FINITE_REVIEW_PASS','archiveSHA256':sha(out),'decodedSHA256Verified':True,'freeze':r['freeze'],'members':pins,'recipePins':{str(p.relative_to(H)):sha(p) for p in (H/'recipe').rglob('*') if p.is_file()}},indent=2)+'\n');print(len(pins),out.stat().st_size)
