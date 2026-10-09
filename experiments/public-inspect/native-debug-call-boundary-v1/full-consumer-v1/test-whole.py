"""No-child whole model transport of retained source-current JS output."""
from pathlib import Path
import json,types,hashlib,sys
HERE=Path(__file__).resolve().parent
p=json.loads(Path(sys.argv[1]).read_text());m=types.ModuleType('transport');m.__file__=str(HERE/'transport.py');exec(compile((HERE/'transport.py').read_bytes(),m.__file__,'exec'),m.__dict__)
rows=[]
for cohort in p['cohorts']:
 raw=Path('/tmp/bendvy56-recursive-'+cohort['kind']+'-js-v1/consumer.stdout').read_bytes();m.check(p,cohort,raw,p['pins']);rows.append(dict(kind=cohort['kind'],bytes=len(raw),rawSHA256=hashlib.sha256(raw).hexdigest(),wholeOracleSHA256=cohort['expectedSHA256'],positiveRejected=cohort['kind']=='mutant'))
print(json.dumps(dict(compilerChildren=0,retainedWholeTransport=rows),indent=2))
