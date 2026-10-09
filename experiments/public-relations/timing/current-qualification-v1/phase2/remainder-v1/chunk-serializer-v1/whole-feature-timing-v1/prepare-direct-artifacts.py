"""No-child binding of admitted successful artifacts into the frozen stage recipe."""
from pathlib import Path
import hashlib,importlib.util,json,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[7]
def sha(p):
 p=Path(p)
 if p.is_symlink() or not p.is_file():raise ValueError('regular nonsymlink input')
 return hashlib.sha256(p.read_bytes()).hexdigest()
def main(directory):
 output=Path(directory).resolve();assert not output.exists() and not output.is_symlink()
 emit=Path('/tmp/bendvy-relations42-direct-emission03');files=set();plans={};artifacts={}
 for label in ('fuel-js','full-js','full-native'):
  path=emit/(label+'-emit-plan.json');p=json.loads(path.read_text());receipt=emit/label/'receipt.json';r=json.loads(receipt.read_text())
  assert r['planSHA256']==sha(path) and r['status']=='NEXT_STATE_EMIT_PASS_NO_TIMING'
  assert r['commands']==[{'label':'emit','exit':0,'failure':None,'capture':'split','runnerSHA256':p['pins'][str(ROOT/'scripts/task_runner.py')],'artifactPass':True}]
  assert [g['label'] for g in r['guards']]==['pre','acquired-emit','post-emit','final'] and all(g['unchanged'] for g in r['guards'])
  for n,h in p['pins'].items():assert sha(n)==h;files.add(Path(n))
  for n,h in r['logs'].items():assert sha(emit/label/n)==h;assert (emit/label/n).read_bytes()==b'';files.add(emit/label/n)
  artifact=Path(p['generated'][0]);state=r['generated'][str(artifact)];assert state=={'bytes':artifact.stat().st_size,'sha256':sha(artifact)}
  files.update([path,receipt,artifact]);plans[label]=p;artifacts[label]=artifact
 spec=importlib.util.spec_from_file_location('runner',ROOT/'scripts/task_runner.py');T=importlib.util.module_from_spec(spec);spec.loader.exec_module(T)
 base=plans['full-js'];assert T.Inputs(files=base['pins'],directories=base['resourceRoots']).expected=={**base['pins'],**base['resourceRoots']}
 files.add(Path(__file__).resolve());pins={str(p):sha(p) for p in sorted(files)};common={**{k:v for k,v in base.items() if k not in ('commands','generated','output','stage','allNineOracles')},'pins':pins,'status':'NOT_LAUNCH_ADMITTED','exactArtifactSHA256':{label:sha(path) for label,path in artifacts.items()}}
 node='/home/node/.local/share/mise/installs/node/24.20.0/bin/node';prefix=['/usr/bin/taskset','-c','5'];output.mkdir();digests={}
 def write(label,stage,commands,generated=[]):
  p={**common,'stage':stage,'commands':commands,'generated':generated,'output':str(output/label)}
  path=output/(label+'-plan.json');path.write_text(json.dumps(p,indent=2)+'\n');digests[path.name]=sha(path)
 write('fuel-js','fuel-runtime',[{'label':'fuel','argv':prefix+[node,str(artifacts['fuel-js'])],'seconds':5,'oracle':str(HERE.parent/'direct-fuel-controls.expected')}])
 cases=base['allNineOracles'];assert len(cases)==9
 write('full-js','runtime',[{'label':'-'.join(c['input']),'argv':prefix+[node,str(artifacts['full-js']),*c['input']],'seconds':5,'oracle':c['oracle'],'walk':c['walk']} for c in cases])
 binary=output/'native-build/trace.native';write('native-build','build',[{'label':'build','argv':prefix+['/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(artifacts['full-native']),'-o',str(binary),'-pthread','-lm'],'seconds':120}],[str(binary)])
 (output/'index.json').write_text(json.dumps(digests,indent=2)+'\n');print(json.dumps(digests,indent=2))
if __name__=='__main__':main(sys.argv[1])
