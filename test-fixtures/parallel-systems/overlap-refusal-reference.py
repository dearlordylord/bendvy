from pathlib import Path
from reference import allocator, column


def world(namespace, original):
    return (
        column({1: (101, 10), 17: (118, 70)}, {})
        + ';' + column({1: (201, 10), 9: (210, 80)}, {})
        + ';301:0;401:0;live=' + ('[1:1:0]' if original else '[]')
        + ';systems=' + ('[3:other:[position, counter], 2:right:[health, score], 1:left:[position, counter]]' if original else '[]')
        + ';tick=0:0:[];allocator=' + allocator(1 if original else 0)
        + f';namespace={namespace};next-system={4 if original else 1};events=0;pending=0'
    )


def observation():
    return (
        'original=' + world(1, True)
        + '|foreign=[1/refused, 2/refused, 3/refused]|world=' + world(2, False)
        + '|locals=501:0,601:0,801:0|cursors=never,never,never|handler=701:0'
    )


if __name__ == '__main__':
    expected = '\n'.join(
        label + '=' + observation()
        for label in ('A-serial', 'A-native', 'B-serial', 'B-native')
    ) + '\n'
    Path(__file__).with_name('overlap-refusal.expected.stdout').write_text(expected)
