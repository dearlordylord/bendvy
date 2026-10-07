"""Retain exact pre-attempt source/script/oracle bytes without running children."""
from pathlib import Path
import hashlib
import json
import sys

plan_path = Path(sys.argv[1]).resolve()
plan = json.loads(plan_path.read_text())
archive = plan_path.parent / 'frozen-source'
objects = archive / 'objects'
objects.mkdir(parents=True, exist_ok=False)
records = []
for file in plan['files']:
    path = Path(file)
    # Explicit file inventory includes tools; retain source, scripts, and oracle
    # rather than copying installed binaries or private execution environments.
    if path.suffix not in ('.bend', '.py', '.json', '.mjs'):
        continue
    content = path.read_bytes()
    digest = hashlib.sha256(content).hexdigest()
    assert digest == plan['inputs'][str(path.resolve())]
    obj = objects / digest
    if obj.exists():
        assert obj.read_bytes() == content
    else:
        obj.write_bytes(content)
    records.append({'path': str(path), 'sha256': digest, 'object': str(obj.relative_to(archive)), 'bytes': len(content)})
manifest = archive / 'index.json'
manifest.write_text(json.dumps({'planSHA256': hashlib.sha256(plan_path.read_bytes()).hexdigest(), 'records': records}, indent=2) + '\n')
print(manifest)
print(hashlib.sha256(manifest.read_bytes()).hexdigest())
