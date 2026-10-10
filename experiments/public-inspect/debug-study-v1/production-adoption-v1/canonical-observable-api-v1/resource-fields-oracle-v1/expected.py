"""Independent #70 complete current source scenario; never runtime-derived."""
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent

def tree(values):
    if len(values) == 1:
        return 'leaf:' + str(values[0])
    mid = len(values) // 2
    return 'node(' + tree(values[:mid]) + ',' + tree(values[mid:]) + ')'

def scenario(schema, read=False, mutant=None):
    first, second = (10, 100) if schema == 'a' else (30, 300)
    keys = ['First', 'Second'] if schema == 'a' else ['Primary', 'Secondary']
    mode = 'Read' if read else 'Write'
    access = '[' + ', '.join(keys) + ']'
    clauses = '[' + ', '.join(k + ':' + mode for k in keys) + ']'
    owner = 'owner{1:1:SelectedResources:access=' + access + ':cursor=0:clauses=' + clauses + '}'

    def snapshot(label, f, s):
        resource = keys[0] + '=' + tree(f) + ';' + keys[1] + '=' + tree(s)
        if schema == 'b':
            resource += ';Untouched{values=node(leaf:700,leaf:701);flags=node(leaf:True,leaf:False)}'
        world = dict(namespace=1, nextId=1, highWater=0, live='leaf:False', capacity=1, depth=0,
                     store='Column{values=leaf:none;stamps=[]}', resource=resource, events='[]',
                     pendingCount=0, pendingEmpty='True',
                     registrations='[1:SelectedResources:' + access + ']', nextSystemId=2, clock=0)
        return label + '|' + owner + '|world{' + '|'.join(k + '=' + str(v) for k,v in world.items()) + '}'

    f, s = list(range(first,first+4)), list(range(second,second+4))
    rows = [snapshot('Before',f,s)]
    for fail in [False,True,False]:
        prior = s[0] if mutant == 'wrong-field' else f[0]
        sibling = prior + 2 if mutant == 'wrong-field' else s[0]
        if read:
            label = 'Success{' + tree([prior,sibling,prior,sibling]) + '}'
        elif fail:
            if mutant == 'incomplete-inverse':
                f, s = list(range(prior+2,prior+6)), list(range(sibling+10,sibling+14))
            label = 'Failure{' + ':'.join(map(str,[prior,sibling,prior+1])) + '}'
        else:
            label = 'Success{' + tree([prior,sibling,prior+1,prior+2]) + '}'
            if mutant == 'wrong-field':
                s = list(range(sibling+10,sibling+14))
            else:
                f, s = list(range(prior+2,prior+6)), list(range(sibling+10,sibling+14))
        rows.append(snapshot(label,f,s))
    return '\n'.join(rows)

if __name__ == '__main__':
    for schema in ['a','b']:
        for read in [False,True]:
            name = schema + ('-read' if read else '-write')
            text = scenario(schema,read)
            (HERE/(name+'-expected.json')).write_text(json.dumps(dict(observation=text),indent=2)+'\n')
            (HERE/(name+'-expected.stdout')).write_text(json.dumps(text)+'\n')

    for name in ['wrong-field', 'incomplete-inverse']:
        text = scenario('a', mutant=name)
        (HERE/(name+'-expected.json')).write_text(json.dumps(dict(observation=text),indent=2)+'\n')
        (HERE/(name+'-expected.stdout')).write_text(json.dumps(text)+'\n')
