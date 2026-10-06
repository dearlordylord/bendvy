#!/usr/bin/env python3
import hashlib,json
from pathlib import Path
P=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for schema in ['Motion','Health']:
 parent=Path('/tmp/bendvy-source-handoff-'+schema.lower()+'-build-v8');framehashes=[]
 for count in [64,1024]:
  build=Path('/tmp/bendvy-handoff-v8-'+schema.lower()+'-dense'+str(count)+'-build-r2');r=json.loads((build/'build.json').read_text());assert r['status']=='BUILD_PASS' and r['sourceClosure']=='4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235'
  before=(parent/'batch.bend').read_text();after=(build/'batch.bend').read_text();suffix='def main() -> IO(Unit):\n  '+schema.lower()+'_batch(256,64)\n';new=suffix.replace('(256,64)','('+str(count)+',64)');assert before.endswith(suffix) and before.count(suffix)==1;assert after==before[:-len(suffix)]+new
  assert (build/'measurement-bend.bend').read_bytes()==(parent/'measurement-bend.bend').read_bytes()
  frame=before[:-len(suffix)]+'def main() -> IO(Unit):\n  '+schema.lower()+'_batch(COUNT,64)\n';h=hashlib.sha256(frame.encode()).hexdigest();assert r['countAdaptation']['bodyFrameSHA256']==h;framehashes.append(h)
  assert r['countAdaptation']['count']==count and r['countAdaptation']['batch']==r['countAdaptation']['ticks']==64
  assert all(c['exit']==0 and not c['timeout'] for c in r['commands']);assert r['toolBytesStableBeforeAfter'] and r['cIncludeBytesStableBeforeAfter']
  for name,pin in r['artifacts'].items():assert sha(build/name)==pin,name
  root=Path(r['sourceRoot']);m=json.loads((root/'overlay.json').read_text());cache=json.loads((root/'cache-specialization.json').read_text());assert m['cacheSpecialization']==cache and m['sources']==cache['runtimeClosure']==cache['specializedClosure']==r['sourcePins'];assert len(r['sourcePins'])==29
  for name,pin in r['sourcePins'].items():assert sha(root/name)==pin,name
  assert sha(P/'build.py')==r['recipeSHA256'] and sha(P/'tool-pins.py')==r['toolPinRecipeSHA256']
 assert framehashes[0]==framehashes[1]
print('FOUR_BUILD_EXACT_MAIN_LITERAL_SOURCE29_AND_BODY_FRAME_PASS')
