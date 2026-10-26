"""Independent full-state oracle for explicit entity commands and cache refusal."""


def column(raw, cache, present):
    return 'capacity=8[' + ''.join(
        f'{i}={raw}/cache={cache}@0:0/0:0;' if i == 1 and present
        else f'{i}=absent@never/never;' for i in range(8)
    ) + ']'


def expected():
    rows = []
    for label, final, coherent in [
        ('native-final', True, True), ('native-retained', False, True),
        ('native-cache-mismatch', True, False), ('serial-final', True, True)
    ]:
        removed = final and coherent
        events = '[error:1:after-enqueue, ran:2]' if coherent else '[refused:1, ran:2]'
        allocator = (
            'next=2,high=1,capacity=2,depth=1,slots=[0:consumed, 1:free],free=[1],order=[]'
            if removed else
            'next=2,high=1,capacity=2,depth=1,slots=[0:consumed, 0:live],free=[],order=[1:0]'
        )
        now, author, peer = (6, '0:4', 5) if removed else ((4, '0:3', 4) if coherent else (2, 'never', 2))
        queue = '[despawn:1:1:0, despawn:1:1:0]' if coherent and not final else '[]'
        receipts = '[despawn-refused:1:1:0, despawned:1:1:0:71:81]' if removed else '[]'
        rows.append(
            f'{label}={events};{events};exact-pending={str(coherent and not final).lower()}'
            + '|world=namespace=1;allocator={' + allocator + '};left='
            + column(71, 71, not removed) + ';right=' + column(81, 81, not removed)
            + ';events=0;legacy-pending=0;registrations=[2:peer:[], 1:author:[]];next=3;'
            + f'clock=0:{now}:[]|permission=' + ('entity' if coherent else 'family')
            + f'|queue={queue}|receipts={receipts}|handle=1:1:0|cursor={author}|peer=801:0:{peer}'
            + f'|handler=901:{2 if coherent else 0}|unapplied=' + ('[2, 1]' if coherent and not final else '[]')
        )
    return '\n'.join(rows) + '\n'


if __name__ == '__main__':
    print(expected(), end='')
