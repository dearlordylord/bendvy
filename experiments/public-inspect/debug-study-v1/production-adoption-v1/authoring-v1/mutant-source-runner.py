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
 prior=HERE/'preflight/1791456504443000687';old=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='33317edaeb1d44694b6bb7c027fe75e1fce74ebd54d47a15d82550d3bcf7ccae' and sha(prior/'receipt.json')=='4e812fab89865451ef7b31ab54a2b05bce9be5c234b0f63fe34db648325151a2'
 assert receipt['status']=='DEVELOPMENT_ACTUAL_MULTI_OWNER_JS_FULL_ORACLE_PASS_NOT_DELIVERY_NOT_FULL56' and receipt.get('guardFailures',[])==[]
 assert set(receipt['logs'])=={'emit.stdout','emit.stderr','candidate.stdout','candidate.stderr'} and all(sha(prior/n)==h for n,h in receipt['logs'].items())
 assert inv(Path(old['stage']))==old['inventory'] and all(sha(n)==h for n,h in old['pins'].items())
 proposal=json.loads((HERE/'reached-v1/PROPOSAL.json').read_text());assert sha(HERE/'reached-v1/PROPOSAL.json')=='d24cae8d0bf0e2ed698ae8d5fd8d3009510e2dca5214006b9cc8af99e6534dfc'
 out=HERE/'reached-v1'/str(time.time_ns());out.mkdir();stage=out/'stage';stage.mkdir();pins=dict(old['pins']);commands=[]
 tools={name:str(Path(shutil.which(name)).resolve()) for name in ['bend','taskset']}
 for variant in proposal['variants']:
  label=variant['name'];tree=stage/label;shutil.copytree(old['stage'],tree);assert inv(tree)==old['inventory']
  original=HERE/'registered.bend';target=tree/'study/production-adoption-v1/authoring-v1/registered.bend';text=target.read_text();assert text.count(variant['old'])==1;target.write_text(text.replace(variant['old'],variant['new']))
  assert sha(original)==proposal['originalSourceSHA256'] and sha(HERE/'reached-v1'/f'{label}.bend')==variant['sourceSHA256'] and sha(HERE/'reached-v1'/f'{label}.stdout')==variant['expectedSHA256']
  commands.append({'label':label,'argv':[tools['taskset'],'-c','5',tools['bend'],str(tree/'study/production-adoption-v1/authoring-v1/consumer.bend'),'--check-only'],'seconds':5})
 for f in prior.rglob('*'):
  if f.is_file():pins[str(f)]=sha(f)
 env=json.loads(Path(old['environment']).read_text());private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 for f in [Path(__file__),HERE/'reached-v1/PROPOSAL.json',HERE/'pinned-source-positive.stdout',HERE/'pinned-notice.stderr',private,*map(Path,tools.values()),*list((HERE/'reached-v1').glob('*.bend')),*list((HERE/'reached-v1').glob('*.stdout'))]:pins[str(f)]=sha(f)
 roots=[ROOT,HERE,out,stage,Path(env['HOME'])/'.bend',*[Path(n).parent for n in pins],*[f.parent for f in stage.rglob('*') if f.is_file()]]
 plan={'scope':'Two full-oracle semantic mutants typing feasibility only; no reached/runtime/proof','pins':pins,'rootJoins':old['rootJoins'],'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'notice':str(HERE/'pinned-notice.stderr'),'positive':str(HERE/'pinned-source-positive.stdout'),'commands':commands,'proposal':str(HERE/'reached-v1/PROPOSAL.json')}
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
    assert result['failure'] is None
    assert result['exit']==0 and result['stdout']==Path(p['positive']).read_bytes() and result['stderr'] in [b'',Path(p['notice']).read_bytes()]
   r['logs']=dict(logs.hashes) if logs is not None else {};r['generated']=dict(generated)
  r['status']='DEVELOPMENT_MUTANT_SOURCE_TYPING_PASS_NOT_REACHED_NOT_PROOF_NOT_DELIVERY'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
