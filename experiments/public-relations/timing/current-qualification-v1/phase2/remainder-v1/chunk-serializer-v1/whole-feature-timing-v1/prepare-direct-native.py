"""No-child binary binding for the already frozen full-nine Runner recipe."""
from pathlib import Path
import hashlib,importlib.util,json,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[7]
def sha(p):
 p=Path(p)
 if p.is_symlink() or not p.is_file():raise ValueError('regular nonsymlink input')
 return hashlib.sha256(p.read_bytes()).hexdigest()
def main(directory):
 source=Path('/tmp/bendvy-relations42-direct-runtime01');build=source/'native-build-plan.json';basepath=source/'full-js-plan.json';b=json.loads(build.read_text());p=json.loads(basepath.read_text());r=json.loads((source/'native-build/receipt.json').read_text());binary=Path(b['generated'][0])
 assert sha(build)=='eb2b80a1f3b00498451a51391c72e6d0c403ba314982e5dbd01df84c733cc756' and r['planSHA256']==sha(build)
 assert r['status']=='NEXT_STATE_BUILD_PASS_NO_TIMING' and r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None
 assert r['generated'][str(binary)]=={'bytes':binary.stat().st_size,'sha256':sha(binary)}
 assert len(r['guards'])==4 and all(g['unchanged'] for g in r['guards'])
 files=set(map(Path,p['pins']));files.update([build,basepath,binary,Path(__file__).resolve(),source/'native-build/receipt.json',source/'native-build/build.stdout',source/'native-build/build.stderr'])
 for n,h in p['pins'].items():assert sha(n)==h
 for n,h in r['logs'].items():assert sha(source/'native-build'/n)==h and not (source/'native-build'/n).read_bytes()
 spec=importlib.util.spec_from_file_location('runner',ROOT/'scripts/task_runner.py');T=importlib.util.module_from_spec(spec);spec.loader.exec_module(T);assert T.Inputs(files=p['pins'],directories=p['resourceRoots']).expected=={**p['pins'],**p['resourceRoots']}
 directory=Path(directory).resolve();assert not directory.exists() and not directory.is_symlink();directory.mkdir()
 commands=[]
 for c in p['commands']:
  commands.append({**c,'argv':['/usr/bin/taskset','-c','5',str(binary),'--threads','1','--gpu','off',*c['argv'][-4:]]})
 assert len(commands)==9
 plan={**p,'pins':{str(f):sha(f) for f in sorted(files)},'commands':commands,'output':str(directory/'native-full9'),'nativeBinarySHA256':sha(binary),'status':'NOT_LAUNCH_ADMITTED','scope':'Exact direct serializer binary complete9 semantics, no compiler/build replay/comparative timing'}
 target=directory/'native-full9-plan.json';target.write_text(json.dumps(plan,indent=2)+'\n');print(json.dumps({'plan':str(target),'sha256':sha(target),'binarySHA256':sha(binary),'cases':9}))
if __name__=='__main__':main(sys.argv[1])
