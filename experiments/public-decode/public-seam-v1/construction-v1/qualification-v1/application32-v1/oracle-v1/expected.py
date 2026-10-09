"""Independent application32 source model; never reads execution/checker output."""
import copy
import json
from pathlib import Path

def c(tag, **fields):
    return {'$': tag, **fields}

def raw(value):
    if value is None:
        return c('Null')
    if type(value) is int:
        return c('Number', value=value)
    if type(value) is str:
        return c('Text', value=value)
    if type(value) is list:
        return c('Array', items=[raw(v) for v in value])
    return c('Object', fields=[c('Field', name=k, value=raw(v)) for k, v in value.items()])

def some(value):
    return c('Some', value=value)

ACCESS = ['Value', 'Resource', 'Marker']
CASES = ('array3','array128','array256','lateInvalid','struct64','nullableNull','nestedValid','nestedMissing')

def inputs():
    fields = {f'f{i}': i for i in range(64)}
    return {
        'array3': ([1]*3, [], [1]*3),
        'array128': ([1]*128, [], [1]*128),
        'array256': ([1]*256, [], [1]*256),
        'lateInvalid': ([1]*127+['late-invalid'], [], None),
        'struct64': ({**fields, 'extra':'drop-me'}, fields, fields),
        'nullableNull': ({'items':None}, {'items':None}, {'items':None}),
        'nestedValid': ({'items':[{'value':1},{'value':2}]}, {'items':None}, {'items':[{'value':1},{'value':2}]}),
        'nestedMissing': ({'items':[{'value':1},{}]}, {'items':None}, None),
    }

def input_view(value):
    return c('InputView', raw=raw(value), words=[111,222], flags=[True,False])

def owner(value, words, original=None, incoming=False):
    return c('View', raw=raw(value), original=raw(value if original is None else original), words=words, flags=[True,False] if incoming else [False,True])

def entry(entity, added, changed):
    return c('Entry', id=entity, stamp=c('Stamp', added=added, changed=changed))

def snapshot(seed, value, canonical, operation, valid, barrier=False, committed=False):
    inserted = valid and operation == 'insert' and (committed or barrier)
    spawned = valid and operation == 'spawn' and (committed or barrier)
    resource_written = valid and operation == 'resource' and (committed or barrier)
    clock = 2 if inserted else 1
    slots = [some(owner(canonical,[111,222],value,True) if inserted else owner(9,[333,444]))]
    stamps = [entry(1,1,2 if inserted else 1)]
    marker = c('MarkerView', slots=[c('None')], stamps=[])
    if barrier:
        clock += 1
        marker = c('MarkerView', slots=[some(1)], stamps=[entry(1,clock,clock)])
        if spawned:
            clock += 1
            slots.append(some(owner(canonical,[111,222],value,True)))
            stamps.insert(0,entry(2,clock,clock))
    registration = c('RegistrationMeta', id=1, name='application32', access=ACCESS)
    meta = c('Meta', namespace=1, nextId=3 if spawned else 2, highWater=2 if spawned else 1,
             capacity=4 if spawned else 2, depth=2 if spawned else 1, events=[],
             registrations=[registration], nextSystemId=2, clock=clock)
    return c('Snapshot', meta=meta, live=[False,True,barrier,False] if spawned else [False,True],
             store=c('StoreView', values=c('ColumnView', supported=True, slots=slots, stamps=stamps),
                     marker=marker, returned=[], errors=[]),
             resource=owner(canonical,[111,222],value,True) if resource_written else owner(seed,[555,666]),
             pending=0 if barrier else 3 if spawned else 1)

def report(name, operation):
    value, seed, canonical = inputs()[name]
    valid = name not in ('lateInvalid','nestedMissing')
    if valid:
        output = c('ResourceOutputView', value=c('ResourceReplaced',canonical=raw(canonical),undoAvailable=True)) if operation=='resource' else c('ComponentView',value=c('Accepted', target=c('Handle',namespace=1,id=2 if operation=='spawn' else 1), spawned=operation=='spawn',canonical=raw(canonical),undoAvailable=True))
    else:
        error = c('Invalid', path='$[127]' if name=='lateInvalid' else '$.items[1].value', expected='integer', actual=raw('late-invalid') if name=='lateInvalid' else c('Missing'))
        output = c('ResourceOutputView',value=c('ResourceRefused',owner=input_view(value),error=error)) if operation=='resource' else c('ComponentView',value=c('Refused',owner=some(input_view(value)),error=c('Validation',error=error)))
    return c('Report',original=input_view(value),before=snapshot(seed,value,canonical,operation,valid),
             committed=snapshot(seed,value,canonical,operation,valid,committed=True),
             barrier=snapshot(seed,value,canonical,operation,valid,barrier=True),
             instance=c('InstanceView',namespace=1,id=1,name='application32',access=ACCESS,recoveries=[],pending=[]),
             result=c('Completed',output=output))

def expected():
    return [c(schema,operation=operation,name=name,value=report(name,operation))
            for schema,operation in (('Workshop','insert'),('Workshop','spawn'),('Workshop','resource'),('Garden','insert'))
            for name in CASES]

if __name__ == '__main__':
    Path(__file__).with_name('expected.json').write_text(json.dumps(expected(),indent=2)+'\n')
