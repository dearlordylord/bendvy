"""Reuse approved ordinary full simulation recipe; no children."""
import hashlib,json,sys,types
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def prepare():
 base=Path('/tmp/bendvy63-ordinary-delivery-plan-v6.json');p=json.loads(base.read_bytes());assert sha(base)=='89b02105f70aecdc82cdabff3be0b492f4e8d565018b7037957b6b8494af0635'
 old=Path(p['stageRoot']);stage=Path('/tmp/bendvy63-named-loop-stage-v1');out=Path('/tmp/bendvy63-named-loop-qualification-v1');assert not out.exists() and not out.is_symlink()
 source='experiments/public-simulation/bend-v1/scenario.bend'
 for rel,v in p['stagePins'].items():
  assert sha(old/rel)==v
  if rel not in [source,'stage.json']:assert (old/rel).read_bytes()==(stage/rel).read_bytes()
 assert (stage/source).read_bytes()==(H/'scenario.bend').read_bytes()
 cp=H/'compare.py';originalComparator=Path(p['comparator']);relocation=types.ModuleType('prepare');relocation.__file__=str(originalComparator.with_name('prepare.py'));sys.modules['prepare']=relocation;exec(compile(Path(relocation.__file__).read_bytes(),relocation.__file__,'exec'),relocation.__dict__);module=types.ModuleType('optimization_comparator');module.__file__=str(cp);sys.modules[module.__name__]=module;exec(compile(cp.read_bytes(),str(cp),'exec'),module.__dict__)
 assert module.stage_joins(stage)==p['constructorJoins']
 oldout=p['outputRoot'];oldstage=p['stageRoot']
 for cmd in p['commands']:cmd['argv']=[x.replace(oldout,str(out)).replace(oldstage,str(stage))for x in cmd['argv']]
 paths={Path(x)for x in p['pins']};paths.update(q for q in H.iterdir()if q.is_file());paths.update(q for q in stage.rglob('*')if q.is_file());paths.add(base)
 p.update(comparator=str(cp.resolve()),outputRoot=str(out),stageRoot=str(stage),stagePins={str(q.relative_to(stage)):sha(q)for q in stage.rglob('*')if q.is_file()},pins={str(q.resolve()):sha(q)for q in paths},scope='Single named-loop source candidate; complete unchanged14phase×2schema ordinary semantic qualification, no performance or closedresolver claim')
 p['smallInputPaths']=sorted(set(p['smallInputPaths'])|{str(q.resolve())for q in paths if str(q.resolve())not in set(p['toolConfiguration']['tools'].values())})
 p['configPresence']={k.replace(oldstage,str(stage)):v for k,v in p['configPresence'].items()}
 p['timing']='No timing before full semantic qualification; unchanged existing criteria'
 return p
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
