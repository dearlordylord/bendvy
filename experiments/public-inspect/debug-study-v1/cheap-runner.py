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
   for n in ['check.json','bend.json','bender.json','package.json','.bend.json','bend.config.json','tsconfig.json','.node-version','.nvmrc','.npmrc']:paths.add(p/n)
 return {str(p):sha(p) if p.is_file() else None for p in paths}
def prepare(reuse=None):
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
 for name in ['reference.ts','normalize-limit.js','EXPECTED.stdout','ORACLE.json']:
  source=HERE/name;sources[str(source)]=sha(source);target=stage/'study'/name;target.write_text(source.read_text().replace(str(refroot/'src/index.ts'),str(stage/'reference/src/index.ts')))
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
 plan={'scope':'Development full-oracle preflight; direct tool/resource pins, no fresh owned loader probes and no delivery qualification','pins':{**sources,**{str(p):sha(p) for p in files}},'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'resource':str(resource),'resourceInventory':inv(resource),'configRoots':sorted({str(p) for p in [ROOT,HERE,stage,resource,Path('/home/node/.bend'),*[p.parent for p in stage.rglob('*') if p.is_file()],*[Path(p).parent for p in sources]]}),'configs':configs([ROOT,HERE,stage,resource,Path('/home/node/.bend'),*[p.parent for p in stage.rglob('*') if p.is_file()],*[Path(p).parent for p in sources]]),'emitDiagnosticSource':str(ROOT/'.references/bend2/bend2/main.ts'),'emitDiagnosticSHA256':sha(ROOT/'.references/bend2/bend2/main.ts'),'commands':[{'label':'reference','argv':[tools['taskset'],'-c','5',tools['node'],str(stage/'study/reference.ts')],'seconds':5},{'label':'emit','argv':[tools['taskset'],'-c','5',tools['bend'],str(stage/'study/main.bend'),'-o',str(out/'main.js')],'seconds':30,'artifact':str(out/'main.js')},{'label':'candidate','argv':[tools['taskset'],'-c','5',tools['node'],str(out/'main.js')],'seconds':5}]}
 if reuse:
  # Freeze all preceding development raw/receipts/stages/history without replay.
  for previous in (HERE/'preflight').iterdir():
   if previous==out:continue
   for file in previous.rglob('*'):
    if file.is_file():plan['pins'][str(file)]=sha(file)
  for file in (HERE/'history-unary-limit').rglob('*'):
   if file.is_file():plan['pins'][str(file)]=sha(file)
  prior=Path(reuse).resolve();oldplan=json.loads((prior.parent/'plan.json').read_text());oldreceipt=json.loads(prior.read_text())
  assert oldreceipt['planSHA256']==sha(prior.parent/'plan.json') and oldreceipt['commands'][0]['label']=='reference' and oldreceipt['commands'][0]['exit']==0 and oldreceipt['commands'][0]['failure'] is None
  for n,h in oldplan['pins'].items():
   if str(refroot) in n or n in [str(HERE/'reference.ts'),str(HERE/'normalize-limit.js')]:assert sha(n)==h;plan['pins'][n]=h
  for n in ['plan.json','receipt.json','reference.stdout','reference.stderr','emit.stdout','emit.stderr']:
   file=prior.parent/n;plan['pins'][str(file)]=sha(file)
  assert (prior.parent/'reference.stderr').read_bytes()==b'' and len((prior.parent/'reference.stdout').read_bytes().splitlines())==16
  assert sha(prior.parent/'reference.stdout')==oldreceipt['logs']['reference.stdout'] and sha(prior.parent/'reference.stderr')==oldreceipt['logs']['reference.stderr']
  history=HERE/'history-unary-limit/cheap-runner-90f5-failure.py';assert sha(history)==oldplan['pins'][str(Path(__file__))];plan['pins'][str(history)]=sha(history)
  archivedStage=Path(oldplan['stage']);assert inv(archivedStage)==oldplan['inventory']
  for file in archivedStage.rglob('*'):
   if file.is_file():plan['pins'][str(file)]=sha(file)
  plan['failedHistory']={'receiptStatus':oldreceipt['status'],'compilerStdout':str(prior.parent/'emit.stdout'),'compilerStderr':str(prior.parent/'emit.stderr'),'wrapper':str(history),'stage':str(archivedStage)}
  plan['commands']=plan['commands'][1:];plan['referenceReuse']={'receipt':str(prior),'raw':str(prior.parent/'reference.stdout'),'scope':'Actual prior Node TS16 PASS reused exact original source; no fresh reference call'}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))
