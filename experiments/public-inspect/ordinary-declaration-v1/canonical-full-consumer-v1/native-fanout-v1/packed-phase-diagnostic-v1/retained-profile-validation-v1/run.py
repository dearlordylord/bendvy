"""Validation-only admission entry; never invokes compiler or recreates profile."""
import hashlib,json,sys,types
from pathlib import Path
root=Path(__file__).resolve().parent;planpath=root/'plan.json';expected=sys.argv[1]
assert hashlib.sha256(planpath.read_bytes()).hexdigest()==expected
plan=json.loads(planpath.read_text());assert str(Path(sys.executable).resolve())==plan['tools']['python']
for p,digest in plan['pins'].items():
    p=Path(p);assert p.is_file() and not p.is_symlink() and hashlib.sha256(p.read_bytes()).hexdigest()==digest
assert not (root/'receipt.json').exists() and not (root/'receipt.json').is_symlink()
module=types.ModuleType('retained_profile_collector');module.__file__=plan['collector']
exec(compile(Path(plan['collector']).read_bytes(),plan['collector'],'exec'),module.__dict__)
module.run(planpath,expected)
