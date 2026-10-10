"""Independent complete source-derived schedule observation model."""
import copy
import json
import os
from pathlib import Path

HERE = Path(__file__).resolve().parent
ENTRY = Path('/workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-observation-v1/consumer.bend')
CORE = Path('/workspace/formal-proofs/bendvy/src/ecs')


def c(tag, *fields):
    return {'constructor': tag, 'fields': list(fields)}


def steps():
    return [c('Phase', 'Update'), c('System', 1, 1), c('Barrier'), c('System', 2, 2)]


def requirements():
    return [[], [c('Resource', 7)], [], [c('Resource', 7), c('Resource', 7)]]


def operational():
    entries = [c('Entry', step, need) for step, need in zip(steps(), requirements())]
    return c('Sequence', entries[0], c('Sequence', entries[1], c('Sequence', entries[2], entries[3])))


def owners():
    return [c('RegistryView', 1, 1, 'CounterRuns', ['counter'], 0),
            c('RegistryView', 1, 2, 'CounterSkipped', ['counter'], 0)]


def world(after_run):
    # W.create starts namespace1, no entity IDs consumed. Registration prepends.
    # The observed pending closure is counted without invoking or discarding it.
    return ('1|1|0|leaf:False|1|0|Unit|leaf:' + ('112' if after_run else '0') +
            '|[]|' + ('0' if after_run else '1') +
            '|[2:CounterSkipped:[counter], 1:CounterRuns:[counter]]|3|0')


def state(enabled, after_run=False):
    return c('State', world(after_run), operational(), 1, 'OrdinaryUpdate',
             steps(), [c('Resource', 7)], owners(), enabled)


def description(omit_description_needs=False):
    needs = requirements()
    if omit_description_needs:
        needs = [[] for _ in needs]
    return c('Some', c('Description', 1, 'OrdinaryUpdate',
                      [c('PlannedStep', step, need) for step, need in zip(steps(), needs)], owners()))


def report(omit_description_needs=False):
    projected = description(omit_description_needs)
    return c('Report', state(False), c('None'), projected, copy.deepcopy(projected),
             state(True), c('Done', [c('Entered', 'Update'), c('Ran', 1),
                                     c('Applied'), c('Skipped', 2)]),
             state(True, True), copy.deepcopy(projected))


def model(omit_description_needs=False):
    # Independent factory roots are scoped, so A/B have identical data output.
    return [report(omit_description_needs), report(omit_description_needs)]


MODULES = dict.fromkeys(['Phase', 'System', 'Barrier', 'Entered', 'Ran', 'Applied', 'Skipped'], CORE / 'schedule.bend')
MODULES.update(dict.fromkeys(['Resource', 'Entry', 'Sequence'], CORE / 'schedule-provision.bend'))
MODULES.update(dict.fromkeys(['RegistryView', 'Description', 'PlannedStep'], ENTRY.parent / 'schedule.bend'))


def render(value, mutant_namespace=False):
    recurse = lambda v: render(v, mutant_namespace)
    if isinstance(value, bool):
        return 'True{}' if value else 'False{}'
    if isinstance(value, int):
        return str(value)
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, list):
        return '[' + ', '.join(map(recurse, value)) + ']'
    tag = value['constructor']
    directory = ENTRY.parent / 'runtime-v1/mutant' if mutant_namespace else ENTRY.parent
    module = MODULES.get(tag)
    if mutant_namespace and module == ENTRY.parent / 'schedule.bend':
        module = directory / 'schedule.bend'
    name = tag if module is None else os.path.relpath(module.with_suffix(''), directory) + '.' + tag
    return name + '{' + ', '.join(map(recurse, value['fields'])) + '}'


def stdout(value, mutant_namespace=False):
    return '(' + ', '.join(render(v, mutant_namespace) for v in value) + ')\n'


if __name__ == '__main__':
    for name, omit, namespace in [('normal', False, False),
                                  ('description-mutant', True, True),
                                  ('mutant-namespace-normal', False, True)]:
        value = model(omit)
        (HERE / (name + '-expected.json')).write_text(json.dumps(value, indent=2) + '\n')
        (HERE / (name + '-expected.stdout')).write_text(stdout(value, namespace))
