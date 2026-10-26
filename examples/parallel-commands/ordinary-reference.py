"""Full preliminary ordinary consumer oracle, derived without implementation imports."""


def expected():
    rows = []
    for label, final, enabled in [("native-final", True, True), ("native-retained", False, True), ("native-empty", False, False), ("serial-final", True, True)]:
        value, changed, now = (71, 6, 6) if final else (1, 0, 4)
        column = ''.join(
            f'{i}={value}/cache={value}@0:0/0:{changed};' if i == 1
            else f'{i}=absent@never/never;'
            for i in range(8)
        )
        queue = '[]' if final or not enabled else '[1:1:0:71, 1:1:0:71]'
        receipts = '[applied:1:1:0:71, applied:1:1:0:1]' if final else '[]'
        author, peer = (4, 5) if final else (3, 4)
        rows.append(
            label + '='
            + ('[error:1:after-enqueue, ran:2];[error:1:after-enqueue, ran:2]' if enabled else '[ran:1, ran:2];[ran:1, ran:2]')
            + ';exact-pending=' + ('true' if enabled and not final else 'false')
            + '|world=namespace=1;allocator={next=2,high=1,capacity=2,depth=1,'
            + 'slots=[0:consumed, 0:live],free=[],order=[1:0]}'
            + f';column=capacity=8[{column}];events=0;legacy-pending=0;'
            + 'registrations=[2:peer:[], 1:author:[]];next=3;'
            + f'clock=0:{now}:[]|queue={queue}|receipts={receipts}'
            + f'|handle=1:1:0|cursor=0:{author}|peer=801:0:{peer}'
            + ('|handler=901:2|unapplied=' if enabled else '|handler=901:0|unapplied=') + ('[]' if final else '[2, 1]')
        )
    return '\n'.join(rows) + '\n'


if __name__ == '__main__':
    print(expected(), end='')
