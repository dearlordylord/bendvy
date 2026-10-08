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
  if p.is_symlink():
   resolved=p.resolve();kind='file' if resolved.is_file() else 'directory' if resolved.is_dir() else 'absent' if not resolved.exists() else 'other'
   return {'kind':'symlink','target':os.readlink(p),'resolvedPath':str(resolved),'resolvedKind':kind,'resolvedSHA256':sha(resolved) if kind=='file' else None,'resolvedInventory':inv(resolved) if kind=='directory' else None}
  if p.is_file():return {'kind':'file','sha256':sha(p)}
  if p.is_dir():return {'kind':'directory','inventory':inv(p)}
  return {'kind':'absent'}
 return {str(p):state(p) for p in paths}
def prepare():
 out=HERE/'preflight'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';stage.mkdir();sources={}
 refroot=ROOT/'.references/bevy-ts/packages/core';shutil.copytree(refroot/'src',stage/'reference/src');shutil.copyfile(refroot/'package.json',stage/'reference/package.json')
 for file in (refroot/'src').rglob('*'):
  if file.is_file():sources[str(file)]=sha(file)
 sources[str(refroot/'package.json')]=sha(refroot/'package.json')
 (stage/'study').mkdir()
 for name in ['reference.ts','ORACLE.json']:
  source=HERE/name;sources[str(source)]=sha(source);(stage/'study'/name).write_text(source.read_text().replace(str(refroot/'src')+'/',str(stage/'reference/src')+'/'))
 (stage/'study/package.json').write_text('{"type":"module"}\n')
 env=dict(os.environ)
 for name in list(env):
  if name in ['NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE'] or name.startswith(('LD_','DYLD_')):env.pop(name,None)
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 tools={name:str(Path(shutil.which(name)).resolve()) for name in ['node','taskset']}
 files=[Path(__file__),ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'scripts/evidence_boundary.py',private,*map(Path,tools.values())]
 roots=[ROOT,HERE,out,stage,*[Path(name).parent for name in tools.values()],*[f.parent for f in stage.rglob('*') if f.is_file()],*[Path(name).parent for name in sources]]
 plan={'scope':'Development actual pinned TS full2 Description typed DTOs and lossless before/after; direct installed tools, no ordinary resolver discovery/delivery/Bend/full56 claim','pins':{**sources,**{str(file):sha(file) for file in files}},'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'commands':[{'label':'reference','argv':[tools['taskset'],'-c','5',tools['node'],str(stage/'study/reference.ts')],'seconds':5}]}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))
def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=json.loads(Path(p['environment']).read_text());r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=L.CommandLogs(out,[c['label'] for c in p['commands']]);inputs=T.Inputs(files=[path,*p['pins']],directories=[stage]);runner=T.Runner(logs,inputs=inputs,env=env,cwd=stage,capture='split')
 def source_guard():
  assert sha(path)==r['planSHA256']
  assert all(sha(n)==s for n,s in p['pins'].items());assert inv(stage)==p['inventory'];assert sha(p['environment'])==p['environmentSHA256'];assert configs(list(map(Path,p['configRoots'])))==p['configs']
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
    assert result['exit']==0 and result['failure'] is None and result['stderr']==b''
    rows=[json.loads(line) for line in result['stdout'].splitlines()];oracle=json.loads((stage/'study/ORACLE.json').read_text())['cases']
    assert len(rows)==2 and [{'name':row['name'],'description':row['dto']} for row in rows]==oracle
    assert all(row['beforeDTO']==row['afterDTO']==row['dto'] for row in rows)
   r['logs']=dict(logs.hashes);r['generated']=dict(generated)
  r['status']='DEVELOPMENT_ACTUAL_TS_FULL_DTO2_PASS_NOT_BEND_NOT_DELIVERY_NOT_FULL56'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
