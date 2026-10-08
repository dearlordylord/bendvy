"""Actual generic multi-owner default IO preflight; no backend/adoption qualification."""
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
 out=HERE/'preflight'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';stage.mkdir();sources={};joins={}
 study=HERE.parent.parent
 def target(source):
  return stage/'src/ecs'/source.relative_to(ROOT/'src/ecs') if source.is_relative_to(ROOT/'src/ecs') else stage/'study'/source.relative_to(study)
 def copy_bend(source):
  source=source.resolve()
  if str(source) in sources:return
  sources[str(source)]=sha(source);destination=target(source);destination.parent.mkdir(parents=True,exist_ok=True);text=source.read_text()
  if source.is_relative_to(ROOT/'src/ecs'):joins[str(source)]=sha(source)
  for name in re.findall(r'^\s*import\s+(\S+)',text,re.M):
   if name=='Base':continue
   foreign=name.startswith('"');child=(source.parent/name.strip('"')).resolve() if not name.startswith('/') else Path(name)
   if foreign:
    sources[str(child)]=sha(child);copied=target(child);copied.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(child,copied)
    if child.is_relative_to(ROOT/'src/ecs'):joins[str(child)]=sha(child)
   else:copy_bend(child);copied=target(child)
   rel=os.path.relpath(copied,destination.parent);rel=rel if rel.startswith('.') else './'+rel
   text=re.sub(r'(^\s*import\s+)'+re.escape(name)+r'(?=\s|$)',lambda m:m.group(1)+('"'+rel+'"' if foreign else rel),text,flags=re.M)
  destination.write_text(text)
 copy_bend(HERE/'main.bend')
 for name in ['ORACLE.json','OWNER-ORACLE.json','EXPECTED.stdout']:
  p=HERE/name;sources[str(p)]=sha(p);q=target(p);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
 prior=HERE/'preflight/1791454914248485636';old=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='4978ee5066a5813c09ae86924dfdadeb8f99421a3b782f3532b69cba6977b579'
 assert sha(prior/'receipt.json')=='a8245620dd681d40dc0647b9077c3c2f6aa3472aa0beaec8cd35a94bfa804754'
 assert receipt['status']=='DEVELOPMENT_ACTUAL_TS_FULL_DTO2_PASS_NOT_BEND_NOT_DELIVERY_NOT_FULL56'
 assert receipt.get('guardFailures',[])==[] and inv(Path(old['stage']))==old['inventory']
 assert set(receipt['logs'])=={'reference.stdout','reference.stderr'} and len(receipt['commands'])==1
 command=receipt['commands'][0];assert command['argv']==old['commands'][0]['argv'] and command['seconds']==5 and command['exit']==0 and command['failure'] is None
 assert all(sha(prior/name)==digest for name,digest in receipt['logs'].items())
 assert all(sha(name)==digest for name,digest in old['pins'].items())
 for p in prior.rglob('*'):
  if p.is_file():sources[str(p)]=sha(p)
 sources.update(old['pins'])
 env=dict(os.environ)
 for name in list(env):
  if name in ['NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'] or name.startswith(('LD_','DYLD_')):env.pop(name,None)
 env.update(OMP_NUM_THREADS='1',BEND_THREADS='1',CUDA_VISIBLE_DEVICES='')
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 tools={name:str(Path(shutil.which(name)).resolve()) for name in ['bend','taskset']}
 base=Path('/home/node/.bend/bend2/base.bend')
 files=[HERE/'pinned-notice.stderr',Path(__file__),ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'scripts/evidence_boundary.py',private,base,*map(Path,tools.values())]
 roots=[ROOT,HERE,study,out,stage,Path('/home/node/.bend/bend2'),Path(env['HOME'])/'.bend',*[Path(name).parent for name in tools.values()],*[p.parent for p in stage.rglob('*') if p.is_file()],*[Path(name).parent for name in sources]]
 plan={'scope':'Development actual multi-owner default IO full2 DTO/full World and Registry/Provisioned controls; TS reference separately reused; no proof/adoption/full56','pins':{**sources,**{str(p):sha(p) for p in files}},'rootJoins':joins,'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'notice':str(HERE/'pinned-notice.stderr'),'entry':str(target(HERE/'main.bend')),'expected':str(target(HERE/'EXPECTED.stdout')),'commands':[{'label':'candidate','argv':[tools['taskset'],'-c','5',tools['bend'],str(target(HERE/'main.bend'))],'seconds':5}]}
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
    assert result['stdout']==Path(p['expected']).read_bytes()
    # The compiler update banner is an exact independently classified tool notice.
    assert result['stderr'] in [b'',Path(p['notice']).read_bytes()]
   r['logs']=dict(logs.hashes) if logs is not None else {};r['generated']=dict(generated)
  r['status']='DEVELOPMENT_ACTUAL_MULTI_OWNER_IO_FULL_ORACLE_PASS_NOT_DELIVERY_NOT_FULL56'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
