"""Independent metadata/owner oracle for command retirement, restore and rebind."""


def column(raw, cache, present):
    return 'capacity=8[' + ''.join(
        f'{i}={raw}/cache={cache}@0:0/0:0;' if i == 1 and present
        else f'{i}=absent@never/never;' for i in range(8)
    ) + ']'


def expected():
    rows = []
    peer = '2:peer:[]'
    author = '1:author:[]'
    for label in ('restore', 'rebind', 'rebind-refused', 'cache-mismatch'):
        coherent = label != 'cache-mismatch'
        initial = '[error:1:after-enqueue, ran:2]' if coherent else '[refused:1, ran:2]'
        if coherent:
            registrations = f'[3:rebound:[], {peer}]' if label == 'rebind' else f'[{author}, {peer}]'
            next_id = 4 if label == 'rebind' else (4294967295 if label == 'rebind-refused' else 3)
            operation = 'rebind=refused;restore=ok' if label == 'rebind-refused' else label + '=ok'
            owner = '3:never:entity' if label == 'rebind' else '1:0:1:entity'
            stage = f';retired:registrations=[{peer}];next=3;clock=0:2:[];{operation};registrations={registrations};next={next_id};clock=0:2:[];owner={owner}'
            final = '[ran:3, ran:2]' if label == 'rebind' else '[ran:1, ran:2]'
            allocator = 'next=2,high=1,capacity=2,depth=1,slots=[0:consumed, 1:free],free=[1],order=[]'
            now, cursor, errors, pending, permission = 5, '0:3', 1, 'true', 'entity'
            receipts = '[despawned:1:1:0:71:81]'
        else:
            registrations = f'[{peer}, {author}]'
            stage = f';retire=refused;registrations={registrations};next=3;clock=0:1:[];owner=1:never:family'
            final = initial
            allocator = 'next=2,high=1,capacity=2,depth=1,slots=[0:consumed, 0:live],free=[],order=[1:0]'
            now, cursor, errors, pending, permission = 2, 'never', 0, 'false', 'family'
            receipts, next_id = '[]', 3
        rows.append(
            f'{label}=initial={initial}{stage};rebuilt-pending={pending};rebuilt-history=[];final={final};exact-pending=false'
            + '|world=namespace=1;allocator={' + allocator + '};left='
            + column(71, 71, not coherent) + ';right=' + column(81, 81, not coherent)
            + f';events=0;legacy-pending=0;registrations={registrations};next={next_id};clock=0:{now}:[]'
            + f'|permission={permission}|queue=[]|receipts={receipts}|handle=1:1:0|cursor={cursor}'
            + f'|peer=801:0:{4 if coherent else 2}|handler=901:{errors}|unapplied=[]'
        )
    return '\n'.join(rows) + '\n'


if __name__ == '__main__':
    print(expected(), end='')
