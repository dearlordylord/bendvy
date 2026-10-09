"""Metadata-only copied-compiler batch; never starts a compiler child."""
from pathlib import Path
import hashlib,json,os,re,shutil,sys,types
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
REFERENCE=ROOT/'.references/bend2/bend2'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def load(p):
 m=types.ModuleType(p.stem);m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__);return m

def main():
 assert sha(REFERENCE/'comp.ts')=='32fb66e09f608ce9e4b173384bcfeec453db8c5bc96650e26ad861bef815a8d9'
 target=Path('/tmp/bendvy-layout-equality-v1-batch01');target.mkdir()
 manifest=json.loads((HERE/'source-manifest.json').read_text())
 for mode in ('baseline','candidate'):
  copy=target/mode;copy.mkdir()
  for name in ('bend.ts','base.bend') :shutil.copyfile(REFERENCE/name,copy/name)
  shutil.copytree(REFERENCE/'effs',copy/'effs')
  shutil.copyfile(REFERENCE/'comp.ts' if mode=='baseline' else HERE/'comp.ts',copy/'comp.ts')
  shutil.copyfile(HERE/'emit.mts',copy/'emit.mts')
 configuration=load(ROOT/'experiments/public-simulation/delivery-v1/installed-config.py')
 runner=load(ROOT/'scripts/task_runner.py')
 node=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node').resolve()
 tools={'node':str(node),'python':str(Path(sys.executable).resolve()),'taskset':'/usr/bin/taskset'}
 fixed=[HERE/'development.py',HERE/'prepare.py',HERE/'emit.mts',HERE/'comp.ts',HERE/'source-manifest.json',HERE/'controls.mjs',HERE/'portable-control-result.json',ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py',*map(Path,tools.values())]
 fixedpins={str(p.resolve()):sha(p) for p in fixed}
 copyfiles=[p for mode in ('baseline','candidate') for p in (target/mode).rglob('*') if p.is_file()]
 fixedpins.update({str(p):sha(p) for p in copyfiles})
 index={'status':'FROZEN_UNADMITTED_NO_COMPILER_CHILD','plans':[],'equalityPairs':[],'candidateFullOnly':True}
 def plan(label,mode,stage,entry,inventory):
  stage=stage.resolve();seen=set()
  def visit(p):
   p=p.resolve()
   if p in seen:return
   seen.add(p)
   for dep in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
    if dep!='Base':visit(p.parent/dep)
  visit(stage/entry)
  assert all(p.is_relative_to(stage) for p in seen)
  pins=dict(fixedpins);pins.update({str(stage/n):h for n,h in inventory.items()})
  out=target/label;out.mkdir()
  data={'scope':'Copied clean-reference layout-string equality experiment; emit only, no runtime/performance acceptance','tools':tools,'pins':pins,'resourceRoots':runner.Inputs(directories=[str(target/'baseline'),str(target/'candidate'),str(stage)]).expected,'stage':str(stage),'sourceInventory':inventory,'entryRelative':entry,'importClosure':sorted(str(p.relative_to(stage)) for p in seen),'environment':configuration.environment(),'cwd':str(HERE),'generated':str(out/'scenario.c'),'native':str(out/'unused.native'),'commands':[{'label':'emit','argv':[tools['taskset'],'-c','5',tools['node'],str(target/mode/'emit.mts'),str(stage/entry),str(out/'scenario.c')],'capSeconds':30}]}
  path=out/'plan.json';path.write_text(json.dumps(data,indent=2)+'\n')
  row={'label':label,'mode':mode,'plan':str(path),'sha256':sha(path),'launchArgv':[tools['python'],str(HERE/'development.py'),str(path),sha(path)]};index['plans'].append(row);return row
 for fixture in manifest['fixtures']:
  source=Path(fixture['path']);assert sha(source)==fixture['sha256'];name=source.stem
  stage=target/('fixture-'+name);stage.mkdir();shutil.copyfile(source,stage/source.name)
  inv={source.name:sha(source)}
  a=plan(name+'-baseline','baseline',stage,source.name,inv);b=plan(name+'-candidate','candidate',stage,source.name,inv)
  index['equalityPairs'].append({'baseline':a['plan'],'candidate':b['plan'],'comparison':'entire generated scenario.c bytes only when both complete'})
 previous=Path('/tmp/bendvy-inspect54-initial-layout01/plan.json');old=json.loads(previous.read_text());stage=Path(old['stage'])
 assert {str(p.relative_to(stage)):sha(p) for p in stage.rglob('*.bend')}==old['sourceInventory']
 full=plan('inspector-candidate','candidate',stage,Path(old['entrypoint']).name,old['sourceInventory'])
 index['originalStaticPlan']={'path':str(previous),'sha256':sha(previous),'scope':'source closure only; static instrumented compiler is NOT baseline'}
 (HERE/'batch-index.json').write_text(json.dumps(index,indent=2)+'\n')
 for row in index['plans']:
  destination=HERE/'prepared'/row['label'];destination.mkdir(parents=True);shutil.copyfile(row['plan'],destination/'plan.json')
 print(json.dumps({'plans':len(index['plans']),'index':str(HERE/'batch-index.json'),'sha256':sha(HERE/'batch-index.json')}))
if __name__=='__main__':main()
