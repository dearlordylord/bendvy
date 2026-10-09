"""No-child exact artifact binding into reviewed negative Runner stages."""
from pathlib import Path
import json,hashlib,sys,importlib.util
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[7]
def sha(p):
 p=Path(p);assert p.is_file() and not p.is_symlink();return hashlib.sha256(p.read_bytes()).hexdigest()
def main(directory):
 source=Path('/tmp/bendvy-relations42-direct-mutants01');directory=Path(directory).resolve();assert not directory.exists() and not directory.is_symlink();sequence=json.loads((source/'sequence.json').read_text());files={source/'sequence.json',Path(__file__).resolve()};subjects={};bases={}
 for mutation in ['last-leaf','moved-walk']:
  for backend in ['js','native']:
   label=mutation+'-'+backend;planpath=source/(label+'-emit-plan.json');base=json.loads(planpath.read_text());receiptpath=source/label/'receipt.json';r=json.loads(receiptpath.read_text());assert r['planSHA256']==sha(planpath) and r['status']=='NEXT_STATE_EMIT_PASS_NO_TIMING';assert len(r['guards'])==4 and all(g['unchanged'] for g in r['guards']);assert r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None
   for n,h in base['pins'].items():assert sha(n)==h;files.add(Path(n))
   for n,h in r['logs'].items():raw=source/label/n;assert sha(raw)==h and raw.read_bytes()==b'';files.add(raw)
   artifact=Path(base['generated'][0]);assert r['generated'][str(artifact)]=={'bytes':artifact.stat().st_size,'sha256':sha(artifact)};files.update([planpath,receiptpath,artifact]);subjects[label]=artifact;bases[label]=base
  for raw in (source/(mutation+'-source5')).iterdir():
   if raw.is_file():files.add(raw)
 spec=importlib.util.spec_from_file_location('runner',ROOT/'scripts/task_runner.py');T=importlib.util.module_from_spec(spec);spec.loader.exec_module(T)
 base=bases['last-leaf-js'];assert T.Inputs(files=base['pins'],directories=base['resourceRoots']).expected=={**base['pins'],**base['resourceRoots']};pins={str(f):sha(f) for f in sorted(files)};directory.mkdir();digests={}
 for mutation in ['last-leaf','moved-walk']:
  artifact=subjects[mutation+'-js'];command={'label':'depth-256-16-0','argv':['/usr/bin/taskset','-c','5','/home/node/.local/share/mise/installs/node/24.20.0/bin/node',str(artifact),*sequence['anchorInput']],'seconds':5,'positiveOracle':sequence['positiveOracle'],'counterOracle':sequence['lastLeafCounterOracle'] if mutation=='last-leaf' else sequence['movedWalkCounterOracle'],'counterWalk':sequence['lastLeafCounterWalk'] if mutation=='last-leaf' else sequence['movedWalkCounterWalk'],'positiveWalk':sequence['positiveWalk']}
  runtime={**base,'stage':'runtime','pins':pins,'executionSource':sequence['executionSource'],'mutation':mutation,'backend':'js','subjectArtifact':str(artifact),'subjectSHA256':sha(artifact),'commands':[command],'output':str(directory/(mutation+'-js')),'generated':[],'scope':'Actual direct full30 governing reached mutant; whole counterbytes + positive rejection and2actualmarkers; broadnormal9unchanged','status':'NOT_LAUNCH_ADMITTED'};target=directory/(mutation+'-js-plan.json');target.write_text(json.dumps(runtime,indent=2)+'\n');digests[target.name]=sha(target)
  c=subjects[mutation+'-native'];binary=directory/(mutation+'-native-build/trace.native');build={**base,'pins':pins,'stage':'build','executionSource':str(HERE/'next-state-execution.py'),'commands':[{'label':'build','argv':['/usr/bin/taskset','-c','5','/tmp/bendvy-clang19-diagnostic/clang19','-O3',str(c),'-o',str(binary),'-pthread','-lm'],'seconds':120}],'output':str(binary.parent),'generated':[str(binary)],'status':'NOT_LAUNCH_ADMITTED'};target=directory/(mutation+'-native-build-plan.json');target.write_text(json.dumps(build,indent=2)+'\n');digests[target.name]=sha(target)
 (directory/'index.json').write_text(json.dumps(digests,indent=2)+'\n');print(json.dumps(digests,indent=2))
if __name__=='__main__':main(sys.argv[1])
