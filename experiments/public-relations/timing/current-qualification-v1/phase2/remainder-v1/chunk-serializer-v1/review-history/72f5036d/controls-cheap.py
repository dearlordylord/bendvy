"""Single bounded pure CLI controls consumer; no installed-tool/backend acceptance."""
from pathlib import Path
import hashlib,json,os,runpy,shutil,sys,time
H=Path(__file__).resolve().parent;R=H.parents[6];sys.dont_write_bytecode=True;sys.path.insert(0,str(R/'scripts'));import task_runner as T
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def prepare():
 source=json.loads((H/'cheap-source-plan.json').read_text());closure=source['targets'][1]['sourceClosure'];files={R/name for name in closure}|{H/'expected-controls.json',H/'expected-controls.stdout',H/'cheap-source-plan.json',Path(__file__).resolve(),R/'scripts/task_runner.py',R/'scripts/receipt-logs.py',Path('/workspace/formal-proofs/bendvy/.references/bend2/bend2/main.ts'),Path('/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts'),Path(shutil.which('bend')).resolve(),Path(shutil.which('taskset')).resolve()};out=R/'.artifacts'/('relations-chunk-controls-cheap-'+str(time.time_ns()));out.mkdir();env=dict(os.environ,BEND_NO_TELEMETRY='1');private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600);inputs=T.Inputs(files=files)
 p={'scope':'Actual pure main CLI term_snf consumer (not IO generatedJS); five complete authored control fields only, no proof/emitted/Native/speed acceptance','command':['taskset','-c','5','bend',str(H/'controls.bend')],'seconds':5,'files':list(map(str,files)),'inputs':inputs.expected,'environmentSHA256':sha(private),'expected':str(H/'expected-controls.stdout'),'valueOracle':str(H/'expected-controls.json'),'formatSource':'Pinned reference bend2/main.ts849-858 purebook_run and bend.ts1390-1406 constructor/1306-1314 string display','noReplay':'Retain firstfailure, no expectation relearning/capraise'};(out/'plan.json').write_text(json.dumps(p,indent=2)+'\n');print(out/'plan.json');print(sha(out/'plan.json'))
def run(path):
 path=Path(path).resolve();out=path.parent;p=json.loads(path.read_text());private=out/'private-environment.json';assert sha(private)==p['environmentSHA256'];env=json.loads(private.read_text());inputs=T.Inputs(files=p['files']);assert inputs.expected==p['inputs'];logs=runpy.run_path(str(R/'scripts/receipt-logs.py'))['CommandLogs'](out,['controls']);runner=T.Runner(logs,inputs=inputs,env=env,cwd=R);receipt={'status':'INCOMPLETE','planSHA256':sha(path)}
 try:
  v=runner.run('controls',p['command'],p['seconds']);assert v['exit']==0 and v['failure'] is None;assert v['stdout']==Path(p['expected']).read_bytes(),'full five-field oracle mismatch'
  assert all(line.startswith(b'bend ') and b' is available: run bend update' in line for line in v['stderr'].splitlines());inputs.guard();logs.guard();receipt['status']='PURE_FIVE_FIELD_CONTROLS_DEVELOPMENT_PASS_NOT_PROOF'
 except BaseException as e:receipt['error']=str(e);raise
 finally:receipt['logs']=dict(logs.hashes);(out/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(out)
if __name__=='__main__':prepare() if len(sys.argv)==1 else run(sys.argv[1])
