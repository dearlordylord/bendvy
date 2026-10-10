"""Source-only complete runtime record transport witness; no backend input."""
import json

def world(populated, resource, registered):
    # reserve/activate preserve clock; first component replacement stamps clock1.
    live = 'node(node(leaf:False,leaf:True),node(leaf:True,leaf:False))' if populated else 'leaf:False'
    store = 'Column{values=leaf:some(Payload{leaf:42});stamps=[1:1:1]}' if populated else 'Column{values=leaf:none;stamps=[]}'
    registrations = '[1:CounterUpdate:[Counter]]' if registered else '[]'
    return (f'namespace=1|nextId={3 if populated else 1}|highWater={2 if populated else 0}|live={live}'
            f'|capacity={4 if populated else 1}|depth={2 if populated else 0}|store={store}'
            f'|resource=leaf:{resource}|events=[]|pendingCount=0|pendingEmpty=True'
            f'|registrations={registrations}|nextSystemId=2|clock={1 if populated else 0}')

def fields(cursor):
    # resource_registry retains no Clause list; ResourceKind retains Write.
    return (f'Registry{{1:1|name=CounterUpdate|access=[Counter]|cursor={cursor}'
            '|slot=Update|clauses=[]|kind=Resource:Write}')

def scenario(populated):
    resource, cursor, registered = 10, 0, True
    clock = 1 if populated else 0
    lines = []
    def observe():
        lines.append(fields(cursor)+'|world{'+world(populated,resource,registered)+'}')
    observe()
    # Successful body consumes affine Args, replaces resource, returns prior Array.
    lines.append('Success:'+str(resource)); resource += 1; cursor = clock
    observe()
    # Failure performs same replacement, then transaction inverse restores old Array.
    # Failed tracked outcome does not replace cursor. Failed output is not observed.
    lines.append('Failure:'+str(resource))
    observe()
    lines.append('Success:'+str(resource)); resource += 1; cursor = clock
    observe()
    lines.append('Skipped')
    observe()
    # Trusted administrative fixture clears only World registration metadata.
    registered = False
    lines.append('TrustedInvalidation')
    observe()
    # Metadata refusal returns original Args flags Array; true value read explicitly.
    lines.append('RejectedArgs:True')
    observe()
    return ''.join(line+'\n' for line in lines)

def render():
    # Local entry import gives consumer.Report; String.show uses escaped newlines.
    return ('consumer.Report{'+json.dumps(scenario(False))+', '+json.dumps(scenario(True))+'}\n').encode()

if __name__ == '__main__':
    import sys
    sys.stdout.buffer.write(render())
