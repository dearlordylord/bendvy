"""State-transition oracle for deferred visibility; imports no Bend code or output."""


def expected():
    rows = []
    for label, kind in [('native-auto', 'auto'), ('native-ignored', 'late'),
                        ('native-explicit', 'auto'), ('native-disabled', 'late'),
                        ('native-finaloff', 'retained'), ('serial-auto', 'auto')]:
        if kind == 'auto':
            first = second = '[error:1:after-enqueue, ran:3, ran:2]'
            value, stamp, now, author, peer, guard, reader = 71, 8, 10, 6, 7, 9, 10
            reads, last, guard_last, history = 2, '71', 71, '[]'
        elif kind == 'late':
            first, second = '[error:1:after-enqueue, ran:3, skip:2]', '[error:1:after-enqueue, ran:3, ran:2]'
            value, stamp, now, author, peer, guard, reader = 71, 9, 9, 5, 6, 7, 8
            reads, last, guard_last, history = 1, '71', 71, '[]'
        else:
            first = second = '[error:1:after-enqueue, ran:3, skip:2]'
            value, stamp, now, author, peer, guard, reader = 1, 0, 6, 4, 5, 6, None
            reads, last, guard_last, history = 0, 'never', 1, '[3, 1]'
        pending = kind == 'retained'
        queue = '[1:1:0:71, 1:1:0:none, 1:1:0:71, 1:1:0:none]' if pending else '[]'
        receipts = '[]' if pending else '[applied:1:1:0:none, applied:1:1:0:71, applied:1:1:0:none, applied:1:1:0:1]'
        column = ''.join(
            f'{i}={value}/cache={value}@0:{stamp}/0:{stamp};' if i == 1
            else f'{i}=absent@never/never;' for i in range(8)
        )
        rows.append(
            f'{label}={first};{second};exact-pending={str(pending).lower()}'
            + '|world=namespace=1;allocator={next=2,high=1,capacity=2,depth=1,'
            + 'slots=[0:consumed, 0:live],free=[],order=[1:0]}'
            + f';column=capacity=8[{column}];events=0;legacy-pending=0;'
            + 'registrations=[4:guard:[token], 3:peer:[], 2:reader:[token], 1:author:[]];next=5;'
            + f'clock=0:{now}:[]|queue={queue}|receipts={receipts}'
            + f'|handle=1:1:0|cursor=0:{author}|reader=501:{reads}:1:1:0:{last}:'
            + (f'0:{reader}' if reader is not None else 'never')
            + f'|guard=601:2:1:1:0:{guard_last}:0:{guard}|peer=801:0:{peer}'
            + f'|handler=901:2|unapplied={history}'
        )
    return '\n'.join(rows) + '\n'


if __name__ == '__main__':
    print(expected(), end='')
