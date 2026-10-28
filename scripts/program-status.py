#!/usr/bin/env python3
"""Read or update one program checkpoint; derive counts and live Git state."""
import argparse
import fcntl
import json
from pathlib import Path
from task_runner import run


def validate(state):
    allowed = {'schema', 'integration_worktree', 'issues', 'completed', 'in_work',
               'publication_frozen', 'legacy_public_pr_snapshot'}
    unknown = set(state) - allowed
    if unknown:
        raise ValueError('remove duplicated/cached status fields: ' + ', '.join(sorted(unknown)))
    if state.get('schema') != 1 or not isinstance(state.get('publication_frozen'), bool):
        raise ValueError('schema 1 and explicit publication_frozen required')
    issues, completed, active = state['issues'], state['completed'], state['in_work']
    for values in (issues, active):
        if not isinstance(values, list) or any(type(i) is not int for i in values) or len(values) != len(set(values)):
            raise ValueError('issue lists require unique integers')
    if not isinstance(completed, dict) or any(str(int(i)) != i for i in completed):
        raise ValueError('completed maps issue numbers to completion report paths')
    done = set(map(int, completed))
    if not done <= set(issues) or not set(active) <= set(issues) or done & set(active):
        raise ValueError('completed and in_work must be disjoint subsets of issues')
    if len(active) > 3:
        raise ValueError('at most three unfinished issues may be in work')
    for report in completed.values():
        if not isinstance(report, str) or not Path(report).is_file():
            raise ValueError('completion report missing: ' + str(report))


def view(state):
    validate(state)
    root = Path(state['integration_worktree']).resolve()
    def git(*args):
        return run(['git', '-C', str(root), *args], timeout=None,
                   capture_output=True, text=True, check=True).stdout.strip()
    return dict(state, completed_count=len(state['completed']), issue_count=len(state['issues']),
                remaining=[i for i in state['issues'] if str(i) not in state['completed']],
                live_integration_head=git('rev-parse', 'HEAD'),
                live_integration_changes=git('status', '--porcelain'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('checkpoint', type=Path)
    parser.add_argument('--in-work', type=int, nargs='*')
    parser.add_argument('--complete', type=int)
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    if (args.complete is None) != (args.report is None):
        parser.error('--complete and --report must be supplied together')
    path = args.checkpoint.resolve()
    with path.with_suffix('.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        state = json.loads(path.read_text())
        validate(state)
        if args.in_work is not None:
            state['in_work'] = args.in_work
        if args.complete is not None:
            state['completed'][str(args.complete)] = str(args.report.resolve())
            state['in_work'] = [i for i in state['in_work'] if i != args.complete]
        observed = view(state)
        if args.in_work is not None or args.complete is not None:
            temporary = path.with_suffix('.tmp')
            temporary.write_text(json.dumps(state, indent=2) + '\n')
            temporary.replace(path)
    print(json.dumps(observed, indent=2))


if __name__ == '__main__':
    main()
