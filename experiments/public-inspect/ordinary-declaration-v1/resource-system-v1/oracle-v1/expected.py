"""Independent resource-only runner fixture model; no runtime inputs."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def state(entities, resource):
    assert entities in (0, 2)
    return dict(namespace=1, nextId=entities + 1, highWater=entities,
                live='leaf:False' if not entities else
                'node(node(leaf:False,leaf:True),node(leaf:True,leaf:False))',
                capacity=1 if not entities else 4, depth=0 if not entities else 2,
                store='Column{values=leaf:none;stamps=[]}',
                resource='Counter{leaf:' + str(resource) + '}', events='[]',
                pendingCount=0, pendingEmpty='True',
                registrations='[1:CounterUpdate:[Counter]]', nextSystemId=2,
                clock=0)


def scenario(entities, omit_rollback=False):
    # Both cases invoke the resource-only body once per actual Registry run.
    # Replacement preserves clock. Failure restores the existing owner11.
    steps = ([('Success', 10, 11), ('Failure', 11, 12), ('Success', 12, 13)]
             if omit_rollback else
             [('Success', 10, 11), ('Failure', 11, 11), ('Success', 11, 12)])
    owner = ('owner{1:1:CounterUpdate:access=[Counter]:cursor=0:'
             'slot=Update:clauses=[Counter:Write]}')
    return '\n'.join(kind + '{prior=' + str(prior) + '}|' + owner + '|world{' +
                     '|'.join(k + '=' + str(v) for k, v in state(entities, final).items()) + '}'
                     for kind, prior, final in steps)


def model(omit_rollback=False):
    return dict(empty=scenario(0, omit_rollback), nonempty=scenario(2, omit_rollback))


def render(value):
    return 'Report{' + json.dumps(value['empty']) + ', ' + json.dumps(value['nonempty']) + '}\n'


if __name__ == '__main__':
    for name, omit in [('normal', False), ('rollback-mutant', True)]:
        value = model(omit)
        (HERE / (name + '-expected.json')).write_text(json.dumps(value, indent=2) + '\n')
        (HERE / (name + '-expected.stdout')).write_text(render(value))
