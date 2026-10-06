#!/usr/bin/env python3
"""Fresh exact full64 driver build; explicit child-only Clang19 and immutable source pins."""
import argparse,pathlib,json,hashlib,os,subprocess,signal,time
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--overlay',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
b=pathlib.Path('/tmp/bendvy-query-frozen-provider-motion-build-v2' if a.schema=='Motion' else '/tmp/bendvy-query-frozen-provider-health-build')
s=b/'batch.bend';expected={'Motion':'a3cc8f260aba3d9c272edd364d45eb08a44f19788cd4ac426920bea9ea3dfaa9','Health':'c48e49f22f71b10c65fe8fef42976335d760949a479fb80bc54b73d3569697c5'};assert sha(s)==expected[a.schema],'Original full64 driver drift'
pins=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert len(pins)==29 and all(sha(a.overlay/n)==v for n,v in pins.items())
t=a.output/'batch.bend';original=s.read_text();prefix='/tmp/bendvy-query-frozen-provider-native-v3/';assert prefix in original;t.write_text(original.replace(prefix,str(a.overlay.resolve())+'/'))
r={'status':'INCOMPLETE','schema':a.schema,'CPU':10,'recipeSHA256':sha(pathlib.Path(__file__)),'sourcePins':pins,'sourceInputSHA256':sha(s),'sourceOutputSHA256':sha(t),'adaptation':'exact absolute overlay prefix only','defaultProofSeconds':5,'commands':[]}
for argv,cap in [(['bend',str(t),'--check-only'],15),(['bend',str(t),'-o',str(a.output/'batch.c')],30),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(a.output/'batch.c'),'-o',str(a.output/'batch-native'),'-lm','-pthread'],120),(['bend',str(t),'-o',str(a.output/'batch.js')],30)]:
 st=time.monotonic();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';child=subprocess.Popen(['taskset','-c','10',*argv],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=child.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(child.pid,signal.SIGKILL);out=child.communicate()[0]
 r['commands'].append({'argv':argv,'limitSeconds':cap,'elapsedSeconds':time.monotonic()-st,'exit':child.returncode,'timeout':timed,'output':out});(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n')
 if child.returncode:r['status']='FAIL';break
else:r['status']='BUILD_PASS'
r['artifacts']={name:sha(a.output/name) for name in ['batch.bend','batch.c','batch-native','batch.js'] if (a.output/name).is_file()};(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
