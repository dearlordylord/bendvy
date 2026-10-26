from pathlib import Path
from reference import allocator, column


def observation():
    position, health, counter, score = 10, 10, 0, 0
    reports = []
    errors = 0
    for run in range(1, 4):
        position += 1
        health += 2
        counter += 10
        score += 3
        if run == 2:
            errors += 1
            left = f'1/error/after-write/{run}'
        else:
            left = f'1/success/{run}'
        reports.append(f'[{left}, 2/success/{run}]')
    world = (
        column({1: (101, position), 17: (118, 70)}, {1: 5})
        + ';' + column({1: (201, health), 9: (210, 80)}, {1: 6})
        + f';301:{counter}/cache=301:{counter};401:{score}/cache=401:{score};live=[1:1:0]'
        + ';systems=[2:right:[health, score], 1:left:[position, counter]];tick=0:6:[]'
        + ';allocator=' + allocator(1)
        + ';namespace=1;next-system=3;events=0;pending=0'
    )
    return (
        '|'.join(reports)
        + '|world=' + world
        + '|locals=501:3,601:3|cursors=0:5,0:6'
        + f'|handler=701:{errors}'
    )


if __name__ == '__main__':
    expected = '\n'.join(
        label + '=' + observation()
        for label in ('A-serial', 'A-native', 'B-serial', 'B-native')
    ) + '\n'
    Path(__file__).with_name('scheduled.expected.stdout').write_text(expected)
