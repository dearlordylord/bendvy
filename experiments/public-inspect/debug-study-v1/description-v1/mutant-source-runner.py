"""Frozen development preflight only; no tool discovery or delivery qualification."""
import argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 spec=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','task_runner');L=load(ROOT/'scripts/receipt-logs.py','logs');B=load(ROOT/'scripts/evidence_boundary.py','boundary')
def inv(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def configs(roots):
 paths=set()
 for root in roots:
  for p in [root,*root.parents]:
   for n in ['check.json','check.jsonc','bender.jsonc','.bend','bend.json','bend.jsonc','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc','.clang','clang.cfg','bunfig.toml']:paths.add(p/n)
 def state(p):
  if p.is_symlink():return {'kind':'symlink','target':os.readlink(p),'resolvedSHA256':sha(p) if p.is_file() else None}
  if p.is_file():return {'kind':'file','sha256':sha(p)}
  if p.is_dir():return {'kind':'directory'}
  return {'kind':'absent'}
 return {str(p):state(p) for p in paths}
def prepare():
 prior=HERE/'preflight/1791441880404529800';old=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='a1a5af87ea5aba1dda8706f3ee392480f3e9a4f70462ee058d40f969373e05fd'
 assert sha(prior/'receipt.json')=='906d1e0b5f38062eea372a0acfd0f5bd1df3f9d5bc5c635d9d26d63c86ce6e67'
 assert receipt['status']=='DEVELOPMENT_DESCRIPTION_FULL9_PASS_NOT_DELIVERY_NOT_FORMAT_PUBLICATION' and receipt.get('guardFailures',[])==[]
 assert [(c['label'],c['seconds'],c['exit'],c['failure']) for c in receipt['commands']]==[('emit',30,0,None),('candidate',5,0,None)]
 assert all(all(c[k]==old['commands'][j][k] for k in old['commands'][j]) for j,c in enumerate(receipt['commands']))
 assert set(receipt['logs'])=={'emit.stdout','emit.stderr','candidate.stdout','candidate.stderr'}
 assert all(sha(prior/n)==h for n,h in receipt['logs'].items())
 assert (prior/'candidate.stdout').read_bytes()==(HERE/'EXPECTED.stdout').read_bytes() and (prior/'candidate.stderr').read_bytes()==b''
 assert inv(Path(old['stage']))==old['inventory']
 assert all(sha(n)==h for n,h in old['pins'].items())
 proposal=json.loads((HERE/'MUTANT-PROPOSAL.json').read_text());assert sha(HERE/'MUTANT-PROPOSAL.json')=='ce1fff11d518a5ea031acbb6ccda64e2386d4e5262d3e9122a08fb075531a032'
 out=HERE/'mutant-source-v1'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';stage.mkdir();commands=[]
 taskset=str(Path(shutil.which('taskset')).resolve());bend=str(Path(shutil.which('bend')).resolve())
 for m in proposal['mutants']:
  target=stage/m['name'];shutil.copytree(Path(old['stage']),target)
  source=target/'study'/m['source'];assert sha(source)==m['sourceSHA256']
  text=source.read_text();assert text.count(m['old'])==1;source.write_text(text.replace(m['old'],m['new']))
  for name,h in old['inventory'].items():
   if name=='study/'+m['source']:assert (target/name).read_text()==(Path(old['stage'])/name).read_text().replace(m['old'],m['new'])
   else:assert sha(target/name)==h
  commands.append({'label':m['name'],'argv':[taskset,'-c','5',bend,str(target/'study/main.bend'),'--check-only'],'seconds':5})
 pins={**old['pins'],str(Path(__file__)):sha(__file__),str(HERE/'MUTANT-PROPOSAL.json'):sha(HERE/'MUTANT-PROPOSAL.json')}
 for f in prior.rglob('*'):
  if f.is_file():pins[str(f)]=sha(f)
 private=out/'private-environment.json';private.write_bytes(Path(old['environment']).read_bytes());private.chmod(0o600);pins[str(private)]=sha(private)
 roots=[*map(Path,old['configRoots']),out,stage,HERE,*[f.parent for f in stage.rglob('*') if f.is_file()]]
 plan={**old,'scope':'Two exact mutant source shapes; source typing only, no reach/proof/runtime/authority qualification','pins':pins,'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'commands':commands,'mutations':proposal,'normalJSPlan':str(prior/'plan.json'),'normalJSReceipt':str(prior/'receipt.json')}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=json.loads(Path(p['environment']).read_text());r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
 def source_guard():
  assert sha(path)==r['planSHA256']
  assert all(sha(n)==s for n,s in p['pins'].items());assert inv(stage)==p['inventory'];assert inv(Path(p['resource']))==p['resourceInventory'];assert sha(p['environment'])==p['environmentSHA256'];assert configs(list(map(Path,p['configRoots'])))==p['configs']
 def generated_guard():
  assert all(sha(n)==s for n,s in generated.items());runner.inputs.guard()
 def generated_registration():
  assert sha(path)==r['planSHA256']
  for c in p['commands']:
   if 'artifact' in c and Path(c['artifact']).is_file() and c['artifact'] not in generated:generated[c['artifact']]=sha(c['artifact'])
  runner.inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage])
 def evidence_record():
  r['logs']=dict(logs.hashes);r['generated']=dict(generated)
 guards=[('generated-registration',generated_registration),('source-config-env',source_guard),('raw',logs.guard),('generated',generated_guard),('record-evidence',evidence_record)]
 with B.ReceiptBoundary(r,out/'receipt.json',guards):
  source_guard();logs.guard()
  for c in p['commands']:
   item={**c,'exit':None,'failure':None};r['commands'].append(item)
   with B.GuardBoundary(guards):
    source_guard();logs.guard();generated_guard()
    if 'artifact' in c:assert not Path(c['artifact']).exists()
    try:
     result=runner.run(c['label'],c['argv'],c['seconds'],expected=None);item.update(exit=result['exit'],failure=result['failure'])
    except BaseException as e:
     result=getattr(e,'result',None)
     if result is not None:item.update(exit=result['exit'],failure=result['failure'])
     raise
    assert result['exit']==0 and result['failure'] is None
    assert result['stdout']==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
    assert result['stderr'] in [b'',b'bend 2.0.36 is available: run bend update\n']
   r['logs']=dict(logs.hashes);r['generated']=dict(generated)
  r['status']='MUTANT_SOURCE_SHAPES_TYPECHECKED_NOT_REACHED_NOT_PROOF_NOT_DELIVERY'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
