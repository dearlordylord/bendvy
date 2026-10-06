#!/usr/bin/env python3
"""Preserve exact29 baseline except private callback token reuse; no compiler edits."""
import argparse,hashlib,json,re,shutil
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--baseline',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((a.baseline/'overlay.json').read_text());assert len(m['sources'])==29
cache=json.loads((a.baseline/'cache-specialization.json').read_text())
assert cache==m['cacheSpecialization'],'Embedded/standalone baseline cache receipt mismatch'
assert cache['runtimeClosure']==m['sources'],'Baseline runtime closure differs from actual source pins'
assert cache['specializedClosure']==m['sources'],'Baseline specialized closure differs from actual source pins'
assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(m['sources'],sort_keys=True,separators=(',',':')).encode()).hexdigest(),'Baseline runtime closure digest mismatch'
for name,digest in m['sources'].items():
 assert sha(a.baseline/name)==digest,name
 target=a.output/name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(a.baseline/name,target)
name='experiments/s-integrate/prototype-static-client.bend';target=a.output/name;text=target.read_text();original=text
for schema,position,ledger,view in [('motion','PositionToken','MotionLedgerToken','PositionView'),('health','VitalsToken','HealthLedgerToken','VitalsView')]:
 start=text.index('def '+schema+'_body_ledger(');end=text.index('def '+schema+'_body(',start)
 helpers=text[start:end].replace(schema+'_body_ledger(',schema+'_body_ledger_tokens(').replace(schema+'_body_read(',schema+'_body_read_tokens(')
 helpers=helpers.replace('readsum:U32,pair:',f'token:T.{ledger},readsum:U32,pair:',1)
 helpers=helpers.replace(f'set(owner,T.{ledger}{{}}', 'set(owner,token',1)
 helpers=helpers.replace(f'~setledger:Owner -> T.{ledger} -> U32 -> Owner,pair:',f'~setledger:Owner -> T.{ledger} -> U32 -> Owner,token:T.{position},pair:',1)
 old=next(line for line in helpers.splitlines() if f'case (owner,T.Found{{T.{view}' in line)
 new=old.replace(f'set(owner,T.{position}{{}}','set(owner,token').replace(f'~Owner,~setledger,sum(values)',f'~Owner,~setledger,ledgerToken,sum(values)').replace(f',T.{ledger}{{}}))',',ledgerToken))')
 # Bind only Data tokens; the arbitrary affine owner is never duplicated.
 new=new.replace(': '+schema+'_body_ledger_tokens(',':\n      +ledgerToken = {T.'+ledger+'{} : T.'+ledger+'}\n      '+schema+'_body_ledger_tokens(')
 helpers=helpers.replace(old,new)
 text=text[:end]+helpers+text[end:]
 # Preserve the public header and old read/ledger helper bodies; change only its routing body.
 body=f'  {schema}_body_read(~Owner,~set,~ledger,~setledger,get(owner,T.{position}{{}}))'
 replacement=f'  +token = {{T.{position}{{}} : T.{position}}}\n  {schema}_body_read_tokens(~Owner,~set,~ledger,~setledger,token,get(owner,token))'
 assert text.count(body)==1;text=text.replace(body,replacement)
target.write_text(text)
oldheaders=[line for line in original.splitlines() if line.startswith(('def ','type '))]
newheaders=[line for line in text.splitlines() if line.startswith(('def ','type '))]
assert all(line in newheaders for line in oldheaders)
m['sources']={n:sha(a.output/n) for n in m['sources']}
cache['runtimeClosure']=dict(m['sources'])
cache['specializedClosure']=dict(m['sources'])
cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(m['sources'],sort_keys=True,separators=(',',':')).encode()).hexdigest()
m['cacheSpecialization']=cache
(a.output/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n')
m['tokenReuse']={'baselineManifestSHA256':sha(a.baseline/'overlay.json'),'baselineSources':json.loads((a.baseline/'overlay.json').read_text())['sources'],'changedModules':[name],'originalSHA256':hashlib.sha256(original.encode()).hexdigest(),'candidateSHA256':sha(target),'originalHeadersRetained':True,'scope':'Four private tokens helpers; public motion/health body routing changed. Callback bodies are new source, not original callback pin acceptance. Full owner/get/set/access function types unchanged.'}
(a.output/'overlay.json').write_text(json.dumps(m,indent=2)+'\n')
Path(__file__).with_name('candidate-client.bend').write_text(text)
print(json.dumps(m['tokenReuse']))
