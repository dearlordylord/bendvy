"""Full preliminary ordinary consumer oracle, derived without implementation imports."""


def expected():
    rows = []
    for final in [True, False]:
        value, changed, now = (71, 6, 6) if final else (1, 0, 4)
        column = ''.join(
            f'{i}={value}/cache={value}@0:0/0:{changed};' if i == 1
            else f'{i}=absent@never/never;'
            for i in range(8)
        )
        queue = '[]' if final else '[1:1:0:71, 1:1:0:71]'
        receipts = '[applied:1:1:0:71, applied:1:1:0:1]' if final else '[]'
        author, peer = (4, 5) if final else (3, 4)
        rows.append(
            ('final=' if final else 'retained=')
            + '[error:1:after-enqueue, ran:2];[error:1:after-enqueue, ran:2]'
            + '|world=namespace=1;allocator={next=2,high=1,capacity=2,depth=1,'
            + 'slots=[0:consumed, 0:live],free=[],order=[1:0]}'
            + f';column=capacity=8[{column}];events=0;legacy-pending=0;'
            + 'registrations=[2:peer:[], 1:author:[]];next=3;'
            + f'clock=0:{now}:[]|queue={queue}|receipts={receipts}'
            + f'|handle=1:1:0|cursor=0:{author}|peer=801:0:{peer}'
            + '|handler=901:2|unapplied=' + ('[]' if final else '[2, 1]')
        )
    return '\n'.join(rows) + '\n'


if __name__ == '__main__':
    print(expected(), end='')
