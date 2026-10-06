#!/usr/bin/env python3
import pathlib,json,hashlib,tarfile
H=pathlib.Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();paths=set();summary={'status':'FRESH_DESCENDING_GENERATED_CHAIN_FINITE_CONTROLS_PASS','sourceClosure':'b0fdd6c41be12b34efc79e45edc98225c1b0158a51976b432a1646bfcae9e8f0','scope':'Generated-JS only; no source/Native/compiler/refinement/heap/speed/adoption claim','schemas':{}}
for pin in json.loads((H/'row-input-pins.json').read_text()).values():
 paths.add(pathlib.Path(pin['inputPath']));paths.update(pathlib.Path(p) for p in pin['provenancePins']);root=pathlib.Path(pin['sourceRoot']);paths.update(root/n for n in pin['sourcePins'])
for schema in ['motion','health']:
 for name in ['full65','count']:
  p=pathlib.Path('/tmp/bendvy-descending-generated-'+schema+'-'+name);paths.update(x for x in p.iterdir() if x.is_file())
 program=pathlib.Path('/tmp/bendvy-descending-generated-'+schema+'-nested.js');paths.update([program,pathlib.Path(str(program)+'.recipe.json')]);counts=json.load(open('/tmp/bendvy-descending-generated-'+schema+'-count/evidence.json'));assert counts['status']=='FRESH_EXACT_SOURCE_NINE_WORLDS_PAIR_PASS';before,after=counts['counts'];assert after['ordinaryConstructors']-before['ordinaryConstructors']==-1835520;full=json.load(open('/tmp/bendvy-descending-generated-'+schema+'-full65/evidence.json'));assert full['status']=='PASS_FULL65';summary['schemas'][schema]={'rawOrdinaryConstructors':before['ordinaryConstructors'],'finalOrdinaryConstructors':after['ordinaryConstructors'],'delta':-1835520,'full65':full,'countEvidence':counts,'finalPath':str(program),'finalSHA256':sha(program)}
for name in ['frozen-v1','nested-controllers-v1','witness-v1']:
 p=pathlib.Path('/tmp/bendvy-descending-generated-'+name);paths.update(x for x in p.iterdir() if x.is_file())
for name in ['row','tuple','nested']:paths.add(pathlib.Path('/tmp/bendvy-descending-'+name+'-guards.json'))
paths.add(pathlib.Path('/tmp/bendvy-private-id-query-descending-tx-controls-v1/evidence.json'));source=pathlib.Path('/tmp/bendvy-private-id-query-descending-v1');paths.update(source/x for x in ['overlay.json','cache-specialization.json']);paths.update(pathlib.Path('/tmp').glob('bendvy-descending-generated-*.log'))
summary['firststage']=json.load(open('/tmp/bendvy-descending-generated-frozen-v1/evidence.json'));summary['nestedControllers']=json.load(open('/tmp/bendvy-descending-generated-nested-controllers-v1/evidence.json'));summary['retainedWitness']=json.load(open('/tmp/bendvy-descending-generated-witness-v1/evidence.json'));assert summary['firststage']['actualControllerRecords']==576;assert summary['nestedControllers']['records']==576
manifest=[]
with tarfile.open(E/'receipts.tar.gz','w:gz') as tar:
 for p in sorted(paths):
  assert p.is_file(),p
  arc=str(p).lstrip('/');tar.add(p,arcname=arc,recursive=False);manifest.append({'path':str(p),'archivePath':arc,'sha256':sha(p),'bytes':p.stat().st_size})
(E/'manifest.json').write_text(json.dumps({'files':manifest,'archiveSHA256':sha(E/'receipts.tar.gz')},indent=2)+'\n');summary['archiveSHA256']=sha(E/'receipts.tar.gz');summary['recipes']=json.load(open(H/'unchanged-recipes.json'));summary['catalogs']={str(p.relative_to(H)):sha(p) for p in [H/'row-input-pins.json',H/'input-pins.json',H/'token-pool/input-pins.json',H/'nested/input-pins.json']};(E/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(len(manifest),(E/'receipts.tar.gz').stat().st_size)
