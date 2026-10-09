"""No-child two actual binary bindings into existing reviewed full30 negative recipe."""
from pathlib import Path
import json,hashlib,sys,importlib.util
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[7]
def sha(p):
 p=Path(p);assert p.is_file() and not p.is_symlink();return hashlib.sha256(p.read_bytes()).hexdigest()
def main(directory):
 source=Path('/tmp/bendvy-relations42-direct-mutant-runtime01');directory=Path(directory).resolve();assert not directory.exists() and not directory.is_symlink();files={Path(__file__).resolve()};subjects={};bases={}
 for mutation in ['last-leaf','moved-walk']:
  path=source/(mutation+'-native-build-plan.json');b=json.loads(path.read_text());basepath=source/(mutation+'-js-plan.json');base=json.loads(basepath.read_text());receipt=source/(mutation+'-native-build/receipt.json');r=json.loads(receipt.read_text());assert r['planSHA256']==sha(path) and r['status']=='NEXT_STATE_BUILD_PASS_NO_TIMING';assert len(r['guards'])==4 and all(g['unchanged'] for g in r['guards']);assert r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None
  artifact=Path(b['generated'][0]);assert r['generated'][str(artifact)]=={'bytes':artifact.stat().st_size,'sha256':sha(artifact)};files.update([path,basepath,receipt,artifact]);subjects[mutation]=artifact;bases[mutation]=base
  for n,h in base['pins'].items():assert sha(n)==h;files.add(Path(n))
  for n,h in r['logs'].items():raw=receipt.parent/n;assert sha(raw)==h and raw.read_bytes()==b'';files.add(raw)
 spec=importlib.util.spec_from_file_location('runner',ROOT/'scripts/task_runner.py');T=importlib.util.module_from_spec(spec);spec.loader.exec_module(T);base=bases['last-leaf'];assert T.Inputs(files=base['pins'],directories=base['resourceRoots']).expected=={**base['pins'],**base['resourceRoots']};pins={str(f):sha(f) for f in sorted(files)};directory.mkdir();digests={}
 for mutation,base in bases.items():
  artifact=subjects[mutation];assert len(base['commands'])==1;command={**base['commands'][0],'argv':['/usr/bin/taskset','-c','5',str(artifact),'--threads','1','--gpu','off','depth','256','16','0']}
  plan={**base,'pins':pins,'backend':'native','subjectArtifact':str(artifact),'subjectSHA256':sha(artifact),'commands':[command],'output':str(directory/(mutation+'-native')),'status':'NOT_LAUNCH_ADMITTED'};path=directory/(mutation+'-native-plan.json');path.write_text(json.dumps(plan,indent=2)+'\n');digests[path.name]=sha(path)
 (directory/'index.json').write_text(json.dumps(digests,indent=2)+'\n');print(json.dumps(digests,indent=2))
if __name__=='__main__':main(sys.argv[1])
