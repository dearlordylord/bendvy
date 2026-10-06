#!/usr/bin/env python3
"""Fresh exact full64 driver build; explicit child-only Clang19 and immutable source pins."""
import argparse,pathlib,json,hashlib,os,subprocess,signal,time
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--overlay',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
b=pathlib.Path('/tmp/bendvy-packed-paired-motion-build-v3' if a.schema=='Motion' else '/tmp/bendvy-packed-paired-health-build-v3')
s=b/'batch.bend';expected={'Motion': '26746058bd2a49123d7810e3e0b2e5b4ab29c382f19919da3c1ac70ba820f4b2', 'Health': 'df88b678664f69da3a541194003bc238811b8d141df18c59c0d9a2530b0aeea1'};assert sha(s)==expected[a.schema],'Original full64 driver drift'
pins=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert len(pins)==29 and all(sha(a.overlay/n)==v for n,v in pins.items())
local=b/'measurement-bend.bend';assert sha(local)=={'Motion': '5ac7445c938f3f20bc7c50435ca23fa811fc4315b0554a8a3b4d8c57b58a6b82', 'Health': '17e7b0e43d0e1860c3686b100720b036e84e7984dbf042289e521a9e9786e7ee'}[a.schema]
base=pathlib.Path('/tmp/bendvy-packed-paired-journal-both-v3/experiments/s-integrate/measurement-bend.bend').read_text();normalized=local.read_text().replace('/tmp/bendvy-packed-paired-journal-both-v3/experiments/s-integrate/','./');assert normalized.startswith(base)
extras=normalized[len(base):];assert 'def prototype_packed_'+a.schema.lower()+'_fresh(' in extras
measurement=a.output/'measurement-bend.bend';measurement.write_text((a.overlay/'experiments/s-integrate/measurement-bend.bend').read_text().replace('import ./','import '+str(a.overlay.resolve())+'/experiments/s-integrate/')+extras)
t=a.output/'batch.bend';original=s.read_text();prefix='/tmp/bendvy-packed-paired-journal-both-v3/';assert prefix in original;t.write_text(original.replace(prefix,str(a.overlay.resolve())+'/'))
r={'status':'INCOMPLETE','schema':a.schema,'CPU':10,'recipeSHA256':sha(pathlib.Path(__file__)),'sourcePins':pins,'sourceInputSHA256':sha(s),'sourceOutputSHA256':sha(t),'measurementSourceSHA256':sha(local),'measurementOutputSHA256':sha(measurement),'adaptation':'exact source overlay + byte-preserved original builder fresh-entry suffix','defaultProofSeconds':5,'commands':[]}
for argv,cap in [(['bend',str(t),'--check-only'],15),(['bend',str(t),'-o',str(a.output/'batch.c')],30),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(a.output/'batch.c'),'-o',str(a.output/'batch-native'),'-lm','-pthread'],120),(['bend',str(t),'-o',str(a.output/'batch.js')],30)]:
 st=time.monotonic();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';child=subprocess.Popen(['taskset','-c','10',*argv],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=child.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(child.pid,signal.SIGKILL);out=child.communicate()[0]
 r['commands'].append({'argv':argv,'limitSeconds':cap,'elapsedSeconds':time.monotonic()-st,'exit':child.returncode,'timeout':timed,'output':out});(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n')
 if child.returncode:r['status']='FAIL';break
else:r['status']='BUILD_PASS'
r['artifacts']={name:sha(a.output/name) for name in ['batch.bend','batch.c','batch-native','batch.js'] if (a.output/name).is_file()};(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
