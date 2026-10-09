"""Freeze the specific existing-helper acquisition stage; launch nothing."""
import hashlib
import json
from pathlib import Path
import sys
HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def prepare():
    declaration = json.loads((HERE / 'DECLARATION-v2.json').read_bytes())
    if len(declaration['resolver_inputs']) != 893 or len(declaration['loader_search_directories']) != 64: raise ValueError('Full declaration required')
    for path, expected in declaration['helperSourcePins'].items():
        if sha(Path(path).read_bytes()) != expected: raise ValueError('Declaration source drift: ' + path)
    helpers = {'runner': ROOT / 'scripts/task_runner.py', 'pins': ROOT / 'scripts/owned-tool-pins.py', 'boundary': ROOT / 'scripts/evidence_boundary.py', 'logs': ROOT / 'scripts/receipt-logs.py', 'metadata': ROOT / 'experiments/public-simulation/delivery-v1/prepare-metadata.py'}
    sourcefiles = list(helpers.values()) + [HERE / 'acquire.py', Path(__file__), HERE / 'DECLARATION-v2.json', HERE / 'test-acquisition.py']
    python = str(Path(sys.executable).resolve(strict=True)); sourcefiles.append(Path(python))
    namespace = {'__file__': str(HERE.parent / 'metadata-evidence-v6/verify.py'), '__name__': 'historical_toolpins'}
    exec(compile(Path(namespace['__file__']).read_bytes(), namespace['__file__'], 'exec'), namespace)
    old, receipt, raws = namespace['verified']()
    toolpaths = list(declaration['configuration']['tools'].values()) + [python]
    tools = {path: old['pins'][path] for path in toolpaths}
    resources = {}
    for root in declaration['configuration']['resource_roots']:
        resources[root] = {str(p): {'resolved': str(p.resolve(strict=True)), 'bytes': p.stat().st_size} for p in sorted(Path(root).rglob('*')) if p.is_file()}
    resource_files = {row['resolved']: row['bytes'] for files in resources.values() for row in files.values()}
    planpath = '/tmp/bendvy63-resolver-acquisition-plan-v2.json'
    output = '/tmp/bendvy63-resolver-acquisition-v2'
    if Path(output).exists() or Path(output).is_symlink(): raise ValueError('Output must start absent')
    source_pins = dict(declaration['helperSourcePins'])
    source_pins.update({str(p.resolve()): sha(p.read_bytes()) for p in sourcefiles})
    return {'scope': 'One existing-PinnedTools metadata5 acquisition; no compiler/header/linker/generated runtime or performance qualification', 'outputRoot': output, 'python': python, 'sourcePins': source_pins, 'toolPins': tools, 'helpers': {k: str(v) for k, v in helpers.items()}, 'declaration': declaration, 'resourceMetadata': resources, 'resourceCost': {'uniqueFiles': len(resource_files), 'uniqueBytes': sum(resource_files.values()), 'fileBytesReadForCost': 0}, 'lock': '/tmp/bendvy-parity-heavy.lock', 'command': [declaration['configuration']['taskset'], '-c', '5', python, str(HERE / 'acquire.py'), '--worker', planpath], 'commandDigestArgument': 'Exact supplied plan SHA appended at execution; avoids a self-referential plan hash', 'outerCapSeconds': 5, 'allHashingInsideOuterCap': True, 'cost': declaration['cost'], 'status': 'PREPARED_NOT_EXECUTED_NOT_RESOLVER_ADMISSION'}

if __name__ == '__main__': print(json.dumps(prepare(), indent=2))
