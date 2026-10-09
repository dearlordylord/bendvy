"""Metadata-only successor plan using retained lowering-cost recipe; no child."""
from pathlib import Path
import json,hashlib,sys,types,shutil
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
BASE=ROOT/'experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/layout-followup-v1/leaf-lift-v1/lowering-cost-v1/plan.json'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 old=json.loads(BASE.read_text())
 assert {p:sha(p) for p in old['pins']}==old['pins']
 runnerpath=ROOT/'scripts/task_runner.py';runner=types.ModuleType('runner');runner.__file__=str(runnerpath);exec(compile(runnerpath.read_bytes(),str(runnerpath),'exec'),runner.__dict__)
 assert runner.Inputs(directories=old['resourceRoots']).expected==old['resourceRoots']
 assert len(old['sourceInventory'])==46
 assert {str(p.relative_to(old['stage'])):sha(p) for p in Path(old['stage']).rglob('*.bend')}==old['sourceInventory']
 out=Path('/tmp/bendvy-inspect54-outline-once01');out.mkdir()
 plan=dict(old);pins=dict(old['pins'])
 for p in HERE.iterdir():
  if p.is_file() and p.name not in ('plan.json','PREPARED.json'):pins[str(p.resolve())]=sha(p)
 pins[str(BASE)]=sha(BASE)
 plan.update(scope='One isolated optional-once nonflat outlining copied-compiler diagnostic; complete unchanged46-source Inspector; no runtime/performance/adoption qualification',pins=pins,cwd=str(HERE),generated=str(out/'reference.c'),native=str(out/'unused.native'),costArtifact=str(out/'cost.json'),commands=[{'label':'emit','argv':[old['tools']['taskset'],'-c','5',old['tools']['node'],str(HERE/'emit.mts'),old['entrypoint'],str(out/'reference.c'),str(out/'cost.json')],'capSeconds':30}],postConsumer='No runtime stage: complete existing costs + actual suppressed-once root/caller/callee/segment attribution',cooperativeCutoffMilliseconds=25000,behaviorSourceSHA256=sha(HERE/'comp.ts'),diagnosticSourceSHA256=sha(HERE/'cost-comp.ts'))
 path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');(HERE/'plan.json').write_bytes(path.read_bytes())
 index={'status':'FROZEN_UNADMITTED_NO_COMPILER_CHILD','plan':str(path),'sha256':sha(path),'launchArgv':[old['tools']['python'],str(HERE/'development.py'),str(path),sha(path)],'parentRecipe':str(BASE),'parentRecipeSHA256':sha(BASE),'stages':1,'scope':'candidate-onlyemit30/cooperative25; no baseline replay/Clang/runtime'}
 (HERE/'PREPARED.json').write_text(json.dumps(index,indent=2)+'\n');print(json.dumps(index))
if __name__=='__main__':main()
