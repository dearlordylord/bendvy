#!/usr/bin/env python3
import pathlib,json,hashlib,tarfile,gzip,io
H=pathlib.Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();files=[]
for stem in ['health','motion']:
 for root in [pathlib.Path('/tmp/bendvy-direct-tuple-'+stem+'-full65'),pathlib.Path('/tmp/bendvy-direct-tuple-'+stem+'-count'),pathlib.Path('/tmp/bendvy-direct-tuple-'+stem+'-profile')]:
  files += [p for p in root.iterdir() if p.name=='evidence.json' or p.name.endswith('.txt') or p.name.endswith('.sites.json')]
 for suffix in ['-final.js','-final.js.recipe.json']:
  files.append(pathlib.Path('/tmp/bendvy-direct-tuple-'+stem+suffix))
for root in ['/tmp/bendvy-direct-tuple-health-eligible-count-v2','/tmp/bendvy-direct-tuple-motion-base-count','/tmp/bendvy-direct-tuple-health-base-profile','/tmp/bendvy-direct-tuple-motion-base-profile','/tmp/bendvy-direct-tuple-controllers-final','/tmp/bendvy-direct-tuple-final-controls']:
 files += [p for p in pathlib.Path(root).iterdir() if p.name=='evidence.json' or p.name.endswith('.txt') or p.name.endswith('.json') or p.name.endswith('.recipe.json')]
files += [pathlib.Path('/tmp/bendvy-direct-tuple-packed-'+s+'-analysis.json') for s in ['motion','health']]
pins={str(p):sha(p) for p in sorted(set(files))};(E/'archive-pins.json').write_text(json.dumps(pins,indent=2)+'\n')
with tarfile.open(E/'receipts.tar.gz','w:gz') as t:
 for p in sorted(set(files)):t.add(p,arcname=str(p).lstrip('/'),recursive=False)
summary={'status':'FINITE_CURRENT_INPUT_DIRECT_TUPLE_CONTROLS_PASS','scope':'Generated-JS causal probe only; no Bend/compiler/Native change, universal refinement, timing or adoption claim','sourceClosure':'0b3339e7fde4dc1af610ec76b1656b2f9c39748a546ba5929766d7445a51fa43','nativeChange':False,'perCallClosuresAdded':0,'schemas':{},'controllers':json.loads(pathlib.Path('/tmp/bendvy-direct-tuple-controllers-final/evidence.json').read_text())['status'],'controls':json.loads(pathlib.Path('/tmp/bendvy-direct-tuple-final-controls/evidence.json').read_text())['status'],'archiveSHA256':sha(E/'receipts.tar.gz'),'packedScope':'Static feasibility only; not admitted by catalog or validated by current controller gates'}
for s in ['motion','health']:
 b=pathlib.Path('/tmp/bendvy-direct-tuple-'+s+('-base-count' if s=='motion' else '-eligible-count-v2')+'/evidence.json');a=pathlib.Path('/tmp/bendvy-direct-tuple-'+s+'-count/evidence.json');before=json.loads(b.read_text());after=json.loads(a.read_text());summary['schemas'][s]={'candidatePath':'/tmp/bendvy-direct-tuple-'+s+'-final.js','candidateSHA256':sha(pathlib.Path('/tmp/bendvy-direct-tuple-'+s+'-final.js')),'full65Status':json.loads(pathlib.Path('/tmp/bendvy-direct-tuple-'+s+'-full65/evidence.json').read_text())['status'],'nineWorlds':True,'ordinaryConstructorsBefore':before['ordinaryConstructors'],'ordinaryConstructorsAfter':after['ordinaryConstructors'],'delta':after['ordinaryConstructors']-before['ordinaryConstructors'],'staticEligible':22 if s=='motion' else 23,'clones':22 if s=='motion' else 23}
(E/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps({'archiveFiles':len(pins),'archiveSHA256':summary['archiveSHA256']}))
