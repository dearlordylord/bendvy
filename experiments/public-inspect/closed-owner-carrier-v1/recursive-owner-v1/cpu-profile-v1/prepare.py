"""Freeze exact recursive consumer profile cohort; metadata only."""
import gzip
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')
REFERENCE = HERE.parent.parent / 'schema-partition-v1/garden-reference-diagnostic-v1'


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main(output):
    previous = Path('/tmp/bendvy-inspect54-recursive-native02/plan.json')
    if sha(previous) != '772a4aa0bdb96b5bea2aa5249110be26ede0321d2b681d693df04ba9a87d7e98':
        raise ValueError('Exact recursive consumer plan drift')
    source = json.loads(previous.read_text())
    pins = dict(source['pins'])
    for name in ['bend.ts', 'base.bend', 'compiler-copy.tar.gz', 'copy-inventory.json']:
        pins[str(REFERENCE / name)] = sha(REFERENCE / name)
    for path in (REFERENCE / 'effs').rglob('*'):
        if path.is_file():
            pins[str(path)] = sha(path)
    if gzip.decompress((HERE / 'comp.ts.gz').read_bytes()) != (HERE / 'comp.ts').read_bytes():
        raise ValueError('Profile compiler materialization mismatch')
    for path in HERE.iterdir():
        if path.is_file():
            pins[str(path.resolve())] = sha(path)
    node = Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node').resolve(strict=True)
    pins[str(node)] = sha(node)
    pins[str(previous)] = sha(previous)
    if {name:sha(name)for name in pins} != pins:
        raise ValueError('Input drift')
    output = Path(output).resolve()
    output.mkdir(parents=True,exist_ok=False)
    artifact = output / 'reference.c'
    profile = output / 'recursive.cpuprofile'
    prefix = ['/usr/bin/taskset', '-c', '5', str(node)]
    plan = {'scope':'Exact afbbe327 full recursive consumer copied-reference sampled CPU profile; diagnostic abort only, no installedELF/Native/parity/performance qualification',
            'pins':pins,'sourceEntry':source['entrypoint'],'sourceInventory':source['sourceInventory'],'wholeOracleSHA256':source['oracleSHA256'],'wholeOracleBytes':source['oracleBytes'],
            'environment':source['environment'],'output':str(artifact),'profile':str(profile),
            'argv':prefix+[str(HERE / 'emit.mts'),source['entrypoint'],str(artifact),str(profile)],
            'capSeconds':30,'cooperativeCutoffMilliseconds':25000,
            'preparedHelperControls':prefix+[str(HERE / 'helper-controls.mjs')],
            'preparedSmoke':prefix+[str(HERE / 'smoke.mjs'),str(output / 'smoke.cpuprofile')],
            'helperCapSeconds':5,'scopeLimit':'Profile may be censored by uninterruptible calls, missing stop reply, outercap or serialization. Original errors retain their identity after attempted profile capture.'}
    path=output/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(sha(path))


if __name__ == '__main__':
    main(sys.argv[1])
