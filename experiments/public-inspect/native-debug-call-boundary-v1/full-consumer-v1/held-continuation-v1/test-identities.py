"""No-child source relocation and complete transport controls; synthetic output only."""
from pathlib import Path
import types,json,hashlib
HERE=Path(__file__).resolve().parent
root=HERE.parent
oldplan=json.loads(Path('/tmp/bendvy-debug56-call-boundary-full03/plan.json').read_text())
def compiled(path,name):
 m=types.ModuleType(name);m.__file__=str(path);exec(compile(path.read_bytes(),str(path),'exec'),m.__dict__);return m
transport=compiled(root/'transport.py','transport');P=transport.parser(oldplan['pins'])
identity=compiled(HERE/'identities.py','identity')
pins={str(p):hashlib.sha256(p.read_bytes()).hexdigest()for p in [*root.glob('parser-*.py'),HERE/'identities.py']}
pins.update({r['original']:hashlib.sha256(Path(r['original']).read_bytes()).hexdigest()for r in json.loads((root/'PARSER-ADAPTERS.json').read_text())})
rows=[]
for kind,file in [('normal','main.bend'),('mutant','main-drop-handlers.bend')]:
 previous=json.loads(Path('/tmp/bendvy56-recursive-'+kind+'-js-v1/plan.json').read_text());path=HERE/(kind+'-identities.json');derived=identity.derive(P,previous['constructorInventory'],HERE/file);assert derived==json.loads(path.read_text())
 reloc={r['originalToken']:r['candidateToken']for r in derived['sourceDerivedConstructorRelocation']}
 def rename(value):
  if isinstance(value,list):return [rename(x)for x in value]
  if isinstance(value,dict):
   if set(value)=={'constructor','fields'}:return {'constructor':reloc[value['constructor']],'fields':rename(value['fields'])}
   return {k:rename(v)for k,v in value.items()}
  return value
 actual=P.BASE.parse_term(Path('/tmp/bendvy56-recursive-'+kind+'-js-v1/consumer.stdout').read_text());synthetic=P.BASE.render_term(rename(actual)).encode()
 cohort=dict(kind=kind,inventory=str(path),join=previous['join'],oracle=previous['oracle'],heldIdentity=True,entrypoint=str(HERE/file),originalInventory=previous['constructorInventory']);transport.check(oldplan,cohort,synthetic,pins)
 altered=synthetic.replace(next(iter(derived['constructors'])).encode(),b'Unrelated.constructor',1)
 if altered==synthetic:altered=b'Unrelated{'+synthetic+b'}'
 try:transport.check(oldplan,cohort,altered,pins)
 except (ValueError,AssertionError):pass
 else:raise AssertionError('unrelated constructor accepted')
 rows.append(dict(kind=kind,sourceFiles=71,constructors=len(reloc),wholeModelAccepted=True,unrelatedRejected=True,syntheticOnly=True))
print(json.dumps(dict(compilerChildren=0,controls=rows),indent=2))
