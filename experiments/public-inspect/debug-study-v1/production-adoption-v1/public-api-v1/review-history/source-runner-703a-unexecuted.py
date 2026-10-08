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
 proposal=json.loads((HERE/'SOURCE-PROPOSAL.json').read_text());assert sha(HERE/'SOURCE-PROPOSAL.json')=='0d5828b5fe642b5e037b724fdfee0c3d2abf4ce9b090e024c6aa97510497d27e'
 assert sha(HERE/'authority-v1/SOURCE-PROPOSAL.json')=='1f7890acc22f15a26a5cd2b78396e79b563a61d9e0e1175cdcf59ffe5e9627d2';authority=json.loads((HERE/'authority-v1/SOURCE-PROPOSAL.json').read_text())
 for source,item in proposal['sourceMap'].items():assert sha(source)==item['sourceSHA256'] and sha(HERE/item['copy'])==item['copySHA256']
 assert all(sha(n)==h for n,h in proposal['rootJoins'].items())
 assert {f.name:sha(f) for f in (HERE/'candidate/src/ecs').glob('debug-*.bend')}==proposal['productionFiles']
 assert inv(HERE/'candidate')=={'src/ecs/'+n:d for n,d in {**proposal['productionFiles'],**proposal['copiedCurrentCoreFiles']}.items()}
 assert inv(HERE/'client')==proposal['clientFiles']
 assert set(inv(HERE/'authority-v1'))==set(authority['controls'])|{'SOURCE-PROPOSAL.json'}
 for name,item in authority['controls'].items():assert sha(HERE/'authority-v1'/name)==item['copySHA256']
 out=HERE/'preflight'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';stage.mkdir()
 for folder in ['candidate','client','authority-v1']:shutil.copytree(HERE/folder,stage/folder)
 pins={str(HERE/item['copy']):item['copySHA256'] for item in proposal['sourceMap'].values()}
 pins.update({source:item['sourceSHA256'] for source,item in proposal['sourceMap'].items()});pins.update(proposal['rootJoins']);pins.update({str(HERE/'authority-v1'/n):v['copySHA256'] for n,v in authority['controls'].items()})
 env=dict(os.environ)
 for name in list(env):
  if name in ['NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'] or name.startswith(('LD_','DYLD_')):env.pop(name,None)
 env.update(OMP_NUM_THREADS='1',BEND_THREADS='1',CUDA_VISIBLE_DEVICES='')
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 tools={name:str(Path(shutil.which(name)).resolve()) for name in ['bend','taskset']}
 for f in [Path(__file__),HERE/'SOURCE-PROPOSAL.json',HERE/'authority-v1/SOURCE-PROPOSAL.json',HERE.parent/'authoring-v1/pinned-source-positive.stdout',HERE.parent/'authoring-v1/pinned-notice.stderr',ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'scripts/evidence_boundary.py',private,Path('/home/node/.bend/bend2/base.bend'),*map(Path,tools.values())]:pins[str(f)]=sha(f)
 labels=['consumer','positive','schema','component-resource','label-resource','read-write','affine-world'];commands=[]
 for label in labels:
  target=stage/'client/consumer.bend' if label=='consumer' else stage/'authority-v1'/(label+'.bend')
  commands.append({'label':label,'argv':[tools['taskset'],'-c','5',tools['bend'],str(target),'--check-only'],'seconds':5})
 roots=[ROOT,HERE,out,stage,Path('/home/node/.bend/bend2'),Path(env['HOME'])/'.bend',*[Path(n).parent for n in pins],*[f.parent for f in stage.rglob('*') if f.is_file()]]
 plan={'scope':'Fresh public eight-module + core-only client source consumer/positive/five RAW_UNCLASSIFIED refusals; no proof/runtime/adoption/full56','pins':pins,'rootJoins':proposal['rootJoins'],'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'notice':str(HERE.parent/'authoring-v1/pinned-notice.stderr'),'positive':str(HERE.parent/'authoring-v1/pinned-source-positive.stdout'),'commands':commands}
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
    if c['label'] in ['consumer','positive']:
     assert result['exit']==0 and result['stdout']==Path(p['positive']).read_bytes() and result['stderr'] in [b'',Path(p['notice']).read_bytes()]
    else:
     assert result['exit']==1 and result['stdout']==b''
     # Complete raw stderr retained. Exit one is not classification/proof.
   r['logs']=dict(logs.hashes) if logs is not None else {};r['generated']=dict(generated)
  r['status']='DEVELOPMENT_PUBLIC_SOURCE_COLLECTION_RAW_UNCLASSIFIED_NOT_PROOF_NOT_DELIVERY'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
