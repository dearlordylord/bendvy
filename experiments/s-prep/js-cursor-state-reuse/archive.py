import pathlib,json,hashlib,tarfile
H=pathlib.Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=True);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();paths=set()
for pin in json.loads((H/'input-pins.json').read_text()).values():paths.update(pathlib.Path(p) for p in pin['files']);paths.add(pathlib.Path(pin['inputPath']))
for name in ['counts','motion-full65','health-full65','query-witness-v2','guards-v2','mutants']:
 p=pathlib.Path('/tmp/bendvy-cursor-state-'+name)
 if p.exists():paths.update(x for x in p.rglob('*') if x.is_file() and ('guards' not in name or x.name in ['evidence.json','refusal.txt']))
for p in pathlib.Path('/tmp').glob('bendvy-cursor-state-*.log'):paths.add(p)
p=pathlib.Path('/tmp/bendvy-cursor-state-query-witness/evidence.json');paths.add(p)
for schema in ['motion','health']:paths.update([pathlib.Path('/tmp/bendvy-cursor-state-'+schema+'.js'),pathlib.Path('/tmp/bendvy-cursor-state-'+schema+'.js.recipe.json')])
manifest=[]
with tarfile.open(E/'receipts.tar.gz','w:gz') as tar:
 for p in sorted(paths):
  if not p.is_file():continue
  arc=str(p).lstrip('/');tar.add(p,arcname=arc,recursive=False);manifest.append({'path':str(p),'archivePath':arc,'sha256':sha(p),'bytes':p.stat().st_size})
(E/'manifest.json').write_text(json.dumps({'files':manifest,'archiveSHA256':sha(E/'receipts.tar.gz')},indent=2)+'\n');r={'status':'MECHANISM_ONLY_FINITE_PASS_WITH_NEW_CONTROLLER_AND_GENERIC_GATES_OPEN','sourceClosure':'bdf6b2fc46d2a89615d0e9eb48d44f4a3e8c8f2ff5b8268d7ca50463e6bfbe94','recipeSHA256':sha(H/'rewrite.cjs'),'catalogSHA256':sha(H/'input-pins.json'),'evidence':{n:json.load(open('/tmp/bendvy-cursor-state-'+n+'/evidence.json')) for n in ['counts','motion-full65','health-full65','query-witness-v2','guards-v2','mutants']},'open':['Fresh enumeration/controller integration; existing supplied-ID576 does not exercise this route','Fresh nonidentity generic/fallback runtime exposure','Physical heap and speed evidence; no adoption']};(E/'status.json').write_text(json.dumps(r,indent=2)+'\n');print(len(manifest),(E/'receipts.tar.gz').stat().st_size)
