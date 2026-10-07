"""Preserve historical Query development/preflight bytes without credit transfer."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent;STAGE=HERE/'promotion-stage';OUT=HERE/'promotion-capsules'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
roots=list(STAGE.glob('development-query-stage*'))+list((STAGE/'query-lifetime').glob('development-stage*'))
roots += [p for p in (STAGE/'evidence').iterdir() if p.name!='query-1791368619238781128']
roots += [p for p in (STAGE/'query-lifetime/evidence').iterdir() if p.name!='1791369196701030146']
files=sorted({p for root in roots for p in root.rglob('*') if p.is_file() and '__pycache__' not in p.parts})
expected={str(p.relative_to(HERE)):sha(p) for p in files};target=OUT/'history.tar.gz';assert not target.exists()
with tarfile.open(target,'w:gz',compresslevel=9) as tar:
 for p in files:tar.add(p,arcname=str(p.relative_to(HERE)),recursive=False)
with tarfile.open(target,'r:gz') as tar:actual={m.name:hashlib.sha256(tar.extractfile(m).read()).hexdigest() for m in tar.getmembers() if m.isfile()}
assert actual==expected;assert all(sha(HERE/name)==h for name,h in expected.items())
(OUT/'history-index.json').write_text(json.dumps({'scope':'Historical exact development failures/check-only observations/preflights; no terminal acceptance transfer','recipeSHA256':sha(Path(__file__)),'archive':str(target.relative_to(HERE)),'sha256':sha(target),'bytes':target.stat().st_size,'members':expected},indent=2)+'\n')
print(target.stat().st_size,len(expected))
