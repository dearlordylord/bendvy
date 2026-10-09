"""Pinned TS ordinary decode development reference; prepared admission required."""
import argparse,fcntl,hashlib,importlib.util,json,re,shutil,sys
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'scripts'))
import task_runner
from evidence_boundary import ReceiptBoundary,GuardBoundary

def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
LOGS=load('decode_ts_logs',ROOT/'scripts/receipt-logs.py')
CONFIG=load('decode_ts_config',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py')
COMMON=load('decode_ts_resolution',ROOT/'experiments/public-snapshot/persistence-gate-v1/basic-world-v1/reference-cheap.py')

def strict(actual,expected,path='$'):
 assert type(actual) is type(expected),('type',path)
 if type(expected) is dict:
  assert actual.keys()==expected.keys(),('keys',path)
  for key in expected:strict(actual[key],expected[key],path+'.'+key)
 elif type(expected) is list:
  assert len(actual)==len(expected),('length',path)
  for n,(a,e) in enumerate(zip(actual,expected)):strict(a,e,path+f'[{n}]')
 else:assert actual==expected,('value',path)

def read_plan(path,digest):
 assert path.is_file() and not path.is_symlink(),'regular prepared plan required'
 assert re.fullmatch('[a-f0-9]{64}',digest or '') and hashlib.sha256(path.read_bytes()).hexdigest()==digest,'admitted plan digest differs'
 return json.loads(path.read_text())

def source_basis(path,expected_sha):
 assert path.is_file() and not path.is_symlink(),'regular independent source basis required'
 basis=json.loads(path.read_text());assert basis['expectedSHA256']==expected_sha,'model basis expected digest differs'
 for filename,digest in basis['sources'].items():
  p=Path(filename);assert p.is_file() and not p.is_symlink() and hashlib.sha256(p.read_bytes()).hexdigest()==digest,'independent source basis drift'
 return basis

def run(out,expected_path,expected_sha,oracle_commit,basis_path,execute=False,plan_sha=None):
 assert expected_path.is_file() and not expected_path.is_symlink(),'independent expected file required'
 assert re.fullmatch('[a-f0-9]{64}',expected_sha) and hashlib.sha256(expected_path.read_bytes()).hexdigest()==expected_sha,'independent expected digest differs'
 expected=json.loads(expected_path.read_text())
 basis=source_basis(basis_path,expected_sha)
 plan_path=out/'plan.json';admitted=read_plan(plan_path,plan_sha) if execute else None
 if not execute:out.mkdir()
 assert not (out/'receipt.json').exists(),'cohort already executed'
 raw=out/'raw'
 if not execute:raw.mkdir()
 assert raw.is_dir() and not raw.is_symlink() and not any(raw.iterdir()),'empty regular raw directory required'
 env=CONFIG.environment();private=out/'private-environment.json'
 if not execute:private.write_text(json.dumps(env,sort_keys=True)+'\n');private.chmod(0o600)
 assert private.is_file() and not private.is_symlink() and private.read_text()==json.dumps(env,sort_keys=True)+'\n','explicit environment drift'
 node=Path(shutil.which('node')).resolve();affinity=Path(shutil.which('taskset')).resolve();python=Path(sys.executable).resolve()
 files=[HERE/'reference.mjs',Path(__file__).resolve(),expected_path,private,node,affinity,python,Path(task_runner.__file__),Path(LOGS.__file__),ROOT/'scripts/evidence_boundary.py',Path(CONFIG.__file__),Path(COMMON.__file__)]
 files.extend(Path(p) for p in basis['sources'])
 files.extend(p for p in expected_path.parent.iterdir() if p.is_file() and p.suffix in ('.py','.json','.md'))
 files.append(ROOT/'experiments/public-decode/complete-v1/oracle-v1/expected-complete.py')
 source=ROOT/'.references/bevy-ts/packages/core/src'
 inputs=task_runner.Inputs(files=files,directories=[source]);configs=COMMON.configs([*files,source],env['HOME'])
 command=[str(affinity),'-c','5',str(node),str(HERE/'reference.mjs')]
 plan={'scope':__doc__,'oracleCommit':oracle_commit,'oracleSha256':expected_sha,'sourceBasis':str(basis_path),'argv':command,'capSeconds':5,'inputs':inputs.expected,'configuration':configs,'environmentSha256':hashlib.sha256(private.read_bytes()).hexdigest()}
 if execute:assert plan==admitted,'source/tool/config/environment differ from admitted plan'
 else:plan_path.write_text(json.dumps(plan,indent=2)+'\n')
 inputs=task_runner.Inputs(files=[*files,plan_path],directories=[source])
 if not execute:
  inputs.guard();print(json.dumps({'status':'PREPARED_NO_CHILD','plan':str(plan_path),'planSha256':hashlib.sha256(plan_path.read_bytes()).hexdigest()}));return
 logs=LOGS.CommandLogs(raw,['reference-run']);record={'status':'INCOMPLETE','scope':__doc__,'preparedPlanSha256':plan_sha,'command':None,'rawHashes':{}}
 def guard():
  assert read_plan(plan_path,plan_sha)==admitted,'admitted plan drift'
  inputs.guard();assert COMMON.configs([*files,source],env['HOME'])==configs,'resolver/configuration drift'
  logs.guard();record['rawHashes']=dict(logs.hashes)
 with ReceiptBoundary(record,out/'receipt.json',[('source/tools/config/environment/plan/raw',guard)]):
  guard()
  with GuardBoundary([('source/tools/config/environment/plan/raw',guard)]):
   with open('/tmp/bendvy-parity-heavy.lock','a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX);guard()
    current=task_runner.Inputs(files=[*files,plan_path],directories=[source]);assert current.expected==inputs.expected,'post-acquire input discovery drift'
    runner=task_runner.Runner(logs,inputs=current,env=env,cwd=HERE)
    try:result=runner.run('reference-run',command,5)
    except BaseException as error:
     failed=getattr(error,'result',None)
     if type(failed) is dict:record['command']={k:v for k,v in failed.items() if not isinstance(v,bytes)}
     raise
    record['command']={k:v for k,v in result.items() if not isinstance(v,bytes)}
  observed=(raw/'reference-run.stdout').read_bytes()
  strict(json.loads(observed),expected)
  assert (raw/'reference-run.stderr').read_bytes()==b'','unexpected runtime stderr'
  record['comparison']='full type-sensitive independent TS model equality; raw preserved'
  record['status']='DEVELOPMENT_PASS'
 print(json.dumps({'receipt':str(out/'receipt.json'),'status':record['status']}))

if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True);p.add_argument('--expected',type=Path,required=True);p.add_argument('--expected-sha256',required=True);p.add_argument('--oracle-commit',required=True);p.add_argument('--source-basis',type=Path,required=True);p.add_argument('--execute',action='store_true');p.add_argument('--plan-sha256');a=p.parse_args()
 run(a.output.resolve(),a.expected.resolve(),a.expected_sha256,a.oracle_commit,a.source_basis.resolve(),a.execute,a.plan_sha256)
