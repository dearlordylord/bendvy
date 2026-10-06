import argparse,pathlib,json,hashlib,os,subprocess,signal,time
p=argparse.ArgumentParser();p.add_argument('--schema',choices=['Motion','Health'],required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--resume',action='store_true');a=p.parse_args();a.output.mkdir(exist_ok=a.resume)
b=pathlib.Path('/tmp/bendvy-query-frozen-provider-motion-build-v2' if a.schema=='Motion' else '/tmp/bendvy-query-frozen-provider-health-build')
s=b/'batch.bend';t=a.output/'batch.bend';t.write_text(s.read_text().replace('/tmp/bendvy-query-frozen-provider-native-v3/',str(a.overlay.resolve())+'/'))
r={'status':'INCOMPLETE','sourceInputSHA256':hashlib.sha256(s.read_bytes()).hexdigest(),'sourceOutputSHA256':hashlib.sha256(t.read_bytes()).hexdigest(),'adaptation':'exact absolute overlay prefix only','commands':[]}
commands=[(['bend',str(t),'--check-only'],15),(['bend',str(t),'-o',str(a.output/'batch.c')],30),(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(a.output/'batch.c'),'-o',str(a.output/'batch-native'),'-lm','-pthread'],120),(['bend',str(t),'-o',str(a.output/'batch.js')],30)]
if a.resume:
 old=json.loads((a.output/'build.json').read_text());assert old['sourceOutputSHA256']==r['sourceOutputSHA256'];assert len(old['commands'])==3 and all(x['exit']==0 for x in old['commands'][:2]);assert old['commands'][2]['exit']==127
 r['previousBuild']=old;r['previousCSHA256']=hashlib.sha256((a.output/'batch.c').read_bytes()).hexdigest();commands=commands[2:]
for argv,cap in commands:
 st=time.monotonic();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';child=subprocess.Popen(['taskset','-c','10',*argv],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timeout=False
 try:out=child.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:timeout=True;os.killpg(child.pid,signal.SIGKILL);out=child.communicate()[0]
 r['commands'].append({'argv':argv,'limitSeconds':cap,'elapsedSeconds':time.monotonic()-st,'exit':child.returncode,'timeout':timeout,'output':out});(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n')
 if child.returncode: r['status']='FAIL';break
else:r['status']='BUILD_PASS'
(a.output/'build.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
