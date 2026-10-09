"""No-child matched Inspector CPU/1MiB heap preparation; no baseline execution."""
from pathlib import Path
import gzip,hashlib,json,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main(directory):
 directory=Path(directory).resolve();assert not directory.exists() and not directory.is_symlink();directory.mkdir();wrappers=directory/'wrappers';wrappers.mkdir()
 prior=Path('/tmp/bendvy-relations42-direct-runtime01/full-js-plan.json');base=json.loads(prior.read_text());assert sha(prior)=='6867dce4649fe0b498e8cad833ed8efab05ffa1677b7351a7330bb3bf28bc9ca'
 artifact=Path('/tmp/bendvy-relations42-direct-emission03/full-js/trace.js');assert sha(artifact)=='be864b9a08233df0e5ec113c999c39c339d0fcc62dc23212ada9e7b12d22adcd'
 source=artifact.read_text();trailer='cli(process.argv.slice(1));\nio_exit($main$, null);';ending=trailer+'\n' if source.endswith(trailer+'\n') else trailer;assert source.endswith(ending);body=source[:-len(ending)]
 before=HERE.parent/'profile-evidence-v1';old=json.loads((before/'index.json').read_text());assert sha(before/'objects.tar.gz')==old['archiveSHA256'];bindings={k:v for k,v in old['files'].items() if k in ('original-partial/candidate-cpu.profile.json','coarse-allocation/candidate-allocation.profile.json')};assert len(bindings)==2
 files=set(map(Path,base['pins']));files.update([prior,Path(__file__).resolve(),HERE/'next-state-profile-execution.py',HERE/'next-state-profile-tail.js',HERE/'test-next-state-profile-soft-failure.js',HERE/'test-next-state-profile-entry.py',HERE/'test-next-state-profile-failure.py',HERE.parent/'profile.py',HERE.parent/'profile-coarse-allocation.py',before/'index.json',before/'objects.tar.gz',before/'verify.py',HERE.parent/'cpu-candidate-analysis.json',HERE.parent/'allocation-coarse-analysis.json',HERE.parent/'PROFILE-REPORT.md'])
 for n,h in base['pins'].items():assert sha(n)==h
 files.update(p for p in (HERE/'next-state-profile-evidence-v1').rglob('*') if p.is_file())
 commands={}
 for mode in ('cpu','allocation'):
  out=directory/mode;profile=out/'subject.profile.json';wrapper=wrappers/(mode+'.cjs')
  start="await profPost('Profiler.enable');await profPost('Profiler.setSamplingInterval',{interval:100});await profPost('Profiler.start');" if mode=='cpu' else "await profPost('HeapProfiler.enable');await profPost('HeapProfiler.startSampling',{samplingInterval:1048576,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true});"
  stop="const profResult=await profPost('Profiler.stop');" if mode=='cpu' else "const profResult=await profPost('HeapProfiler.stopSampling');"
  tail=(HERE/'next-state-profile-tail.js').read_text()
  replacements={'__PROFILE_START__':start,'__APP_INVOCATION__':trailer,'__PROFILE_STOP__':stop.replace('const profResult=','profResult='),'__PROFILE_PATH_JSON__':json.dumps(str(profile)),'__PROFILE_MODE_JSON__':json.dumps(mode)}
  for key,value in replacements.items():assert tail.count(key)==1;tail=tail.replace(key,value)
  tail='\n'+tail
  wrapper.write_text(body+tail);assert wrapper.read_text().startswith(body) and wrapper.read_text()[len(body):].count(trailer)==1;files.add(wrapper)
  command={**next(c for c in base['commands'] if c['argv'][-4:]==['depth','256','16','0']),'argv':['/usr/bin/taskset','-c','5','/home/node/.local/share/mise/installs/node/24.20.0/bin/node',str(wrapper),'depth','256','16','0'],'mode':mode,'profile':str(profile)};commands[mode]=command
 pins={str(p):sha(p) for p in sorted(files)};digests={}
 for mode,command in commands.items():
  p={**base,'stage':'cpu-profile' if mode=='cpu' else 'allocation-profile','executionSource':str(HERE/'next-state-profile-execution.py'),'pins':pins,'commands':[command],'output':str(directory/mode),'generated':[command['profile']],'scope':'One current complete30 depth256/span16 Inspector diagnostic; starts after static declarations, same retained sampler settings; no baseline replay/time ratio/RSS/total allocation qualification','historicalProfileBindings':bindings,'samplingStart':'After static generated declarations; before CLI invocation and all ECS setup/operations/forcing/serialization','wrapperBodySHA256':hashlib.sha256(body.encode()).hexdigest(),'wrapperBytesDelta':'Original full generated body unchanged; old Inspector tail reused, try/finally stop/capture preserving primary app errors; exclusive profile writes and actual invocation/zero-exit audit.'}
  target=directory/(mode+'-plan.json');target.write_text(json.dumps(p,indent=2)+'\n');digests[target.name]=sha(target)
 (directory/'index.json').write_text(json.dumps(digests,indent=2)+'\n');print(json.dumps(digests,indent=2))
if __name__=='__main__':main(sys.argv[1])
