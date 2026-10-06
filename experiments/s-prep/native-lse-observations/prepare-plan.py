#!/usr/bin/env python3
"""Prospective exact same-C flags enrollment. Does not execute children."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
p=argparse.ArgumentParser();p.add_argument('--catalog',type=Path,action='append',required=True);p.add_argument('--review',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();assert not a.output.exists()
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
pins={}
def pin(path,expected=None):
 path=Path(path).resolve();h=sha(path)
 if expected is not None:assert h==expected,('drift',str(path))
 assert str(path) not in pins or pins[str(path)]==h;pins[str(path)]=h;return h
review=json.loads(a.review.read_text());assert review['status']=='ADMITTED_PROSPECTIVE_PLAN'
assert review['observerSHA256']==sha(HERE/'observe.py')
assert review['catalogPins']=={str(x.resolve()):sha(x) for x in a.catalog}
pin(a.review)
for path in [__file__,HERE/'observe.py',HERE/'summarize.py']:pin(path)
schemas={}
for path in a.catalog:
 pin(path);c=json.loads(path.read_text());schema=c['schema'];assert schema in ['Motion','Health'] and schema not in schemas
 # Caller supplies the actual fresh verified enrollment; every referenced byte is checked now and after execution.
 assert c['scope']=='SAME_C_LSE_DENSE1024_ENROLLMENT'
 assert c['count']==1024 and c['batch']==64 and c['iterations']==64
 assert c['defaultFlags']==['-O3'] and c['lseFlags']==['-O3','-march=armv8-a+lse']
 assert c['hwcapAtomics'] is True
 for path,h in c['pins'].items():pin(path,h)
 for key in ['sourceRoot','sourceClosure','defaultBuild','lseBuild','hardwareReceipt','jsFreeze','admission','jsProgram','defaultNative','lseNative','defaultC','lseC']:
  assert key in c
 assert sha(c['defaultC'])==sha(c['lseC'])==c['cSHA256']
 assert c['defaultNative']!=c['lseNative']
 assert all(str(Path(c[k]).resolve()) in pins for k in ['defaultBuild','lseBuild','hardwareReceipt','jsFreeze','admission','jsProgram','defaultNative','lseNative','defaultC','lseC'])
 b=json.loads(Path(c['defaultBuild']).read_text());assert b['status']=='BUILD_PASS' and b['schema']==schema
 assert len(b['sourcePins'])==29
 l=json.loads(Path(c['lseBuild']).read_text());assert l['status']=='BOTH_UNCHANGED_C_LSE_BUILD_AND_ELF_INSPECTION_PASS' and l['toolsStableBeforeAfter']
 subject=l['subjects'][schema];assert subject['bytesStableAfterBuild']
 assert subject['sourceRoot']==c['sourceRoot'] and subject['sourceClosure']==c['sourceClosure'] and subject['source29']==b['sourcePins']
 assert subject['inputC']==c['defaultC'] and subject['inputCSHA256']==c['cSHA256']
 assert subject['baselineNative']==c['defaultNative'] and subject['native']==c['lseNative']
 pin(c['defaultNative'],subject['baselineNativeSHA256']);pin(c['lseNative'],subject['nativeSHA256'])
 assert subject['inputBuildSHA256']==sha(c['defaultBuild'])
 assert subject['flags']==['-O3','-march=armv8-a+lse','-lm','-pthread']
 assert l['hostBefore']==l['hostAfter'] and l['hostBefore']['HWCAP_ATOMICS'] is True
 compiler='/tmp/bendvy-clang19-diagnostic/clang19'
 expected=[compiler,'-O3','-march=armv8-a+lse',c['defaultC'],'-o',c['lseNative'],'-lm','-pthread']
 assert sum(x['argv']==expected and x['exit']==0 for x in l['commands'])==1
 default=[x['argv'] for x in b['commands'] if '-O3' in x['argv'] and c['defaultC'] in x['argv']]
 assert len(default)==1 and '-march=armv8-a+lse' not in default[0]
 assert not any(x.startswith('-march') or x in ['-O2','-Os','-Ofast'] for x in default[0])
 
 for rel,h in b['sourcePins'].items():pin(Path(c['sourceRoot'])/rel,h)
 manifest=json.loads((Path(c['sourceRoot'])/'overlay.json').read_text());cache=json.loads((Path(c['sourceRoot'])/'cache-specialization.json').read_text());assert manifest['cacheSpecialization']==cache
 assert cache['runtimeClosure']==cache['specializedClosure']==b['sourcePins']
 assert cache['runtimeClosureSHA256']==cache['specializedClosureSHA256']==c['sourceClosure']
 pin(Path(c['sourceRoot'])/'overlay.json');pin(Path(c['sourceRoot'])/'cache-specialization.json')
 f=json.loads(Path(c['jsFreeze']).read_text());assert f['sourceRoot']==c['sourceRoot'] and f['sourceClosure']==c['sourceClosure'] and f['sourcePins']==b['sourcePins']
 for key in ['normalConsumedFiles','currentReceipts']:
  assert f[key]
  for name,h in f[key].items():pin(name,h)
 assert f['schemaPrograms'][schema.lower()]==c['jsProgram']
 assert c['actualFull65Receipts']
 for name,h in c['actualFull65Receipts'].items():pin(name,h)
 # Libraries, compiler, prospective include and hardware bytes are explicit required groups, not inferred from an old build.
 for key in ['toolPins','headerPins','libraryPins','hardwarePins']:
  assert c[key]
  for name,h in c[key].items():pin(name,h)
 roles=[{'name':'baseline-JS','argv':['node',c['jsProgram']]},{'name':'baseline-Native','argv':[c['defaultNative'],'--threads','1','--gpu','off']},{'name':'handoff-JS','argv':['node',c['jsProgram']]},{'name':'lse-Native','argv':[c['lseNative'],'--threads','1','--gpu','off']}]
 schemas[schema]={'roles':roles,'sourceClosure':c['sourceClosure'],'catalog':str(path.resolve()),'sameJSMeaning':'Both JS roles intentionally execute the identical current guarded program; only Native compiler flags differ.'}
assert set(schemas)=={'Motion','Health'}
plan={'scope':'RAW_SAME_C_LSE_DENSE1024_DIAGNOSTIC','count':1024,'batch':64,'iterations':64,'observerSHA256':sha(HERE/'observe.py'),'schemas':schemas,'pins':dict(sorted(pins.items())),'reviewAdmission':{'status':review['status'],'path':str(a.review.resolve()),'sha256':sha(a.review)},'order':'ten fixed rotations: five shifts then five reversed shifts','claimLimit':'Raw diagnostic only; no canonical allowance/reset/keep, qualification, full22 or product acceptance'}
a.output.write_text(json.dumps(plan,indent=2)+'\n');print('PROSPECTIVE_SAME_C_LSE_PLAN_PREPARED',sha(a.output))
