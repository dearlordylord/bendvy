"""Fresh multi-owner JS preflight, exact actual IO prerequisite."""
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
   for n in ['check.json','check.jsonc','bender.jsonc','.bend','bend.json','bend.jsonc','bend.toml','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc','.clang','clang.cfg','bunfig.toml']:paths.add(p/n)
 def state(p):
  if p.is_symlink():
   resolved=p.resolve();kind='file' if resolved.is_file() else 'directory' if resolved.is_dir() else 'absent' if not resolved.exists() else 'other'
   return {'kind':'symlink','target':os.readlink(p),'resolvedPath':str(resolved),'resolvedKind':kind,'resolvedSHA256':sha(resolved) if kind=='file' else None,'resolvedInventory':inv(resolved) if kind=='directory' else None}
  if p.is_file():return {'kind':'file','sha256':sha(p)}
  if p.is_dir():return {'kind':'directory','inventory':inv(p)}
  return {'kind':'absent'}
 return {str(p):state(p) for p in paths}
def equal(a,b):
 if type(a) is not type(b):return False
 if isinstance(a,dict):return a.keys()==b.keys() and all(equal(a[k],b[k]) for k in a)
 if isinstance(a,list):return len(a)==len(b) and all(equal(x,y) for x,y in zip(a,b))
 return a==b
def prepare():
 prior=HERE/'reached-v1/1791458316395361984';old=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='461a3624213a49916c5903e2b1d302d859a0f5454d27e7dc32a8286568ebf738' and sha(prior/'receipt.json')=='5164645a1c4efade23e85f1d15cb9c1d92983f597565f379de2cf91e68bc9d3e'
 assert receipt['status']=='DEVELOPMENT_MUTANT_SOURCE_TYPING_PASS_NOT_REACHED_NOT_PROOF_NOT_DELIVERY' and receipt.get('guardFailures',[])==[]
 assert set(receipt['logs'])=={c['label']+'.'+stream for c in old['commands'] for stream in ['stdout','stderr']} and all(sha(prior/n)==h for n,h in receipt['logs'].items())
 assert len(receipt['commands'])==2 and all(c['exit']==0 and c['failure'] is None and c['argv']==old['commands'][j]['argv'] and c['seconds']==5 for j,c in enumerate(receipt['commands']))
 assert inv(Path(old['stage']))==old['inventory'] and all(sha(n)==h for n,h in old['pins'].items())
 out=HERE/'reached-v1'/str(time.time_ns());out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage);assert inv(stage)==old['inventory'];pins=dict(old['pins'])
 for f in prior.rglob('*'):
  if f.is_file():pins[str(f)]=sha(f)
 env=json.loads(Path(old['environment']).read_text());private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 tools={n:str(Path(shutil.which(n)).resolve()) for n in ['bend','node','taskset']}
 for f in [Path(__file__),private,*map(Path,tools.values())]:pins[str(f)]=sha(f)
 commands=[]
 for label in ['omitted-needs','cursor-mutated']:
  entry=stage/label/'study/production-adoption-v1/authoring-v1/main.bend';artifact=out/(label+'.js');expected=HERE/'reached-v1'/(label+'.stdout')
  commands.extend([{'label':label+'-emit','argv':[tools['taskset'],'-c','5',tools['bend'],str(entry),'-o',str(artifact)],'seconds':30,'artifact':str(artifact)},{'label':label+'-candidate','argv':[tools['taskset'],'-c','5',tools['node'],str(artifact)],'seconds':5,'expected':str(expected)}])
 roots=[ROOT,HERE,out,stage,Path(env['HOME'])/'.bend',*[Path(n).parent for n in pins],*[f.parent for f in stage.rglob('*') if f.is_file()]]
 plan={'scope':'Fresh JS two reached full15-line independent counterfactuals; all owners/DTO rows retained, no Native/proof/full56','pins':pins,'rootJoins':old['rootJoins'],'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'notice':old['notice'],'commands':commands,'typedPrerequisite':{'plan':str(prior/'plan.json'),'receipt':str(prior/'receipt.json')}}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))

def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=None;r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=None;runner=None
 def source_guard():
  assert sha(path)==r['planSHA256']
  assert all(sha(n)==s for n,s in p['pins'].items());assert inv(stage)==p['inventory'];assert sha(p['environment'])==p['environmentSHA256'];assert configs(list(map(Path,p['configRoots'])))==p['configs'];assert sha(p['notice'])=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
 def generated_guard():
  assert all(sha(n)==s for n,s in generated.items())
  if runner is not None:runner.inputs.guard()
 def generated_registration():
  assert sha(path)==r['planSHA256']
  for c in p['commands']:
   if 'artifact' in c and Path(c['artifact']).is_file() and c['artifact'] not in generated:generated[c['artifact']]=sha(c['artifact'])
  if runner is not None:runner.inputs=T.Inputs(files=[path,*p['pins'],*generated],directories=[stage])
 def evidence_record():
  r['logs']=dict(logs.hashes) if logs is not None else {};r['generated']=dict(generated)
 def raw_guard():
  if logs is not None:logs.guard()
 guards=[('generated-registration',generated_registration),('source-config-env',source_guard),('raw',raw_guard),('generated',generated_guard),('record-evidence',evidence_record)]
 with B.ReceiptBoundary(r,out/'receipt.json',guards):
  source_guard()
  env=json.loads(Path(p['environment']).read_text());logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);logs.guard()
  runner=T.Runner(logs,inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]),env=env,cwd=stage,capture='split')
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
    if c['label'].endswith('-emit'):
     assert result['stdout']==b'' and result['stderr'] in [b'',Path(p['notice']).read_bytes()] and Path(c['artifact']).is_file()
    else:
     assert result['stdout']==Path(c['expected']).read_bytes() and result['stderr']==b''
   r['logs']=dict(logs.hashes) if logs is not None else {};r['generated']=dict(generated)
  r['status']='DEVELOPMENT_REACHED_MUTANT_JS_FULL_ORACLES_PASS_NOT_NATIVE_PROOF_FULL56'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
