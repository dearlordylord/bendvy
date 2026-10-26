from pathlib import Path


def column(values, changed):
    items = []
    for index in range(32):
        if index in values:
            token, value = values[index]
            stamp = f'0:0/0:{changed.get(index, 0)}'
            items.append(f'{index}={token}:{value}/cache={token}:{value}@{stamp};')
        else:
            items.append(f'{index}=absent@never/never;')
    return 'capacity=32[' + ''.join(items) + ']'


def array_text(values):
    return '[' + ', '.join(values) + ']'


def allocator(live):
    capacity = 1 << live.bit_length()
    phases = ['0:live' if 1 <= index <= live else '0:consumed'
              for index in range(capacity)]
    return (
        f'next={live + 1},high={live},capacity={capacity},depth={capacity.bit_length() - 1}'
        + ',slots=' + array_text(phases)
        + ',free=[],order=' + array_text([f'{index}:0' for index in range(1, live + 1)])
    )


def observation():
    position, health, counter, score = 10, 10, 0, 0
    statuses = []
    for run in range(1, 4):
        position += 1
        counter += 10
        health += 2
        score += 3
        left = f'error/after-write/{run}' if run == 2 else f'success/{run}'
        statuses.append(f'{left},success/{run}')
    world = (
        column({1: (101, position), 17: (118, 70)}, {1: 5})
        + ';' + column({1: (201, health), 9: (210, 80)}, {1: 6})
        + f';301:{counter}/cache=301:{counter};401:{score}/cache=401:{score};live='
        + array_text([f'1:{index}:0' for index in range(1, 18)])
        + ';systems=[2:right:[health, score], 1:left:[position, counter]];tick=0:6:[]'
        + ';allocator=' + allocator(17)
        + ';namespace=1;next-system=3;events=0;pending=0'
    )
    foreign = (
        column({1: (101, 10), 17: (118, 70)}, {})
        + ';' + column({1: (201, 10), 9: (210, 80)}, {})
        + ';301:0/cache=301:0;401:0/cache=401:0;live=[];systems=[];tick=0:0:[]'
        + ';allocator=' + allocator(0)
        + ';namespace=2;next-system=1;events=0;pending=0'
    )
    return (
        '|'.join(statuses)
        + '|foreign=refused,refused|world='
        + world
        + '|locals=501:3,601:3|cursors=0:5,0:6|foreign-world='
        + foreign
    )


if __name__ == '__main__':
    expected = '\n'.join(
        label + '=' + observation()
        for label in ('A-serial', 'A-native', 'B-serial', 'B-native')
    ) + '\n'
    Path(__file__).with_name('expected.stdout').write_text(expected)
