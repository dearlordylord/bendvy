from pathlib import Path
from reference import allocator, column


def observation():
    position, health, counter, score = 10, 10, 0, 0
    reports = []
    errors = 0
    for run in range(1, 4):
        position += 2
        counter += 20
        if run == 2:
            errors += 2
            left = f'1/error/after-write/{run}'
            other = f'3/error/after-write/{run}'
            right = '2/disabled'
        else:
            left = f'1/success/{run}'
            other = f'3/success/{run}'
            if run == 1:
                health += 2
                score += 3
                right = f'2/success/{run}'
            else:
                errors += 1
                right = '2/condition-error/condition-after-read'
        reports.append(f'[{left}, {right}, {other}]')
    world = (
        column({1: (101, position), 17: (118, 70)}, {1: 9})
        + ';' + column({1: (201, health), 9: (210, 80)}, {1: 4})
        + f';301:{counter}/cache=301:{counter};401:{score}/cache=401:{score};live=[1:1:0]'
        + ';systems=[4:guard:[position], 3:other:[position, counter], 2:right:[health, score], 1:left:[position, counter]];tick=0:10:[]'
        + ';allocator=' + allocator(1)
        + ';namespace=1;next-system=5;events=0;pending=0'
    )
    return (
        '|'.join(reports)
        + '|world=' + world
        + '|locals=501:3,601:1,801:3|cursors=0:8,0:4,0:9'
        + f'|handler=701:{errors}|guard=901:3:101:{position}|guard-cursor=0:10'
    )


if __name__ == '__main__':
    expected = '\n'.join(
        label + '=' + observation()
        for label in ('A-serial', 'A-native', 'B-serial', 'B-native')
    ) + '\n'
    Path(__file__).with_name('overlap-conditions.expected.stdout').write_text(expected)
