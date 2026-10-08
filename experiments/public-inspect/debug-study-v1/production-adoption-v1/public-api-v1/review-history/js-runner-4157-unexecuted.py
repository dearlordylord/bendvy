"""Fresh public core JS full-owner qualification; metadata freeze then reviewed execution."""
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

def prepare():
 prior=HERE/'preflight/1791461164565958029';old=json.loads((prior/'plan.json').read_text());r=json.loads((prior/'receipt.json').read_text())
 assert sha(prior/'plan.json')=='2d13951c959596086a9822497879b6a6e82a840c1b213889959408d446f9f7f7' and sha(prior/'receipt.json')=='12e2b734fa458cb1899d889e108bcc9554dd9385c967126a861aabf5cd1ee28a'
 assert r['status']=='DEVELOPMENT_PUBLIC_CORE_IO_FULL_ORACLE_PASS_NOT_ADOPTION_FULL56_PROOF' and r.get('guardFailures',[])==[]
 assert len(r['commands'])==1 and r['commands'][0]['argv']==old['commands'][0]['argv'] and r['commands'][0]['seconds']==5 and r['commands'][0]['failure'] is None and r['commands'][0]['exit']==0
 assert set(r['logs'])=={'candidate.stdout','candidate.stderr'} and all(sha(prior/n)==d for n,d in r['logs'].items())
 assert (prior/'candidate.stdout').read_bytes()==Path(old['expected']).read_bytes() and (prior/'candidate.stderr').read_bytes() in [b'',Path(old['notice']).read_bytes()]
 assert inv(Path(old['stage']))==old['inventory'] and all(sha(n)==d for n,d in old['pins'].items()) and fulltree(Path(old['resource']))==old['resourceInventory']
 out=HERE/'preflight'/str(time.time_ns());out.mkdir();stage=out/'stage';shutil.copytree(old['stage'],stage);assert inv(stage)==old['inventory'];pins=dict(old['pins'])
 for f in prior.rglob('*'):
  if f.is_file():pins[str(f)]=sha(f)
 # Reuse the actual pinned TS2/raw comparator from the qualified normal capsule; no TS new call.
 priorTS=HERE.parent/'authoring-v1/preflight/1791454914248485636';ts=json.loads((priorTS/'plan.json').read_text());tr=json.loads((priorTS/'receipt.json').read_text())
 assert sha(priorTS/'plan.json')=='4978ee5066a5813c09ae86924dfdadeb8f99421a3b782f3532b69cba6977b579' and sha(priorTS/'receipt.json')=='a8245620dd681d40dc0647b9077c3c2f6aa3472aa0beaec8cd35a94bfa804754' and tr.get('guardFailures',[])==[]
 assert tr['planSHA256']==sha(priorTS/'plan.json') and tr['status']=='DEVELOPMENT_ACTUAL_TS_FULL_DTO2_PASS_NOT_BEND_NOT_DELIVERY_NOT_FULL56' and len(tr['commands'])==1 and tr['commands'][0]['argv']==ts['commands'][0]['argv'] and tr['commands'][0]['seconds']==5 and tr['commands'][0]['exit']==0 and tr['commands'][0]['failure'] is None
 assert set(tr['logs'])=={'reference.stdout','reference.stderr'} and all(sha(priorTS/n)==d for n,d in tr['logs'].items()) and inv(Path(ts['stage']))==ts['inventory']
 for n,d in ts['pins'].items():assert sha(n)==d;pins[n]=d
 for f in priorTS.rglob('*'):
  if f.is_file():pins[str(f)]=sha(f)
 env=json.loads(Path(old['environment']).read_text());private=out/'private-environment.json';private.write_text(json.dumps(env,sort_keys=True));private.chmod(0o600)
 expected=HERE.parent/'authoring-v1/EXPECTED.stdout';assert sha(expected)=='a940e1b778f2749507e642dab274c98cb7ed0d77aed4b9de195be0a77a183f6f'
 tools={n:str(Path(shutil.which(n)).resolve()) for n in ['bend','taskset','node']}
 for f in [Path(__file__),private,expected,HERE/'AUTHORITY-CLASSIFICATION.json',*map(Path,tools.values())]:pins[str(f)]=sha(f)
 roots=[ROOT,HERE,out,stage,Path(env['HOME'])/'.bend',Path(old['resource']),*[Path(n).parent for n in pins],*[f.parent for f in stage.rglob('*') if f.is_file()]]
 plan={**old,'scope':'Fresh public eight-core-module JS full9205 owner/DTO oracle; actualIO and TS2 reused, no adoption/full56/proof/perf','pins':pins,'stage':str(stage),'inventory':inv(stage),'environment':str(private),'environmentSHA256':sha(private),'configRoots':list(map(str,roots)),'configs':configs(roots),'commands':[{'label':'emit','argv':[tools['taskset'],'-c','5',tools['bend'],str(stage/'client/main.bend'),'--target','js','-o',str(out/'main.js')],'seconds':30,'artifact':str(out/'main.js')},{'label':'candidate','argv':[tools['taskset'],'-c','5',tools['node'],str(out/'main.js')],'seconds':5}],'expected':str(expected),'actualTSReuse':{'plan':str(priorTS/'plan.json'),'receipt':str(priorTS/'receipt.json')}}
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(path);print(sha(path))

def run(path):
 path=Path(path).resolve();p=json.loads(path.read_text());out=path.parent;stage=Path(p['stage']);env=None;r={'status':'INCOMPLETE','planSHA256':sha(path),'scope':p['scope'],'commands':[]};generated=dict(p.get('preexistingGenerated',{}));logs=None;runner=None
 def source_guard():
  assert sha(path)==r['planSHA256']
  assert all(sha(n)==s for n,s in p['pins'].items());assert inv(stage)==p['inventory'];assert sha(p['environment'])==p['environmentSHA256'];assert configs(list(map(Path,p['configRoots'])))==p['configs'];assert fulltree(Path(p['resource']))==p['resourceInventory'];assert sha(p['positive'])=='931f1e664a679af1355a9ca547ac1daef9f7b14137bc7cc21b110b0cc504b5b1';assert sha(p['notice'])=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
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
    if c['label']=='emit':assert result['stdout']==b'' and result['stderr'] in [b'',Path(p['notice']).read_bytes()] and Path(c['artifact']).is_file()
    else:assert result['stdout']==Path(p['expected']).read_bytes() and result['stderr']==b''
   r['logs']=dict(logs.hashes) if logs is not None else {};r['generated']=dict(generated)
  r['status']='DEVELOPMENT_PUBLIC_CORE_JS_FULL_ORACLE_PASS_NOT_ADOPTION_FULL56_PROOF'
parser=argparse.ArgumentParser();parser.add_argument('--prepare',action='store_true');parser.add_argument('--run');a=parser.parse_args();prepare() if a.prepare else run(a.run)