def prepare_generated(receipt):
 prior=Path(receipt).resolve();oldpath=prior.parent/'plan.json';old=json.loads(oldpath.read_text());r=json.loads(prior.read_text())
 assert r['status']=='INCOMPLETE' and r['planSHA256']==sha(oldpath) and len(r['commands'])==1 and r['commands'][0]['label']=='emit' and r['commands'][0]['exit']==0 and r['commands'][0]['failure'] is None and r['guardFailures']==[]
 assert (prior.parent/'emit.stdout').read_bytes()==b'' and (prior.parent/'emit.stderr').read_bytes()==b'bend 2.0.36 is available: run bend update\n'
 artifact=Path(old['commands'][0]['artifact']);assert sha(artifact)==r['generated'][str(artifact)]
 history=HERE/'history-unary-limit/cheap-runner-160cf-failure.py';assert sha(history)==old['pins'][str(Path(__file__))]
 pins={}
 for name,digest in old['pins'].items():
  if name==str(Path(__file__)):continue
  assert sha(name)==digest;pins[name]=digest
 for file in [oldpath,prior,prior.parent/'emit.stdout',prior.parent/'emit.stderr',history,artifact,Path(__file__),ROOT/'.references/bend2/bend2/main.ts']:
  pins[str(file)]=sha(file)
 stage=Path(old['stage']);assert inv(stage)==old['inventory']
 out=HERE/'preflight'/str(time.time_ns());out.mkdir();roots=list(map(Path,old['configRoots']))+[out,artifact.parent]
 classification=out/'emit-classification.json';classification.write_text(json.dumps({'status':'EXACT_KNOWN_COMPILER_UPDATE_NOTICE_ONLY','originalCohortStatus':'INCOMPLETE','stderr':str(prior.parent/'emit.stderr'),'stderrSHA256':sha(prior.parent/'emit.stderr'),'bytes':42,'source':str(ROOT/'.references/bend2/bend2/main.ts'),'sourceSHA256':sha(ROOT/'.references/bend2/bend2/main.ts'),'sourceLine':203,'generated':str(artifact),'generatedSHA256':sha(artifact),'scope':'Source-backed diagnostic classification, not historical cohort PASS'},indent=2)+'\n');pins[str(classification)]=sha(classification)
 plan={**old,'pins':pins,'commands':[old['commands'][-1]],'configRoots':list(map(str,roots)),'configs':configs(roots),'preexistingGenerated':{str(artifact):sha(artifact)},'emitReuse':{'receipt':str(prior),'classification':str(classification),'scope':'Exact emitted JS reused; whole prior cohort INCOMPLETE retained; no fresh emit/TS'},'scope':'Development remaining Node5 only; exact compiled/source/TS16 reuse; no delivery'}
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
     rows=[json.loads(line) for line in result['stdout'].splitlines()];assert len(rows)==16
     for row in rows:assert row['before']==row['after']
   r['logs']=dict(logs.hashes);r['generated']=dict(generated)
  r['status']='DEVELOPMENT_PREFLIGHT_FULL16_PASS_NOT_DELIVERY'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');parser.add_argument('--reuse-reference');parser.add_argument('--reuse-emit');a=parser.parse_args();(prepare_generated(a.reuse_emit) if a.reuse_emit else prepare(a.reuse_reference)) if a.prepare else run(a.run)
