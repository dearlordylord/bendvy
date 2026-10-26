"""Independent no-execution oracle for invalid deferred configurations."""


def expected():
    column = ''.join(
        f'{i}=1/cache=1@0:0/0:0;' if i == 1
        else f'{i}=absent@never/never;' for i in range(8)
    )
    state = (
        'invalid;invalid;exact-pending=false'
        '|world=namespace=1;allocator={next=2,high=1,capacity=2,depth=1,'
        'slots=[0:consumed, 0:live],free=[],order=[1:0]}'
        f';column=capacity=8[{column}];events=0;legacy-pending=0;'
        'registrations=[4:guard:[token], 3:peer:[], 2:reader:[token], 1:author:[]];next=5;'
        'clock=0:0:[]|queue=[]|receipts=[]|handle=1:1:0|cursor=never'
        '|reader=501:0:1:1:0:never:never|guard=601:0:1:1:0:never:never'
        '|peer=801:never|handler=901:0|unapplied=[]'
    )
    return ''.join(f'{label}={state}\n' for label in (
        'unknown-explicit', 'duplicate-explicit', 'conditioned-explicit', 'unknown-ignored'
    ))


if __name__ == '__main__':
    print(expected(), end='')
