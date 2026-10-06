from pathlib import Path
import tarfile,json,hashlib
H=Path(__file__).resolve().parent;O=Path('/tmp/bendvy-slot-host-swap-selective-independent-v1');F=Path('/tmp/bendvy-slot-host-swap-selective-frozen-v1');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r=json.load(open(O/'evidence.json'));assert r['status']=='INDEPENDENT_COMPOSITION_BOTH65_TEN_EDGES_TX576_HELPER130_EXCEPTION6_GUARDS29_BRIDGE4_LIVE6_PASS';assert all(x['exit']==0 for x in r['commands']);assert json.load(open(O/'parent-review.json'))['status']=='INDEPENDENT_TEN_CURRENT_SLOT_PARENTS_PRIOR_ROW_POOL_TUPLE_SOURCE_JOINS_AND_SELECTIVE_REDERIVATION_PASS';assert json.load(open(O/'independent-route.json'))['status']=='INDEPENDENT_CURRENT_SLOT_FIVE_FUNCTION_STATIC_ROUTE_AND_EIGHT_LIVE_COUNTER_MATRICES_PASS';entries={str(p.relative_to(O)):p for p in O.rglob('*')if p.is_file()and p.suffix in ['.json','.txt','.js','.mjs']};entries.update({'freeze/'+str(p.relative_to(F)):p for p in F.rglob('*')if p.is_file()});S=F/'recipe/selective';entries.update({'selective-parent-freeze/'+str(p.relative_to(S)):p for p in S.rglob('*')if p.is_file()})
for s in ['motion','health']:entries['producer-counts/'+s+'.json']=Path(f'/tmp/bendvy-slot-host-swap-selective-{s}-count/evidence.json')
entries['history/first-enrollment-failed.txt']=Path('/tmp/bendvy-js-profile-followup/experiments/s-prep/js-profile-followup/slot-host-swap-selective/enrollment-attempt-v1.txt')
out=H/'review-evidence.tar.gz'
with tarfile.open(out,'w:gz')as t:
 for n,p in sorted(entries.items()):t.add(p,arcname=n,recursive=False)
pins={n:sha(p)for n,p in entries.items()}
with tarfile.open(out)as t:assert {m.name:hashlib.sha256(t.extractfile(m).read()).hexdigest()for m in t.getmembers()}==pins
(H/'manifest.json').write_text(json.dumps({'status':'INDEPENDENT_CURRENT_SLOT_SELECTIVE_POSITIONED_SWAP_FINITE_REVIEW_PASS','archiveSHA256':sha(out),'decodedSHA256Verified':True,'freeze':r['freeze'],'members':pins,'recipePins':{str(p.relative_to(H)):sha(p)for p in (H/'recipe').rglob('*')if p.is_file()}},indent=2)+'\n');print(len(pins),out.stat().st_size)
