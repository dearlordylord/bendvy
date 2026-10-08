"""Five-second pinned TS development preflight; no backend/delivery acceptance."""
import os
from pathlib import Path
import shutil
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')
sys.path.insert(0, str(ROOT / 'scripts'))
import check_preflight


def main():
    node = Path(shutil.which('node')).resolve()
    taskset = Path(shutil.which('taskset')).resolve()
    reference = ROOT / '.references/bevy-ts/packages/core'
    env = dict(os.environ)
    for name in list(env):
        if name in ('NODE_OPTIONS', 'NODE_PATH', 'NODE_REPL_EXTERNAL_MODULE') or name.startswith(('LD_', 'DYLD_')):
            env.pop(name)
    checks = [{
        'label': 'subscription-lifecycle',
        'argv': [str(taskset), '-c', '5', str(node), str(HERE / 'reference.mjs')],
        'seconds': 5,
        'stdout': str(HERE / 'expected.stdout')
    }]
    files = [str(path) for path in (
        Path(__file__), ROOT / '.references/sources.json',
        reference / 'package.json', node, taskset,
        ROOT / 'scripts/task_runner.py', ROOT / 'scripts/check_preflight.py'
    )]
    output = ROOT / '.artifacts' / ('trace-subscription-development-' + str(time.time_ns()))
    print(output, flush=True)
    receipt = check_preflight.run(
        output, root=HERE, files=files,
        directories=[str(HERE), str(reference / 'src')], checks=checks, env=env
    )
    print(receipt)


if __name__ == '__main__':
    main()
