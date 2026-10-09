"""Run portable admission controls affected by staged collector/helper changes."""
from pathlib import Path
from task_runner import run
import sys


ROOT = Path(__file__).resolve().parents[1]
COLLECTOR = ('experiments/public-relation-readers/current-adoption-v1/'
             'ts-reference-v1/fullcapacity-v1/')
CONTROL = COLLECTOR + 'test-admission.py'
DEPENDENCIES = {
    COLLECTOR + 'run.py', CONTROL,
    'scripts/run-admission-controls.py',
    'scripts/task_runner.py', 'scripts/evidence_boundary.py',
    'scripts/receipt-logs.py',
    'experiments/public-restore/reference-v1/run.py',
}


SIMULATION = 'experiments/public-simulation/delivery-v1/'
OPTIMIZATION = SIMULATION + 'optimization-v1/'
SHARED = {'scripts/run-admission-controls.py', 'scripts/task_runner.py',
          'scripts/evidence_boundary.py', 'scripts/receipt-logs.py'}
INSPECTOR_LEAF = ('experiments/public-inspect/closed-owner-carrier-v1/'
                  'recursive-owner-v1/layout-followup-v1/leaf-lift-v1/')
CONTROL_SETS = (
    (INSPECTOR_LEAF + 'test-preparation.py', SHARED | {
        INSPECTOR_LEAF + 'development.py',
        INSPECTOR_LEAF + 'test-preparation.py',
        INSPECTOR_LEAF + 'complete-expected.txt.gz'}),
    (CONTROL, DEPENDENCIES),
    (OPTIMIZATION + 'test-sampling-receipt.py', SHARED | {
        OPTIMIZATION + 'test-sampling-receipt.py',
        OPTIMIZATION + 'prepare-sampling.py'}),
    (OPTIMIZATION + 'test-timing.py', SHARED | {
        OPTIMIZATION + 'test-timing.py', OPTIMIZATION + 'validate-timing.py',
        OPTIMIZATION + 'prepare-timing.py', SIMULATION + 'run-delivery.py',
        SIMULATION + 'timing-v1/instrument.py'}),
    (OPTIMIZATION + 'test-after-profile.py', SHARED | {
        OPTIMIZATION + 'test-after-profile.py',
        OPTIMIZATION + 'validate-after-profile.py',
        OPTIMIZATION + 'prepare-after-profile.py', SIMULATION + 'run-delivery.py'}),
)


def selected(paths):
    return [control for control, dependencies in CONTROL_SETS
            if dependencies.intersection(paths)]


def main():
    paths = run(
        ['git', 'diff', '--cached', '--name-only', '--diff-filter=ACMR', '-z'],
        cwd=ROOT, timeout=5, capture_output=True, check=True).stdout.decode().split('\0')
    controls = selected(paths)
    if not controls:
        return
    # Controls run working-tree source; qualify the bytes actually being committed.
    checked = set().union(*(dependencies for control, dependencies in CONTROL_SETS
                          if control in controls))
    for name in checked:
        staged = run(['git', 'show', ':' + name], cwd=ROOT,
                     timeout=5, capture_output=True, check=True).stdout
        if (ROOT / name).read_bytes() != staged:
            raise ValueError('Stage the complete admission-control change: ' + name)
    for name in controls:
        result = run([sys.executable, str(ROOT / name)], cwd=ROOT,
                     timeout=30, capture_output=True)
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        result.check_returncode()


if __name__ == '__main__':
    main()
