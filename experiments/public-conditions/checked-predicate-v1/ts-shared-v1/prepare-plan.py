"""Prepare the existing adapter plan only; no subject execution."""
from pathlib import Path
import gzip, hashlib, json
HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
    inventory = json.loads((HERE / 'FREEZE.json').read_text())['sourceInventory']
    assert all(sha(Path(path)) == digest for path, digest in inventory.items())
    oracle = json.loads((HERE / 'ORACLES.json').read_text())
    expected = gzip.decompress((HERE / 'expected.stdout.gz').read_bytes())
    assert len(expected) == oracle['bytes']
    assert hashlib.sha256(expected).hexdigest() == oracle['sha256']
    paths = [*map(Path, inventory), ROOT / 'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/detached-v2/check-source.py', ROOT / 'scripts/task_runner.py', ROOT / 'experiments/public-simulation/delivery-v1/installed-config.py', Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node'), Path('/usr/bin/taskset'), HERE / 'capture-reference.py.source', HERE / 'FREEZE.json', HERE / 'INDEPENDENT-SOURCE-BASIS.json', HERE / 'ORACLES.json', HERE / 'model.py.source', HERE / 'expected.stdout.gz']
    plan = {'scope': json.loads((HERE / 'FREEZE.json').read_text())['scope'], 'capSeconds': 5, 'pins': {str(path): sha(path) for path in paths}, 'out': str(HERE / 'ref01'), 'oracleCommit': json.loads((HERE / 'ORACLE-ADOPTION.json').read_text())['oracleCommit'], 'oracleBytes': len(expected), 'oracleSHA256': hashlib.sha256(expected).hexdigest()}
    target = HERE / 'REFERENCE-PLAN.json'
    target.write_text(json.dumps(plan, indent=2) + '\n')
    print(sha(target))
if __name__ == '__main__': main()
