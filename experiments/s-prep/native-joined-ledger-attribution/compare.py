#!/usr/bin/env python3
"""Read-only Health source/count/profile reconciliation; no time acceptance."""
import argparse,pathlib,json,hashlib,collections
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();roots={'baseline':pathlib.Path('/tmp/bendvy-joined-ledger-baseline-health-count'),'joined':pathlib.Path('/tmp/bendvy-joined-ledger-native-health-count')};e={k:json.loads((v/'evidence.json').read_text()) for k,v in roots.items()};closures={'baseline':'bdba8a91c1b56f4961217454139b79dc5c1614ab2301f4dae766a0cd70934bb3','joined':'8cb83bc7467ca8e9b0192b8dadd89d3c143262d37e812079342289be1c0f6e26'};rows=[]
for role,m in e.items():
 assert m['status']=='CALLSITE_COUNTS_FULL65_FIELDS_PASS';assert hashlib.sha256(json.dumps(m['runtimeSources'],sort_keys=True,separators=(',',':')).encode()).hexdigest()==closures[role]
 source=pathlib.Path('/tmp/bendvy-flat-journal-health-v4/batch.c' if role=='baseline' else '/tmp/bendvy-joined-flatjournal-ledger-health-build-v1/batch.c');build=json.loads((source.parent/'build.json').read_text());assert build.get('sourcePins',build.get('runtimeSources'))==m['runtimeSources'];assert build['artifacts']['batch.c']==sha(source)==m['sourceSHA256']==m['sourceAfterSHA256'];assert build['artifacts']['batch.bend']==sha(source.parent/'batch.bend')==m['entrySHA256'];assert sha(source.parent/'build.json')==m['upstreamBuildSHA256'];rows.append({'role':role,'sourceC':str(source),'sourceSHA256':sha(source),'buildSHA256':sha(source.parent/'build.json'),'countSHA256':sha(roots[role]/'evidence.json')})
for key in ['recipeSHA256','referenceSHA256','compilerWrapperSHA256','compilerELFSHA256','fullWorlds','updates']:assert e['baseline'][key]==e['joined'][key]
ops={}
for role,root in roots.items():
 c=collections.Counter()
 for s in json.loads((root/'sites.json').read_text()):c[s['operation']]+=s.get('entries',0)
 ops[role]=c
assert ops['baseline']==ops['joined']
profile=pathlib.Path('/tmp/bendvy-joined-ledger-native-health-profile/evidence.json');pr=json.loads(profile.read_text());assert pr['status']=='PROFILE_AND_FULL65_FIELDS_PASS' and pr['phaseClocks']==[3,4] and pr['sourceSHA256']==e['joined']['sourceSHA256']
r={'status':'JOINED_HEALTH_FRESH_NATIVE_COUNTS_AND_PROFILE_PASS','schema':'Health','sourceClosures':closures,'bindings':rows,'metrics':{key:{role:e[role][key] for role in roots}|{'delta':e['joined'][key]-e['baseline'][key]} for key in ['heapEntries','rfcCreated','requestedWords']},'allInstrumentedOperationTotalsEqual':True,'operationTotals':dict(ops['joined']),'profileEvidenceSHA256':sha(profile),'profileCMatchesJoined':True,'scope':'Health-specific finite count equality; profile sampling/instrumentation not cycles/speed/causality; no Motion transfer or product acceptance'};a.output.write_text(json.dumps(r,indent=2)+'\n');print('PASS')
