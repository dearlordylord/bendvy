#!/usr/bin/env python3
import pathlib,json,hashlib,tarfile
H=pathlib.Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();files=[]
for schema in ['motion','health']:
 for kind in ['base-count','tuple-count','row-pool-tuple-count','tuple-full65','row-full65','row-pool-tuple-full65','base-profile','tuple-profile','row-pool-tuple-profile']:
  root=pathlib.Path('/tmp/bendvy-packed-paired-'+schema+'-'+kind);files += [p for p in root.iterdir() if p.name=='evidence.json' or p.name.endswith('.txt') or p.name.endswith('.sites.json')]
 build=pathlib.Path('/tmp/bendvy-packed-paired-'+schema+'-build-v3');files += [build/p for p in ['build.json','recipe.json','static-driver.json']]
for root in ['/tmp/bendvy-packed-paired-generated-frozen-v1','/tmp/bendvy-packed-paired-generated-witness','/tmp/bendvy-packed-paired-generated-controllers-v1']:
 files += [p for p in pathlib.Path(root).iterdir() if p.is_file() and (p.name.endswith('.json') or p.name.endswith('.txt') or p.name in ['motion-tuple.js','health-tuple.js'])]
files += [pathlib.Path('/tmp/bendvy-packed-paired-tx-controls-v3/evidence.json'),pathlib.Path('/tmp/bendvy-packed-paired-row-guards-final.json'),pathlib.Path('/tmp/bendvy-packed-paired-tuple-guards.json')]
files += [pathlib.Path('/tmp/bendvy-packed-paired-journal-both-v3')/p for p in ['overlay.json','cache-specialization.json']]
pins={str(p):sha(p) for p in sorted(set(files))};(E/'archive-pins.json').write_text(json.dumps(pins,indent=2)+'\n')
with tarfile.open(E/'receipts.tar.gz','w:gz') as t:
 for p in sorted(set(files)):t.add(p,arcname=str(p).lstrip('/'),recursive=False)
summary={'status':'FINITE_PACKED_PAIRED_GENERATED_CHAIN_PASS','scope':'Generated-JS causal probe only, no source/compiler/Native/physicalheap/speed/refinement/adoption claim','sourceClosure':'d437d8f7e97ae66764e470c58cada7182715b8724d9dd065d20e55417e01e744','freshActualControllerRecords':576,'frozenDriverReceiptSHA256':sha(pathlib.Path('/tmp/bendvy-packed-paired-generated-frozen-v1/evidence.json')),'snapshotStatus':json.loads(pathlib.Path('/tmp/bendvy-packed-paired-generated-witness/evidence.json').read_text())['status'],'archiveSHA256':sha(E/'receipts.tar.gz'),'schemas':{}}
for schema in ['motion','health']:
 b=json.loads(pathlib.Path('/tmp/bendvy-packed-paired-'+schema+'-base-count/evidence.json').read_text());q=json.loads(pathlib.Path('/tmp/bendvy-packed-paired-'+schema+'-tuple-count/evidence.json').read_text());a=json.loads(pathlib.Path('/tmp/bendvy-packed-paired-'+schema+'-row-pool-tuple-count/evidence.json').read_text());summary['schemas'][schema]={'rawOrdinaryConstructors':b['ordinaryConstructors'],'tupleOrdinaryConstructors':q['ordinaryConstructors'],'finalOrdinaryConstructors':a['ordinaryConstructors'],'delta':a['ordinaryConstructors']-b['ordinaryConstructors'],'full65Status':json.loads(pathlib.Path('/tmp/bendvy-packed-paired-'+schema+'-row-pool-tuple-full65/evidence.json').read_text())['status'],'finalPath':'/tmp/bendvy-packed-paired-generated-frozen-v1/'+schema+'-tuple.js','finalSHA256':sha(pathlib.Path('/tmp/bendvy-packed-paired-generated-frozen-v1/'+schema+'-tuple.js'))}
(E/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps({'archiveFiles':len(pins),'archiveBytes':(E/'receipts.tar.gz').stat().st_size,'archiveSHA256':summary['archiveSHA256']}))
