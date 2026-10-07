"""Bind exact matched source siblings into small negative cohorts, without probes."""
from pathlib import Path
import argparse,json,sys,time,types
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.dont_write_bytecode=True
B=types.ModuleType('inspect54_controls');B.__file__=str(HERE/'control-development.py')
exec((HERE/'control-development.py').read_text().split('p=argparse.ArgumentParser();')[0],B.__dict__)
def prepare(proposal,positive):
 proposal=Path(proposal).resolve();prior=json.loads(proposal.read_text());assert prior['kind']=='negatives'
 original=B.task_runner.Inputs(files=prior['files'],directories=map(Path,prior['directories']));assert original.expected==prior['inputs']
 positive=Path(positive).resolve();r=json.loads(positive.read_text());p_path=positive.parent/'plan.json';p=json.loads(p_path.read_text())
 assert r['status']=='SAFE_SOURCE_POSITIVES_PASS' and r['planSHA256']==B.sha(p_path)
 assert r['commands']==[{'label':'positive-'+name,'exit':0,'failure':None} for name in ['owner','query','read']]
 siblings=B.task_runner.Inputs(files=p['files'],directories=map(Path,p['directories']));assert siblings.expected==p['inputs']
 files=set(map(Path,prior['files']))|set(map(Path,p['files']))|{proposal,positive,p_path,Path(__file__).resolve()}
 for name,digest in r['logs'].items():
  raw=positive.parent/name;assert B.sha(raw)==digest;files.add(raw)
 directories=set(map(Path,prior['directories']))|set(map(Path,p['directories']))
 for index in range(2):
  out=ROOT/'.artifacts'/('inspect54-controls-negatives-bound-'+str(index+1)+'-'+str(time.time_ns()));out.mkdir()
  private=out/'private-environment.json';private.write_bytes(Path(prior['privateEnvironment']).read_bytes());private.chmod(0o600)
  selected=files|{private};inputs=B.task_runner.Inputs(files=selected,directories=directories)
  plan={**prior,'files':sorted(map(str,selected)),'directories':sorted(map(str,directories)),'inputs':inputs.expected,'commands':prior['commands'][index*3:index*3+3],'privateEnvironment':str(private),'environmentSHA256':B.sha(private),'matchedSiblingJoin':{'receipt':str(positive),'receiptSHA256':B.sha(positive),'plan':str(p_path),'planSHA256':B.sha(p_path),'commands':r['commands'],'rawLogs':r['logs'],'sourceInputs':p['inputs']},'unexecutedProposal':{'plan':str(proposal),'sha256':B.sha(proposal)},'scope':'Exactly three cheap source negative controls with exact successful sibling source/raw receipt joins. Deadline or unrelated diagnostics never acceptance; complete raw intended-diagnostic review required. No probes/backend/proof/runtime/full54 acceptance.'}
  roots=list(map(Path,prior['configurationRoots']))+[out];plan['configurationRoots']=list(map(str,roots));plan['configurationStates']=B.configurations(roots)
  path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(B.sha(path))
p=argparse.ArgumentParser();p.add_argument('--prepare',action='store_true');p.add_argument('--proposal');p.add_argument('--positive');p.add_argument('--run');a=p.parse_args()
if a.prepare:prepare(a.proposal,a.positive)
else:B.run(a.run)
