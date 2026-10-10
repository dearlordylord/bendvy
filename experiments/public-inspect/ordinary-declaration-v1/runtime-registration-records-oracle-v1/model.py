"""Complete three-registration A0/2 witness, derived before backend execution."""
import json

def bindings():
    # App records append canonical registry runtime fields in registration order.
    return ('[1:1:PositionRead:Update:cursor=0:[Position, Position]:[Position:Read, Position:Added], '
            '1:2:CounterUpdate:Update:cursor=0:[Counter]:[Counter:Write], '
            '1:3:PositionAbsent:Update:cursor=0:[Position]:[Position:Without]]')
def world(populated):
    live='node(node(leaf:False,leaf:True),node(leaf:True,leaf:False))' if populated else 'leaf:False'
    store='Column{values=leaf:some(Payload{leaf:42});stamps=[1:1:1]}' if populated else 'Column{values=leaf:none;stamps=[]}'
    return (f'namespace=1|nextId={3 if populated else 1}|highWater={2 if populated else 0}|live={live}'
            f'|capacity={4 if populated else 1}|depth={2 if populated else 0}|store={store}'
            '|resource=leaf:10|events=[]|pendingCount=0|pendingEmpty=True'
            '|registrations=[3:PositionAbsent:[Position], 2:CounterUpdate:[Counter], 1:PositionRead:[Position, Position]]'
            f'|nextSystemId=4|clock={1 if populated else 0}')
def snapshot(populated,enabled):
    # Added at cursor0 selects populated id1; Without selects live id2 only.
    first='[1:1:Product(Found:42,Unit)]' if populated else '[]'
    third='[1:2:Unit]' if populated else '[]'
    debug='Debug{bindings='+bindings()+'|rows=['+first+', Counter=10, '+third+']}' if enabled else 'Disabled'
    return debug+'|world{'+world(populated)+'}'
def scenario(populated):
    return '\n'.join([snapshot(populated,True),snapshot(populated,True),snapshot(populated,False)])
def render():
    # Entry imports consumer; book_load namespaces its Report as consumer.Report.
    return ('consumer.Report{'+json.dumps(scenario(False))+', '+json.dumps(scenario(True))+'}\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(render())
