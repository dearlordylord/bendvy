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
   for n in ['check.json','bend.json','bend.jsonc','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc']:paths.add(p/n)
 return {str(p):sha(p) if p.is_file() else None for p in paths}
def prepare(reference_only=False):
 out=HERE/'preflight'/str(time.time_ns());out.mkdir(parents=True);stage=out/'stage';stage.mkdir();sources={}
 def copy_bend(source,target):
  source=source.resolve()
  if str(source) in sources:return
  sources[str(source)]=sha(source);target.parent.mkdir(parents=True,exist_ok=True);text=source.read_text()
  for name in re.findall(r'^\s*import\s+(\S+)',text,re.M):
   if name=='Base':continue
   if name.startswith('"'):
    # Foreign import is copied from its exact authored path without execution.
    foreign=(source.parent/name.strip('"')).resolve();dest=stage/'src/ecs'/foreign.name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(foreign,dest);sources[str(foreign)]=sha(foreign);continue
   child=(source.parent/name).resolve() if not name.startswith('/') else Path(name)
   if str(child).startswith(str(ROOT/'src/ecs')):dest=stage/'src/ecs'/child.relative_to(ROOT/'src/ecs')
   else:dest=stage/'study'/child.name
   copy_bend(child,dest)
  text=text.replace(str(ROOT/'src/ecs')+'/',os.path.relpath(stage/'src/ecs',target.parent)+'/')
  target.write_text(text)
 copy_bend(HERE/'main.bend',stage/'study/main.bend')
 refroot=ROOT/'.references/bevy-ts/packages/core';shutil.copytree(refroot/'src',stage/'reference/src');shutil.copyfile(refroot/'package.json',stage/'reference/package.json')
 for f in (refroot/'src').rglob('*'):
  if f.is_file():sources[str(f)]=sha(f)
 sources[str(refroot/'package.json')]=sha(refroot/'package.json')
 for name in ['reference.ts','EXPECTED.stdout','ORACLE.json']:
  source=HERE/name;sources[str(source)]=sha(source);target=stage/'study'/name;target.write_text(source.read_text().replace(str(refroot/'src')+'/',str(stage/'reference/src')+'/'))
 # Explicit module semantics for authored .js without installing dependencies.
 (stage/'study/package.json').write_text('{"type":"module"}\n')
 env=dict(os.environ)
 for n in ['NODE_OPTIONS','NODE_PATH','NODE_REPL_EXTERNAL_MODULE']:env.pop(n,None)
 for n in list(env):
  if n.startswith(('LD_','DYLD_')):env.pop(n,None)
 private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 files=[Path(__file__),ROOT/'scripts/task_runner.py',ROOT/'scripts/receipt-logs.py',ROOT/'scripts/evidence_boundary.py',private]
 tools={n:str(Path(shutil.which(n)).resolve()) for n in ['node','bend','taskset']}
 files+=list(map(Path,tools.values()));files.append(ROOT/'.references/bend2/bend2/main.ts')
 # Static compiler resource tree; no discovery commands or version probes.
 resource=Path('/home/node/.bend/bend2');files += [p for p in resource.rglob('*') if p.is_file()]
 plan={'scope':'Development full-oracle preflight; direct tool/resource pins, no fresh owned loader probes and no delivery qualification','pins':{**sources,**{str(p):sha(p) for p in files}},'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'resource':str(resource),'resourceInventory':inv(resource),'configRoots':sorted({str(p) for p in [ROOT,HERE,stage,resource,Path('/home/node/.bend'),*[Path(n).parent for n in tools.values()],*[p.parent for p in stage.rglob('*') if p.is_file()],*[Path(p).parent for p in sources]]}),'configs':configs([ROOT,HERE,stage,resource,Path('/home/node/.bend'),*[Path(n).parent for n in tools.values()],*[p.parent for p in stage.rglob('*') if p.is_file()],*[Path(p).parent for p in sources]]),'emitDiagnosticSource':str(ROOT/'.references/bend2/bend2/main.ts'),'emitDiagnosticSHA256':sha(ROOT/'.references/bend2/bend2/main.ts'),'commands':[{'label':'reference','argv':[tools['taskset'],'-c','5',tools['node'],str(stage/'study/reference.ts')],'seconds':5},{'label':'emit','argv':[tools['taskset'],'-c','5',tools['bend'],str(stage/'study/main.bend'),'-o',str(out/'main.js')],'seconds':30,'artifact':str(out/'main.js')},{'label':'candidate','argv':[tools['taskset'],'-c','5',tools['node'],str(out/'main.js')],'seconds':5}]}
 historical=[]
 for previous in (HERE/'preflight').iterdir():
  if previous==out or not (previous/'receipt.json').is_file():continue
  receipt=json.loads((previous/'receipt.json').read_text());assert receipt['planSHA256']==sha(previous/'plan.json')
  archived=json.loads((previous/'plan.json').read_text());assert inv(Path(archived['stage']))==archived['inventory']
  expectedraw={c['label']+'.'+stream for c in receipt['commands'] if c['exit'] is not None for stream in ['stdout','stderr']}
  assert set(receipt['logs'])==expectedraw
  assert {f.name for f in previous.iterdir() if f.is_file() and f.suffix in ['.stdout','.stderr']}==expectedraw
  assert all(sha(previous/name)==h for name,h in receipt['logs'].items())
  for file in previous.rglob('*'):
   if file.is_file():plan['pins'][str(file)]=sha(file)
  historical.append({'plan':str(previous/'plan.json'),'receipt':str(previous/'receipt.json'),'status':receipt['status'],'scope':'Original whole cohort status preserved; no subject reuse claimed'})
 for file in (HERE/'source-history').rglob('*'):
  if file.is_file():plan['pins'][str(file)]=sha(file)
 plan['historicalCohorts']=historical
 if reference_only:
  plan['commands']=plan['commands'][:1]
  plan['scope']='Development reference-only full9 failure reproduction; no candidate/emit/tool-discovery qualification'
 prior=HERE/'preflight/1791440813082986928'
 original=json.loads((prior/'plan.json').read_text());receipt=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='2ee2dce254e940d8521afc4842f026a9b3a350c0586abf03447b0eb31ebb6e97'
 assert sha(prior/'receipt.json')=='8b396cdbd105f4f02fea1002c0ad0b5ec196e7fc0c0de9dce4eed31e4c8b3ef1'
 assert receipt['status']=='DEVELOPMENT_REFERENCE_FULL9_PASS_NOT_DELIVERY'
 assert len(receipt['commands'])==1 and receipt['commands'][0]['label']=='reference'
 assert receipt['commands'][0]['exit']==0 and receipt['commands'][0]['failure'] is None
 assert set(receipt['logs'])=={'reference.stdout','reference.stderr'}
 assert all(sha(prior/name)==digest for name,digest in receipt['logs'].items())
 assert (prior/'reference.stderr').read_bytes()==b''
 rows=[json.loads(line) for line in (prior/'reference.stdout').read_bytes().splitlines()]
 assert len(rows)==9 and [row['scoped'] for row in rows]==json.loads((HERE/'ORACLE.json').read_text())['cases']
 assert all(row['before']==row['after'] for row in rows)
 # Actual original sources must remain exact; relocated staged reference path only changes with OUT.
 assert all(plan['pins'].get(name)==digest for name,digest in sources.items() if name in original['pins'])
 assert all(sha(name)==digest for name,digest in original['pins'].items())
 oldstage=Path(original['stage']);assert inv(oldstage)==original['inventory']
 assert set(inv(stage))==set(original['inventory'])
 for name in original['inventory']:
  if name=='study/reference.ts':
   assert (stage/name).read_text()==(oldstage/name).read_text().replace(str(oldstage/'reference/src'),str(stage/'reference/src'))
  else:assert sha(stage/name)==original['inventory'][name]
 plan['commands']=plan['commands'][1:]
 plan['scope']='Development remaining candidate emit30/Node5 full9; exact successful reference-only actual TS subject reuse; no fresh reference call or delivery qualification'
 plan['referenceReuse']={'plan':str(prior/'plan.json'),'planSHA256':sha(prior/'plan.json'),'receipt':str(prior/'receipt.json'),'receiptSHA256':sha(prior/'receipt.json'),'raw':dict(receipt['logs']),'scope':'Actual full9 strict DTO and before/after source-bound TS observations only; original successful reference-only scope retained'}
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
    if c['label']=='emit':
     assert result['stderr'] in (b'',b'bend 2.0.36 is available: run bend update\n');item['stderrClassification']='EMPTY' if result['stderr']==b'' else 'EXACT_KNOWN_42B_UPDATE_NOTICE'
    else:assert result['stderr']==b''
    if c['label']=='emit':assert result['stdout']==b'';generated[c['artifact']]=sha(c['artifact'])
    elif c['label']=='candidate':assert result['stdout']==(stage/'study/EXPECTED.stdout').read_bytes()
    else:
     rows=[json.loads(line) for line in result['stdout'].splitlines()];assert len(rows)==9
     oracle=json.loads((stage/'study/ORACLE.json').read_text())['cases']
     assert [row['scoped'] for row in rows]==oracle
     for row in rows:assert row['before']==row['after']
   r['logs']=dict(logs.hashes);r['generated']=dict(generated)
  r['status']='DEVELOPMENT_REFERENCE_FULL9_PASS_NOT_DELIVERY' if len(p['commands'])==1 else 'DEVELOPMENT_DESCRIPTION_FULL9_PASS_NOT_DELIVERY_NOT_FORMAT_PUBLICATION'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--reference-only',action='store_true');a=parser.parse_args();prepare(a.reference_only) if a.prepare else run(a.run)
