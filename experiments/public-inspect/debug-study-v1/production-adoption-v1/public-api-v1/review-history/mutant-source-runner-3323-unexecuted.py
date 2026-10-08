"""Matched canonical-factory source collection; raw negatives stay unclassified."""
import argparse,hashlib,importlib.util,json,os,re,shutil,sys,time
from pathlib import Path
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=Path(__file__).resolve().parent
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p,n):
 spec=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
T=load(ROOT/'scripts/task_runner.py','task_runner');L=load(ROOT/'scripts/receipt-logs.py','logs');B=load(ROOT/'scripts/evidence_boundary.py','boundary')
def inv(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
def fulltree(root,trail=()):
 root=Path(root);real=str(root.resolve())
 if real in trail:return {'@cycle':{'kind':'cycle','resolvedPath':real}}
 trail=(*trail,real);result={}
 for entry in sorted(root.rglob('*')):
  result[str(entry.relative_to(root))]=fullstate(entry,trail)
 return result
def fullstate(p,trail=()):
 p=Path(p)
 if p.is_symlink():
  resolved=p.resolve();kind='file' if resolved.is_file() else 'directory' if resolved.is_dir() else 'absent' if not resolved.exists() else 'other'
  return {'kind':'symlink','target':os.readlink(p),'resolvedPath':str(resolved),'resolvedKind':kind,'resolvedSHA256':sha(resolved) if kind=='file' else None,'resolvedInventory':fulltree(resolved,trail) if kind=='directory' else None}
 if p.is_file():return {'kind':'file','sha256':sha(p)}
 if p.is_dir():return {'kind':'directory'}
 return {'kind':'absent'}
def configs(roots):
 names=['check.json','check.jsonc','bender.jsonc','.bend','bend.json','bend.jsonc','bend.toml','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc','.clang','clang.cfg','bunfig.toml']
 pending=set(map(Path,roots));visited=set();states={}
 def targets(value):
  if not isinstance(value,dict):return []
  result=[]
  if value.get('kind')=='symlink':result.append(Path(value['resolvedPath']))
  for child in value.values():
   if isinstance(child,dict):result.extend(targets(child))
  return result
 while pending:
  root=pending.pop()
  if root in visited:continue
  visited.add(root)
  for parent in [root,*root.parents]:
   for name in names:
    path=parent/name
    if str(path) in states:continue
    value=fullstate(path)
    if value['kind']=='directory':value['inventory']=fulltree(path)
    states[str(path)]=value
    for target in targets(value):pending.add(target if target.is_dir() else target.parent)
 return states

def equal(a,b):
 if type(a) is not type(b):return False
 if isinstance(a,dict):return a.keys()==b.keys() and all(equal(a[k],b[k]) for k in a)
 if isinstance(a,list):return len(a)==len(b) and all(equal(x,y) for x,y in zip(a,b))
 return a==b
def prepare():
 prior=HERE/'preflight/1791461522920881252';old=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='435d3c741170fdede0e301d5a317e24db2c083400f225147ba442f3bede26145' and sha(prior/'receipt.json')=='152daf0fc0b227a90a93a5be7bc355c1cf0e7584536a7b76cdc678da6525db89'
 assert receipt['status']=='DEVELOPMENT_PUBLIC_CORE_JS_FULL_ORACLE_PASS_NOT_ADOPTION_FULL56_PROOF' and receipt.get('guardFailures',[])==[]
 assert set(receipt['logs'])=={'emit.stdout','emit.stderr','candidate.stdout','candidate.stderr'} and all(sha(prior/n)==h for n,h in receipt['logs'].items())
 assert len(receipt['commands'])==2 and all(c['argv']==old['commands'][i]['argv'] and c['seconds']==old['commands'][i]['seconds'] and c['exit']==0 and c['failure'] is None for i,c in enumerate(receipt['commands']))
 assert receipt['generated']=={str(prior/'main.js'):'e0945eafe88aefc9fff42aed5ca8705ca34d9a53829d6bfc0640361edea23b9f'} and all(sha(n)==h for n,h in receipt['generated'].items())
 assert (prior/'candidate.stdout').read_bytes()==Path(old['expected']).read_bytes() and (prior/'candidate.stderr').read_bytes()==b''
 assert inv(Path(old['stage']))==old['inventory'] and all(sha(n)==h for n,h in old['pins'].items()) and fulltree(Path(old['resource']))==old['resourceInventory']
 proposal=json.loads((HERE/'reached-v1/PROPOSAL.json').read_text());assert sha(HERE/'reached-v1/PROPOSAL.json')=='60a38f741c1ff49a76a55e1ad846b3501d6fcdc9e6c77f5ef26962cf8d2beb51'
 out=HERE/'reached-v1'/str(time.time_ns());out.mkdir();stage=out/'stage';stage.mkdir();pins=dict(old['pins']);commands=[]
 tools={name:str(Path(shutil.which(name)).resolve()) for name in ['bend','taskset']}
 for variant in proposal['variants']:
  label=variant['name'];tree=stage/label;shutil.copytree(old['stage'],tree);assert inv(tree)==old['inventory']
  original=HERE/'candidate/src/ecs/debug-registered.bend';target=tree/'src/ecs/debug-registered.bend';text=target.read_text();assert text.count(variant['old'])==1;target.write_text(text.replace(variant['old'],variant['new']))
  assert sha(original)==proposal['originalSourceSHA256'] and sha(HERE/'reached-v1'/label/'debug-registered.bend')==variant['sourceSHA256'] and sha(HERE/'reached-v1'/label/'EXPECTED.stdout')==variant['expectedSHA256']
  commands.append({'label':label,'argv':[tools['taskset'],'-c','5',tools['bend'],str(tree/'client/consumer.bend'),'--check-only'],'seconds':5})
 for f in prior.rglob('*'):
  if f.is_file():pins[str(f)]=sha(f)
 env=json.loads(Path(old['environment']).read_text());private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 for f in [Path(__file__),HERE/'reached-v1/PROPOSAL.json',Path(old['positive']),Path(old['notice']),private,*map(Path,tools.values()),*list((HERE/'reached-v1').glob('*/*.bend')),*list((HERE/'reached-v1').glob('*/*.stdout'))]:pins[str(f)]=sha(f)
 roots=[ROOT,HERE,out,stage,Path(env['HOME'])/'.bend',*[Path(n).parent for n in pins],*[f.parent for f in stage.rglob('*') if f.is_file()]]
 plan={'scope':'Two full-oracle semantic mutants typing feasibility only; no reached/runtime/proof','pins':pins,'rootJoins':old['rootJoins'],'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'notice':str(Path(old['notice'])),'positive':str(Path(old['positive'])),'commands':commands,'proposal':str(HERE/'reached-v1/PROPOSAL.json'),'resource':old['resource'],'resourceInventory':old['resourceInventory']}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))

def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=None;r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=None;runner=None
 def source_guard():
  assert sha(path)==r['planSHA256']
  assert all(sha(n)==s for n,s in p['pins'].items());assert inv(stage)==p['inventory'];assert sha(p['environment'])==p['environmentSHA256'];assert configs(list(map(Path,p['configRoots'])))==p['configs'];assert sha(p['notice'])=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494';assert sha(p['positive'])=='931f1e664a679af1355a9ca547ac1daef9f7b14137bc7cc21b110b0cc504b5b1';assert fulltree(Path(p['resource']))==p['resourceInventory']
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
    assert result['failure'] is None
    assert result['exit']==0 and result['stdout']==Path(p['positive']).read_bytes() and result['stderr'] in [b'',Path(p['notice']).read_bytes()]
   r['logs']=dict(logs.hashes) if logs is not None else {};r['generated']=dict(generated)
  r['status']='DEVELOPMENT_MUTANT_SOURCE_TYPING_PASS_NOT_REACHED_NOT_PROOF_NOT_DELIVERY'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
