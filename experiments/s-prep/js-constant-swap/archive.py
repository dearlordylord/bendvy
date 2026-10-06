#!/usr/bin/env python3
import pathlib,json,hashlib,tarfile
H=pathlib.Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=True);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();paths=set()
for pin in json.loads((H/'input-pins.json').read_text()).values():
 paths.update(pathlib.Path(p) for p in pin['files']);paths.add(pathlib.Path(pin['inputPath']))
for name in ['controls-frozen','witness','guards-frozen','motion-full65','health-full65']:
 p=pathlib.Path('/tmp/bendvy-constant-swap-'+name)
 if p.is_dir():paths.update(x for x in p.rglob('*') if x.is_file() and ('guards' not in name or x.name in ['evidence.json','refusal.txt']))
for p in pathlib.Path('/tmp').glob('bendvy-constant-swap-*.log'):paths.add(p)
for name in ['controls-v1','controls-v2','controls-v3','controls-v4','controls-final','guards-v2','guards-v3']:
 p=pathlib.Path('/tmp/bendvy-constant-swap-'+name)/'evidence.json'
 if p.exists():paths.add(p)
manifest=[]
with tarfile.open(E/'receipts.tar.gz','w:gz') as tar:
 for p in sorted(paths):
  if not p.is_file():continue
  arc=str(p).lstrip('/');tar.add(p,arcname=arc,recursive=False);manifest.append({'path':str(p),'archivePath':arc,'sha256':sha(p),'bytes':p.stat().st_size})
(E/'manifest.json').write_text(json.dumps({'files':manifest,'archiveSHA256':sha(E/'receipts.tar.gz')},indent=2)+'\n')
status={'status':'BOUNDED_CONSTANT_SWAP_FINITE_PASS','sourceClosure':'bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94','normalFull65':[json.load(open('/tmp/bendvy-constant-swap-'+s+'-full65/evidence.json')) for s in ['motion','health']],'countsAndActualControllers':json.load(open('/tmp/bendvy-constant-swap-controls-frozen/evidence.json')),'retainedWitness':json.load(open('/tmp/bendvy-constant-swap-witness/evidence.json')),'refusalsAndOrder':json.load(open('/tmp/bendvy-constant-swap-guards-frozen/evidence.json')),'recipeSHA256':sha(H/'rewrite.cjs'),'catalogSHA256':sha(H/'input-pins.json'),'scope':'Generated-JS closed-program causal probe only; no physical-heap/speed/adoption or universal refinement claim'}
(E/'status.json').write_text(json.dumps(status,indent=2)+'\n');print(len(manifest),(E/'receipts.tar.gz').stat().st_size)
