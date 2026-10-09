"""No-child matched Inspector CPU/1MiB heap preparation; no baseline execution."""
from pathlib import Path
import gzip,hashlib,json,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main(directory):
 directory=Path(directory).resolve();assert not directory.exists() and not directory.is_symlink();directory.mkdir();wrappers=directory/'wrappers';wrappers.mkdir()
 prior=Path('/tmp/bendvy-relations42-next-state-runtime01/candidate-cpu-plan.json');base=json.loads(prior.read_text());assert sha(prior)=='f739f3461f9ca8d897abc01c2576bb379f0df815fc045df1a17c7bb34393d594'
 artifact=Path('/tmp/bendvy-relations42-next-state-emission03/full-js/trace.js');assert sha(artifact)=='7ee5e05e47ecaa937ed2331ed2a91ec9d1232011bad2f74c87a77a3a9fcbd6d1'
 source=artifact.read_text();trailer='cli(process.argv.slice(1));\nio_exit($main$, null);';ending=trailer+'\n' if source.endswith(trailer+'\n') else trailer;assert source.endswith(ending);body=source[:-len(ending)]
 before=HERE.parent/'profile-evidence-v1';old=json.loads((before/'index.json').read_text());assert sha(before/'objects.tar.gz')==old['archiveSHA256'];bindings={k:v for k,v in old['files'].items() if k in ('original-partial/candidate-cpu.profile.json','coarse-allocation/candidate-allocation.profile.json')};assert len(bindings)==2
 files=set(map(Path,base['pins']));files.update([prior,Path(__file__).resolve(),HERE/'next-state-profile-execution.py',HERE/'test-next-state-profile-entry.py',HERE/'test-next-state-profile-failure.py',HERE.parent/'profile.py',HERE.parent/'profile-coarse-allocation.py',before/'index.json',before/'objects.tar.gz',before/'verify.py',HERE.parent/'cpu-candidate-analysis.json',HERE.parent/'allocation-coarse-analysis.json',HERE.parent/'PROFILE-REPORT.md'])
 for n,h in base['pins'].items():assert sha(n)==h
 commands={}
 for mode in ('cpu','allocation'):
  out=directory/mode;profile=out/'subject.profile.json';wrapper=wrappers/(mode+'.cjs')
  start="await profPost('Profiler.enable');await profPost('Profiler.setSamplingInterval',{interval:100});await profPost('Profiler.start');" if mode=='cpu' else "await profPost('HeapProfiler.enable');await profPost('HeapProfiler.startSampling',{samplingInterval:1048576,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true});"
  stop="const profResult=await profPost('Profiler.stop');" if mode=='cpu' else "const profResult=await profPost('HeapProfiler.stopSampling');"
  tail="\nconst profSession=new (require('node:inspector').Session)();profSession.connect();\nconst profPost=(method,params={})=>new Promise((resolve,reject)=>profSession.post(method,params,(error,result)=>error?reject(error):resolve(result)));\nconst profExit=process.exit;let profZero=0;process.exit=code=>{if(code!==0)throw Error('nonzero application exit:'+code);profZero++;};\n(async()=>{\n"+start+'\n'+trailer+'\n'+stop+"\nif(profZero!==1)throw Error('expected one completed invocation');require('node:fs').writeFileSync("+json.dumps(str(profile))+",JSON.stringify({profile:profResult.profile,zeroExits:profZero,invocations:1,mode:"+json.dumps(mode)+"}),{flag:'wx',mode:0o600});profSession.disconnect();process.exit=profExit;})().catch(error=>{process.exit=profExit;profSession.disconnect();console.error(error);process.exit(1);});\n"
  wrapper.write_text(body+tail);assert wrapper.read_text().startswith(body) and wrapper.read_text()[len(body):].count(trailer)==1;files.add(wrapper)
  command={**base['commands'][0],'argv':['/usr/bin/taskset','-c','5','/home/node/.local/share/mise/installs/node/24.20.0/bin/node',str(wrapper),'depth','256','16','0'],'mode':mode,'profile':str(profile)};commands[mode]=command
 pins={str(p):sha(p) for p in sorted(files)};digests={}
 for mode,command in commands.items():
  p={**base,'stage':'cpu-profile' if mode=='cpu' else 'allocation-profile','executionSource':str(HERE/'next-state-profile-execution.py'),'pins':pins,'commands':[command],'output':str(directory/mode),'generated':[command['profile']],'scope':'One current complete30 depth256/span16 Inspector diagnostic; starts after static declarations, same retained sampler settings; no baseline replay/time ratio/RSS/total allocation qualification','historicalProfileBindings':bindings,'samplingStart':'After static generated declarations; before CLI invocation and all ECS setup/operations/forcing/serialization','wrapperBodySHA256':hashlib.sha256(body.encode()).hexdigest(),'wrapperBytesDelta':'Original full generated body unchanged; old Inspector tail reused, exclusive profile write and disconnect-on-error guards added.'}
  target=directory/(mode+'-plan.json');target.write_text(json.dumps(p,indent=2)+'\n');digests[target.name]=sha(target)
 (directory/'index.json').write_text(json.dumps(digests,indent=2)+'\n');print(json.dumps(digests,indent=2))
if __name__=='__main__':main(sys.argv[1])
