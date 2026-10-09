"""Metadata-only sparse successor preparation; no child launched."""
import gzip
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main(output):
    previous = Path('/tmp/bendvy-inspect54-garden-reference02/plan.json')
    plan = json.loads(previous.read_text())
    if sha(previous) != 'e492dc5f48879c1fb27771d29efa1a900013044fe0c7ed031c205e30c3421950':
        raise ValueError('Original source-current diagnostic plan drift')
    pins = dict(plan['pins'])
    if {name: sha(name) for name in pins} != pins:
        raise ValueError('Original source/tool/helper boundary drift')
    if gzip.decompress((HERE / 'comp.ts.gz').read_bytes()) != (HERE / 'comp.ts').read_bytes():
        raise ValueError('Sparse compiler materialization mismatch')
    for path in HERE.iterdir():
        if path.is_file():
            pins[str(path.resolve())] = sha(path)
    pins[str(previous)] = sha(previous)
    output = Path(output).resolve()
    output.mkdir(parents=True, exist_ok=False)
    target = output / 'reference.c'
    plan.update({'scope': 'Sparse Garden copied-reference emission progress only; no installed ELF phase binding, Native/parity/performance qualification',
                 'pins': pins, 'output': str(target),
                 'argv': plan['argv'][:4] + [str(HERE / 'emit.mts'), plan['entry'], str(target)],
                 'observations': 'Major phase/iteration boundaries always logged; seven counters powers of two through2^24 and shared2s checkpoints on every1024th call. No old global budget exhaustion.'})
    plan.pop('progressLimit', None)
    path = output / 'plan.json'
    path.write_text(json.dumps(plan, indent=2) + '\n')
    print(sha(path))


if __name__ == '__main__':
    main(sys.argv[1])
