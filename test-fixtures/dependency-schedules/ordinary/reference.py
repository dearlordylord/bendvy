"""Scenario-derived serial observations; no Bend implementation imports."""


def expected():
    reports = [
        'finished=body/1/body/1,ran/2/1,skip/3,ran/4/1,',
        'finished=body/1/body/2,ran/2/2,condition/3/condition,ran/4/2,',
        'finished=body/1/body/3,ran/2/3,ran/3/3,ran/4/3,',
    ]
    registrations = ','.join(f'{identifier}/{name}/counter,' for identifier, name in
                             [(6, 'changing'), (5, 'positive'), (4, 'c'),
                              (3, 'b'), (2, 'a'), (1, 'writer')]) + ','
    world = ('world=1:301:3:cache=3/401:retained:cache=retained:events=0:pending=0:registered='
             + registrations
             + ':next=7:clock=16::allocator=1:0:1:0:0:0:0:consumed')
    systems = '/'.join(
        f'1:{identifier}:{name}:{token}:{runs}:access=counter,:cursor={tick}'
        for identifier, name, token, runs, tick in
        [(1, 'writer', 501, 3, 11), (2, 'a', 502, 3, 13),
         (3, 'b', 503, 1, 15), (4, 'c', 504, 3, 16)]) + ':routes=1,2,/1,/3,'
    guards = ('1:5:positive:601:3:access=counter,:cursor=12/'
              '1:6:changing:602:3:access=counter,:cursor=14:routes=5,')
    state = (world + ';systems=' + systems + ';guards=' + guards
             + ';handler=701:body,body,condition,body,;state-bindings=2>5,3>6,'
             + ';plan=order=1:resource/counter,;2:resource/counter,;'
             + '3:resource/counter,;4:resource/counter,;:edges=1>2,2>3,3>4,'
             + ';app-bindings=2>5,3>6,')
    observation = '|'.join([*reports, state])
    return ''.join(schema + '=' + observation + '\n' for schema in ['alpha', 'beta'])


def admission_expected():
    # Both owners are registered, but permission rejection precedes every run.
    world = ('world=1:301:0:cache=0/401:retained:cache=retained:events=0:pending=0:'
             'registered=2/writable-guard/counter,,1/reader/counter,,'
             ':next=3:clock=0::allocator=1:0:1:0:0:0:0:consumed')
    observation = ('invalid-condition/2|' + world
                   + '|reader=1:1:reader:901:0:access=counter,:cursor=none'
                   + '|guard=1:2:writable-guard:902:0:access=counter,:cursor=none'
                   + '|handler=701:|state-bindings=1>2,|plan=rejected=condition/2'
                   + '|app-bindings=1>2,')
    return ''.join(schema + '=' + observation + '\n' for schema in ['alpha', 'beta'])


if __name__ == '__main__':
    import sys
    print(admission_expected() if '--admission' in sys.argv else expected(), end='')
