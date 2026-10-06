#!/usr/bin/env python3
"""Fail closed on source provenance and original public/callback drift."""
import argparse,hashlib,json,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();base=Path('/workspace/formal-proofs/bendvy/experiments/s-prep/source-fold-noaux-join/overlay-v1');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads((a.overlay/'overlay.json').read_text());assert len(m['sources'])==29
for rel,h in m['sources'].items():assert sha(a.overlay/rel)==h
rows=[]
expectedBaseline='49614f72311af5b03123d536ff301115d28b8886bf516b0d7057a8c52e68ad38'
bp=json.loads((base/'overlay.json').read_text())['sources'];assert len(bp)==29 and set(bp)==set(m['sources']);assert hashlib.sha256(json.dumps(bp,sort_keys=True,separators=(',',':')).encode()).hexdigest()==expectedBaseline
for rel,h in bp.items():assert sha(base/rel)==h
cm=json.loads((a.overlay/'cache-specialization.json').read_text());assert cm==m['cacheSpecialization'];assert cm['specializedClosure']==m['sources'];assert cm['runtimeClosure']==m['sources']
for filename in ['transaction.bend','held-adapter.bend','measurement-bend.bend']:
 old=(base/'experiments/s-integrate'/filename).read_text();new=(a.overlay/'experiments/s-integrate'/filename).read_text()
 if filename!='measurement-bend.bend':assert new.startswith(old)
 orig=list(re.finditer(r'^def (\w+)\([^\n]*',old,re.M));headers={x[1]:x[0] for x in orig}
 for name,header in headers.items():assert header in new
 rows.append({'file':filename,'originalSHA256':sha(base/'experiments/s-integrate'/filename),'candidateSHA256':sha(a.overlay/'experiments/s-integrate'/filename),'unchangedOriginalHeaders':len(headers),'originalPrefixByteIdentical':filename!='measurement-bend.bend'})
for name in ['prototype-static-client.bend','payload.bend','cached-payload.bend','types.bend','storage.bend','query.bend','transaction-dispatch-adapters.bend','held.bend']:assert sha(base/'experiments/s-integrate'/name)==sha(a.overlay/'experiments/s-integrate'/name)
# Every original measurement definition except the two authorized concrete invoke hooks remains byte present.
old=(base/'experiments/s-integrate/measurement-bend.bend').read_text();new=(a.overlay/'experiments/s-integrate/measurement-bend.bend').read_text()
for x in re.finditer(r'^def (\w+)\(.*?(?=\ndef |\ntype |\Z)',old,re.M|re.S):
 if x[1] in ['motion_invoke','health_invoke']:continue
 assert x[0].strip() in new,x[1]
a.output.write_text(json.dumps({'status':'SOURCE29_PUBLIC_HEADERS_CALLBACKS_AND_ORIGINALS_PASS','sourcePins':m['sources'],'rows':rows,'changedOriginalBodies':['motion_invoke','health_invoke'],'scope':'Only two concrete private transport hooks; no production authority/refinement acceptance'},indent=2)+'\n');print('PASS')
