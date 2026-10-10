"""Independent source-derived automatic-App expectations. No runtime inputs."""
import copy
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = Path('/workspace/formal-proofs/bendvy')
PARENT = ROOT / 'experiments/public-inspect/ordinary-declaration-v1/canonical-adoption-v1/oracle-v2/expected.py'
spec = importlib.util.spec_from_file_location('qualified_leaf_model', PARENT)
leaf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(leaf)


def world_text():
    # Reuse the independently authored original affine leaf's complete world
    # model/formatter; extend only the operations present in this consumer.
    delivery = copy.deepcopy(leaf.p.delivery(False))
    world = delivery['owner']['world']
    world.update(nextId=3, highWater=2, capacity=4, depth={'nat': 2},
                 live=leaf.p.c('ANode', left=world['live'],
                               right=leaf.p.c('ANode', left=leaf.p.leaf(True),
                                              right=leaf.p.leaf(False))),
                 registrations=[{'id': 2, 'name': 'PositionAbsent', 'access': ['Position']},
                                {'id': 1, 'name': 'PositionRead', 'access': ['Position', 'Position']}],
                 nextSystemId=3)
    formatted = leaf.observation(delivery)
    return formatted.split('|world={', 1)[1].split('}|rows=', 1)[0]


def debug_text(remove_first_rows=False):
    # System.access retains each clause, including Read and Added for Position.
    bindings = ('[1:1:PositionRead:Update:[Position, Position]:[Position:Read, Position:Added], '
                '1:2:PositionAbsent:Update:[Position]:[Position:Without]]')
    first = '[]' if remove_first_rows else '[1:1:Product(Found:42,Unit)]'
    rows = '[' + first + ', [1:2:Unit]]'
    return 'Debug{fixtureInitialCursor=0|bindings=' + bindings + '|rows=' + rows + '}'


def model(remove_first_rows=False):
    owners = ('[1:1:PositionRead:Update:cursor=0:[Position, Position]:[Position:Read, Position:Added], '
              '1:2:PositionAbsent:Update:cursor=0:[Position]:[Position:Without]]')
    world = 'owners' + owners + '|world{' + world_text() + '}'
    debug = debug_text(remove_first_rows)
    text = ('before{' + world + '}\nfirst|' + debug + '\nsecond|' + debug +
            '\ndisabled|Disabled\nfourth|' + debug + '\nafter{' + world + '}')
    # Each schema creates its own Factory root: namespace1 in both is expected.
    # This is not a globally unique independent-world-root qualification.
    return {'first': text, 'second': text}


def render(value):
    # The pure main returns only local Data Report{String,String}; no owner or
    # function enters the printed term. Presentation strings remain private.
    return 'Report{' + json.dumps(value['first']) + ', ' + json.dumps(value['second']) + '}\n'


if __name__ == '__main__':
    normal = model(False)
    mutant = model(True)
    assert normal != mutant
    assert normal['first'] == normal['second']
    assert 'Position:Added' in normal['first']
    assert 'registrations=[2:PositionAbsent:[Position], 1:PositionRead:[Position, Position]]' in normal['first']
    for name, value in [('normal', normal), ('filter', mutant)]:
        (HERE / (name + '-expected.json')).write_text(json.dumps(value, indent=2) + '\n')
        (HERE / (name + '-expected.stdout')).write_text(render(value))
