"""Independent owner/state oracle for foreign refusal and original-World retry."""


def column(value, stamp):
    return 'capacity=8[' + ''.join(
        f'{i}={value}/cache={value}@0:{stamp}/0:{stamp};' if i == 1
        else f'{i}=absent@never/never;' for i in range(8)
    ) + ']'


def expected():
    foreign = (
        'namespace=1;allocator={next=1,high=0,capacity=1,depth=0,'
        'slots=[0:consumed],free=[],order=[]};column=' + column(1, 0)
        + ';events=0;legacy-pending=0;registrations=[];next=1;clock=0:0:[]'
    )
    original = (
        'namespace=2;allocator={next=2,high=1,capacity=2,depth=1,'
        'slots=[0:consumed, 0:live],free=[],order=[1:0]};column=' + column(71, 7)
        + ';events=0;legacy-pending=0;registrations='
        '[4:guard:[token], 3:peer:[], 2:reader:[token], 1:author:[]];next=5;clock=0:7:[]'
    )
    return (
        'initial=[error:1:after-enqueue, ran:3, skip:2]'
        ';foreign-run=[refused:1, refused:3, condition-refused:2];foreign-pending=true'
        + '|foreign=' + foreign
        + ';retry=[ran:1, ran:3, skip:2];exact-pending=false|world=' + original
        + '|queue=[]|receipts=[applied:2:1:0:none, applied:2:1:0:1]'
        '|handle=2:1:0|cursor=0:4|reader=501:0:2:1:0:never:never'
        '|guard=601:2:2:1:0:1:0:6|peer=801:0:5|handler=901:1|unapplied=[]\n'
    )


if __name__ == '__main__':
    print(expected(), end='')
