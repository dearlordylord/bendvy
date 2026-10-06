import pathlib,json,hashlib,tarfile
H=pathlib.Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();paths=set()
for pin in json.loads((H/'input-pins.json').read_text()).values():paths.add(pathlib.Path(pin['inputPath']));paths.update(pathlib.Path(p) for p in pin['files'])
for name in ['controls','witness','counted-reads','motion-full65','health-full65','guards']:
 root=pathlib.Path('/tmp/bendvy-unused-row-'+name);paths.update(p for p in root.rglob('*') if p.is_file() and ('guards' not in name or p.name in ['refusal.txt','evidence.json']))
for p in pathlib.Path('/tmp').glob('bendvy-unused-row-*.log'):paths.add(p)
for s in ['motion','health']:paths.update([pathlib.Path('/tmp/bendvy-unused-row-'+s+'.js'),pathlib.Path('/tmp/bendvy-unused-row-'+s+'.js.recipe.json')])
manifest=[]
with tarfile.open(E/'receipts.tar.gz','w:gz') as tar:
 for p in sorted(paths):
  assert p.is_file(),p
  arc=str(p).lstrip('/');tar.add(p,arcname=arc,recursive=False);manifest.append({'path':str(p),'archivePath':arc,'sha256':sha(p),'bytes':p.stat().st_size})
(E/'manifest.json').write_text(json.dumps({'files':manifest,'archiveSHA256':sha(E/'receipts.tar.gz')},indent=2)+'\n');r={'status':'EXACT_UNUSED_PRIVATE_ROW_READS_FINITE_PASS','sourceClosure':'b0fdd6c41be12b34efc79e45edc98225c1b0158a51976b432a1646bfcae9e8f0','recipeSHA256':sha(H/'rewrite.cjs'),'catalogSHA256':sha(H/'input-pins.json'),'scope':'No allocation/speed/general-DCE/universal-alias/adoption claim','receipts':{name:json.load(open('/tmp/bendvy-unused-row-'+name+'/evidence.json')) for name in ['controls','witness','counted-reads','motion-full65','health-full65','guards']}};assert r['receipts']['controls']['status']=='FRESH_NINE_WORLDS_BOTH_SCHEMAS_AND_ACTUAL_576_PASS';assert len(r['receipts']['controls']['controllers'])==8;(E/'summary.json').write_text(json.dumps(r,indent=2)+'\n');print(len(manifest),(E/'receipts.tar.gz').stat().st_size)
