"""Independent complete ordinary-resource App fixture expectations."""
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
MODEL = HERE.parent / 'resource-system-oracle-v1/expected.py'
spec = importlib.util.spec_from_file_location('qualified_resource_fixture_model', MODEL)
resource = importlib.util.module_from_spec(spec)
spec.loader.exec_module(resource)


def snapshot(entities, value, enabled=True, omit_rendered=False):
    binding = ('1:1:CounterUpdate:access=[Counter]:cursor=0:'
               'slot=Update:clauses=[Counter:Write]')
    bindings = '[' + binding + ']'
    rendered = '[]' if omit_rendered else '[Counter=' + str(value) + ']'
    label = 'Debug{bindings=' + bindings + '|resources=' + rendered + '}' if enabled else 'Disabled'
    world = '|'.join(k + '=' + str(v) for k, v in resource.state(entities, value).items())
    return label + '|owners=' + bindings + '|world{' + world + '}'


def scenario(entities, omit_rendered=False):
    snap = lambda value, enabled=True: snapshot(entities, value, enabled, omit_rendered)
    # Description/snapshot do not run a body. Each actual invocation consumes
    # affine Args and transports affine Output or existing typed failure.
    return '\n'.join([snap(10), snap(10), snap(10, False),
                      'Success{prior=10}', snap(11),
                      'Failure{prior=11}', snap(11),
                      'Success{prior=11}', snap(12), snap(12)])


def model(omit_rendered=False):
    return dict(empty=scenario(0, omit_rendered), nonempty=scenario(2, omit_rendered))


def stdout(value):
    return 'Report{' + json.dumps(value['empty']) + ', ' + json.dumps(value['nonempty']) + '}\n'


if __name__ == '__main__':
    for name, omit in [('normal', False), ('presentation-mutant', True)]:
        value = model(omit)
        (HERE / (name + '-expected.json')).write_text(json.dumps(value, indent=2) + '\n')
        (HERE / (name + '-expected.stdout')).write_text(stdout(value))
