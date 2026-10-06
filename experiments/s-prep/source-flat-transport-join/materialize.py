#!/usr/bin/env python3
"""Fail-closed join of independently verified, disjoint source variants."""
import argparse, hashlib, json, shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
closure=lambda pins:hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
EXPECTED={'baseline':'409d87045a832f021c7d7a1aa880ebfd16ff8d2b9eb5035883d96f781a49daad','query':'ac8de957a37d85cb473168d43c89c589e418fd32685f5269a225d11d68dac31a','held':'411467c393032950d49e203564ec6f68635065417562ea3864d5afabb173c233'}
p=argparse.ArgumentParser();p.add_argument('--baseline',type=Path,required=True);p.add_argument('--query',type=Path,required=True);p.add_argument('--held',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
inputs={}
for role in EXPECTED:
 folder=getattr(a,role).resolve(strict=True);assert not any(x.is_symlink() for x in folder.rglob('*'))
 pins={str(x.relative_to(folder)):sha(x) for x in folder.rglob('*.bend')};m=json.loads((folder/'overlay.json').read_text());c=json.loads((folder/'cache-specialization.json').read_text())
 assert len(pins)==29 and pins==m['sources']==c['runtimeClosure']==c['specializedClosure']
 assert c==m['cacheSpecialization'] and closure(pins)==c['runtimeClosureSHA256']==EXPECTED[role]
 inputs[role]={'folder':str(folder),'pins':pins,'manifestSHA256':sha(folder/'overlay.json')}
b=inputs['baseline']['pins'];q=inputs['query']['pins'];h=inputs['held']['pins']
qchanges=sorted(n for n in b if b[n]!=q[n]);hchanges=sorted(n for n in b if b[n]!=h[n])
assert qchanges==['experiments/s-integrate/measurement-bend.bend','experiments/s-integrate/query.bend']
assert hchanges==['experiments/s-integrate/held-adapter.bend'] and not set(qchanges)&set(hchanges)
a.output=a.output.absolute();assert a.output.is_relative_to(HERE) and not a.output.exists()
shutil.copytree(a.query,a.output)
for n in hchanges:shutil.copyfile(a.held/n,a.output/n)
pins={str(x.relative_to(a.output)):sha(x) for x in a.output.rglob('*.bend')};assert all(pins[n]==(h[n] if n in hchanges else q[n]) for n in pins)
m=json.loads((a.output/'overlay.json').read_text());c=json.loads((a.output/'cache-specialization.json').read_text());c.update(runtimeClosure=pins,specializedClosure=pins.copy(),runtimeClosureSHA256=closure(pins));m.update(sources=pins,cacheSpecialization=c)
r={'status':'ASSEMBLED_UNVERIFIED_SOURCE_JOIN','inputClosures':EXPECTED,'inputManifests':{k:v['manifestSHA256'] for k,v in inputs.items()},'changedModules':qchanges+hchanges,'sourceOwners':{n:'Held' if n in hchanges else 'Query' for n in qchanges+hchanges},'sources':pins,'outputClosureSHA256':closure(pins),'recipeSHA256':sha(Path(__file__)),'priorIndependentGatesDoNotAcceptJoin':True,'performanceAcceptance':False,'productionAdoption':False,'claim':'Exact disjoint source join; no emitted-JS transform or original callback algorithm change. Fresh gates required.'}
for n,v in [('overlay.json',m),('cache-specialization.json',c),('source-flat-transport-join.json',r)]:(a.output/n).write_text(json.dumps(v,indent=2)+'\n')
print(json.dumps({'status':r['status'],'closureSHA256':closure(pins)}))
