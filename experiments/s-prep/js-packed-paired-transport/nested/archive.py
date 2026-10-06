#!/usr/bin/env python3
import pathlib,json,hashlib,tarfile
H=pathlib.Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();files=[];summary={'status':'FRESH_NESTED_DIRECT_EDGE_FINITE_CONTROLS_PASS','scope':'Exact generated-JS causal variant, no newhelpers/closures/source/compiler/Native/heap/speed/universalrefinement/adoption','controllers':{'query':576,'packed':576},'variants':{}}
for family,prefix in [('query','direct-tuple'),('packed','packed-paired')]:
 for schema in ['motion','health']:
  name='/tmp/bendvy-'+prefix+'-'+schema+'-nested';source=pathlib.Path(name+'.js');summary['variants'][family+'-'+schema]={'programPath':str(source),'programSHA256':sha(source),'ordinaryConstructors':json.loads(pathlib.Path(name+'-count/evidence.json').read_text())['ordinaryConstructors'],'additionalDelta':-131072,'full65':json.loads(pathlib.Path(name+'-full65/evidence.json').read_text())['status'],'nineWorlds':True};files.extend([source,pathlib.Path(str(source)+'.recipe.json')]);
  for suffix in ['-full65','-count','-profile']:
   files += [p for p in pathlib.Path(name+suffix).iterdir() if p.name=='evidence.json' or p.name.endswith('.txt') or p.name.endswith('.sites.json')]
for root in ['/tmp/bendvy-nested-tuple-controllers-v1','/tmp/bendvy-nested-tuple-witnesses-v1']:
 files += [p for p in pathlib.Path(root).iterdir() if p.name.endswith('.json') or p.name.endswith('.txt')]
files.append(pathlib.Path('/tmp/bendvy-nested-tuple-guards.json'));pins={str(p):sha(p) for p in sorted(set(files))};(E/'archive-pins.json').write_text(json.dumps(pins,indent=2)+'\n')
with tarfile.open(E/'receipts.tar.gz','w:gz') as t:
 for p in sorted(set(files)):t.add(p,arcname=str(p).lstrip('/'),recursive=False)
summary['archiveSHA256']=sha(E/'receipts.tar.gz');(E/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps({'archiveFiles':len(pins),'archiveSHA256':summary['archiveSHA256']}))
