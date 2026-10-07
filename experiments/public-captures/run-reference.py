"""Run the bounded actual TS capture observation with the shared preflight."""
import argparse
import os
from pathlib import Path
import shutil
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
import check_preflight

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path)
args = parser.parse_args()
node = Path(shutil.which('node')).resolve()
taskset = Path(shutil.which('taskset')).resolve()
fixture = ROOT / 'experiments/public-captures/reference.mjs'
output = args.output or ROOT / '.artifacts' / ('public-captures-reference-' + str(time.time_ns()))
check_preflight.run(output, root=ROOT,
    files=[str(node), str(taskset), 'experiments/public-captures/reference.mjs',
           'experiments/public-captures/expected.json', 'experiments/public-captures/expected.stdout',
           'experiments/public-captures/run-reference.py', '.references/sources.json'],
    directories=['.references/bevy-ts/packages/core/src'],
    checks=[{'label': 'ts-capture-observations',
             'argv': [str(taskset), '-c', '6', str(node), str(fixture)],
             'seconds': 5, 'stdout': 'experiments/public-captures/expected.stdout'}],
    env=dict(os.environ))
print(output / 'receipt.json')
