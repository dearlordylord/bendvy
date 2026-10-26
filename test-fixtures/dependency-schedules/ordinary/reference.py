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
    world = ('world=1:301:3/401:retained:events=0:pending=0:registered='
             + registrations
             + ':next=7:clock=16::allocator=1:0:1:0:0:0:0:consumed')
    systems = '/'.join(
        f'1:{identifier}:{name}:{token}:{runs}:access=counter,:cursor={tick}'
        for identifier, name, token, runs, tick in
        [(1, 'writer', 501, 3, 11), (2, 'a', 502, 3, 13),
         (3, 'b', 503, 1, 15), (4, 'c', 504, 3, 16)])
    guards = ('1:5:positive:601:3:access=counter,:cursor=12/'
              '1:6:changing:602:3:access=counter,:cursor=14')
    state = (world + ';systems=' + systems + ';guards=' + guards
             + ';handler=701:body,body,condition,body,')
    observation = '|'.join([*reports, state])
    return ''.join(schema + '=' + observation + '\n' for schema in ['alpha', 'beta'])


if __name__ == '__main__':
    print(expected(), end='')
