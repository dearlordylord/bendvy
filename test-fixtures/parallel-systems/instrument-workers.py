import argparse
import hashlib
import json
from pathlib import Path


def replace_once(text, before, after):
    count = text.count(before)
    if count != 1:
        raise ValueError(f'expected one anchor, found {count}: {before!r}')
    return text.replace(before, after, 1)


def segment_bounds(text, name):
    anchor = f'  WL_CASE({name})\n  {{\n'
    start = text.index(anchor)
    if text.count(anchor) != 1:
        raise ValueError(f'ambiguous segment: {name}')
    stop = text.find('\n  WL_CASE(', start + len(anchor))
    return start, len(text) if stop < 0 else stop


def instrument(source, plan):
    digest = hashlib.sha256(source.encode()).hexdigest()
    if digest != plan['sourceSha256']:
        raise ValueError('generated C source digest differs from the frozen plan')
    worker_limit = plan['workerLimit']
    if not isinstance(worker_limit, int) or not 1 <= worker_limit <= 64:
        raise ValueError('workerLimit must fit the 64-bit worker mask')
    groups = plan['groups']
    if not groups or len({group['name'] for group in groups}) != len(groups):
        raise ValueError('diagnostic group names must be nonempty and unique')
    cases = [case for group in groups for case in group['cases']]
    if len(set(cases)) != len(cases):
        raise ValueError('semantic cases must belong to exactly one group')
    if any(not group['cases'] for group in groups):
        raise ValueError('every semantic group needs reached cases')
    globals_text = (
        'static _Thread_local u32 bendvy_diag_worker;\n'
        f'static unsigned long long bendvy_diag_masks[{len(groups)}];\n'
        f'static unsigned long long bendvy_diag_counts[{len(groups)}];\n'
        'static unsigned long long bendvy_diag_forks;\n'
        'static void bendvy_diag_hit(u32 group) {\n'
        f'  if (bendvy_diag_worker >= {worker_limit}) {{ abort(); }}\n'
        '  __atomic_fetch_or(&bendvy_diag_masks[group], '
        '1ull << bendvy_diag_worker, __ATOMIC_RELAXED);\n'
        '  __atomic_fetch_add(&bendvy_diag_counts[group], 1ull, __ATOMIC_RELAXED);\n'
        '}\n'
    )
    changed = replace_once(source, 'static u32             pool_size;\n',
                           globals_text + 'static u32             pool_size;\n')
    changed = replace_once(changed, 'static void* pool_work(void* arg) {\n',
                           'static void* pool_work(void* arg) {\n'
                           '  bendvy_diag_worker = (u32)(uintptr_t)arg;\n')
    for index, group in enumerate(groups):
        for case in group['cases']:
            anchor = f'  WL_CASE({case})\n  {{\n'
            changed = replace_once(changed, anchor,
                                   anchor + f'    bendvy_diag_hit({index});\n')
    for fork in plan['forks']:
        start, stop = segment_bounds(changed, fork['case'])
        section = changed[start:stop]
        section = replace_once(
            section, fork['anchor'],
            fork['anchor'] + '\n        __atomic_fetch_add('
            '&bendvy_diag_forks, 1ull, __ATOMIC_RELAXED);'
        )
        changed = changed[:start] + section + changed[stop:]
    report = '  fprintf(stderr, "BENDVY_WORKERS'
    arguments = []
    for index, group in enumerate(groups):
        name = group['name']
        if not name.isidentifier() or not name.isascii():
            raise ValueError(f'invalid diagnostic name: {name}')
        report += f' {name}=%llx/%llu'
        arguments.extend([
            f'__atomic_load_n(&bendvy_diag_masks[{index}], __ATOMIC_RELAXED)',
            f'__atomic_load_n(&bendvy_diag_counts[{index}], __ATOMIC_RELAXED)',
        ])
    report += ' forks=%llu\\n", ' + ', '.join(arguments + [
        '__atomic_load_n(&bendvy_diag_forks, __ATOMIC_RELAXED)'
    ]) + ');\n'
    return replace_once(changed, '  io_sync();\n  return 0;\n',
                        '  io_sync();\n' + report + '  return 0;\n')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('plan', type=Path)
    parser.add_argument('source', type=Path)
    parser.add_argument('destination', type=Path)
    args = parser.parse_args()
    plan = json.loads(args.plan.read_text())
    args.destination.write_text(instrument(args.source.read_text(), plan))


if __name__ == '__main__':
    main()
