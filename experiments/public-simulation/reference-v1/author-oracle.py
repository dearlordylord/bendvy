"""Pre-execution, literal checkpoint oracle; never consumes observed output."""
import copy
import json
from pathlib import Path

HERE = Path(__file__).parent
assert json.loads((HERE / 'inputs.json').read_text()) == {
    'seed': 0, 'fixedStep': 1, 'goal': 2, 'damage': 1, 'health': [2, 1, 1]}

EMPTY = {'hits': [], 'deaths': []}
FIRST = {'hits': [{'entity': 2, 'damage': 1}], 'deaths': [{'entity': 2}]}
SECOND = {'hits': [{'entity': 1, 'damage': 1}, {'entity': 3, 'damage': 1}],
          'deaths': [{'entity': 3}]}
THIRD = {'hits': [{'entity': 1, 'damage': 1}], 'deaths': [{'entity': 1}]}
INITIAL = [(1, 0, 1, 2), (2, 0, 2, 1), (3, 0, 1, 1)]
ONE_PENDING = [(1, 1, 1, 2), (2, 2, 2, 0), (3, 1, 1, 1)]
ONE = [(1, 1, 1, 2), (3, 1, 1, 1)]
TWO_PENDING = [(1, 2, 1, 1), (3, 2, 1, 0)]
TWO = [(1, 2, 1, 1)]
THREE_PENDING = [(1, 3, 1, 0)]

# Runtime.commitSystemTransaction advances one extra tick for each nonempty
# event batch (Runtime.ts:1027-1035), including both event kinds together.
# frame, tick, step, all live owners, complete pending-command descriptors,
# cumulative independent host observer journals, expected result.
specs = [
 ('register-readers', 1, 2, 0, [], [], [EMPTY], [EMPTY], True),
 ('queue-spawn', 2, 3, 0, [], ['spawn']*3, [EMPTY], [EMPTY], True),
 ('spawn-barrier', 3, 4, 0, INITIAL, [], [EMPTY], [EMPTY], True),
 ('step-1-damage', 4, 7, 1, ONE_PENDING, ['despawn'], [EMPTY], [EMPTY], True),
 ('step-1-readers', 5, 9, 1, ONE_PENDING, ['despawn'], [EMPTY,FIRST], [EMPTY,FIRST], True),
 ('step-1-barrier', 6, 10, 1, ONE, [], [EMPTY,FIRST], [EMPTY,FIRST], True),
 ('step-2-damage', 7, 13, 2, TWO_PENDING, ['despawn'], [EMPTY,FIRST], [EMPTY,FIRST], True),
 ('step-2-reader-failure', 8, 15, 2, TWO_PENDING, ['despawn'], [EMPTY,FIRST,SECOND], [EMPTY,FIRST,SECOND], False),
 ('step-2-reader-retry', 9, 16, 2, TWO_PENDING, ['despawn'], [EMPTY,FIRST,SECOND], [EMPTY,FIRST,SECOND,SECOND], True),
 ('step-2-barrier', 10, 17, 2, TWO, [], [EMPTY,FIRST,SECOND], [EMPTY,FIRST,SECOND,SECOND], True),
 ('step-3-damage', 11, 20, 3, THREE_PENDING, ['despawn'], [EMPTY,FIRST,SECOND], [EMPTY,FIRST,SECOND,SECOND], True),
 ('step-3-readers', 12, 22, 3, THREE_PENDING, ['despawn'], [EMPTY,FIRST,SECOND,THIRD], [EMPTY,FIRST,SECOND,SECOND,THIRD], True),
 ('step-3-barrier', 13, 23, 3, [], [], [EMPTY,FIRST,SECOND,THIRD], [EMPTY,FIRST,SECOND,SECOND,THIRD], True),
 ('empty-readers', 14, 25, 3, [], [], [EMPTY,FIRST,SECOND,THIRD,EMPTY], [EMPTY,FIRST,SECOND,SECOND,THIRD,EMPTY], True),
]

def phase(spec):
    label, frame, tick, step, units, pending, a, b, ok = spec
    entities = [{'id': entity, 'components': {'Simulation/Position': x,
                 'Simulation/Velocity': velocity, 'Simulation/Health': health},
                 'relations': {}} for entity, x, velocity, health in units]
    result = {'ok': True} if ok else {'ok': False, 'error': {
        'kind': 'SystemFailure', 'system': 'Simulation/ReaderB', 'error': 'RetryReaderB'}}
    return {'label': label, 'result': result, 'dump': {
        'version': 1, 'frame': frame, 'tick': tick, 'entityCount': len(entities),
        'entities': entities, 'resources': {'Simulation/Step': step}, 'machines': {},
        'pendingCommands': [{'tag': tag, 'system': 'Simulation/Spawn' if tag == 'spawn'
                             else 'Simulation/Damage'} for tag in pending]},
        'readers': {'a': copy.deepcopy(a), 'b': copy.deepcopy(b)}}

output = [{'root': root, 'phases': [phase(spec) for spec in specs]}
          for root in ['Workshop', 'Garden']]
(HERE / 'expected.json').write_text(json.dumps(output, indent=2)+'\n')
(HERE / 'expected.stdout').write_text(json.dumps(output,separators=(',',':'))+'\n')
