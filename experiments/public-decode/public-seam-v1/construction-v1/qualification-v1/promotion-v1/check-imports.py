"""Check every import-only candidate and its exact inverse to qualified source."""
from pathlib import Path
import hashlib,json,re
H=Path(__file__).resolve().parent
manifest=json.loads((H/'manifest.json').read_bytes())
for item in manifest['modules']:
    origin=Path(item['origin']);candidate=Path(item['candidate'])
    assert hashlib.sha256(origin.read_bytes()).hexdigest()==item['originSHA256']
    assert hashlib.sha256(candidate.read_bytes()).hexdigest()==item['candidateSHA256']
    inverse=candidate.read_text()
    for change in item['importMapping']:
        assert inverse.count(change['candidate']+'\n')==1
        inverse=inverse.replace(change['candidate']+'\n',change['original']+'\n',1)
    assert inverse==origin.read_text(),'non-import source delta'
    for target in re.findall(r'^import\s+(\S+)',candidate.read_text(),re.M):
        if target!='Base':assert (H/'library'/target).is_file() or (Path('/workspace/formal-proofs/bendvy/src/ecs')/target).is_file()
print('PASS six qualified source inverses and canonical dependency targets')
