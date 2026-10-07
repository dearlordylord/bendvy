"""Finalize the additive candidate catalogue; never modifies live src."""
from pathlib import Path
import hashlib,json,difflib
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
original=json.loads((HERE/'derivation.json').read_text())
for item in original['modules'] if isinstance(original.get('modules'),list) else []:
 pass
modules={p.name:sha(p) for p in sorted((HERE/'modules').glob('*.bend'))}
assert len(modules)==8
for name in modules:assert not (ROOT/'src/ecs'/name).exists(),name
patch=''.join(''.join(difflib.unified_diff([],p.read_text().splitlines(keepends=True),fromfile='/dev/null',tofile='b/src/ecs/'+p.name)) for p in sorted((HERE/'modules').glob('*.bend')))
(HERE/'additive-modules.patch').write_text(patch)
(HERE/'promotion-source.json').write_text(json.dumps({'scope':'Additive staged candidate only; no live src write, proof or acceptance','moduleCount':8,'modules':modules,'core':{p.name:sha(p) for p in sorted((ROOT/'src/ecs').glob('*.bend'))},'originalDerivationSHA256':sha(HERE/'derivation.json'),'patchSHA256':sha(HERE/'additive-modules.patch'),'recipeSHA256':sha(__file__)},indent=2)+'\n')
