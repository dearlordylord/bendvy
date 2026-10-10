"""Independent finite heterogeneous-record App model; no runtime inputs."""
import json

NAMES=('PositionRead','CounterUpdate','PositionAbsent')
ACCESS=('[Position, Position]','[Counter]','[Position]')
CLAUSES=('[Position:Read, Position:Added]','[]','[Position:Without]')
STEPS='[Phase:Update, System:1:condition=1, System:2:condition=2, Barrier, System:3:condition=3]'
def bindings(cursors):
    return '['+', '.join(f'1:{i+1}:{name}:Update:cursor={cursors[i]}:{ACCESS[i]}:'+(CLAUSES[i] if i!=1 else '[Counter:Write]') for i,name in enumerate(NAMES))+']'
def owners(cursors):
    return '['+', '.join(f'Registry{{1:{i+1}|name={name}|access={ACCESS[i]}|cursor={cursors[i]}|slot=Update|clauses={CLAUSES[i]}|kind='+('Resource:Write' if i==1 else 'Component')+'}' for i,name in enumerate(NAMES))+']'
def world(populated,value,pending):
    live='node(node(leaf:False,leaf:True),node(leaf:True,leaf:False))' if populated else 'leaf:False'
    store='Column{values=leaf:some(Payload{leaf:42});stamps=[1:1:1]}' if populated else 'Column{values=leaf:none;stamps=[]}'
    return (f'namespace=1|nextId={3 if populated else 1}|highWater={2 if populated else 0}|live={live}'
            f'|capacity={4 if populated else 1}|depth={2 if populated else 0}|store={store}'
            f'|resource=leaf:{value}|events=[]|pendingCount={int(pending)}|pendingEmpty={str(not pending)}'
            '|registrations=[3:PositionAbsent:[Position], 2:CounterUpdate:[Counter], 1:PositionRead:[Position, Position]]'
            f'|nextSystemId=4|clock={int(populated)}')
def observed(label,populated,value,pending,cursors):
    return label+'|owners='+owners(cursors)+'|world{'+world(populated,value,pending)+'}'
def snapshot(populated,value,pending,cursors,enabled):
    first='[1:1:Product(Found:42,Unit)]' if populated else '[]'
    last='[1:2:Unit]' if populated else '[]'
    label='Debug{fixtureInitialCursor=0|bindings='+bindings(cursors)+f'|rows=[{first}, Counter={value}, {last}]'+'}' if enabled else 'Disabled'
    return observed(label,populated,value,pending,cursors)
def run(populated,value,cursors,first):
    # Component query results are List<Unit> (0/1), while the actual resource
    # result owns the complete displaced Array. Conditions do not touch World.
    unit='[Unit]' if populated else '[]'
    if first:
        observations='[Entered:Update, Ran:1, Ran:2, Applied, Skipped:3]'
        outputs='[Component:'+unit+'][Resource:leaf:10][]'
    else:
        observations='[Entered:Update, Skipped:1, Ran:2, Applied, Ran:3]'
        outputs='[Resource:leaf:111][Component:'+unit+'][]'
    label='Finished{namespace=1|name=Ordinary|steps='+STEPS+'|observations='+observations+'|refused=None|outputs='+outputs+'}'
    return observed(label,populated,value,False,cursors)
def scenario(populated):
    clock=int(populated)
    initial=(0,0,0);after_first=(clock,clock,0);after_second=(clock,clock,clock)
    lines=[snapshot(populated,10,True,initial,True),snapshot(populated,10,True,initial,True),snapshot(populated,10,True,initial,False),
           run(populated,111,after_first,True),snapshot(populated,111,False,after_first,True),snapshot(populated,111,False,after_first,False),
           run(populated,112,after_second,False),snapshot(populated,112,False,after_second,True),snapshot(populated,112,False,after_second,True)]
    return ''.join(line+'\n' for line in lines)
def render():
    # entry-a imports consumer; Report is defined in that module. Both fields
    # are String and use the pinned installed show_val JSON-string printer.
    return ('consumer.Report{'+json.dumps(scenario(False))+', '+json.dumps(scenario(True))+'}\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(render())
