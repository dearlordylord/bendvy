"""Fresh nominal shared-declaration IO prototype; prior scope remains separate."""
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
   for n in ['bend.toml','check.json','check.jsonc','bender.jsonc','.bend','bend.json','bend.jsonc','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc','.clang','clang.cfg','bunfig.toml']:paths.add(p/n)
 def state(p):
  if p.is_symlink():
   resolved=p.resolve();kind='file' if resolved.is_file() else 'directory' if resolved.is_dir() else 'absent' if not resolved.exists() else 'other'
   return {'kind':'symlink','target':os.readlink(p),'resolvedPath':str(resolved),'resolvedKind':kind,'resolvedSHA256':sha(resolved) if kind=='file' else None,'resolvedInventory':inv(resolved) if kind=='directory' else None}
  if p.is_file():return {'kind':'file','sha256':sha(p)}
  if p.is_dir():return {'kind':'directory','inventory':inv(p)}
  return {'kind':'absent'}
 return {str(p):state(p) for p in paths}
def prepare():
 out=HERE/'preflight'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';stage.mkdir();sources={}
 def copy_bend(source):
  source=source.resolve()
  if str(source) in sources:return
  sources[str(source)]=sha(source)
  if source.is_relative_to(ROOT/'src/ecs'):target=stage/'src/ecs'/source.relative_to(ROOT/'src/ecs')
  else:target=stage/'study'/source.relative_to(HERE.parent)
  target.parent.mkdir(parents=True,exist_ok=True);text=source.read_text()
  for name in re.findall(r'^\s*import\s+(\S+)',text,re.M):
   if name=='Base':continue
   foreign=name.startswith('"');child=(source.parent/name.strip('"')).resolve() if not name.startswith('/') else Path(name)
   if foreign:
    destination=stage/'src/ecs'/child.relative_to(ROOT/'src/ecs');destination.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(child,destination);sources[str(child)]=sha(child)
   else:
    copy_bend(child)
    destination=stage/'src/ecs'/child.relative_to(ROOT/'src/ecs') if child.is_relative_to(ROOT/'src/ecs') else stage/'study'/child.relative_to(HERE.parent)
   relocated=os.path.relpath(destination,target.parent);relocated=relocated if relocated.startswith('.') else './'+relocated
   text=re.sub(r'(^\s*import\s+)'+re.escape(name)+r'(?=\s|$)',lambda m:m.group(1)+('"'+relocated+'"' if foreign else relocated),text,flags=re.M)
  target.write_text(text)
 copy_bend(HERE/'main-v2.bend')
 for name in ['ORACLE.json','OWNER-V2-ORACLE.json','EXPECTED-V2.stdout']:
  source=HERE/name;sources[str(source)]=sha(source);shutil.copyfile(source,stage/'study/full-dto-v1'/name)
 prior=HERE/'preflight/1791445919387571114';old=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='7281cc169cc84647fd8aace1e618971a7518dcaf5adbec09d39a05dd479aac8c' and sha(prior/'receipt.json')=='9efcb8e84369351f423814c9715607973a6ce3d0c0932cdc0dc334082481126f'
 assert inv(Path(old['stage']))==old['inventory'];assert set(receipt['logs'])=={'reference.stdout','reference.stderr'}
 assert all(sha(prior/name)==digest for name,digest in receipt['logs'].items())
 for file in prior.rglob('*'):
  if file.is_file():sources[str(file)]=sha(file)
 for name,digest in old['pins'].items():
  if '/.references/bevy-ts/' in name or name==str(HERE/'reference.ts') or name==str(HERE/'ORACLE.json'):assert sha(name)==digest;sources[name]=digest
 failed=HERE/'preflight/1791447217620126472';failedPlan=json.loads((failed/'plan.json').read_text());failedReceipt=json.loads((failed/'receipt.json').read_text())
 assert sha(failed/'plan.json')=='99164c03d65a474dd3078c7d949eda6ea3dca09dd0fcb5cbe4fce001f087d3b9' and sha(failed/'receipt.json')=='2f32ed1920e2ef06dba27e3d084919bb090f4c37e5378805a5221ea6b0469351'
 assert failedReceipt['status']=='INCOMPLETE' and failedReceipt['commands']==[{**failedPlan['commands'][0],'exit':0,'failure':None}] and not failedReceipt.get('guardFailures',[])
 assert inv(Path(failedPlan['stage']))==failedPlan['inventory'];assert set(failedReceipt['logs'])=={'candidate-io.stdout','candidate-io.stderr'};assert all(sha(failed/name)==digest for name,digest in failedReceipt['logs'].items())
 for file in failed.rglob('*'):
  if file.is_file():sources[str(file)]=sha(file)
 for file in (HERE/'source-history/io99164-render-order').rglob('*'):
  if file.is_file():sources[str(file)]=sha(file)
 assert sha(HERE/'source-history/io99164-render-order/render.bend')==failedPlan['pins'][str(HERE/'render.bend')]
 assert sha(HERE/'source-history/io99164-render-order/io-runner.py')==failedPlan['pins'][str(HERE/'io-runner.py')]
 for name,digest in failedPlan['pins'].items():
  if name.startswith(str(ROOT/'src/ecs')) or name.startswith(str(HERE.parent)) and name.endswith('.bend') and name!=str(HERE/'render.bend'):assert sha(name)==digest
 successful=HERE/'preflight/1791447933964133413';successPlan=json.loads((successful/'plan.json').read_text());successReceipt=json.loads((successful/'receipt.json').read_text())
 assert sha(successful/'plan.json')=='d5ba21da2bf90418da9a8d1163ef64d002835ac009069e3786dfd4986cc37880' and sha(successful/'receipt.json')=='f2e70e5380b8f41ba9801cdf94753080614ecd5b805a36155ad167442ccc0a18'
 assert successReceipt['status']=='DEVELOPMENT_ACTUAL_BEND_IO_FULL_DTO2_PASS_NOT_JS_NATIVE_DELIVERY_FULL56' and not successReceipt.get('guardFailures',[]) and successReceipt['commands']==[{**successPlan['commands'][0],'exit':0,'failure':None}]
 assert inv(Path(successPlan['stage']))==successPlan['inventory'];assert set(successReceipt['logs'])=={'candidate-io.stdout','candidate-io.stderr'} and all(sha(successful/name)==digest for name,digest in successReceipt['logs'].items())
 for file in successful.rglob('*'):
  if file.is_file():sources[str(file)]=sha(file)
 env=dict(os.environ)
 for name in list(env):
  if name in ['NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'] or name.startswith(('LD_','DYLD_')):env.pop(name,None)
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 tools={name:str(Path(shutil.which(name)).resolve()) for name in ['bend','taskset']}
 resource=Path('/home/node/.bend/bend2')
 files=[*[f for f in resource.rglob('*') if f.is_file()],ROOT/'.references/bend2/bend2/main.ts',Path(__file__),ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'scripts/evidence_boundary.py',private,*map(Path,tools.values())]
 roots=[ROOT,HERE,out,stage,resource,Path('/home/node/.bend'),*[Path(name).parent for name in tools.values()],*[f.parent for f in stage.rglob('*') if f.is_file()],*[Path(name).parent for name in sources]]
 plan={'scope':'Development actual Bend namespace IO full2 Description DTO and exact full owner controls; actual prior TS2 reuse, no fresh TS/tool probes/delivery/full56','pins':{**sources,**{str(file):sha(file) for file in files}},'stage':str(stage),'inventory':inv(stage),'resource':str(resource),'resourceInventory':inv(resource),'trustedPreflight':{'plan':str(successful/'plan.json'),'receipt':str(successful/'receipt.json'),'scope':'Previous trusted metadata IO actual PASS only, not current declaration-v2 acceptance'},'failedIO':{'plan':str(failed/'plan.json'),'receipt':str(failed/'receipt.json'),'status':'INCOMPLETE','soleSourceDelta':'Full DTO local lint renderer subject-before-message; independent oracle unchanged'},'referenceReuse':{'plan':str(prior/'plan.json'),'receipt':str(prior/'receipt.json'),'raw':str(prior/'reference.stdout'),'scope':'Actual successful TS2 reuse only; no fresh TS call'},'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'commands':[{'label':'candidate-io','argv':[tools['taskset'],'-c','5',tools['bend'],str(stage/'study/full-dto-v1/main-v2.bend')],'seconds':5}]}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=json.loads(Path(p['environment']).read_text());r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
 def source_guard():
  assert sha(path)==r['planSHA256']
  assert all(sha(n)==s for n,s in p['pins'].items());assert inv(stage)==p['inventory'];assert sha(p['environment'])==p['environmentSHA256'];assert inv(Path(p['resource']))==p['resourceInventory'];assert configs(list(map(Path,p['configRoots'])))==p['configs']
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
    assert result['exit']==0 and result['failure'] is None and result['stderr'] in [b'',b'bend 2.0.36 is available: run bend update\n']
    assert result['stdout']==(stage/'study/full-dto-v1/EXPECTED-V2.stdout').read_bytes()
    lines=result['stdout'].splitlines();rows=[json.loads(line) for line in lines[:2]];oracle=json.loads((stage/'study/full-dto-v1/ORACLE.json').read_text())['cases']
    def strict(a,b):
     if type(a) is not type(b):return False
     if isinstance(a,dict):return a.keys()==b.keys() and all(strict(a[k],b[k]) for k in a)
     if isinstance(a,list):return len(a)==len(b) and all(strict(x,y) for x,y in zip(a,b))
     return a==b
    assert len(lines)==6 and strict(rows,oracle)
    controls=json.loads((stage/'study/full-dto-v1/OWNER-V2-ORACLE.json').read_text());assert lines[2:]==[('ownerBefore='+controls['before']).encode(),('ownerAfter='+controls['after']).encode(),('registration='+controls['registration']).encode(),('requirements='+controls['requirements']).encode()]
   r['logs']=dict(logs.hashes);r['generated']=dict(generated)
  r['status']='DEVELOPMENT_ACTUAL_DECLARATION_IO_FULL_DTO2_PASS_NOT_JS_NATIVE_DELIVERY_FULL56'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
