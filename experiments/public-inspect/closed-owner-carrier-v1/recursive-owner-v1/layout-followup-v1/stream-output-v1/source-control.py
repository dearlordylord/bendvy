"""No-child exact source topology and byte-transport control; no runtime oracle claim."""
from pathlib import Path
import json,hashlib
HERE=Path(__file__).resolve().parent
BASE=HERE.parent.parent
stage=HERE/'stage'
files=sorted(p.relative_to(stage)for p in stage.rglob('*')if p.is_file())
assert len(files)==46
assert [str(p)for p in files if (stage/p).read_bytes()!=(BASE/'stage'/p).read_bytes()]==['output-io-main.bend']
s=(stage/'output-io-main.bend').read_text()
blocks=[]
for name,operation in [('workshop_driver','write'),('workshop_retry','write'),('garden_driver','write'),('garden_retry','print')]:
 prefix=f'def {name}() -> IO(Unit):\n  IO.{operation}('
 start=s.index(prefix)+len(prefix);end=s.index(')\n',start)
 blocks.append(s[start:end])
original=(stage/'output-adapter.bend').read_text().split('def main() -> String:\n  ')[1].strip()
qualified=original.replace('driver(', 'Output.driver(').replace('retry(', 'Output.retry(')
assert ' ++ '.join(blocks)==qualified
assert s.count('IO.bind(Unit,Unit,workshop_driver(),after_workshop_driver)')==1
assert s.count('IO.bind(Unit,Unit,workshop_retry(),after_workshop_retry)')==1
assert s.count('IO.bind(Unit,Unit,garden_driver(),after_garden_driver)')==1
assert s.count('\n  garden_retry()\n')==1
assert s.count('IO.print(')==1 and s.count('IO.write(')==3
print(json.dumps({'status':'SOURCE_ORDERED_CONCAT_TRANSPORT_PASS','sourceFiles':46,'changedFiles':['output-io-main.bend'],'blocks':blocks,'transport':'First3 IO.write, final IO.print, identical concatenated expression plus final LF','limits':'Inspection control only; full actual consumer output equality remains required'},indent=2))
