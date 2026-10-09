"""Loader-only adapter of existing complete recursive declaration transport."""
import hashlib,json,re,types
from pathlib import Path
HERE=Path(__file__).resolve().parent

def parser(pins):
 rows=json.loads((HERE/'PARSER-ADAPTERS.json').read_text());by={r['original']:r for r in rows}
 def execute(origin,module):
  origin=str(Path(origin).resolve(strict=True));row=by[origin];adapted=HERE/row['adapted']
  for p in [Path(origin),adapted]:
   if p.is_symlink()or not p.is_file()or hashlib.sha256(p.read_bytes()).hexdigest()!=pins[str(p)]:raise ValueError('parser source drift')
  original=Path(origin).read_text();expected,n=re.subn(r'\b(\w+)\.loader\.exec_module\((\w+)\)',r'SOURCE_LOADER(\1.origin,\2)',original)
  if n!=row['replacements']or expected.encode()!=adapted.read_bytes():raise ValueError('loader-only inverse mismatch')
  module.__file__=origin;module.__dict__['SOURCE_LOADER']=execute
  exec(compile(adapted.read_bytes(),origin,'exec'),module.__dict__)
 module=types.ModuleType('complete_recursive_transport');execute(rows[-1]['original'],module);return module

def check(plan,cohort,raw,pins):
 P=parser(pins);identity=json.loads(Path(cohort['inventory']).read_text());join=json.loads(Path(cohort['join']).read_text())
 if cohort.get('heldIdentity'):
  path=HERE/'held-continuation-v1/identities.py'
  if hashlib.sha256(path.read_bytes()).hexdigest()!=pins[str(path)]:raise ValueError('relocation source drift')
  module=types.ModuleType('held_identity');module.__file__=str(path);exec(compile(path.read_bytes(),str(path),'exec'),module.__dict__)
  if identity!=module.derive(P,cohort['originalInventory'],cohort['entrypoint']):raise ValueError('held source/constructor inventory drift')
  P.BASE.GROUPS['Output.Report']=['Handler.Reported']
  actual=P.BASE.normalize(P.BASE.parse_term(raw.decode()),identity['constructors'],join)
 else:actual=P.normalize(raw.decode(),identity,join)
 expected=json.loads(Path(cohort['oracle']).read_text());P.BASE.strict_equal(actual,expected)
 if cohort['kind']=='mutant':
  positive=json.loads(Path(plan['cohorts'][0]['oracle']).read_text())
  if actual==positive:raise ValueError('whole positive did not reject reached omission')
 return actual
